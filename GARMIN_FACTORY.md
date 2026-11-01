# Garmin Watch Face Factory — AI Agent Instructions

This document provides standing guidance for AI agents working in this repository. Follow the user's explicit instructions first; when requirements are unclear, ask before making potentially disruptive changes.

## Project scope
- Build and maintain Garmin watch faces using Garmin Connect IQ and Monkey C.
- The current project targets Garmin Venu 2. Check `manifest.xml` for the actual device targets and minimum Connect IQ API level before implementing changes.
- Use only APIs supported by the project's declared minimum API level and target device.

## Repository safety
- Never modify `main` directly unless the user explicitly requests it.
- Work in a dedicated branch for each task, using the exact branch name requested by the user.
- Do not merge branches or open pull requests unless requested.
- Preserve existing code, resources, `manifest.xml`, and GitHub Actions workflows unless changes to them are explicitly required and authorized.
- Do not change unrelated files, formatting, or behavior. Prefer the smallest practical diff.
- Never commit secrets, developer signing keys, credentials, generated binaries, or local build artifacts.

## Implementation principles
- Prefer simple, maintainable Monkey C code and existing project structure.
- Preserve working watch-face behavior unless a change is requested.
- Design for the round AMOLED Venu 2 screen: use high contrast, readable typography, and safe margins to avoid clipping.
- Keep drawing efficient, avoid unnecessary allocations and updates, and be mindful of battery consumption.
- Handle potentially unavailable sensor or activity data safely.
- Do not add dependencies, permissions, or new device targets without a clear need and user approval.

## Verification
- Review the exact diff before committing; confirm that only intended files and lines changed.
- Where tooling is available, compile for `venu2` and test in the Connect IQ simulator.
- Do not claim a build, simulator test, or on-device validation succeeded unless it actually ran.
- If testing is unavailable, clearly state what remains unverified.

## Reporting changes
- Summarize what changed and why.
- Identify the branch, changed files, and commit SHA.
- State whether `main` and the GitHub Actions workflow were left untouched.
- Report validation results and any remaining limitations accurately.

## Change discipline
- Inspect the current repository state before editing; do not assume previous chat descriptions match the latest branch.
- Use the user's specified base branch, if given. Otherwise, normally branch from `main`.
- Avoid overwriting concurrent work. Stop and reassess if the target file has changed unexpectedly.
