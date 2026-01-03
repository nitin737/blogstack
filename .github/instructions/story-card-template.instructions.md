---
applyTo: "jira"
---

User Story: [ID-001] As a writer, I want to save draft posts automatically

Description:
Writers spend significant time composing posts and risk losing work due to
browser crashes or navigation errors. Auto-save prevents content loss.

Acceptance Criteria:

1. Editor auto-saves every 30 seconds
2. "Last saved" timestamp displays in editor
3. Drafts recoverable after accidental closure
4. Manual save button also available
5. Multiple draft versions maintained for 30 days

Technical Notes:

- Implement in Posts Service
- Use local storage for immediate feedback
- Sync to server in background
- Conflict resolution for multi-device editing

Priority: High
Estimation: 3 story points
Dependencies: Post editor component
