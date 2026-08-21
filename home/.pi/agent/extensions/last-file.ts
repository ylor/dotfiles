import { spawnSync } from "node:child_process";
import { access } from "node:fs/promises";
import { resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const FILE_TOOLS = new Set(["read", "edit", "write"]);

async function openNeovim(path: string, ctx: ExtensionContext): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify("Neovim requires the TUI mode.", "error");
		return;
	}

	try {
		await access(path);
	} catch {
		ctx.ui.notify(`File does not exist: ${path}`, "error");
		return;
	}

	const exitCode = await ctx.ui.custom<number | null>((tui, _theme, _keybindings, done) => {
		tui.stop();
		process.stdout.write("\x1b[2J\x1b[H");

		const result = spawnSync("nvim", ["--", path], {
			cwd: ctx.cwd,
			stdio: "inherit",
			env: process.env,
		});

		tui.start();
		tui.requestRender(true);
		done(result.status);
		return { render: () => [], invalidate: () => {} };
	});

	if (exitCode !== 0) {
		ctx.ui.notify(`Neovim exited with code ${exitCode ?? "unknown"}.`, "error");
	}
}

export default function (pi: ExtensionAPI) {
	let lastFile: string | undefined;

	const rememberPath = (path: string, cwd: string) => {
		lastFile = resolve(cwd, path.replace(/^@/, ""));
	};

	const rememberReferences = (text: string, cwd: string) => {
		const matches = text.matchAll(/(?:^|\s)@([^\s]+)/g);
		for (const match of matches) {
			rememberPath(match[1].replace(/[),;:!?]+$/, ""), cwd);
		}
	};

	pi.on("session_start", (_event, ctx) => {
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message" || entry.message.role !== "user") continue;

			const content = entry.message.content;
			if (typeof content === "string") {
				rememberReferences(content, ctx.cwd);
				continue;
			}

			for (const part of content) {
				if (part.type === "text") rememberReferences(part.text, ctx.cwd);
			}
		}
	});

	pi.on("input", (event, ctx) => {
		rememberReferences(event.text, ctx.cwd);
	});

	pi.on("tool_call", (event, ctx) => {
		const toolName = event.toolName.split(".").at(-1);
		if (!toolName || !FILE_TOOLS.has(toolName)) return;

		const input = event.input as { path?: unknown };
		if (typeof input.path === "string") rememberPath(input.path, ctx.cwd);
	});

	pi.registerShortcut("ctrl+alt+e", {
		description: "Open the last referenced file in Neovim",
		handler: async (ctx) => {
			if (!lastFile) {
				ctx.ui.notify("No file was referenced in this session.", "warning");
				return;
			}

			await openNeovim(lastFile, ctx);
		},
	});
}
