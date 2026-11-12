# {{title}}
{{subtitle}}

| | |
|---|---|
| Slug | `{{slug}}` |
| Author | {{author}} |
| Kind | {{kind}} |
| Language | {{language}} |
| Status | see `paper.jdn` |
| Created | {{date}} |
| Scaffold | paper-thicket `{{thicket_version}}` |

## Layout

| Path | Contents |
|---|---|
| `paper.md` | The paper, one sentence per line. Its front matter holds the bibliographic metadata |
| `TELOS.md` | Whose condition this paper should change, and why |
| `ledger.md` | Decisions, with stable IDs (`D-001`) |
| `references.bib` | Bibliography (BibTeX); cite as `[@key]` |
| `paper.jdn` | Workflow state: status, scaffold version, submission and publication records |
| `figures/` | Figures and their sources |
| `reviews/` | Reviews, one file each |
| `readings/` | Reading editions worth keeping |
| `private/` | Not in Git: chat exports, participant data |
| `build/` | Not in Git: generated output |
| `*.janet`, `templates/`, `THICKET.md`, `AGENTS.md` | Scaffold from paper-thicket; update with `git pull thicket main` |

## Workflow

1. The author writes `paper.md` and decides. Only the author commits to `main`, or a tool acting on his explicit instruction under his identity, with `Drafted-by:` naming the tool (for example, the initialization commit made by `/new-paper`).
2. Language corrections come on `edit/<yyyy-mm-dd>-<scope>` branches: grammar, spelling and punctuation only.
3. Reviews are files in `reviews/`. They never edit the paper.
4. Commits carry trailers: `Words:`, `Drafted-by:`, `Reviewed-by:`, `Refs:`.
5. Versions are Git tags (`v0.1`, ...). When tagging, update `draft` and `date` in the front matter of `paper.md`.
6. Status values: `concept`, `draft`, `revision`, `ready-for-submission`, `submitted`, `accepted`, `published`, `withdrawn`. Record the status in `paper.jdn`, and change it only on an actual event or author decision.
