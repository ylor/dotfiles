import type {
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";

function hideLspStatus(ctx: ExtensionContext): void {
	if (ctx.mode !== "tui") return;

	const setStatus = ctx.ui.setStatus.bind(ctx.ui);
	setStatus("pi-lens-lsp", undefined);
	ctx.ui.setStatus = (key, value) => {
		if (key !== "pi-lens-lsp") setStatus(key, value);
	};
}

export default function (pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => hideLspStatus(ctx));
}
