# Social Identities Flashcard Site: Build Plan

A Quizlet-style study site for the Social Identities midterm (testing center, Oct 22), built with plain HTML, CSS, and JavaScript (no build step), versioned in git, with progress saved in the browser. The card content already exists in `data/` (444 cards, 9 decks). This plan covers the app that studies them.

## 1. Goals

- Study short cards (1 to 3 sentences) on **theories, key studies, and the specific data** in them.
- Rate every card ("know it" / "still learning") and have the site remember it.
- Sort and filter cards by how well you know them; star cards to review again.
- Adaptive **Learn mode**, and a **Match mode** for "which theory is this?" multiple choice.
- Easy to extend after the midterm: more decks, more modes, later a backend.

**Out of scope for v1:** accounts/login, cross-device sync, timed Match game, written Test mode. The data model leaves room for all of these.

## 2. Tech decisions (settled)

| Decision | Choice | Why |
|---|---|---|
| Framework | None. Vanilla JS using ES modules | No build step, easy to read, easy to host |
| Styling | One `styles.css` using CSS variables | Light/dark theme with minimal effort |
| Persistence | `localStorage` behind a small `store.js` | Zero backend; can later be swapped for an API |
| Card data | JSON files in `/data` | Diffable in git, easy to regenerate or hand-edit |
| Hosting | GitHub Pages (free) | Static site, deploys from the repo |

**Gotcha:** ES modules and `fetch()` do not work from `file://`. Run a local server: `python3 -m http.server 8000` or the VS Code "Live Server" extension.

**Risk:** `localStorage` is wiped when browser data is cleared and is per-browser. v1 must include **Export / Import progress** (JSON file).

## 3. Repo structure

```
flashcards/
├── index.html
├── css/styles.css
├── js/
│   ├── app.js            # bootstraps, hash router, view switching
│   ├── store.js          # localStorage read/write, export/import
│   ├── scheduler.js      # mastery + next-review logic (pure functions)
│   ├── learn.js          # Learn-mode session engine (pure functions)
│   ├── match.js          # Match-mode question builder (pure functions)
│   ├── views/            # home.js, deck.js, flip.js, learn.js, match.js
│   └── util.js
├── data/                 # GENERATED: decks.json + one JSON file per deck
├── content/cards/        # SOURCE OF TRUTH: editable card text files
├── scripts/build_decks.py
├── tests/
├── PLAN.md
└── CLAUDE.md
```

## 4. Content (already built)

Cards are authored as text lines in `content/cards/*.txt`:

```
Front ||| Back ||| Source ||| tag1,tag2
```

`python3 scripts/build_decks.py content/cards data` turns them into the JSON the app loads and checks card length and duplicate fronts. **Edit the text files, then rebuild.** Do not hand-edit `data/*.json`.

| Deck id | Cards | Covers |
|---|---|---|
| `identity` | 51 | What is identity; identity theory vs. social identity theory; self-categorization theory (Hogg et al., 1995) |
| `intergroup` | 58 | Realistic Group Conflict Theory, Tajfel & Turner (1979), minimal groups, Robbers Cave, intergroup contact |
| `belonging` | 42 | Baumeister & Leary (1995), ostracism, Seidman Facebook study, Big Five |
| `cse` | 31 | Collective self-esteem and Crocker & Luhtanen (1990) |
| `culture` | 52 | Salvador lecture, Kitayama & Salvador (2024): self-construal, varieties of interdependence, cultural dimensions |
| `race` | 45 | Racial vs. ethnic identity, Rogers et al. (2012), Rhodes (2013) |
| `multiracial` | 61 | Gaither (2015), Wilkins et al. (2010), Yampolsky et al. (2021) |
| `language` | 41 | Hansen & Liu (1997), DeJesus accents, bilingual infant studies |
| `gender` | 63 | Gender schema theory, Coyle & Liben, Olson et al., Edwards & Jones, Latu et al. |

**Card schema:**

```json
{
  "id": "cse-021",
  "term": "C&L 1990: how were groups formed?",
  "definition": "Minimal intergroup paradigm: each participant drew a slip labeled A or B...",
  "topic": "Crocker & Luhtanen (1990) study",
  "source": "Crocker & Luhtanen 1990",
  "tags": ["study"]
}
```

- `id` is **permanent**. Progress is keyed by it. Never renumber or reuse ids. To avoid renumbering problems when adding cards, append new lines at the **end** of a deck's text file (ids are assigned in order).
- `tags` are what the app filters on: `theory`, `def`, `study`, `data`, `example`, `discussion`, and `match` (a card whose back is a theory/concept name that is a good multiple-choice target).
- `source` tells you where to look when a card seems off (a reading or a slide deck).

**Known content gaps** (not in the material available when the cards were written):

- The three YouTube videos could not be read. Add cards from their transcripts into new text files.
- Your slides list "Self-Affirmation Theory" and Cecilia Mo (2015) as titles only, with no definitions, so there are no cards on them. Add them from your lecture notes.
- The Albuja et al. (2019) slide shows only the sample, not the findings.

## 5. Progress model

```json
{
  "version": 1,
  "cards": {
    "cse-021": { "box": 2, "seen": 6, "correct": 4, "streak": 2,
                 "lastSeen": "2026-10-05T16:30:00Z", "due": "2026-10-07T16:30:00Z",
                 "starred": true }
  },
  "settings": { "theme": "dark", "flipSides": false, "shuffle": true }
}
```

Keep a `version` field from day one so future schema changes can migrate old saves.

## 6. Mastery and scheduling

Simple **Leitner boxes** (0 to 4). New cards start in box 0. "Know it" moves up one box. "Still learning" drops to box 0 (setting: or down one). Intervals per box: 0 / 1 / 2 / 4 / 7 days. Mastery labels: **New** (never seen), **Learning** (box 0 to 1), **Reviewing** (box 2 to 3), **Mastered** (box 4). Keep `scheduler.js` as pure functions for easy unit tests.

## 7. Features by milestone

Because the midterm is the deadline, ship in this order.

**M1: Skeleton and data.** `index.html`, hash router (`#/`, `#/deck/<id>`, `#/flip/<id>`, `#/learn/<id>`), load `decks.json` and deck files, home view with deck list and card counts.

**M2: Flip-card study.** Click or Space to flip; `→`/`K` = Know it, `←`/`L` = Still learning, `S` = star. Shuffle and "flip sides" toggles. Session progress bar and an end-of-session summary with a "study missed cards" button. Every rating saves immediately.

**M3: Deck view (sort / filter / review pile).** List of all cards with mastery badges. Sort by mastery (weakest first), most missed, least recently seen, original order. Filter by mastery, starred only, topic, **tag** (e.g., only `study` and `data` cards, or only `theory`), and due today. Search box. "Study these cards" launches a session from any filter. Stacked bar of mastery counts per deck.

*After M3 you have the core Quizlet loop. Everything below is a bonus.*

**M4: Learn mode (adaptive).** Rounds of about 7 cards weighted toward weak/due cards. Multiple choice for new cards (distractors from the same `topic` or deck), self-graded recall for seen cards. A card retires after 2 correct in a row; wrong answers re-queue a few positions later.

**M5: Match mode ("which theory is this?").** Uses `match`-tagged cards in reverse: show the description, choose the theory/concept from 4 options drawn from other `match` cards in the same deck. Targets the multiple-choice style on your midterm.

**M6: Polish and safety.** Export/Import progress, per-deck reset, light/dark theme, mobile layout, keyboard help overlay, accessibility.

## 8. Testing

- Unit tests for `scheduler.js`, `learn.js`, and `match.js` (Node's built-in test runner or Vitest).
- Manual checklist per milestone: rate a card, refresh, confirm it persisted; export, clear storage, import, confirm restored.
- Data check: `python3 scripts/build_decks.py content/cards data` must report "No problems". Lines flagged as "long" that are only numbered lists (1) 2) 3)) are fine.

## 9. Deployment

Push to GitHub and enable Pages. Use relative URLs (`./data/...`). Progress is tied to the site origin, so `localhost` and the Pages URL have separate progress. Use Export/Import to move between them.

## 10. Working in VS Code with Claude

Put `CLAUDE.md` (included) in the repo root. Suggested prompts in order:

1. "Read PLAN.md and CLAUDE.md. Implement M1 only, then stop."
2. "Implement M2."
3. Continue milestone by milestone, committing after each.

## 11. Remaining decisions

- Wrong-answer penalty: drop to box 0 (recommended, simplest) or one box down.
- Learn mode answers: multiple choice for new cards and self-graded recall for seen cards (recommended).
- Whether to add an "Everything" view that combines all decks (recommended, no extra data needed).
