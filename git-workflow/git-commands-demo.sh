#!/bin/bash
# =============================================================================
# Git Workflow Demonstration Script
# DevOps CI/CD Security Platform
# =============================================================================

set -e

echo "========================================="
echo " Git Workflow Demonstration"
echo "========================================="

# Assumes this is run inside the cloned repository
# git clone https://github.com/rajubandar/devops-cicd-security-platform.git
# cd devops-cicd-security-platform

# -----------------------------------------------------------------------------
# 1. Initialize and configure
# -----------------------------------------------------------------------------
echo "[1] Configuring Git..."
git config user.name  "DevOps Engineer"
git config user.email "devops@company.com"

# -----------------------------------------------------------------------------
# 2. Create branches
# -----------------------------------------------------------------------------
echo "[2] Creating branches..."
git checkout -b development  2>/dev/null || git checkout development
git checkout -b staging      2>/dev/null || git checkout staging
git checkout -b production   2>/dev/null || git checkout production
git checkout main

echo "  Branches created: development, staging, production"

# -----------------------------------------------------------------------------
# 3. STASH demonstration
# -----------------------------------------------------------------------------
echo "[3] Demonstrating git stash..."

git checkout development
echo "# WIP: Temporary change" >> configs/deployment.yaml
git stash                         # Stash the change
git stash list                    # Show stash list
git stash pop                     # Restore stashed change
git checkout configs/deployment.yaml  # Clean up

echo "  Stash demo complete"

# -----------------------------------------------------------------------------
# 4. Commit for each section
# -----------------------------------------------------------------------------
echo "[4] Creating section commits..."

# Linux setup commit
git add linux-setup/
git commit -m "feat: Linux administration and user management setup" 2>/dev/null || echo "Nothing to commit"

# Git workflow commit
git add git-workflow/
git commit -m "feat: Git workflow and branching strategy documentation" 2>/dev/null || echo "Nothing to commit"

# CI/CD commit
git add .github/
git commit -m "feat: CI/CD pipeline with GitHub Actions" 2>/dev/null || echo "Nothing to commit"

# SonarQube commit
git add sonarqube/
git commit -m "feat: SonarQube integration and quality gates" 2>/dev/null || echo "Nothing to commit"

# OPA commit
git add policies/
git commit -m "feat: OPA policy enforcement for deployments" 2>/dev/null || echo "Nothing to commit"

# -----------------------------------------------------------------------------
# 5. CHERRY-PICK demonstration
# -----------------------------------------------------------------------------
echo "[5] Demonstrating cherry-pick..."

# Get last commit SHA
LAST_COMMIT=$(git log --format='%H' -n 1)
echo "  Cherry-pick target: $LAST_COMMIT"

git checkout staging
git cherry-pick $LAST_COMMIT --no-commit 2>/dev/null || echo "Cherry-pick applied (or no change)"
git reset HEAD . 2>/dev/null
git checkout . 2>/dev/null
git checkout development

echo "  Cherry-pick demo complete"

# -----------------------------------------------------------------------------
# 6. REBASE demonstration
# -----------------------------------------------------------------------------
echo "[6] Demonstrating git rebase..."

git checkout staging
# Simulate rebase onto main
# git rebase main
git checkout development
echo "  Rebase demo complete (run: git checkout staging && git rebase main)"

# -----------------------------------------------------------------------------
# 7. SIMULATE Merge Conflict and Resolve
# -----------------------------------------------------------------------------
echo "[7] Simulating merge conflict..."

# Branch A: feature-a
git checkout -b feature-a 2>/dev/null || git checkout feature-a
echo "Feature A content" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "feat: Feature A changes" 2>/dev/null || echo "No changes"

# Branch B: feature-b (conflicting change)
git checkout main
git checkout -b feature-b 2>/dev/null || git checkout feature-b
echo "Feature B content" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "feat: Feature B changes" 2>/dev/null || echo "No changes"

# Merge would produce conflict; resolve manually:
# git merge feature-a
# <<< HEAD (feature-b): Feature B content
# === 
# >>> feature-a: Feature A content
# Resolution:
echo "Merged: Feature A and B" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "fix: Resolve merge conflict between feature-a and feature-b" 2>/dev/null || echo "No changes"

git checkout development
echo "  Merge conflict simulation complete"

# -----------------------------------------------------------------------------
# 8. REVERT and RESET demonstration
# -----------------------------------------------------------------------------
echo "[8] Demonstrating revert and reset..."

# Revert safely undoes a commit by creating a new one
echo "  git revert HEAD    # Safe undo (creates new commit)"
echo "  git reset --hard HEAD~1  # Destructive undo (removes commit)"

# -----------------------------------------------------------------------------
# 9. RESTORE deleted file
# -----------------------------------------------------------------------------
echo "[9] Demonstrating file restore..."
echo "  # If a file was accidentally deleted:"
echo "  git checkout HEAD -- configs/deployment.yaml"
echo "  # Or using restore:"
echo "  git restore configs/deployment.yaml"

# -----------------------------------------------------------------------------
# 10. Graphical commit history
# -----------------------------------------------------------------------------
echo "[10] Git commit history (graphical):"
git log --oneline --graph --all --decorate | head -30

echo ""
echo "========================================="
echo " Git Workflow Demo Complete!"
echo "========================================="
