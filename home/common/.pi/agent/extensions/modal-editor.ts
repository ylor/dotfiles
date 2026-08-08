/**
 * Minimal Vim-like modal editor.
 *
 * Normal mode: h/j/k/l, 0, $, x, i, a, dd, yy, p, P
 * Cursor: block in normal mode, bar in insert mode
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Mode = "normal" | "insert";
type Operator = "d" | "y";

const NORMAL_KEYS: Record<string, string> = {
	h: "\x1b[D",
	j: "\x1b[B",
	k: "\x1b[A",
	l: "\x1b[C",
	"0": "\x01",
	$: "\x05",
	x: "\x1b[3~",
};

const CURSOR_SHAPE: Record<Mode, string> = {
	normal: "\x1b[2 q", // steady block
	insert: "\x1b[6 q", // steady bar
};

const FAKE_BLOCK_CURSOR = /\x1b\[7m([^\x1b]*)\x1b\[0m/;

class ModalEditor extends CustomEditor {
	private mode: Mode = "insert";
	private pendingOperator: Operator | null = null;
	private lineRegister: string | null = null;
	private renderedCursorMode: Mode | null = null;

	private setMode(mode: Mode): void {
		this.mode = mode;
		this.pendingOperator = null;
		this.updateCursorShape();
		this.tui.requestRender();
	}

	private updateCursorShape(): void {
		if (this.renderedCursorMode === this.mode) return;
		this.renderedCursorMode = this.mode;
		this.tui.setShowHardwareCursor(true);
		this.tui.terminal.write(CURSOR_SHAPE[this.mode]);
	}

	private replaceLines(lines: string[], targetLine: number, targetCol = 0): void {
		this.setText(lines.join("\n"));

		// setText() places the cursor at the end. Walk visual lines until the
		// requested logical line is reached, which also works for wrapped text.
		while (this.getCursor().line > targetLine) this.moveCursor(-1, 0);
		while (this.getCursor().line < targetLine) this.moveCursor(1, 0);

		const line = this.getLines()[targetLine] ?? "";
		this.setCursorCol(Math.min(targetCol, line.length));
		this.tui.requestRender();
	}

	private deleteLine(): void {
		const lines = this.getLines();
		const { line, col } = this.getCursor();
		this.lineRegister = lines[line] ?? "";

		if (lines.length === 1) {
			this.replaceLines([""], 0);
			return;
		}

		lines.splice(line, 1);
		const targetLine = Math.min(line, lines.length - 1);
		this.replaceLines(lines, targetLine, col);
	}

	private yankLine(): void {
		const { line } = this.getCursor();
		this.lineRegister = this.getLines()[line] ?? "";
	}

	private pasteLine(after: boolean): void {
		if (this.lineRegister === null) return;

		const lines = this.getLines();
		const { line } = this.getCursor();
		const targetLine = line + (after ? 1 : 0);
		lines.splice(targetLine, 0, this.lineRegister);
		this.replaceLines(lines, targetLine);
	}

	private handleOperator(key: string): boolean {
		if (this.pendingOperator) {
			const operator = this.pendingOperator;
			this.pendingOperator = null;
			if (key !== operator) return false;

			if (operator === "d") this.deleteLine();
			else this.yankLine();
			return true;
		}

		if (key === "d" || key === "y") {
			this.pendingOperator = key;
			return true;
		}

		return false;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") this.setMode("normal");
			else if (this.pendingOperator) this.pendingOperator = null;
			else super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		if (this.handleOperator(data)) return;

		switch (data) {
			case "i":
				this.setMode("insert");
				return;
			case "a":
				super.handleInput("\x1b[C");
				this.setMode("insert");
				return;
			case "p":
				this.pasteLine(true);
				return;
			case "P":
				this.pasteLine(false);
				return;
		}

		const mappedKey = NORMAL_KEYS[data];
		if (mappedKey) {
			super.handleInput(mappedKey);
			return;
		}

		// Preserve application shortcuts while ignoring unmapped printable keys.
		if (data.length !== 1 || data.charCodeAt(0) < 32) super.handleInput(data);
	}

	render(width: number): string[] {
		this.updateCursorShape();
		let lines = super.render(width);

		// Insert mode uses the hardware bar cursor instead of the editor's fake block.
		if (this.mode === "insert") {
			lines = lines.map((line) => line.replace(FAKE_BLOCK_CURSOR, "$1"));
		}
		if (lines.length === 0) return lines;

		const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => new ModalEditor(tui, theme, keybindings));
	});
}
