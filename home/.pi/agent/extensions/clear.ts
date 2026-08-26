import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
	pi.registerShortcut("ctrl+shift+k", {
		description: "Start a new session",
		handler: async (ctx) => {
			await ctx.newSession();
		},
	});

	pi.registerCommand("clear", {
		description: "Start a new session",
		handler: async (_args, ctx) => {
			await ctx.newSession();
		},
	});
}
