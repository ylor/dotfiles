import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { registerUsageHandler } from "./codex-usage.ts";

const PROVIDER = "openrouter";
const CREDITS_URL = "https://openrouter.ai/api/v1/credits";

type CreditsResponse = {
	data?: {
		total_credits?: number;
		total_usage?: number;
	};
};

async function fetchUsage(apiKey: string): Promise<CreditsResponse> {
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

function formatCredits(value: number): string {
	return `$${value.toFixed(2)}`;
}

function formatUsage(usage: CreditsResponse): string {
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

export default function (pi: ExtensionAPI): void {
	registerUsageHandler(pi, PROVIDER, async (extensionPi: ExtensionAPI, ctx: ExtensionContext) => {
		ctx.ui.setStatus("openrouter-usage-loading", "Checking OpenRouter usage…");
		try {
			const apiKey = await ctx.modelRegistry.getApiKeyForProvider(PROVIDER);
			if (!apiKey) throw new Error("No OpenRouter API key configured.");

			const usage = await fetchUsage(apiKey);
			extensionPi.sendMessage(
				{
					customType: "openrouter-usage",
					content: formatUsage(usage),
					display: true,
				},
				{ triggerTurn: false },
			);
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`Could not read OpenRouter usage: ${message}`, "error");
		} finally {
			ctx.ui.setStatus("openrouter-usage-loading", undefined);
		}
	});
}
