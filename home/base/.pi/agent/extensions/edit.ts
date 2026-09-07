import { spawnSync } from "node:child_process";
import { statSync } from "node:fs";
import { homedir } from "node:os";
import { resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext, SessionEntry } from "@earendil-works/pi-coding-agent";

export function sessionFiles(entries: SessionEntry[], cwd: string): string[] {
	const calls = new Map<string, string>();
	const files = new Set<string>();
	for (const entry of entries) {
		if (entry.type !== "message") continue;
		const message = entry.message;
		if (message.role === "assistant") {
			for (const block of message.content) {
				if (block.type !== "toolCall" || !["edit", "write"].includes(block.name)) continue;
				let path = block.arguments.path;
				if (typeof path !== "string" || !path) continue;
				path = path.replace(/^@/, "");
				if (path.startsWith("~/")) path = resolve(homedir(), path.slice(2));
				calls.set(block.id, resolve(cwd, path));
			}
		} else if (message.role === "toolResult" && !message.isError) {
			const path = calls.get(message.toolCallId);
			if (!path) continue;
			files.delete(path);
			files.add(path);
		}
	}
	return [...files].reverse().filter((path) => {
		try {
			return statSync(path).isFile();
		} catch {
			return false;
		}
	});
}

export default function (pi: ExtensionAPI) {
	const command = {
		description: "Open modified session files in $EDITOR, most recently modified first",
		handler: async (_args: string, ctx: ExtensionContext) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/edit requires interactive pi.", "error");
				return;
			}
			if (!ctx.isIdle()) {
				ctx.ui.notify("Wait for the agent to finish before opening files.", "warning");
				return;
			}
			const editor = process.env.EDITOR?.trim();
			if (!editor) {
				ctx.ui.notify("Set $EDITOR first.", "error");
				return;
			}
			const files = sessionFiles(ctx.sessionManager.getBranch(), ctx.cwd);
			if (!files.length) {
				ctx.ui.notify("No existing files edited or written in this session branch.", "info");
				return;
			}
			const editorArgs: string[] = [];
			if (/(?:^|\/)(?:nvim|vim)(?:\s|$)/.test(editor)) {
				for (const [from, to] of [["q", "qa"], ["wq", "wqa"]]) {
					editorArgs.push("-c", `cnoreabbrev <expr> ${from} getcmdtype() == ':' && getcmdline() == '${from}' ? '${to}' : '${from}'`);
				}
			}
			const error = await ctx.ui.custom<string | undefined>((tui, _theme, _kb, done) => {
				let error: string | undefined;
				tui.stop();
				try {
					process.stdout.write("\x1b[2J\x1b[H");
					// Interpret editor flags, but never interpolate session paths into shell code.
					const result = spawnSync("/bin/sh", ["-c", `${editor} "$@"`, "pi-edit", ...editorArgs, ...files], {
						cwd: ctx.cwd,
						stdio: "inherit",
					});
					if (result.error) error = result.error.message;
					else if (result.status !== 0) error = `Editor exited with ${result.signal ?? result.status}.`;
				} catch (cause) {
					error = String(cause);
				} finally {
					tui.start();
					tui.requestRender(true);
				}
				done(error);
				return { render: () => [], invalidate() {} };
			});
			if (error) ctx.ui.notify(error, "error");
		},
	};
	pi.registerCommand("edit", command);
	pi.registerShortcut("ctrl+e", {
		description: command.description,
		handler: (ctx) => command.handler("", ctx),
	});
}
