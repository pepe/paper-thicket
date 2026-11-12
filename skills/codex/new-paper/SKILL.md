---
name: new-paper
description: Create a new article or report repository from the paper-thicket scaffold. Use when the author asks to start a new paper repository or invokes $new-paper.
---

# New paper

Create a fresh repository from the scaffold and initialize its files. The author supplies the paper's content and decides what goes into `main`.

## Prepare

- Use the project containing this skill as the scaffold if it has `THICKET.md` and `init.janet`. Otherwise use `~/code/paper-thicket`. The default destination is `~/papers/<slug>`. Respect paths the author specifies.
- Read the scaffold's `THICKET.md`, `AGENTS.md`, and the five questions in `templates/TELOS.md`. The shared contract is `init.janet` as documented in `THICKET.md`. Follow `THICKET.md` if this skill differs on initializer arguments or behavior. Check that the scaffold is a clean Git checkout with a local `main` branch and that Janet runs. Check that the selected scaffold revision permits a tool to make the initialization commit on `main` with the author's explicit instruction. Verify the Git identity for the new repository before committing. Use the configured Git name as the default bibliographic author.
- Reuse details the author has supplied. Ask together for any missing details that need a decision. Title is required, subtitle is optional, language defaults to `en`, and kind defaults to `article` (`report` is also supported).
- Propose a slug from the title. Transliterate to ASCII, lowercase, drop a leading English article, and join alphanumeric runs with hyphens. For example, “Účel a příjemce” becomes `ucel-a-prijemce`. Keep proposed slugs within 40 characters, breaking at a hyphen when possible. Ask for a replacement if the slug is empty, fails `^[a-z0-9]+(-[a-z0-9]+)*$`, is a reserved directory name on the host, or the destination already exists.
- Show the metadata, absolute destination and scaffold's `main` commit. Include the plan to make one initialization commit on `main` of the new repository under the author's Git identity. Confirm the preview and obtain the author's explicit instruction for that commit if it has not already been given. Once confirmed, invite the author once to answer the five Telos questions using their template wording. The author may answer any number or skip.

## Create

1. Recheck that the confirmed destination is absent and that the scaffold's `main` still matches the confirmed commit. Create the papers root if needed. Use the local clone and remote rename described in `THICKET.md`, selecting `main` explicitly when cloning. Verify the clone's HEAD before running the initializer.
2. Run `janet init.janet` with the confirmed values using the interface in `THICKET.md`. Pass each metadata value as its own argument. If a step fails, report the error and any partial directory. Use the confirmed location only.
3. In the generated `TELOS.md`, replace each answered question's `_Open._` marker with the author's answer verbatim, keeping its original language and line breaks. Use `Written by the author on <ISO date>.` for five answers or `Partly written by the author on <ISO date>.` for fewer. When the author skips, keep the template as generated. Keep `paper.md` at its generated metadata and blank body.
4. Stage the generated files only. With the author's explicit instruction, make one commit on `main` in the fresh clone under the author's existing Git identity. Use the title `Initialize paper: <title>` and the trailer `Drafted-by: Codex new-paper skill`. Verify the commit and that the working tree is clean. If the author chooses to make the commit personally, leave the files staged and report that the commit is pending.

Report the destination, scaffold commit, generated files, initialization commit or pending status, and Telos status. This workflow covers local initialization. Publication and changes to existing papers are separate requests.
