---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree **one question at a time**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Pick the single highest-leverage question from the frontier, ask only that question, then wait for the user's answer before asking another.

Use the built-in `AskUserQuestion` tool whenever it is available. Put exactly one question in each tool call. Include 2-3 mutually exclusive answer choices when the decision has obvious options, mark your recommended option as recommended, and keep each choice short. If the question is open-ended or the tool is not available in the current environment, ask exactly one concise plain-text question instead.

Format a plain-text fallback question like so:

```
❓ **<question title>**: <question body>

➡️ Recommended: <your recommended answer>
```

Never ask a long numbered list of questions. Never ask the whole frontier at once. If several frontier questions are available, keep the remaining ones internal until the current question is answered.

Each user answer reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier after every answer, then ask the next single highest-leverage question. A question whose answer depends on another question still open belongs to a later turn, not the current one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. A running exploration is an unsettled prerequisite, so questions downstream of it must wait for the sub-agent to report. If other frontier questions remain available, still ask only one of them at a time. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
