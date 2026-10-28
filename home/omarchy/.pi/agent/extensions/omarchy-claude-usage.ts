import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

// Keeps Omarchy's agent panel current while Claude is used through pi.
// The panel reads limits with the Claude Code CLI's token, which lapses when
// only pi is used. `claude auth status` renews it without a model request.

const CREDENTIALS = join(process.env.CLAUDE_CONFIG_DIR ?? join(homedir(), ".claude"), ".credentials.json");
const RENEW_MARGIN_MS = 10 * 60 * 1000;

function cliTokenExpiresAt(): number {
	try {
		const credentials = JSON.parse(readFileSync(CREDENTIALS, "utf8"));
		return Number(credentials.claudeAiOauth?.expiresAt) || 0;
	} catch {
		return 0;
	}
}

export default function (pi: ExtensionAPI) {
	let updating = false;

	async function updatePanel() {
		if (updating) return;
		updating = true;
		try {
			const expiresSoon = cliTokenExpiresAt() < Date.now() + RENEW_MARGIN_MS;
			if (expiresSoon) await pi.exec("claude", ["auth", "status"], { timeout: 30_000 });
			await pi.exec("omarchy", ["agent", "usage-update", "claude", "--limits-only"], { timeout: 60_000 });
		} catch {
			// The panel is a nicety; never disturb the session over it.
		} finally {
			updating = false;
		}
	}

	pi.on("agent_settled", async (_event, ctx) => {
		if (ctx.model?.provider !== "anthropic") return;
		void updatePanel();
	});
}
