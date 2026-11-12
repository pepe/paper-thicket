---
name: "new-paper"
description: "Start a new paper in ~/papers by cloning the paper-thicket scaffold, filling its templates with init.janet, softly inviting the Telos, and making one initial commit. Use for /new-paper."
---

# New paper

A new paper is a clone of the current `paper-thicket` scaffold plus one commit that fills in its templates.
This skill runs that conversation. It writes no paper content: no headings, no outline, no text.

## Settings

- Scaffold: `~/code/paper-thicket` (on Windows, `~` is the user's home).
- Papers root: `~/papers`.

`THICKET.md` in the scaffold documents `init.janet`. If its interface differs from what is described here, follow `THICKET.md`.

## Steps

### 0. Check

Stop and say what is missing if any of these fails:

- the scaffold exists, is a Git repository, and has a clean working tree;
- `janet` runs;
- `git config user.name` and `git config user.email` are set. Do not set them yourself.

### 1. Ask

Ask in one message:

- title (required);
- subtitle (optional);
- language (default `en`);
- kind: `article` or `report` (default `article`).

The author is `git config user.name`.

### 2. Propose

Propose a slug from the title:

1. Transliterate to ASCII: Czech diacritics to base letters (á→a, č→c, ď→d, é/ě→e, í→i, ň→n, ó→o, ř→r, š→s, ť→t, ú/ů→u, ý→y, ž→z), other accents likewise.
2. Lowercase. Drop a leading "the", "a" or "an".
3. Replace every run of other characters with one hyphen; trim hyphens at both ends.
4. If longer than 40 characters, cut at the last hyphen before 40.

Examples: "The Work of Purpose" → `work-of-purpose`; "Účel a příjemce" → `ucel-a-prijemce`.

Show one summary for confirmation:

- title, subtitle, language, kind, author;
- slug and path `~/papers/<slug>`;
- scaffold version: `git -C ~/code/paper-thicket rev-parse --short HEAD`.

The author may change anything. If `~/papers/<slug>` already exists, say so and propose another slug; never write into an existing folder. If `~/papers` does not exist, it is created.

### 3. Telos (ask softly, once)

After the summary is confirmed, invite the author to write the paper's Telos now. For example:

> Before I create the paper: would you like to write its Telos now? Five short answers; a sentence each is enough. You can also skip and write it later.

The questions, exactly as the headings in `TELOS.md`:

1. Who should be better off because this paper exists?
2. In what respect: what is their condition now, and what should it be after reading?
3. Why is that change worth it?
4. Who else is affected, and does anyone lose something?
5. And you: what should writing it change for you?

Rules:

- Record the answers verbatim, in the language they were written in. Do not rephrase, expand, translate, polish or summarize them.
- Correct spelling or grammar only if the author asks, and show each change.
- Do not suggest answers or offer examples of answers.
- Ask once. If the author skips, do not insist; mention it once in the final report.

### 4. Create

1. `git clone ~/code/paper-thicket ~/papers/<slug>`
2. In the new folder: `git remote rename origin thicket`
3. In the new folder: `janet init.janet --title "…" [--subtitle "…"] --slug <slug> --lang <language> --kind <kind> --author "<author>"`. If it exits non-zero, stop and show its output.
4. If the author answered any Telos question, edit `TELOS.md`:
   - under each answered heading, replace `_Open._` with the answer, verbatim;
   - replace the line `Open. To be written by the author.` with `Written by the author on <ISO date>.` if all five are answered, or `Partly written by the author on <ISO date>.` otherwise;
   - change nothing else.
5. `git add -A`, then one commit with the author's existing identity:

   ```
   Initialize paper: <title>

   Drafted-by: new-paper skill
   ```

### 5. Report

Report only:

- the path;
- the scaffold version it started from;
- the files `init.janet` wrote;
- the commit hash;
- the Telos status: written, partly written, or not yet written.

Do not suggest content, structure, venues or next steps for the paper.

## Rules

- Never overwrite an existing file or folder.
- Write no paper content.
- Do not modify `paper-thicket` itself.
- Do not push, add other remotes, create a Zenodo record or `CITATION.cff`, or set up CI or hooks.
- Do not change Git configuration.