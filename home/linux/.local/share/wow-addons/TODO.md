# TODO

## `wow toons`: show more than names

Today it lists names from the `WTF/Account/<account>/<realm>/<character>` folders.

### What is on disk (checked 2026-11-13)

Of 46 character folders, only 2 have useful data: Shift Poster and Roll Forever, the ones played since the addons were installed. The other 44 have only `AddOns.txt`, a list of enabled addons.

| | Shift Poster | Roll Forever | Other 44 |
|---|---|---|---|
| Level (from item links) | 14 | 13 | — |
| Race | Skyborne | NightElf | — |
| Class | DRUID | HUNTER | — |
| Faction | Alliance | Alliance | — |
| Sex | female (code 3) | female (code 3) | — |
| Realm | PvE | PvE | — |
| Gold | 87s 88c | 34s 15c | — |
| Bags, equipped and bank items | yes | yes | — |
| Pet | — | Cat, level 9 (from KeepOrToss) | — |

### Where it comes from

- **Syndicator**, in the account-wide `WTF/Account/<account>/SavedVariables/Syndicator.lua`. Characters are under `SYNDICATOR_DATA.Characters["Name-Realm"]`:
  - `details`: `race`, `className`, `class` (number), `faction`, `sex`, `realm`, `character`.
  - `money`: copper.
  - Bags, equipped items, bank, mail, auctions and currencies.
  - Ignore the `Warband` entry at the end, which also has a `details` table.
- **Level**: Syndicator stores no level. Each saved item link has the character's level at save time as its 10th field: `item:6948::::::::14:...` means level 14. If the character levelled since the last save, it is out of date.
- **KeepOrToss**, in the character's `SavedVariables/KeepOrToss.lua`: hunter pet name and level (`pet.level`).
- **WTF folder names**: the name and the realm folder (`91`) for every character, nothing else. `character-list-order.txt` has the login-screen order as IDs, without names.

### Plan

- In `wow toons`, print level, race, class, faction and gold for characters Syndicator knows about. Print names only for the rest.
- Match WTF folder names to Syndicator's names by turning `-` into a space (`Shift-Poster` becomes `Shift Poster`).
- Any character gets data the next time you log into it.
