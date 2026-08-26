import {
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

type Editor = {
	borderColor(text: string): string;
	render(width: number): string[];
};

const MODEL_COLORS: Record<string, string> = {
	"openrouter/deepseek/deepseek-v4-flash-0731": "#4D6BFE",
	"openai-codex/gpt-5.6-sol": "#FE9A00",
	"openai-codex/gpt-5.6-luna": "#90A1B9",
};

function modelColor(ctx: ExtensionContext): string | undefined {
	const model = ctx.model;
	return model && MODEL_COLORS[`${model.provider}/${model.id}`];
}

function rgbParameters(hex: string): string {
	return [1, 3, 5]
		.map((index) => Number.parseInt(hex.slice(index, index + 2), 16))
		.join(";");
}

function colorText(text: string, hex: string, dim: boolean): string {
	const foreground = `\x1b[38;2;${rgbParameters(hex)}m`;
	const styled = `${foreground}${text}\x1b[39m`;
	return dim ? `\x1b[2m${styled}\x1b[22m` : styled;
}

function patchEditor(editor: Editor, ctx: ExtensionContext): void {
	const originalRender = editor.render.bind(editor);
	let fallbackBorderColor = editor.borderColor;

	editor.render = (width) => {
		const lines = originalRender(width);
		const color = modelColor(ctx);
		if (!color) return lines;

		const colorRgb = rgbParameters(color);
		const foreground = `\x1b[38;2;${colorRgb}m`;
		const cursor = `\x1b[48;2;${colorRgb}m\x1b[38;2;0;0;0m`;
		const terminalCursor = `\x1b]12;${color}\x07`;

		return lines.map((line, index) => {
			const prefix = index === 0 ? terminalCursor : "";
			return `${prefix}${foreground}${line.replaceAll("\x1b[7m", cursor)}`;
		});
	};

	const borderColor = (text: string) => {
		const color = modelColor(ctx);
		return color ? colorText(text, color, ctx.thinkingLevel === "off") : fallbackBorderColor(text);
	};

	// Pi replaces borderColor when its state changes. Keep each replacement as the fallback.
	Object.defineProperty(editor, "borderColor", {
		configurable: true,
		get: () => borderColor,
		set: (value: Editor["borderColor"]) => {
			fallbackBorderColor = value;
		},
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		const previous = ctx.ui.getEditorComponent();
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			const editor = previous?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings);
			patchEditor(editor as Editor, ctx);
			return editor;
		});
	});
}
