# v0.12.5 Sample Feedback Triage

Date: 2026-05-18

All examples in this file are fictional placeholder examples. They are not real tester findings and must not be treated as evidence for tuning.

## Example 1 - Missed Pressure Warning During Cinderfen Watch

Fictional feedback:

> "I was fighting near Watch Road and did not notice the warning until after two units died. I was not sure whether I should retreat or keep pushing."

Category:

- Pressure noticeability issue.
- Secondary: clarity/readability.

Evidence strength:

- Moderate if session includes route, node, combat state, and result.
- Weak if this is the only detail.

Severity:

- S2 moderate.

Priority:

- P1 if repeated by 2+ testers.
- P4 if isolated with missing details.

Recommended action:

- Add to pressure warning aggregation.
- If repeated, open a pressure-warning polish task focused on noticeability/action text.

What not to do:

- Do not change pressure timing from one report.
- Do not add live reinforcement systems.
- Do not assume the warning is fine just because telemetry showed it.

## Example 2 - Tester Thought Greedy Economy Was Weak

Fictional feedback:

> "Greedy Economy felt weak. I had tons of Crowns but timed out on Crossing."

Category:

- Balance concern if route evidence is complete.
- Likely clarity/readability if the player did not convert resources into army pressure.

Evidence strength:

- Weak until army state, production timing, resources, and objectives are recorded.

Severity:

- S2 moderate if repeated.
- S4 deferred/noise if isolated and vague.

Priority:

- P4 watch only unless multiple testers cannot diagnose conversion.

Recommended action:

- Ask whether the tester knew that high resources needed to become army and push timing.
- If repeated, consider Greedy Economy copy/readability, not a buff.

What not to do:

- Do not buff Greedy Economy just because greed is risky.
- Do not extend timers from one timeout.

## Example 3 - Retinue + Training Yard II Too Easy

Fictional feedback:

> "With Retinue + Training Yard II I beat Ashen Outpost and both Cinderfen maps with no losses. I did not need the shrine or road objectives."

Category:

- Balance concern.

Evidence strength:

- Strong if route/save is known and multiple nodes are included.
- Stronger if repeated by multiple testers.

Severity:

- S2 moderate for one detailed report.
- S1 major if 3+ testers report trivialization across Ashen and Cinderfen.

Priority:

- P2 future balance pass if repeated.
- P4 watch only if isolated.

Recommended action:

- Add to Retinue + Training Yard II aggregation.
- Require repeat evidence before tuning.
- If threshold is met, create a tiny tuning proposal with the smallest possible value change.

What not to do:

- Do not nerf because it feels powerful once.
- Do not redesign retinue or Training Yard.

## Example 4 - Ugly Map Visuals

Fictional feedback:

> "The map looks rough and the water/swamp art feels placeholder, but I still knew where to go."

Category:

- Art/UI debt.

Evidence strength:

- Clear visual-overhaul note, not balance evidence.

Severity:

- S4 deferred.

Priority:

- P3 future visual overhaul.

Recommended action:

- Add to visual backlog if useful.
- Do not treat as a current gameplay blocker.

What not to do:

- Do not replace runtime art.
- Do not tune combat around aesthetic dissatisfaction.

## Example 5 - Did Not Understand Cinder Shrine +20 Aether

Fictional feedback:

> "I captured the Cinder Shrine but did not realize it gave a one-time Aether surge. I thought it was just another capture point."

Category:

- Clarity/readability issue.

Evidence strength:

- Moderate from one clear report.
- Strong if repeated.

Severity:

- S2 moderate if it changes route decisions.
- S3 minor if the tester still played correctly.

Priority:

- P1 if repeated because a copy/objective tweak may be small.

Recommended action:

- Add to objective tracker clarity and Cinderfen Crossing fairness aggregation.
- Consider copy/readability before balance.

What not to do:

- Do not change shrine reward value before checking whether text is clear.
- Do not add a new shrine mechanic.

## Example 6 - Lost Ashen Outpost And Blamed Balance

Fictional feedback:

> "Ashen Outpost is unfair. I lost after waiting a long time with lots of resources and then pushing Captain Malrec."

Category:

- Balance concern only after checking route evidence.
- Likely clarity/readability or resource-to-army conversion if high resources were not spent.

Evidence strength:

- Weak without army state, objectives, production timing, and result details.

Severity:

- S2 if detailed and repeated.
- S4 one-off noise if vague.

Priority:

- P4 until repeated.

Recommended action:

- Ask for route/profile, army state, objectives captured, resources, and whether results guidance was understood.
- Compare against existing v0.12.3 evidence where Ashen timeouts often reflect slow conversion rather than unfair early defeat.

What not to do:

- Do not reduce Ashen difficulty from one loss.
- Do not treat a timeout after delayed push as proof of structural unfairness.
