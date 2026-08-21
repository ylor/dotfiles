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

function colorText(text: string, hex: string, dim: boolean): string {
	const rgb = [1, 3, 5].map((index) => Number.parseInt(hex.slice(index, index + 2), 16));
	const faint = dim ? "\x1b[2m" : "";
	const resetFaint = dim ? "\x1b[22m" : "";
	return `${faint}\x1b[38;2;${rgb.join(";")}m${text}\x1b[39m${resetFaint}`;
}

function patchEditorColors(editor: BorderEditor, ctx: ExtensionContext): void {
	const originalRender = (editor as BorderEditor & { render: (width: number) => string[] }).render;

	(editor as BorderEditor & { render: (width: number) => string[] }).render = (width) => {
		const model = ctx.model;
		const color = model && MODEL_COLORS[`${model.provider}/${model.id}`];
		const lines = originalRender.call(editor, width);
		if (!color) return lines;

		const rgb = [1, 3, 5].map((index) => Number.parseInt(color.slice(index, index + 2), 16));
		const foreground = `\x1b[38;2;${rgb.join(";")}m`;
		const cursor = `\x1b[48;2;${rgb.join(";")}m\x1b[38;2;0;0;0m`;
		const terminalCursor = `\x1b]12;${color}\x07`;
		return lines.map((line, index) => {
			const prefix = index === 0 ? terminalCursor : "";
			return `${prefix}${foreground}${line.replaceAll("\x1b[7m", cursor)}`;
		});
	};
}

function patchBorder(editor: BorderEditor, ctx: ExtensionContext): void {
	let fallback = editor.borderColor;

	const borderColor = (text: string) => {
		const model = ctx.model;
		if (!model) return fallback(text);

		const color = MODEL_COLORS[`${model.provider}/${model.id}`];
		if (!color) return fallback(text);

		return colorText(text, color, ctx.thinkingLevel === "off");
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
		patchEditorColors(editor as BorderEditor, ctx);
		return editor;
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		const model = ctx.model;
		if (!model || !MODEL_COLORS[`${model.provider}/${model.id}`]) return;

		install(ctx);
	});
}
