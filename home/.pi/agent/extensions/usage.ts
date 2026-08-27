import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
const COMMAND = "usage";
const CODEX_PROVIDER = "openai-codex";
const OPENROUTER_PROVIDER = "openrouter";
const SUPPORTED_PROVIDERS = new Set([CODEX_PROVIDER, OPENROUTER_PROVIDER]);
const CODEX_USAGE_URL = "https://chatgpt.com/backend-api/codex/usage";
const OPENAI_AUTH_CLAIM = "https://api.openai.com/auth";
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
	rate_limit?: {
		primary_window?: { used_percent?: number; reset_at?: number };
		secondary_window?: { used_percent?: number; reset_at?: number };
	};
	code_review_rate_limit?: {
		primary_window?: { used_percent?: number; reset_at?: number };
		secondary_window?: { used_percent?: number; reset_at?: number };
	};
};

type CreditsResponse = {
	data?: {
		total_credits?: number;
		total_usage?: number;
	};
};

function getCodexAccountId(token: string): string | undefined {
	try {
		const payload = JSON.parse(Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8")) as {
			[OPENAI_AUTH_CLAIM]?: { chatgpt_account_id?: string };
		};
		return payload[OPENAI_AUTH_CLAIM]?.chatgpt_account_id;
	} catch {
		return undefined;
	}
}

async function fetchCodexUsage(ctx: ExtensionContext): Promise<CodexUsageResponse> {
	const resolved = await ctx.modelRegistry.getProviderAuth(CODEX_PROVIDER);
	const token = resolved?.auth.apiKey;
	if (!token) throw new Error("No OpenAI Codex credentials configured.");

	const accountId = getCodexAccountId(token);
	if (!accountId) throw new Error("The OpenAI Codex credentials do not contain an account ID.");

	const response = await fetch(CODEX_USAGE_URL, {
		headers: {
			Authorization: `Bearer ${token}`,
			"ChatGPT-Account-Id": accountId,
		},
	});

	let body: CodexUsageResponse & { detail?: string } = {};
	try {
		body = (await response.json()) as CodexUsageResponse & { detail?: string };
	} catch {
		// Use the HTTP status below when the response is not JSON.
	}

	if (!response.ok) throw new Error(body.detail ?? `OpenAI returned HTTP ${response.status}`);
	return body;
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
	const limits: Array<[string, RateLimit]> = [];
	if (usage.rate_limit) {
		limits.push(["Codex", {
			primary: usage.rate_limit.primary_window && {
				usedPercent: usage.rate_limit.primary_window.used_percent,
				resetsAt: usage.rate_limit.primary_window.reset_at,
			},
			secondary: usage.rate_limit.secondary_window && {
				usedPercent: usage.rate_limit.secondary_window.used_percent,
				resetsAt: usage.rate_limit.secondary_window.reset_at,
			},
		}]);
	}
	if (usage.code_review_rate_limit) {
		limits.push(["Code review", {
			primary: usage.code_review_rate_limit.primary_window && {
				usedPercent: usage.code_review_rate_limit.primary_window.used_percent,
				resetsAt: usage.code_review_rate_limit.primary_window.reset_at,
			},
			secondary: usage.code_review_rate_limit.secondary_window && {
				usedPercent: usage.code_review_rate_limit.secondary_window.used_percent,
				resetsAt: usage.code_review_rate_limit.secondary_window.reset_at,
			},
		}]);
	}

	const lines: string[] = [];
	for (const [name, limit] of limits) {
		const label = limits.length > 1 ? `${name}: ` : "";
		if ((limit.primary?.usedPercent ?? 0) > 50) lines.push(label + formatWindow(limit.primary));
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
		return { customType: "codex-usage", content: formatCodexUsage(await fetchCodexUsage(ctx)) };
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
