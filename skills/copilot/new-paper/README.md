# Install the Copilot CLI new-paper skill

From the paper-thicket checkout, run:

```powershell
copilot skill add .\skills\copilot\new-paper\SKILL.md
```

Copilot CLI installs the skill in `~/.copilot/skills/new-paper/`. Confirm it is available with `copilot skill list`, then start a Copilot CLI session and ask it to use the `new-paper` skill. To update the installed copy, run `copilot skill add` again with the revised `SKILL.md`.

Git and Janet must be available when creating a paper. If the scaffold is not at `~/code/paper-thicket`, provide its path when using the skill.
