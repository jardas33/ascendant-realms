# v0.13.1a Statistical Usefulness Review

Date: 2026-05-18

Evidence source: deterministic automated scenario-lab runs only. No human feedback exists in this pass.

## Are The Five Iterations Distinct?

No. The five default extended iterations are deterministic reruns of the same scripted simulator matrix.

This is useful, but only for a specific purpose:

- It confirms the lab can repeat the same evidence shape without drift.
- It makes stale-output and report-consistency checks easier.
- It strengthens confidence that generated dashboards are deterministic.

It does not create:

- random samples
- independent player populations
- statistical confidence intervals
- human route-feel evidence
- proof of warning noticeability

## How To Read Averages, Medians, And Spreads

The profile averages and medians are computed correctly across the repeated metric rows, but their meaning is limited.

Because each iteration repeats the same deterministic rows, profile-level spread is mostly the spread across:

- nodes
- scripts
- Stronghold profiles
- route slices included in the profile definition

It is not random variance between independent attempts.

The new `uniqueDerivedMetricFingerprints` field makes that explicit. Current expected values:

- 1,775 derived rows.
- 355 unique deterministic metric fingerprints.
- Each fingerprint appears once per iteration in the default 5-iteration batch.

## Watchpoint Threshold Usefulness

The thresholds are useful as regression triage, not as direct tuning triggers.

Useful signals:

- repeated Safe Beginner failure would be high-priority
- objective completion collapse would be high-priority
- resource starvation across non-victory rows would indicate future economy review
- Retinue + Training Yard II sweeping the full suite would raise the dominance signal

Limits:

- pressure warning counts do not prove a human noticed the warning
- Greedy Economy timeout rows do not prove the economy is weak
- Fast Army speed does not prove trivialization
- Retinue success does not prove it feels mandatory

## Confidence Review

The current confidence labels are honest enough for automation:

- High confidence means enough deterministic rows matched the profile.
- It does not mean high human confidence.
- It does not mean balance confidence.
- Low or medium row counts should remain human-test priorities if the watchpoint is important.

## v0.13.1a Correction

Reports now say deterministic repeatability rather than implying stochastic evidence. The verifier checks the deterministic fingerprint count so future changes cannot accidentally claim repeated rows are varied without changing the evidence model.
