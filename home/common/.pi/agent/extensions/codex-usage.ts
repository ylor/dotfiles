import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";
import { createInterface } from "node:readline";

type RateLimitWindow = {
	usedPercent?: number | null;
	windowDurationMins?: number | null;
	resetsAt?: number | null;
};

type RateLimitSnapshot = {
	limitId?: string | null;
	limitName?: string | null;
	planType?: string | null;
	primary?: RateLimitWindow | null;
	secondary?: RateLimitWindow | null;
};

type UsageResponse = {
	rateLimits?: RateLimitSnapshot | null;
	rateLimitsByLimitId?: Record<string, RateLimitSnapshot> | null;
};

type AppServerMessage = {
	id?: number;
	result?: UsageResponse;
	error?: { message?: string } | string;
};

async function fetchCodexUsage(): Promise<UsageResponse> {
	const child = spawn("codex", ["app-server", "--stdio"], {
		stdio: ["pipe", "pipe", "pipe"],
	});

	let stderr = "";
	let processError: Error | undefined;
	child.stderr.setEncoding("utf8");
	child.stderr.on("data", (chunk: string) => {
		stderr += chunk;
	});
	child.once("error", (error) => {
		processError = error;
	});

	const lines = createInterface({ input: child.stdout });
	const iterator = lines[Symbol.asyncIterator]();

	const send = (message: unknown) => {
		if (!child.stdin.writable) {
			throw processError ?? new Error("Codex App Server stdin is closed");
		}
		child.stdin.write(`${JSON.stringify(message)}\n`);
	};

	const receive = async (id: number): Promise<AppServerMessage["result"]> => {
		while (true) {
			const { value, done } = await iterator.next();
			if (done) {
				throw processError ?? new Error(stderr.trim() || "Codex App Server exited unexpectedly");
			}

			let message: AppServerMessage;
			try {
				message = JSON.parse(value) as AppServerMessage;
			} catch {
				continue;
			}

			// Notifications do not have the request id we are waiting for.
			if (message.id !== id) continue;
			if (message.error !== undefined) {
				const error = message.error;
				throw new Error(typeof error === "string" ? error : error.message ?? JSON.stringify(error));
			}
			return message.result;
		}
	};

	const run = async (): Promise<UsageResponse> => {
		send({
			id: 1,
			method: "initialize",
			params: {
				clientInfo: {
					name: "pi-codex-usage",
					version: "1.0.0",
				},
				capabilities: {
					experimentalApi: true,
				},
			},
		});
		await receive(1);

		send({ method: "initialized" });
		send({ id: 2, method: "account/rateLimits/read" });
		return (await receive(2)) ?? {};
	};

	let timeoutHandle: ReturnType<typeof setTimeout> | undefined;
	const timeout = new Promise<never>((_, reject) => {
		timeoutHandle = setTimeout(() => reject(new Error("Codex App Server timed out")), 15_000);
	});

	try {
		return await Promise.race([run(), timeout]);
	} finally {
		if (timeoutHandle) clearTimeout(timeoutHandle);
		lines.close();
		child.kill();
	}
}

function formatWindow(window: RateLimitWindow): string {
	const used = window.usedPercent ?? 0;
	const reset = window.resetsAt
		? ` · resets ${new Date(window.resetsAt * 1000).toLocaleString(undefined, {
				dateStyle: "short",
				timeStyle: "short",
			})}`
		: "";

	return `${used}% used${reset}`;
}

function formatUsage(result: UsageResponse): string[] {
	const limits = result.rateLimitsByLimitId && Object.keys(result.rateLimitsByLimitId).length > 0
		? Object.entries(result.rateLimitsByLimitId)
		: result.rateLimits
			? [[result.rateLimits.limitId ?? "codex", result.rateLimits] as const]
			: [];

	if (limits.length === 0) return ["No Codex usage data returned."];

	const output: string[] = [];
	for (const [id, snapshot] of limits) {
		const label = limits.length > 1 ? `${snapshot.limitName ?? id}: ` : "";
		if (snapshot.primary) output.push(`${label}${formatWindow(snapshot.primary)}`);
		if (snapshot.secondary) output.push(`${label}${formatWindow(snapshot.secondary)}`);
	}
	return output;
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("codex-usage", {
		description: "Show ChatGPT Codex subscription usage as a message",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("codex-usage-loading", "Checking Codex usage…");
			try {
				const usage = await fetchCodexUsage();
				pi.sendMessage(
					{
						customType: "codex-usage",
						content: formatUsage(usage).join("\n"),
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
		},
	});
}
