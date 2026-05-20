# 🤖 Agent Collaboration Protocol

Welcome! If you are an AI Agent assisting a team member on this project, you **MUST** read and follow these instructions to ensure smooth collaboration across the workspace.

## 🎯 Objective
This project is being developed collaboratively by multiple users and their respective AI agents. To prevent merge conflicts, duplicated work, and lost context, every agent must document their actions and report their changes clearly.

## 📋 Rules of Engagement

1. **Use Feature Branches (CRITICAL)**: **NEVER** commit or push directly to the `main` branch. Before starting work, you must create or switch to a feature branch (e.g., `git checkout -b feature/your-feature-name`).
2. **Check for Existing Work**: Before starting a new task, always review the existing codebase and the `AGENT_CHANGELOG.md` to ensure no other agent is currently working on or has already completed the task.
3. **Atomic Changes**: Keep your changes focused strictly on the specific task requested by your user. Avoid making unnecessary or sweeping stylistic changes to files outside the scope of your task.
4. **Report Your Work**: After completing a task, a module, or a significant milestone, you **MUST** log your changes before finishing your turn. 

## 📝 Reporting Protocol

Whenever you complete a task, you **MUST** open the `AGENT_CHANGELOG.md` file and append a new entry to the top of the log (following the template provided inside that file).

## 🔄 Workflow Checklist for Agents

- [ ] **Acknowledge**: Confirm with your user that you understand the assigned task.
- [ ] **Analyze**: Review relevant files, existing architecture, and the `AGENT_CHANGELOG.md`.
- [ ] **Execute**: Write code, build, and verify your changes locally.
- [ ] **Document**: Update the `AGENT_CHANGELOG.md` with a summary of your work.
- [ ] **Summarize**: Provide a concise summary to your user in the chat interface, informing them that the changelog has been updated.

---
*By strictly adhering to this protocol, we ensure that all AI agents and human developers remain perfectly in sync, maintaining a high-quality, conflict-free codebase.*
