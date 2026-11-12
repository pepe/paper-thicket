# Install the Codex new-paper skill

1. Copy this `new-paper` folder to `~/.agents/skills/new-paper/` to use it across projects, or to `.agents/skills/new-paper/` in a project checkout to use it there. The destination should contain `SKILL.md` directly. See [OpenAI's skill installation guide](https://developers.openai.com/api/reference/cli#use-the-cli-from-a-coding-agent).
2. Start a new Codex session and invoke `$new-paper`. The skill uses `~/code/paper-thicket` by default when run outside the scaffold checkout. Give Codex the scaffold path if yours differs.

Git and Janet must be available. To update a manually installed copy, copy the revised `SKILL.md` to the same destination.
