import { spawn } from "node:child_process";
import { stat } from "node:fs/promises";
import { basename, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";

function score(path: string, query: string): number {
  if (!query) return 1;

  const name = basename(path).toLowerCase();
  const normalizedQuery = query.toLowerCase();
  if (name === normalizedQuery) return 110;
  if (name.startsWith(normalizedQuery)) return 90;
  if (name.includes(normalizedQuery)) return 60;
  if (path.toLowerCase().includes(normalizedQuery)) return 40;
  return 0;
}

function quotePath(path: string): string {
  return path.includes(" ") ? `"${path}/"` : `${path}/`;
}

async function getDirectories(query: string): Promise<AutocompleteItem[]> {
  const args = [
    "--base-directory", process.cwd(),
    "--max-results", "100",
    "--type", "d",
    "--follow",
    "--hidden",
    "--exclude", ".git",
    "--exclude", ".git/*",
    "--exclude", ".git/**",
  ];

  if (query.includes("/")) args.push("--full-path");
  if (query) args.push(query);

  const paths = await new Promise<string[]>((accept) => {
    const child = spawn("/usr/bin/fd", args, { stdio: ["ignore", "pipe", "ignore"] });
    let stdout = "";
    child.stdout.setEncoding("utf8");
    child.stdout.on("data", (chunk: string) => stdout += chunk);
    child.on("error", () => accept([]));
    child.on("close", (code) => {
      if (code !== 0) {
        accept([]);
        return;
      }
      accept(stdout.trim().split("\n").filter(Boolean).map((path) => path.replace(/\/$/, "")));
    });
  });

  return paths
    .map((path) => ({ path, score: score(path, query) }))
    .filter((entry) => entry.score > 0)
    .sort((left, right) => right.score - left.score)
    .slice(0, 20)
    .map(({ path }) => ({
      value: quotePath(path),
      label: `${basename(path)}/`,
      description: path,
    }));
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("cd", {
    description: "Start a new pi session in a directory",
    getArgumentCompletions: getDirectories,
    handler: async (args, ctx) => {
      const path = args.trim().replace(/^"|"$/g, "").replace(/\/$/, "");
      if (!path) {
        ctx.ui.notify("Select a directory after /cd.", "error");
        return;
      }

      const directory = resolve(ctx.cwd, path);
      const target = await stat(directory).catch(() => null);
      if (!target?.isDirectory()) {
        ctx.ui.notify(`Not a directory: ${directory}`, "error");
        return;
      }

      // Delay the child so the current TUI can restore the terminal first.
      const child = spawn("sh", ["-c", "sleep 0.1; exec pi"], {
        cwd: directory,
        stdio: "inherit",
      });
      child.unref();
      ctx.shutdown();
    },
  });
}
