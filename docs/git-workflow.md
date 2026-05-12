# Git Workflow Documentation

## Branching Strategy

```
main
└── production
    └── staging
        └── development
            └── feature/*
```

## Demonstrated Git Operations

### 1. Stash
```bash
# Save work-in-progress without committing
git stash push -m "WIP: feature implementation"
git stash list
git stash pop                    # restore latest stash
git stash apply stash@{0}        # apply specific stash
```

### 2. Cherry-pick
```bash
# Apply a specific commit from another branch
git log --oneline development
git cherry-pick <commit-sha>     # apply specific commit to current branch
git cherry-pick -n <commit-sha>  # cherry-pick without auto-commit
```

### 3. Rebase
```bash
# Rebase development onto main for linear history
git checkout development
git rebase main
git rebase -i HEAD~3             # interactive rebase - squash last 3 commits
```

### 4. Revert
```bash
# Safely undo a commit by creating a new reverse commit
git revert <commit-sha>
git revert HEAD                  # revert last commit
git revert HEAD~3..HEAD          # revert a range of commits
```

### 5. Reset
```bash
# Move branch pointer (use carefully)
git reset --soft HEAD~1          # undo commit, keep staged changes
git reset --mixed HEAD~1         # undo commit, unstage changes (default)
git reset --hard HEAD~1          # undo commit, discard all changes
```

### 6. Restore Deleted Files
```bash
# Recover a file deleted in a previous commit
git log --oneline -- <deleted-file>
git checkout <commit-sha>^ -- <deleted-file>
git restore --source=HEAD~1 <deleted-file>
```

### 7. Graphical Commit History
```bash
git log --oneline --graph --decorate --all
# Example output:
# * abc1234 (HEAD -> development) feat: add OPA policies
# * def5678 feat: SonarQube integration
# * ghi9012 (staging) feat: CI/CD pipeline
# | * jkl3456 (production) fix: deployment security
# |/
# * mno7890 (main) feat: initial Linux setup
```

## Merge Conflict Simulation & Resolution

```bash
# Simulate conflict
git checkout development
echo 'version: dev' >> configs/deployment.yaml
git add . && git commit -m "dev: update version"

git checkout staging
echo 'version: staging' >> configs/deployment.yaml
git add . && git commit -m "staging: update version"

git merge development
# CONFLICT: Auto-merge failed in configs/deployment.yaml

# Resolve manually in editor, then:
git add configs/deployment.yaml
git commit -m "resolve: merge conflict between dev and staging versions"
```

## Commit Convention

| Prefix | Usage |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `ci:` | CI/CD changes |
| `docs:` | Documentation |
| `security:` | Security-related changes |
| `chore:` | Maintenance |
