# Simplify `tr100.fish` Without `awk`

## Goal and assumptions

Refactor `home/.config/fish/functions/tr100.fish` into a smaller Fish-native implementation.

The report will retain its current fields, box layout, Linux support, macOS support, and SSH-only login details. The report will use root filesystem statistics and will not include ZFS support.

The implementation will not call `awk`. It will prefer Fish built-ins over `grep`, `cut`, `sed`, and `tr`.

The file contains an uncommitted refactor. Preserve that work and refine it instead of restoring the committed version.

## Key findings

- `home/.config/fish/functions/tr100.fish` contains 407 lines. The committed version contains 581 lines.
- The current worktree version contains no `awk` call.
- Helper functions must not remain in the user shell namespace after `tr100` returns.
- Data collection occurs when Fish autoloads the file. Later `tr100` calls reuse stale load, memory, disk, and network values.
- `get_ip_addr` excludes `lo` but not the macOS `lo0` interface.
- The load parser handles comma-separated Linux output, but macOS can use space-separated values.
- The login parser can pass no argument to `is_ipv4` when a record lacks fields.
- The final SSH address row appears after the closing border.
- No repository test suite covers this function.

## Proposed implementation

1. Keep one public function named `tr100`.
2. Define helper functions inside `tr100` and erase them before each return.
3. Replace global configuration values with local values or explicit helper arguments.
4. Move system data collection into `tr100` so each call reads current values.
5. Call `uname` and `lscpu` once per report, then reuse their output.
6. Use `string`, `read`, `math`, and `string repeat` for parsing, conversion, and layout.
7. Preserve the current Linux, macOS, IPv4, IPv6, and last-login branches.
8. Use root filesystem statistics and remove the ZFS branch.
9. Parse both comma-separated and space-separated load averages.
10. Exclude all loopback interfaces and Docker interfaces from address selection.
11. Guard empty login records before IPv4 validation.
12. Build bars only after the report determines the data-column width.
13. Place all conditional rows before the closing border.
14. Remove dead variables, obsolete comments, and redundant command pipelines.
15. Keep comments only where platform output or a non-obvious choice needs context.

## Verification plan

1. Run `fish -n home/.config/fish/functions/tr100.fish`.
2. Run `fish_indent --check home/.config/fish/functions/tr100.fish`.
3. Search the file for `awk` and confirm that no match exists.
4. Source the file in a clean Fish process and call `tr100`.
5. Confirm that each report row has one width and that the final border closes the report.
6. Call `tr100` twice and confirm that both calls complete without leaked temporary state.
7. Run the report twice, confirm that temporary helper functions do not remain, and exercise empty values, zero totals, IPv4 addresses, and IPv6 addresses through the report logic.

## Risks and rejected alternatives

The local machine can verify only its active operating-system branch. Keep the inactive branch simple and close to documented command output.

Do not add a general report framework or a test framework. Both options add more complexity than this one function needs.

Do not source `/etc/os-release`. Direct parsing avoids execution of configuration file contents.
