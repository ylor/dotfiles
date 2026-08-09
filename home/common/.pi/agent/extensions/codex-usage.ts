import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";

const PROVIDER = "openai-codex";
const COMMAND = "usage";
const TIMEOUT_MS = 15_000;

type RateLimitWindow = {
	usedPercent?: number;
	resetsAt?: number;
};

type RateLimit = {
	limitId?: string;
	limitName?: string;
	primary?: RateLimitWindow;
	secondary?: RateLimitWindow;
};

type UsageResponse = {
	rateLimits?: RateLimit;
	rateLimitsByLimitId?: Record<string, RateLimit>;
};

type RpcMessage = {
	id?: number;
	result?: unknown;
	error?: string | { message?: string };
};

function rpcError(error: RpcMessage["error"]): Error {
	if (typeof error === "string") return new Error(error);
	return new Error(error?.message ?? JSON.stringify(error));
}

function fetchUsage(): Promise<UsageResponse> {
	return new Promise((resolve, reject) => {
		const child = spawn("codex", ["app-server", "--stdio"], {
			stdio: ["pipe", "pipe", "pipe"],
		});
		let stdout = "";
		let stderr = "";
		let done = false;

		const timer = setTimeout(() => finish(new Error("Codex App Server timed out")), TIMEOUT_MS);

		function send(message: unknown): void {
			child.stdin.write(`${JSON.stringify(message)}\n`);
		}

		function finish(error?: Error, usage: UsageResponse = {}): void {
			if (done) return;
			done = true;
			clearTimeout(timer);
			child.kill();
			error ? reject(error) : resolve(usage);
		}

		child.stderr.setEncoding("utf8");
		child.stderr.on("data", (chunk: string) => {
			stderr += chunk;
		});
		child.once("error", finish);
		child.once("close", () => {
			if (!done) finish(new Error(stderr.trim() || "Codex App Server exited unexpectedly"));
		});

		child.stdout.setEncoding("utf8");
		child.stdout.on("data", (chunk: string) => {
			stdout += chunk;
			const lines = stdout.split("\n");
			stdout = lines.pop() ?? "";

			for (const line of lines) {
				let message: RpcMessage;
				try {
					message = JSON.parse(line) as RpcMessage;
				} catch {
					continue;
				}

				if (message.id === 2) {
					if (message.error !== undefined) return finish(rpcError(message.error));
					return finish(undefined, (message.result as UsageResponse) ?? {});
				}
				if (message.id === 1) {
					if (message.error !== undefined) return finish(rpcError(message.error));
					send({ method: "initialized" });
					send({ id: 2, method: "account/rateLimits/read" });
				}
			}
		});

		send({
			id: 1,
			method: "initialize",
			params: {
				clientInfo: { name: "pi-codex-usage", version: "1.0.0" },
				capabilities: { experimentalApi: true },
			},
		});
	});
}

function formatWindow(limit: RateLimitWindow): string {
	let text = `${limit.usedPercent ?? 0}% used`;
	if (limit.resetsAt) {
		text += ` · resets ${new Date(limit.resetsAt * 1000).toLocaleString(undefined, {
			dateStyle: "short",
			timeStyle: "short",
		})}`;
	}
	return text;
}

function formatUsage(usage: UsageResponse): string {
	const byId = usage.rateLimitsByLimitId;
	const single = usage.rateLimits;

	let limits: Array<[string, RateLimit]>;
	if (byId && Object.keys(byId).length > 0) {
		limits = Object.entries(byId);
	} else if (single) {
		limits = [[single.limitId ?? "codex", single]];
	} else {
		return "No Codex usage data returned.";
	}

	const lines: string[] = [];
	for (const [id, limit] of limits) {
		const label = limits.length > 1 ? `${limit.limitName ?? id}: ` : "";
		if (limit.primary) lines.push(label + formatWindow(limit.primary));
		if (limit.secondary) lines.push(label + formatWindow(limit.secondary));
	}

	return lines.join("\n") || "No Codex usage data returned.";
}

type UsageHandler = (pi: ExtensionAPI, ctx: ExtensionContext) => Promise<void>;

type UsageRegistry = {
	handlers: Map<string, UsageHandler>;
	commandRegistered: boolean;
	autocompleteRegistered: boolean;
};

const USAGE_REGISTRY_KEY = Symbol.for("pi.usage-registry");
const usageRegistry = (((globalThis as Record<PropertyKey, unknown>)[USAGE_REGISTRY_KEY] ??= {
	handlers: new Map<string, UsageHandler>(),
	commandRegistered: false,
	autocompleteRegistered: false,
}) as UsageRegistry);

export function registerUsageHandler(pi: ExtensionAPI, provider: string, handler: UsageHandler): void {
	usageRegistry.handlers.set(provider, handler);
	if (usageRegistry.commandRegistered) return;
	usageRegistry.commandRegistered = true;

	pi.on("session_start", (_event, ctx) => {
		if (usageRegistry.autocompleteRegistered) return;
		usageRegistry.autocompleteRegistered = true;
		ctx.ui.addAutocompleteProvider((current) => ({
			...current,
			async getSuggestions(lines, line, column, options) {
				const suggestions = await current.getSuggestions(lines, line, column, options);
				if (!suggestions) return suggestions;
				if (usageRegistry.handlers.has(ctx.model?.provider ?? "")) return suggestions;

				return {
					...suggestions,
					items: suggestions.items.filter(
						(item) => item.value.replace(/^\/+/, "") !== COMMAND && item.label.replace(/^\/+/, "") !== COMMAND,
					),
				};
			},
			applyCompletion(lines, line, column, item, prefix) {
				return current.applyCompletion(lines, line, column, item, prefix);
			},
			shouldTriggerFileCompletion(lines, line, column) {
				return current.shouldTriggerFileCompletion?.(lines, line, column) ?? true;
			},
		}));
	});

	pi.registerCommand(COMMAND, {
		description: "Show usage for the active provider as a message",
		async handler(_args, ctx) {
			const handler = usageRegistry.handlers.get(ctx.model?.provider ?? "");
			if (!handler) {
				ctx.ui.notify("/usage is only available with OpenAI Codex or OpenRouter models.", "error");
				return;
			}
			await handler(pi, ctx);
		},
	});
}

export default function (pi: ExtensionAPI): void {
	registerUsageHandler(pi, PROVIDER, async (extensionPi, ctx) => {
		ctx.ui.setStatus("codex-usage-loading", "Checking Codex usage…");
		try {
			const usage = await fetchUsage();
			extensionPi.sendMessage(
				{
					customType: "codex-usage",
					content: formatUsage(usage),
					display: true,
				},
				{ triggerTurn: false },
			);
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`Could not read Codex usage: ${message}`, "error");
		} finally {
			ctx.ui.setStatus("codex-usage-loading", undefined);
		}
	});
}
