import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";

const COMMAND = "usage";
const CODEX_PROVIDER = "openai-codex";
const OPENROUTER_PROVIDER = "openrouter";
const SUPPORTED_PROVIDERS = new Set([CODEX_PROVIDER, OPENROUTER_PROVIDER]);
const TIMEOUT_MS = 15_000;
const CREDITS_URL = "https://openrouter.ai/api/v1/credits";

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

type CodexUsageResponse = {
	rateLimits?: RateLimit;
	rateLimitsByLimitId?: Record<string, RateLimit>;
};

type RpcMessage = {
	id?: number;
	result?: unknown;
	error?: string | { message?: string };
};

type CreditsResponse = {
	data?: {
		total_credits?: number;
		total_usage?: number;
	};
};

function rpcError(error: RpcMessage["error"]): Error {
	if (typeof error === "string") return new Error(error);
	return new Error(error?.message ?? JSON.stringify(error));
}

function fetchCodexUsage(): Promise<CodexUsageResponse> {
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

		function finish(error?: Error, usage: CodexUsageResponse = {}): void {
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
					return finish(undefined, (message.result as CodexUsageResponse) ?? {});
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

async function fetchOpenRouterUsage(apiKey: string): Promise<CreditsResponse> {
	const response = await fetch(CREDITS_URL, {
		headers: { Authorization: `Bearer ${apiKey}` },
	});

	let body: CreditsResponse & { error?: string | { message?: string } } = {};
	try {
		body = (await response.json()) as CreditsResponse & { error?: string | { message?: string } };
	} catch {
		// Use the HTTP status below when the response is not JSON.
	}

	if (!response.ok) {
		const error = body.error;
		const message = typeof error === "string" ? error : error?.message;
		throw new Error(message ?? `OpenRouter returned HTTP ${response.status}`);
	}

	return body;
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

function formatCodexUsage(usage: CodexUsageResponse): string {
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

function formatCredits(value: number): string {
	return `$${value.toFixed(2)}`;
}

function formatOpenRouterUsage(usage: CreditsResponse): string {
	const total = usage.data?.total_credits;
	const used = usage.data?.total_usage;

	if (total == null || used == null) {
		return "No OpenRouter usage data returned.";
	}

	return [
		`${formatCredits(used)} used of ${formatCredits(total)}`,
		`${formatCredits(Math.max(0, total - used))} remaining`,
	].join("\n");
}

function isSupportedProvider(provider: string | undefined): provider is typeof CODEX_PROVIDER | typeof OPENROUTER_PROVIDER {
	return provider !== undefined && SUPPORTED_PROVIDERS.has(provider);
}

async function loadUsage(provider: string, ctx: ExtensionContext): Promise<{ customType: string; content: string }> {
	if (provider === CODEX_PROVIDER) {
		return { customType: "codex-usage", content: formatCodexUsage(await fetchCodexUsage()) };
	}

	const apiKey = await ctx.modelRegistry.getApiKeyForProvider(OPENROUTER_PROVIDER);
	if (!apiKey) throw new Error("No OpenRouter API key configured.");
	return { customType: "openrouter-usage", content: formatOpenRouterUsage(await fetchOpenRouterUsage(apiKey)) };
}

async function showUsage(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	const provider = ctx.model?.provider;
	if (!isSupportedProvider(provider)) {
		ctx.ui.notify("/usage is only available with OpenAI Codex or OpenRouter models.", "error");
		return;
	}

	const providerName = provider === CODEX_PROVIDER ? "Codex" : "OpenRouter";
	ctx.ui.setWorkingMessage(`Checking ${providerName} usage…`);
	ctx.ui.setWorkingVisible(true);

	try {
		const usage = await loadUsage(provider, ctx);
		pi.sendMessage({ ...usage, display: true }, { triggerTurn: false });
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		ctx.ui.notify(`Could not read ${providerName} usage: ${message}`, "error");
	} finally {
		ctx.ui.setWorkingMessage();
	}
}

export default function (pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) => ({
			...current,
			async getSuggestions(lines, line, column, options) {
				const suggestions = await current.getSuggestions(lines, line, column, options);
				if (!suggestions || isSupportedProvider(ctx.model?.provider)) return suggestions;

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
		handler: (_args, ctx) => showUsage(pi, ctx),
	});
}
