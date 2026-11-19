---
name: better
description: Deepen a prompt into the version a top professional would ask for, grounded in the real code and files; or check a subagent brief so it can be acted on cold
disable-model-invocation: true
---

Based on Felix Rieseberg's "Depth" prompt, as adapted by pi-better (https://github.com/nicobailon/pi-better).

## Pick the input

- The text the user gave after `/better`.
- If nothing is given: the task in progress in this session, including the user's feedback so far. If there is none, the code changed in this session or the uncommitted changes (`git status`, `git diff HEAD`). If still unclear, ask.
- If the input is a brief for another agent or subagent (it starts with `brief`, or the user says it's for a subagent), use **Brief mode** below instead.

## Deepen mode

First, without asking me anything, find and read the code, files, docs and logs this touches, so your answers rest on them. I want a deeper version of this task/plan request, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm not asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that.

### How to work

1. Gather the raw material. Don't rely on summaries in the conversation when the source is reachable; screenshots count too. Keep every command quick; I'm waiting until you finish. Search the project and the paths the request names, not whole home, session-log or cache directories. Give any command that might be slow a timeout of 30 seconds or less, and when one times out, narrow it instead of retrying it.
2. Answer (1) to (4) in a few lines each, using concrete facts from what you found: file names, line numbers, counts, real names of components, commands and tools that exist here.
3. Rewrite the prompt so it asks for exactly that: the deeper version, not a bigger one. Keep my goal and voice, put the concrete facts in, and say what proves the result is right. Write it as my own request, ready to send as is.

## Brief mode

The brief is for a subagent that starts with none of this conversation: it sees only the brief, the repo and its own tools. Without asking me anything, read the brief the way that subagent would, check it against the real code, files, docs and logs, and fix only what would trip it up. I want a brief the subagent can act on cold, not a bigger one.

### How to work

1. Keep every command quick, as in Deepen mode: search the project and the paths the brief names, 30-second timeouts, narrow instead of retrying.
2. In a few lines each, using concrete facts from what you found:
   (1) List what the subagent can't resolve on its own: references only this conversation explains ("the bug we found", "option B", "as discussed"), decisions the brief relies on but doesn't state, and files, commands or setup it assumes.
   (2) Check every path, symbol, line number, command and version the brief names against the repo as it is now, and list what is wrong or out of date with the correct value.
   (3) Say how the subagent will know it's done. If the brief doesn't say, find the real check here: a test, a command, an output, a file to compare.
3. Rewrite the brief with only those gaps fixed: put the missing facts in, correct what's wrong, and add the check from (3) if it was missing. Keep its goal, scope, order, wording and length as close to the original as you can. Don't add work it doesn't ask for. If nothing needs fixing, return it unchanged.

## Output

Your reply is: the numbered answers, then the rewritten prompt or brief in a single fenced `text` block, last, with nothing after it.

Never carry the prompt or brief out. Don't edit files, start work, or launch anything; you only read and rewrite. The user decides whether to send it.
