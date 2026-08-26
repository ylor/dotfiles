import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const UPSTREAM_ROOT =
	"https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/examples/extensions";
const EXTENSION_ROOT = join(homedir(), ".pi", "agent", "extensions");
const UPSTREAM_FILES = ["questionnaire.ts", "handoff.ts"];
const FETCH_TIMEOUT_MS = 5_000;
const CHECK_INTERVAL_MS = 60 * 60 * 1_000;
const CACHE_ROOT = join(homedir(), ".cache", "pi");
const LAST_CHECK_PATH = join(CACHE_ROOT, "upstream-update-last-check");

async function checkIsDue(): Promise<boolean> {
	try {
		const lastCheck = Number(await readFile(LAST_CHECK_PATH, "utf8"));
		return !Number.isFinite(lastCheck) || Date.now() - lastCheck >= CHECK_INTERVAL_MS;
	} catch {
		return true;
	}
}

async function differsFromUpstream(fileName: string): Promise<boolean> {
	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);

	try {
		const [localContent, response] = await Promise.all([
			readFile(join(EXTENSION_ROOT, fileName)),
			fetch(`${UPSTREAM_ROOT}/${fileName}`, { signal: controller.signal }),
		]);
		if (!response.ok) return false;

		const upstreamContent = Buffer.from(await response.arrayBuffer());
		return !localContent.equals(upstreamContent);
	} catch {
		return false;
	} finally {
		clearTimeout(timeout);
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI || !(await checkIsDue())) return;

		await mkdir(CACHE_ROOT, { recursive: true });
		await writeFile(LAST_CHECK_PATH, String(Date.now()), "utf8");
		const checks = await Promise.all(
			UPSTREAM_FILES.map(async (fileName) => ({
				fileName,
				differs: await differsFromUpstream(fileName),
			})),
		);
		const updates = checks.filter((check) => check.differs).map((check) => check.fileName);
		if (updates.length === 0) return;

		ctx.ui.notify(`Upstream updates exist for: ${updates.join(", ")}`, "warning");
	});
}
