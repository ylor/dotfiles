import { Box } from "@earendil-works/pi-tui";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const COMMAND = "usage";
const ENTRY_TYPE = "usage";

// Layout copied from Claude Code's /usage panel.
type UsageSection = {
	title: string;
	percent?: number;
	resetsAt?: number;
	detail?: string;
};

// Times are epoch milliseconds, relative to fetchedAt so reopened sessions show the snapshot as it was.
type UsageEntry = {
	fetchedAt: number;
	sections: UsageSection[];
};

type Provider = {
	name: string;
	load: (token: string) => Promise<UsageSection[]>;
};

type AnthropicWindow = { utilization?: number | null; resets_at?: string | null } | null;

async function fetchJson<T>(url: string, headers: Record<string, string>): Promise<T> {
	const response = await fetch(url, { headers });

	let body: any = {};
	try {
		body = await response.json();
	} catch {
		// Use the HTTP status below when the response is not JSON.
	}

	if (!response.ok) {
		const message = body.error?.message ?? body.error;
		throw new Error(typeof message === "string" ? message : `HTTP ${response.status}`);
	}
	return body as T;
}

async function loadAnthropic(token: string): Promise<UsageSection[]> {
	const usage = await fetchJson<Record<string, AnthropicWindow>>(
		"https://api.anthropic.com/api/oauth/usage",
		{ Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
	);

	const windows: Array<[string, AnthropicWindow | undefined]> = [
		["Session", usage.five_hour],
		["Weekly", usage.seven_day],
		["Weekly (Opus)", usage.seven_day_opus],
		["Weekly (Sonnet)", usage.seven_day_sonnet],
	];

	const sections: UsageSection[] = [];
	for (const [title, window] of windows) {
		if (window?.utilization == null) continue;
		const resetsAt = window.resets_at ? Date.parse(window.resets_at) : undefined;
		sections.push({ title, percent: window.utilization, resetsAt });
	}
	if (!sections.length) throw new Error("No usage data returned.");
	return sections;
}

async function loadOpenRouter(token: string): Promise<UsageSection[]> {
	const usage = await fetchJson<{ data?: { total_credits?: number; total_usage?: number } }>(
		"https://openrouter.ai/api/v1/credits",
		{ Authorization: `Bearer ${token}` },
	);

	const total = usage.data?.total_credits;
	const used = usage.data?.total_usage;
	if (total == null || used == null) throw new Error("No usage data returned.");

	const left = Math.max(0, total - used);
	return [{ title: "Credits", detail: `$${left.toFixed(2)} left` }];
}

const PROVIDERS: Record<string, Provider> = {
	anthropic: { name: "Anthropic", load: loadAnthropic },
	openrouter: { name: "OpenRouter", load: loadOpenRouter },
};

const MAX_BAR_WIDTH = 30;
const MIN_BAR_WIDTH = 10;
// Room for " 100%" after the bar.
const BAR_SUFFIX_WIDTH = 5;
const DAY_MS = 24 * 60 * 60 * 1000;

function bar(percent: number, width: number): string {
	const clamped = Math.min(100, Math.max(0, percent));
	const filled = Math.round((clamped / 100) * width);
	return "█".repeat(filled) + "░".repeat(width - filled);
}

function formatDuration(ms: number): string {
	const minutes = Math.max(0, Math.round(ms / 60_000));
	const days = Math.floor(minutes / 1440);
	const hours = Math.floor((minutes % 1440) / 60);
	if (days > 0) return `${days}d ${hours}h`;
	if (hours > 0) return `${hours}h ${minutes % 60}m`;
	return `${minutes}m`;
}

function formatHour(date: Date): string {
	const hour = date.getHours() % 12 || 12;
	const minutes = date.getMinutes();
	const suffix = date.getHours() < 12 ? "am" : "pm";
	return minutes ? `${hour}:${String(minutes).padStart(2, "0")}${suffix}` : `${hour}${suffix}`;
}

// Far resets also show the day and hour, since a long countdown is hard to place.
function formatReset(resetsAt: number, now: number): string {
	const countdown = `Resets in ${formatDuration(resetsAt - now)}`;
	if (resetsAt - now < DAY_MS) return countdown;

	const date = new Date(resetsAt);
	const tomorrow = new Date(now);
	tomorrow.setDate(tomorrow.getDate() + 1);
	const isTomorrow = date.toDateString() === tomorrow.toDateString();
	const day = isTomorrow ? "tomorrow" : date.toLocaleDateString("en-US", { weekday: "short" });
	return `${countdown} (${day} ${formatHour(date)})`;
}

function formatEntry(entry: UsageEntry, width: number, bold: (text: string) => string): string[] {
	const barWidth = Math.min(MAX_BAR_WIDTH, Math.max(MIN_BAR_WIDTH, width - BAR_SUFFIX_WIDTH));
	return entry.sections.flatMap((section, i) => {
		const lines = i === 0 ? [] : [""];
		lines.push(bold(section.title));
		if (section.percent != null) lines.push(`${bar(section.percent, barWidth)} ${Math.round(section.percent)}%`);
		if (section.resetsAt) lines.push(formatReset(section.resetsAt, entry.fetchedAt));
		if (section.detail) lines.push(section.detail);
		return lines;
	});
}

async function showUsage(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	const provider = PROVIDERS[ctx.model?.provider ?? ""];
	if (!provider) {
		ctx.ui.notify("/usage is only available with Anthropic or OpenRouter models.", "error");
		return;
	}

	ctx.ui.setWorkingMessage(`Checking ${provider.name} usage…`);
	ctx.ui.setWorkingVisible(true);

	try {
		const token = await ctx.modelRegistry.getApiKeyForProvider(ctx.model?.provider ?? "");
		if (!token) throw new Error("No credentials configured.");
		const sections = await provider.load(token);
		pi.appendEntry<UsageEntry>(ENTRY_TYPE, { fetchedAt: Date.now(), sections });
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		ctx.ui.notify(`Could not read ${provider.name} usage: ${message}`, "error");
	} finally {
		ctx.ui.setWorkingMessage();
	}
}

export default function (pi: ExtensionAPI): void {
	pi.registerEntryRenderer<UsageEntry>(ENTRY_TYPE, (entry, _options, theme) => {
		const data = entry.data;
		const box = new Box(1, 1, (text) => theme.bg("customMessageBg", text));
		if (!data) return box;

		box.addChild({
			render: (width: number) => formatEntry(data, width, (text) => theme.bold(text)),
			invalidate: () => {},
		});
		return box;
	});

	// Hide /usage from autocomplete when the active provider has no usage endpoint.
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) => ({
			...current,
			async getSuggestions(lines, line, column, options) {
				const suggestions = await current.getSuggestions(lines, line, column, options);
				const supported = Boolean(PROVIDERS[ctx.model?.provider ?? ""]);
				if (!suggestions || supported) return suggestions;

				const isUsage = (text: string) => text.replace(/^\/+/, "") === COMMAND;
				return {
					...suggestions,
					items: suggestions.items.filter((item) => !isUsage(item.value) && !isUsage(item.label)),
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
		description: "Show usage for the active provider",
		handler: (_args, ctx) => showUsage(pi, ctx),
	});
}
