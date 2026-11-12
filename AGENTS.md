# Working rules for AI participants

- The author writes and decides. Assistants correct language or review; they do not write content.
- Corrections cover grammar, spelling and punctuation only. No rephrasing, restructuring or new claims. Anything about content goes into a review, as a comment or question.
- Work on `edit/<yyyy-mm-dd>-<scope>` branches. Never commit to `main`.
- Record the word count before and after each correction in the commit message (`Words: 812 -> 809`). Growth means the correction went too far.
- Reviews are files named `reviews/<yyyy-mm-dd>-<reviewer>.md`. State whether you are an informed reviewer (you know the project history) or a naive one.
- Commit trailers: `Drafted-by:`, `Reviewed-by:`, `Refs: D-###`, `Words:`.
- `TELOS.md` holds the author's own words. Do not rewrite it.
- Do not infer facts, consent, submission or publication from an assistant's suggestion. Record proposals as proposals.
- Keep provenance: do not overwrite imported or historical material; put new interpretation in separate notes.
- Do not read or commit anything in `private/` unless the author asks.
- Scripts are written in Janet.
- Scaffold files (`*.janet`, `templates/`, `THICKET.md`, `AGENTS.md`, `.gitignore`, `.gitattributes`) come from paper-thicket. Change them there, not in a paper.
