/**
 * Small Vim-like editor.
 *
 * Normal: h/j/k/l, w/b, 0, $, x, i, a, dd, yy, text objects, surround, p, P
 * Text objects: diw/daw, yi"/ya", di(/da(, etc.
 * Surround: siw), saw], sw", ss), etc.
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Mode = "normal" | "insert";
type Operator = "d" | "y";
type Range = { start: number; end: number };
type Register = { text: string; linewise: boolean };
type YankHighlight = Range & { line: number };
type Pair = readonly [string, string];

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
	normal: "\x1b[2 q",
	insert: "\x1b[6 q",
};

const TEXT_PAIRS: Record<string, Pair> = {
	"(": ["(", ")"],
	")": ["(", ")"],
	b: ["(", ")"],
	"[": ["[", "]"],
	"]": ["[", "]"],
	"{": ["{", "}"],
	"}": ["{", "}"],
	B: ["{", "}"],
	"<": ["<", ">"],
	">": ["<", ">"],
};

const SURROUND_PAIRS: Record<string, Pair> = {
	"(": ["( ", " )"],
	")": ["(", ")"],
	b: ["(", ")"],
	"[": ["[ ", " ]"],
	"]": ["[", "]"],
	"{": ["{ ", " }"],
	"}": ["{", "}"],
	B: ["{", "}"],
	"<": ["< ", " >"],
	">": ["<", ">"],
};

const FAKE_BLOCK_CURSOR = /\x1b\[7m([^\x1b]*)\x1b\[0m/;
const ANSI_SEQUENCE = /^\x1b\[[0-?]*[ -/]*[@-~]/;
const WORD = /[A-Za-z0-9_]/;
const SPACE = /\s/;
const YANK_HIGHLIGHT_MS = 100;

function isEscaped(text: string, index: number): boolean {
	let count = 0;
	while (index > 0 && text[--index] === "\\") count++;
	return count % 2 === 1;
}

function delimitedRange(text: string, col: number, [open, close]: Pair, around: boolean): Range | null {
	if (open === close) {
		let start = -1;
		for (let i = 0; i < text.length; i++) {
			if (text[i] !== open || isEscaped(text, i)) continue;
			if (start < 0) start = i;
			else if (col >= start && col <= i) {
				return around ? { start, end: i + 1 } : { start: start + 1, end: i };
			} else start = -1;
		}
		return null;
	}

	const stack: number[] = [];
	let best: Range | null = null;
	for (let i = 0; i < text.length; i++) {
		if (text[i] === open) stack.push(i);
		else if (text[i] === close) {
			const start = stack.pop();
			if (start === undefined || col < start || col > i) continue;
			const range = around ? { start, end: i + 1 } : { start: start + 1, end: i };
			if (!best || range.end - range.start < best.end - best.start) best = range;
		}
	}
	return best;
}

function wordRange(text: string, col: number, around: boolean, big: boolean): Range | null {
	if (!text) return null;

	const index = Math.min(Math.max(col, 0), text.length - 1);
	const char = text[index]!;
	let matches: (value: string) => boolean;
	if (SPACE.test(char)) matches = (value) => SPACE.test(value);
	else if (big) matches = (value) => !SPACE.test(value);
	else if (WORD.test(char)) matches = (value) => WORD.test(value);
	else matches = (value) => !SPACE.test(value) && !WORD.test(value);

	let start = index;
	let end = index + 1;
	while (start > 0 && matches(text[start - 1]!)) start--;
	while (end < text.length && matches(text[end]!)) end++;

	if (around && !SPACE.test(char)) {
		const wordEnd = end;
		while (end < text.length && SPACE.test(text[end]!)) end++;
		if (end === wordEnd) while (start > 0 && SPACE.test(text[start - 1]!)) start--;
	}
	return { start, end };
}

function textObjectRange(text: string, col: number, selector: string, around: boolean): Range | null {
	if (selector === "w" || selector === "W") return wordRange(text, col, around, selector === "W");
	if (selector === "\"" || selector === "'" || selector === "`") {
		return delimitedRange(text, col, [selector, selector], around);
	}
	const pair = TEXT_PAIRS[selector];
	return pair ? delimitedRange(text, col, pair, around) : null;
}

function surroundPair(key: string): Pair {
	return SURROUND_PAIRS[key] ?? [key, key];
}

function highlightRange(rendered: string, sourceLength: number, range: Range): string {
	let result = "";
	let sourcePos = 0;
	let highlighted = false;

	for (let i = 0; i < rendered.length; ) {
		if (rendered.startsWith(CURSOR_MARKER, i)) {
			result += CURSOR_MARKER;
			i += CURSOR_MARKER.length;
			continue;
		}

		const ansi = rendered[i] === "\x1b" ? rendered.slice(i).match(ANSI_SEQUENCE)?.[0] : undefined;
		if (ansi) {
			result += ansi;
			if (highlighted && ansi === "\x1b[0m") result += "\x1b[7m";
			i += ansi.length;
			continue;
		}

		const selected = sourcePos < sourceLength && sourcePos >= range.start && sourcePos < range.end;
		if (selected !== highlighted) {
			result += selected ? "\x1b[7m" : "\x1b[0m";
			highlighted = selected;
		}
		result += rendered[i]!;
		sourcePos++;
		i++;
	}

	return highlighted ? `${result}\x1b[0m` : result;
}

class ModalEditor extends CustomEditor {
	private mode: Mode = "insert";
	private command = "";
	private register: Register | null = null;
	private cursorMode: Mode | null = null;
	private yankHighlight: YankHighlight | null = null;
	private yankTimer: ReturnType<typeof setTimeout> | undefined;

	private setMode(mode: Mode): void {
		this.mode = mode;
		this.command = "";
		this.updateCursorShape();
		this.tui.requestRender();
	}

	private updateCursorShape(): void {
		if (this.cursorMode === this.mode) return;
		this.cursorMode = this.mode;
		this.tui.setShowHardwareCursor(true);
		this.tui.terminal.write(CURSOR_SHAPE[this.mode]);
	}

	private replaceLines(lines: string[], line: number, col = 0): void {
		this.setText(lines.join("\n"));
		while (this.getCursor().line > line) this.moveCursor(-1, 0);
		while (this.getCursor().line < line) this.moveCursor(1, 0);
		this.setCursorCol(Math.min(col, this.getLines()[line]?.length ?? 0));
		this.tui.requestRender();
	}

	private deleteLine(): void {
		const lines = this.getLines();
		const { line, col } = this.getCursor();
		this.register = { text: lines[line] ?? "", linewise: true };

		if (lines.length === 1) return this.replaceLines([""], 0);
		lines.splice(line, 1);
		this.replaceLines(lines, Math.min(line, lines.length - 1), col);
	}

	private yankLine(): void {
		const { line } = this.getCursor();
		const text = this.getLines()[line] ?? "";
		this.register = { text, linewise: true };
		this.flashYank(line, { start: 0, end: text.length });
	}

	private flashYank(line: number, range: Range): void {
		this.yankHighlight = { line, ...range };
		if (this.yankTimer) clearTimeout(this.yankTimer);
		this.yankTimer = setTimeout(() => {
			this.yankTimer = undefined;
			this.yankHighlight = null;
			this.tui.requestRender();
		}, YANK_HIGHLIGHT_MS);
		this.tui.requestRender();
	}

	private applyTextObject(operator: Operator, around: boolean, selector: string): void {
		const { line, col } = this.getCursor();
		const lines = this.getLines();
		const text = lines[line] ?? "";
		const range = textObjectRange(text, col, selector, around);
		if (!range) return;

		this.register = { text: text.slice(range.start, range.end), linewise: false };
		if (operator === "y") return this.flashYank(line, range);

		lines[line] = text.slice(0, range.start) + text.slice(range.end);
		this.replaceLines(lines, line, range.start);
	}

	private applySurround(around: boolean, selector: string | null, wrapper: string): void {
		const { line, col } = this.getCursor();
		const lines = this.getLines();
		const text = lines[line] ?? "";
		const range = selector === null ? { start: 0, end: text.length } : textObjectRange(text, col, selector, around);
		if (!range) return;

		const [open, close] = surroundPair(wrapper);
		const selected = text.slice(range.start, range.end);
		lines[line] = text.slice(0, range.start) + open + selected + close + text.slice(range.end);
		const offset = Math.max(0, Math.min(col - range.start, selected.length));
		this.replaceLines(lines, line, range.start + open.length + offset);
	}

	private moveWord(forward: boolean): void {
		const lines = this.getLines();
		let { line, col } = this.getCursor();

		if (forward) {
			const text = lines[line] ?? "";
			if (col < text.length) {
				const char = text[col]!;
				const matches = SPACE.test(char)
					? (value: string) => SPACE.test(value)
					: WORD.test(char)
						? (value: string) => WORD.test(value)
						: (value: string) => !SPACE.test(value) && !WORD.test(value);
				while (col < text.length && matches(text[col]!)) col++;
			}
			while (line < lines.length) {
				const current = lines[line] ?? "";
				while (col < current.length && SPACE.test(current[col]!)) col++;
				if (col < current.length) break;
				line++;
				col = 0;
			}
		} else {
			while (line >= 0) {
				const text = lines[line] ?? "";
				col = Math.min(col - 1, text.length - 1);
				while (col >= 0 && SPACE.test(text[col]!)) col--;
				if (col >= 0) {
					const char = text[col]!;
					const matches = WORD.test(char)
						? (value: string) => WORD.test(value)
						: (value: string) => !SPACE.test(value) && !WORD.test(value);
					while (col > 0 && matches(text[col - 1]!)) col--;
					break;
				}
				line--;
				col = (lines[line] ?? "").length + 1;
			}
		}

		if (line < 0 || line >= lines.length) return;
		while (this.getCursor().line > line) this.moveCursor(-1, 0);
		while (this.getCursor().line < line) this.moveCursor(1, 0);
		this.setCursorCol(col);
		this.tui.requestRender();
	}

	private paste(after: boolean): void {
		if (!this.register) return;

		const lines = this.getLines();
		const { line, col } = this.getCursor();
		if (this.register.linewise) {
			const target = line + (after ? 1 : 0);
			lines.splice(target, 0, this.register.text);
			this.replaceLines(lines, target);
			return;
		}

		const text = lines[line] ?? "";
		const insertAt = Math.min(text.length, col + (after ? 1 : 0));
		lines[line] = text.slice(0, insertAt) + this.register.text + text.slice(insertAt);
		this.replaceLines(lines, line, insertAt + this.register.text.length);
	}

	private handleCommand(key: string): boolean {
		if (!this.command) {
			if (key === "d" || key === "y" || key === "s") {
				this.command = key;
				return true;
			}
			return false;
		}

		if (this.command === "d" || this.command === "y") {
			const operator = this.command as Operator;
			if (key === operator) {
				this.command = "";
				if (operator === "d") this.deleteLine();
				else this.yankLine();
				return true;
			}
			if (key === "i" || key === "a") {
				this.command += key;
				return true;
			}
			this.command = "";
			return false;
		}

		if (/^[dy][ia]$/.test(this.command)) {
			const operator = this.command[0] as Operator;
			const around = this.command[1] === "a";
			this.command = "";
			this.applyTextObject(operator, around, key);
			return true;
		}

		if (this.command === "s") {
			if (key === "s" || key === "i" || key === "a") this.command += key;
			else this.command = `si${key}`;
			return true;
		}

		if (this.command === "si" || this.command === "sa") {
			this.command += key;
			return true;
		}

		const command = this.command;
		this.command = "";
		if (command === "ss") this.applySurround(false, null, key);
		else this.applySurround(command[1] === "a", command[2] ?? null, key);
		return true;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") this.setMode("normal");
			else if (this.command) this.command = "";
			else super.handleInput(data);
			return;
		}

		if (this.mode === "insert") return super.handleInput(data);
		if (this.handleCommand(data)) return;

		switch (data) {
			case "w":
				return this.moveWord(true);
			case "b":
				return this.moveWord(false);
			case "i":
				return this.setMode("insert");
			case "a":
				super.handleInput("\x1b[C");
				return this.setMode("insert");
			case "p":
				return this.paste(true);
			case "P":
				return this.paste(false);
		}

		const mapped = NORMAL_KEYS[data];
		if (mapped) return super.handleInput(mapped);
		if (data.length !== 1 || data.charCodeAt(0) < 32) super.handleInput(data);
	}

	render(width: number): string[] {
		this.updateCursorShape();
		let lines = super.render(width);

		if (this.mode === "insert") {
			lines = lines.map((line) => line.replace(FAKE_BLOCK_CURSOR, "$1"));
		} else if (this.yankHighlight) {
			const cursor = this.getCursor();
			const renderedCursorLine = lines.findIndex((line) => FAKE_BLOCK_CURSOR.test(line));
			if (cursor.line === this.yankHighlight.line && renderedCursorLine >= 0) {
				const source = this.getLines()[cursor.line] ?? "";
				lines[renderedCursorLine] = highlightRange(lines[renderedCursorLine]!, source.length, this.yankHighlight);
			}
		}

		if (!lines.length) return lines;
		const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			const dimLabel = `\x1b[2m${this.borderColor(label)}\x1b[22m`;
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + dimLabel;
		}
		return lines;
	}

	dispose(): void {
		if (this.yankTimer) clearTimeout(this.yankTimer);
		resetCursorColor(this.tui.terminal);
	}
}

function resetCursorColor(terminal: { write: (data: string) => void }): void {
	// Reset the OSC cursor color before pi restores the terminal.
	terminal.write("\x1b]112;\x1b\\");
}

export default function (pi: ExtensionAPI) {
	let terminal: { write: (data: string) => void } | undefined;

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			terminal = tui.terminal;
			return new ModalEditor(tui, theme, keybindings);
		});
	});

	pi.on("session_shutdown", () => {
		if (terminal) resetCursorColor(terminal);
	});
}
