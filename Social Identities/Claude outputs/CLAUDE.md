# Flashcards project

Quizlet-style study site for a Social Identities midterm. See PLAN.md for the milestones.

## Rules
- Vanilla JS (ES modules), HTML, CSS. No frameworks, bundlers, or build step.
- Card ids are permanent. Progress in localStorage is keyed by card id. Never renumber, reuse, or delete ids.
- `content/cards/*.txt` is the source of truth for cards. `data/*.json` is generated: run
  `python3 scripts/build_decks.py content/cards data` after editing card text. Never hand-edit `data/*.json`.
  Add new cards at the END of a deck's text file so existing ids do not shift.
- All localStorage access goes through `js/store.js`. Keep `scheduler.js`, `learn.js`, and `match.js` as pure functions with unit tests.
- Dev server: `python3 -m http.server 8000` (ES modules do not work from file://).
- Cards must stay short: answers of 1 to 3 sentences. Do not paste long paragraphs into cards.
- Work milestone by milestone from PLAN.md and commit after each one.
