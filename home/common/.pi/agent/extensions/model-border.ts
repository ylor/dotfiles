import {
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

type BorderEditor = {
	borderColor(text: string): string;
};

const MODEL_COLORS: Record<string, string> = {
	"openrouter/deepseek/deepseek-v4-flash-0731": "#4D6BFE",
	"openai-codex/gpt-5.6-sol": "#E8A33A",
	"openai-codex/gpt-5.6-luna": "#8291B8",
};

const TARGET_BRIGHTNESS = 145;

type RGB = [number, number, number];

function brightness([red, green, blue]: RGB): number {
	return Math.sqrt(0.299 * red ** 2 + 0.587 * green ** 2 + 0.114 * blue ** 2);
}

function normalizeBrightness(rgb: RGB): RGB {
	const current = brightness(rgb);
	if (current >= TARGET_BRIGHTNESS) {
		return rgb.map((channel) => Math.round((channel * TARGET_BRIGHTNESS) / current)) as RGB;
	}

	let low = 0;
	let high = 1;
	for (let i = 0; i < 10; i++) {
		const mix = (low + high) / 2;
		const lighter = rgb.map((channel) => channel + (255 - channel) * mix) as RGB;
		if (brightness(lighter) < TARGET_BRIGHTNESS) low = mix;
		else high = mix;
	}
	return rgb.map((channel) => Math.round(channel + (255 - channel) * high)) as RGB;
}

function colorText(text: string, hex: string): string {
	const rgb = [1, 3, 5].map((index) => Number.parseInt(hex.slice(index, index + 2), 16)) as RGB;
	return `\x1b[38;2;${normalizeBrightness(rgb).join(";")}m${text}\x1b[39m`;
}

function patchBorder(editor: BorderEditor, ctx: ExtensionContext): void {
	let fallback = editor.borderColor;

	const borderColor = (text: string) => {
		const model = ctx.model;
		const color = model && MODEL_COLORS[`${model.provider}/${model.id}`];
		return color ? colorText(text, color) : fallback(text);
	};

	// Pi keeps assigning borderColor. Save those assignments as the fallback.
	Object.defineProperty(editor, "borderColor", {
		configurable: true,
		get: () => borderColor,
		set: (value: BorderEditor["borderColor"]) => {
			fallback = value;
		},
	});
}

function install(ctx: ExtensionContext): void {
	const previous = ctx.ui.getEditorComponent();

	ctx.ui.setEditorComponent((tui, theme, keybindings) => {
		const editor = previous?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings);
		patchBorder(editor as BorderEditor, ctx);
		return editor;
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		// Defer so later extensions can install their editors first.
		setTimeout(() => install(ctx), 0);
	});
}
