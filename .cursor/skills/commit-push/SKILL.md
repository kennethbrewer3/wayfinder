---
name: commit-push
description: >-
  Stage all changes, create a git commit, and push to the remote tracking
  branch. Use when the user runs /commit-push or asks to add all, commit, and
  push.
disable-model-invocation: true
---

# Git add all, commit, and push

End-to-end publish of the current working tree. Treat the user's request as
explicit approval to commit **and** push.

## Preconditions

1. Run in parallel:
   - `git status`
   - `git diff` and `git diff --cached`
   - `git log -8 --oneline` (match commit message style)
2. If there is nothing to commit and the branch is not ahead of remote, stop
   and say so. Do not create an empty commit.
3. If the working tree is clean but the branch is ahead, skip commit and only
   push.
4. Never update git config, never use `--no-verify` / `--no-gpg-sign` unless
   the user explicitly asks, never force-push to `main`/`master`.

## Preflight (when required)

If workspace rules require format/analyze before commit or push (for example
Wayfinder Dart: `dart format` + `dart analyze --fatal-infos` on touched
packages), run that on the **final** diff now. Fix issues, then continue.
Do not rely on an earlier format from the same session.

Warn and exclude secrets (`.env`, credentials, private keys) even with
`git add -A`. Prefer leaving them unstaged and telling the user.

## Stage

```bash
git add -A
```

Re-check `git status`. If staging would include secrets the user did not
explicitly ask to commit, unstage those files and warn.

## Commit

Draft a concise 1–2 sentence message focused on **why**, matching recent
`git log` style (prefer complete sentences; no conventional-commit prefix
unless the repo already uses them).

Commit with a HEREDOC (never `-i` / interactive git):

```bash
git commit -m "$(cat <<'EOF'
Commit message here.

EOF
)"
```

If a pre-commit hook fails: fix the issue and create a **new** commit (do not
amend unless the amend rules below all apply).

### Amend only when all are true

1. User explicitly requested amend, **or** the commit succeeded but a hook
   modified files that must be included
2. `HEAD` was created by you in this conversation
3. Commit has **not** been pushed (`git status` shows branch ahead)

## Push

```bash
git push -u origin HEAD
```

Use full permissions for push. If Auto-review blocks a push to a protected
branch (e.g. `main`), retry the **exact** same command with
`request_smart_mode_approval` and the provided block reason so the user can
approve.

After push, run `git status -sb` and report the commit hash / remote result
briefly.

## Do not

- Create a PR unless the user also asks for one
- Push with `--force` / `--force-with-lease` unless explicitly requested
- Skip hooks unless explicitly requested
