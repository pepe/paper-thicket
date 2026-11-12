# paper-thicket

The scaffold for papers.
A new paper is a clone of the current version of this repository, followed by one commit that fills in the templates.
Scripts are written in Janet; nothing beyond Janet's standard library and `git` is needed.

## Layout

| Path | Contents |
|---|---|
| `THICKET.md` | This file: what the scaffold is and how a paper is made from it |
| `AGENTS.md` | Rules for AI participants, inherited by every paper |
| `.gitignore`, `.gitattributes` | Git settings, inherited by every paper |
| `init.janet` | Fills the templates into a new paper |
| `words.janet` | Word count of a Markdown file: `janet words.janet paper.md` |
| `reading-edition.janet` | Reading edition PDF: `janet reading-edition.janet paper.md build/<name>.pdf` |
| `templates/` | The files `init.janet` renders into the paper's root |
| `skills/` | The `new-paper` skill, one folder per agent |

Bibliographic metadata (title, subtitle, author, date, language, bibliography) goes in the YAML front matter of `paper.md`.
Workflow state (slug, kind, status, scaffold version, venue, submission and publication records) goes in `paper.jdn`.
Neither file repeats the other's fields.

## The naming rule

No scaffold file may share a path with a file that `init.janet` creates.
That is why the scaffold describes itself here and not in `README.md`.
A paper can then take tool updates with `git pull thicket main` without conflicts.
Papers keep `templates/`; do not delete it.

## Making a paper

The `/new-paper` skill does this. By hand:

1. `git clone ~/code/paper-thicket ~/papers/<slug>`
2. In the new folder: `git remote rename origin thicket`
3. In the new folder:

   ```
   janet init.janet --title "…" [--subtitle "…"] --slug <slug> --lang <language> --kind article|report --author "…" [--date YYYY-MM-DD]
   ```

   - `--slug` matches `^[a-z0-9]+(-[a-z0-9]+)*$`.
   - `--date` defaults to today, local time.
   - It refuses, writing nothing, if any target already exists.
   - It renders every file in `templates/` to the same path in the root, creates the empty folders `private/` and `build/`, and prints the files it wrote.
   - It does not commit and does not touch Git configuration or remotes.
4. One commit: `Initialize paper: <title>`.

Only the author commits to `main`, or a tool acting on his explicit instruction under his identity, with `Drafted-by:` naming the tool (for example, the initialization commit made by `/new-paper`).

Placeholders in templates: `{{title}}`, `{{subtitle}}`, `{{slug}}`, `{{author}}`, `{{language}}`, `{{kind}}`, `{{date}}`, `{{date_long}}` (`12 November 2026`) and `{{thicket_version}}` (the scaffold's commit).
`{{name}}` inserts plain text; `{{name|q}}` inserts a double-quoted string, valid both in YAML and in JDN.
An empty value drops the whole line, except for `{{name|q}}` in `.jdn` files, which renders as `nil`.

## Installing the skills

The `new-paper` skill runs the dialogue for making a paper.
Each agent has its own version:

- **Claude Code:** copy `skills/claude/new-paper/` to `~/.claude/skills/new-paper/`.
- **Codex:** follow the installation notes in `skills/codex/new-paper/`.
- **Copilot CLI:** follow the installation notes in `skills/copilot/new-paper/`.

The contract between the skills and the scaffold is `init.janet` as documented here.
The skills are only the dialogue on top of it; if they disagree, this file wins.

The copies in this repository are for others.
The author's own copies are managed in his accounts.
When a skill changes, both copies are updated.

## Updates

A paper takes scaffold updates with `git pull thicket main`.
`:thicket-version` in `paper.jdn` and the Scaffold row in `README.md` record the scaffold version the paper was initialized from; they are not updated on later pulls.
Git history records each scaffold update the paper has taken.
Templates change only here; existing papers are not regenerated.
