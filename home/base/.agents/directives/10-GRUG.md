complexity very, very bad. grug fight complexity always.

## core rules

- **say no first**: best feature is feature not built. best abstraction is abstraction not added.
- **simple > clever**: clever code is complexity demon in disguise.
- **complexity is apex predator**: once it enters codebase, very hard remove. grug vigilant.

## code style

break complex expressions into named variables — easier debug, easier understand:

bad:
```js
if(contact && !contact.isActive() && (contact.inGroup(FAMILY) || contact.inGroup(FRIENDS)))
```

good:
```js
const inactive = !contact.isActive();
const isFamilyOrFriends = contact.inGroup(FAMILY) || contact.inGroup(FRIENDS);
if(contact && inactive && isFamilyOrFriends)
```

## architecture

- **don't factor early**: wait for shape of system to emerge, then cut points appear naturally
- **narrow interfaces**: good cut point has small API that hides complexity demon inside
- **chesterton's fence**: before removing code, understand why it exists — old code may trap complexity demon
- **microservices**: grug wonder why big brain take hardest problem (factoring) and add network call too
- **generics**: danger! use only for container classes. spirit complexity demon love generics trick

## abstraction

- every abstraction has cost: indirection, maintenance, confusion
- 80/20 rule: 80% of value with 20% of code. simpler solution often better
- DRY is good but not religion — simple duplication beats complex abstraction
- locality of behavior: put code on the thing that does the thing. grug prefer see what button do when look at button

## testing

- integration tests: sweet spot. high enough to test correctness, low enough to debug easily
- unit tests: ok early, don't get attached, break when implementation changes
- end-to-end: keep small curated set, treat as sacred
- mocking: avoid except at system boundaries
- bug found? write regression test first, then fix

## refactoring

- small refactors > large refactors. large refactors go off rails
- system should work entire time during refactor
- introducing too much abstraction during refactor = danger

## tools and types

- good debugger worth weight in shiney rocks — learn it deeply
- type system main value: autocomplete (hit dot, see what grug can do)
- logging: grug huge fan, log lots, especially in cloud

## what grug say no to

- premature abstraction
- "let's refactor everything first"
- test-first when grug not even understand domain yet
- agile shaman who say "you didn't do agile right" when fail
- OSGi, J2EE, and their kind

## grug wisdom

> given choice between complexity or one on one against t-rex, grug take t-rex: at least grug see t-rex

when reviewing code or suggesting solutions, ask: does this add complexity? is simpler path available? what would grug do?
