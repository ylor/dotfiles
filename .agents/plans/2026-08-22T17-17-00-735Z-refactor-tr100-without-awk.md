# Refactor `tr100` without `awk`

## Goal and assumptions

Refactor `home/.config/fish/functions/tr100.fish` into a smaller, faster Fish implementation. Remove every `awk` dependency and preserve the report layout.

Retain support for Arch Linux and macOS. Remove all ZFS detection, collection, health, and display branches.

Treat these output fixes as part of the refactor:

- Truncate every value to the actual 28-character data width.
- Refresh report data on each `tr100` call.
- Keep helper functions absent from the global namespace after each call.

## Key findings

- `home/.config/fish/functions/tr100.fish:8-526` executes data collection during Fish function autoload.
- The file defines many generic global functions and variables that can collide with other Fish configuration.
- The file contains 39 active `awk` references across network, CPU, load, memory, disk, and login collection.
- `home/.config/fish/functions/tr100.fish:529` only prints a subset of the collected values.
- The current code repeats `uname`, `lscpu`, pipelines, loops, and numeric calculations.
- `home/.config/fish/conf.d/prompt/fish_greeting.fish:60-62` calls `tr100` for the interactive greeting.
- Fish has one session-wide function namespace. Nested function definitions require explicit removal after use.
- The repository has no test suite for this function.

## Proposed implementation

1. Keep the license header and replace generic globals with local constants inside `tr100`.
2. Define the few display helpers inside `tr100` with inherited local width values.
3. Remove each helper with `functions --erase` before `tr100` returns.
4. Avoid early returns after helper definitions so normal failures still reach cleanup.
5. Use `string repeat` for borders and bars instead of character loops.
6. Use one local row helper for labels, bars, padding, and width-based truncation.
7. Move all data collection into `tr100` so each call uses current system values.
8. Cache the operating system name and each multi-value command result.
9. Remove all ZFS code and always collect disk data from the platform root data volume.
10. Remove unused configuration, debug code, collectors, variables, comments, and display helpers.
11. Parse `/etc/os-release`, `/proc`, `lscpu`, `df`, `ip`, `ifconfig`, and login output with Fish string functions.
12. Use Fish `math` for percentages, unit conversion, bar size, and macOS uptime.
13. Prefer IPv4, reject loopback and Docker interfaces, then use IPv6 as the fallback.
14. Collect login data only when `SSH_TTY` exists.
15. Preserve macOS memory calculations with `sysctl`, `vm_stat`, Fish regex matches, and Fish math.
16. Preserve Linux memory calculations with one read of `/proc/meminfo` and Fish regex matches.
17. Parse one `df` result into Fish fields for the disk report.
18. Keep useful fallbacks for absent optional commands and unavailable values.
19. Keep the current section order, labels, decorated header, 43-character width, and Unicode bars.

## Verification plan

1. Run `fish -n home/.config/fish/functions/tr100.fish`.
2. Run `fish_indent --check home/.config/fish/functions/tr100.fish`.
3. Search the complete file for `awk` and confirm that no match exists.
4. Search the complete file for ZFS commands and confirm that no match exists.
5. Source the function in a clean Fish process and run `tr100` on Linux.
6. Confirm that every output line has the same display width.
7. Confirm that percentages and bars remain between zero and 100 percent.
8. Run `tr100` twice in one process and confirm that both calls succeed.
9. Query the helper names after each call and confirm that none exist.
10. Review the macOS branch against its native command formats.
11. Compare command count and elapsed time with the current implementation when practical.

## Risks and rejected alternatives

Native command output differs between Linux and macOS. Focused Fish regexes and explicit fallbacks limit this risk.

The current host cannot verify the macOS branch at runtime. Static review will cover that branch.

Fish lacks lexical function scope. Nested helper definitions plus explicit removal provide the requested non-leak behavior without permanent prefixes.

A new test framework adds more complexity than this single Fish function needs. Syntax, output, and branch checks provide sufficient verification.

External replacements such as `sed`, Perl, Python, or `jq` only exchange one parser dependency for another. Fish built-ins keep the implementation small.
