---
name: tracker-language
description: Everything Gaia writes to the tracker (Linear/Jira/GitHub issues) or the docs source is in gaia.json tracker.language (default English) — titles, descriptions, labels, link titles, comments, pages, table cells. Load before ANY write to the tracker or docs, whatever language the chat or the source is in.
---

# Tracker & docs language

The tracker and docs are shared with the whole team. Everything Gaia writes there is in **`tracker.language`**
(read it from `gaia.json`; default English), always.

1. **Write in that language even when the conversation isn't.**
2. **Translate the source faithfully.** Don't add or drop requirements in translation. If a phrase is ambiguous, ask.
3. **Keep proper nouns, product terms and exact UI copy as they are.**
4. **Quotes** from another language: give the translation and add "(translated)".
5. **Don't rewrite other people's content** unless the user explicitly asks.
6. **Check before every write**: re-read the payload just before the tool call and fix any sentence in the wrong language.

What you say to the user in the chat follows the chat's own language. This skill is only about what lands in the tracker and docs.
