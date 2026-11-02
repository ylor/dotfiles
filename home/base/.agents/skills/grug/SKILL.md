---
name: grug
description: Simplify code. Cut needless abstraction, indirection, cleverness, and dead code without changing behavior.
---

# Grug simplify

> complexity very, very bad

Goal: same behavior, less complexity. Simpler code has fewer concepts, fewer layers, and fewer places to look, and it is easier to debug. Line count is not the goal; clever short code is often the most complex. The best simplification is deleting code.

## 1. Pick the target

Use the code the user names. If nothing is named, use the code changed in this session or the uncommitted changes (`git status`, `git diff HEAD`). If still unclear, ask.

If the user asked only for a review, change nothing and go to the report.

## 2. Understand before you cut

Chesterton's fence: do not remove code until you know why it is there.

- Read the code, its callers, and its tests.
- For odd code you want to remove (special cases, retries, sleeps, workarounds, compatibility shims), look for the reason in comments, tests, `git blame`, and `git log -S'<snippet>'`.
- If you cannot find the reason, leave the code and list it as a question. Working code is often ugly because the world is ugly.

## 3. Find the complexity

Prefer changes that remove a whole concept (a layer, an option, a type, a file) over cosmetic tweaks.

- **Dead weight**: unused code, parameters, options, flags, exports, config, commented-out code, comments that repeat the code. Delete it.
- **Early abstraction**: interface with one implementation, factory with one product, base class with one child, wrapper or layer that only forwards calls. Inline it.
- **DRY gone wrong**: a shared helper that needs flags, mode parameters, or callbacks to serve its callers. Split it back into plain copies. Simple duplication beats a complex abstraction.
- **Scattered behavior**: understanding one thing means opening many files. Move the code to the thing that does the thing, and put methods on the object they act on.
- **Clever expressions**: dense conditions, nested ternaries, long chains. Break them into named variables, so each step has a name and a value you can see in a debugger.
- **Type astronautics**: generics outside container types, type-level tricks, deep hierarchies. Use plain concrete types. Most of the value of types is autocomplete, not proofs.
- **Callback piles**: closures passed into closures, callback hell. Write straight-line code. Closures are fine for operations over collections.
- **Visitor pattern**: bad. Use a plain switch or match.
- **Hard common case**: callers must set up many things to do a simple thing. Give the simple case a simple call, and keep the complex call for complex cases.
- **Unmeasured optimization**: caches, memoization, bit tricks, or custom data structures with no profile showing a need. Remove the clearly pointless ones. Propose the rest, because tests rarely catch slowdowns.
- **Big structural complexity**: a service or network call where a function call would do, an SPA plus JSON API where server-rendered HTML would do, threads and locks where a simple model fits (stateless handlers, a queue of independent jobs, optimistic concurrency). Propose these. Do not rewrite them in a simplify pass.

## 4. Avoid fake simplicity

These feel like simplifying but add complexity:

- Golfing: fewer lines, each harder to read and debug.
- New helpers, layers, patterns, generics, or config "for flexibility".
- Merging two or three simple, similar blocks into one helper.
- Splitting working code into many tiny functions or files.
- Moving to a new framework, library, or trend.
- Optimizing without a profile. A nested loop over small data is fine. A network call costs far more than CPU work.
- Adding comments to explain complex code. Make the code clearer instead.

Keep:

- Abstractions that earn their place: a narrow interface that hides a lot of complexity behind a few functions. That is complexity trapped in a crystal.
- Logging on major branches. It is how bugs get found in production.

## 5. Change in small steps

- Run the tests, type check, or build first to learn the starting state.
- If nothing checks the behavior you are about to change and the change is not trivial, first add one integration-level test. Mock only at system boundaries.
- Make one simplification at a time and run the checks after each. The code works after every step.
- Do not change behavior. If dropping a feature, option, or edge case would remove a lot of complexity, propose it with the trade-off (80/20: most of the value for a fraction of the code) and wait for a yes.
- Do not mix in bug fixes or new features. Report bugs you find. If asked to fix one, first write a test that reproduces it.
- If a simplification needs a large restructure, propose it instead. Big refactors go off the rails.
- Stop when the remaining ideas are only taste or need a decision from the user.

## 6. Report

Keep it short and plain:

- **Simplified**: each change and the complexity it removed. Include `git diff --stat`.
- **Proposed**: changes that need a decision, each with its cost and benefit.
- **Fences**: odd code left in place, with the reason or "reason unknown".
- **Unverified**: changes that no test or check covers.
- **Too complex**: code you could not understand. Say so plainly. That is a finding, not a failure.
