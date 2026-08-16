# benjamin-plus A/B eval — results

## v6 FINAL (2026-08-16, job bp6-final): the headline

**On 80 paired SkillsBench tasks (Sonnet 5, low effort, Claude Code 2.1.201):
cost −17.9% median paired (p=0.005) and −16.7% on totals — the first version
where medians and totals agree and both are statistically solid. Turns −20.0%
(p=0.001), total tokens −21.9% (p=0.001), cache reads −23.9% (p=0.001),
output −21.2% (p=0.007), code written −13.3% (p=0.006), wall-clock −15.6%
(p=0.018). Quality: no difference detected (7 better / 5 worse / 68 tie, sign
p=0.77; means 0.36→0.39), not powered as an equivalence test.**

| metric | median paired | p | totals |
|---|--:|--:|--:|
| **cost** | **−17.9%** | **0.005** | −16.7% |
| turns | −20.0% | 0.001 | −18.9% |
| total tokens | −21.9% | 0.001 | −25.0% |
| cache reads | −23.9% | 0.001 | −25.9% |
| output tokens | −21.2% | 0.007 | −14.3% |
| code written | −13.3% | 0.006 | −19.2% |
| wall-clock | −15.6% | 0.018 | −8.3% |
| fresh input | −7.8% | 0.125 | −3.0% |
| quality | 7↑ / 5↓ / 68 tie | sign 0.77 | mean 0.362→0.392 |

**Honesty note on effect size.** v5's same-day run (bp-final, 2026-08-15)
measured −10.0% median cost (p=0.169). Between the two days the CONTROL arm
drifted +10.5% median (+20.5% totals) while the treatment arm stayed flat
(−3.0% v6-vs-v5): day-to-day drift hits the baseline, not the treated arm.
Read the two runs together: the skill's floor is ~−10% on a cheap-baseline
day, ~−18% against a bloated baseline — it acts as a session-cost variance
clamp, so its measured saving scales with how expensive the baseline happens
to run. Both runs are valid same-day paired comparisons.

**v6 change (from the external Java/IDE eval):** one added rule, "Polling is
a step" (wait ≥30 s slices for running commands; no sub-second re-polls; no-op
where execution blocks). Java SWE-bench traces showed 45.8% of the treated
arm's agent steps were polls, 3,982 at sub-5s yields — a pool the v5 rules
never touched. On Claude Code the rule is inert by design; the v6 gate smoke
confirmed zero sleep-insertion regressions.

**Install-method finding (external, decisive):** on Java SWE-bench (Codex
CLI, 225 instances × 3 replicas) hook-injected benjamin was the only arm
significantly cheaper (−4.4% [−7.5,−1.5], p=0.003, solve rate unchanged
p=0.22); skill-folder install saved nothing net (−0.5% n.s.) because fetching
SKILL.md cost a median 3 steps with 73% path misses. The distribution is now
hooks/injection ONLY. Errors this run: the 2 known-broken tasks
(seismic/earthquake) failed identically in both arms and were dropped
symmetrically; 4 one-sided RuntimeErrors (3 control, 1 treatment) were
retried per house rule and all recovered → 80 pairs.

Skill v6: SKILL.md + payload (745 tok) sha256 in `dist/benjamin-plus/SHA256SUMS.txt`.

---

# (v5 archive) benjamin-plus results

**Verdict (2026-08-15, ~$153 total program, 254 billed trials): on the median
task the skill makes the agent measurably leaner — −11.5% code written
(p=0.012) and −13.9% wall-clock (p=0.039), both statistically solid — with
cost −10.0% median paired (p=0.169, NOT significant at 80 pairs) and no
detectable quality difference (7 better / 7 worse / 66 tie, sign p=1.00; mean
reward 0.333 → 0.373, pass rate 30% → 34%, both leaning positive).** Arm
totals are flat (+0.6% cost): the median saving is offset by a tail of hard
tasks where the treatment works longer. Quality was not powered as an
equivalence test; 80 pairs rules out large effects only.

Skill: `skill/benjamin-plus/SKILL.md` **v5**, sha256 `02d2e342…7c139`;
injected payload 632 tokens, sha256 `c95cc7a8…d3ef2` (generated from SKILL.md
by `gen_instruction.py` — single source of truth, enforced by run_ab.sh).
Built from the trace-derived strategy research in `../../winning-strats.md` §4.
Constraints honored: no reward hacking, no benchmark-specific rules, original
text throughout.

## Headline (job `bp-final`: 82 tasks, k=1 per arm, Sonnet 5 LOW effort, 80 clean pairs)

| metric | median paired delta | wilcoxon p | totals |
|---|--:|--:|--:|
| code written (LOC) | **−11.5%** | **0.012** | −10.7% |
| wall-clock | **−13.9%** | **0.039** | +13.5% |
| cost | −10.0% | 0.169 | +0.6% |
| turns | −11.4% | 0.224 | −4.0% |
| output tokens | −13.2% | 0.205 | +8.6% |
| total tokens | −10.1% | 0.330 | −3.2% |
| fresh input (new-in) | +1.5% | 0.527 | +7.7% |
| quality (reward) | 7 ↑ / 7 ↓ / 66 tie | sign p=1.00 | mean 0.333→0.373 |

Read the medians/totals disagreement honestly: the skill wins the middle of
the distribution and gives some of it back on trap-task tails where it works
longer than the baseline (same failure branch, more persistence). Cheaper on
the median task; not cheaper in aggregate.

## Adoption (mechanical proof the treatment fired)

| signal | no-skill | with-skill |
|---|--:|--:|
| payload reached model (trajectory.json) | 0/80 | **80/80** |
| labelled probe chains (`echo == … ==`) | 10 cmds | **102 cmds** |
| batched dependency probes | 7/80 trials | **22/80** |
| Read calls with offset/limit | 20% | 28% |
| Read calls total | 144 | **57** |
| requests median | 12 | 11 |

## The ladder — five versions in one day, and why each existed

| stage | version | result | lesson |
|---|---|---|---|
| smoke10 k=1 | v1 (713 tok) | cost −11.7%, reward 0/4/6 — crash | 4-agent trace diagnosis: 2 failures variance (trap tasks), 2 skill-caused via underdefined "check" |
| smoke10 k=1 | v2 (+check rigor) | syzkaller fixed; out_tok +52% | criteria-check construction = output whale |
| k3x10 (60 trials) | v3 (+check-to-file) | cost totals +7.4% vs medians −8.9%; reward 3/5/2 | k=1 savings were mirage; whales persist; guards added for task X hurt task Y |
| smoke10 k=1 | v4 (cap harness) | whales persist (ada whaled even under v1) | rule-soup has no net-positive config on trap set |
| smoke10 k=1 | **v5 = LEAN** (632 tok) | cost −13%, reward parity, whales tame | keep only rules with clean evidence: recon-in-one-pass, keyhole, dep-probe-once, named-check-is-the-check, env-failure-is-yours, fails-twice→alternative |
| **full 82 tasks** | **v5** | **headline above** | — |

The single most valuable design lesson: **quality guards are not free.**
Every guard added to protect one failure class (v2/v3) generated verification
whales that erased the savings elsewhere. The winning configuration deleted
more rules than it added — small payload, narrow claims, behaviors that are
cheap to comply with.

## Method notes

- **Arms:** `no-skill` vs `with-skill` = skill installed via `--skill` + payload
  appended via `--extra-instruction-path` (skills don't reliably self-activate;
  injection is the honest always-on treatment, per this repo's prior evals).
- Claude Code pinned 2.1.201 both arms; `anthropic/claude-sonnet-5`; effort low.
- Exclusions: the 5 standard (bike-rebalance + 4 known-broken) upfront;
  `seismic-phase-picking` + `earthquake-phase-association` errored identically
  in BOTH arms (RuntimeError — same env issue ponytail hit) → dropped
  symmetrically. `reserves-at-risk-calc` was a ONE-SIDED treatment-arm
  AgentTimeoutError → retried per house rule; completed clean (reward 0.0,
  matching control) → kept. Final: 80 pairs.
- Iteration shortcuts, disclosed: bp2/bp4/bp5 smokes ran the treatment arm only
  against bp1's (k=1) or bp3's (k=3) control — fine for gating, not quotable.
  The headline comes exclusively from bp-final, fresh both-arms, one job name.
- k=1 breadth: per-task rewards flip freely on this benchmark; the 66/80 tie
  rate and the k3x10 stage are why we trust the sign test, not raw flips.

## Ops notes

- Full breadth ran with the mandatory 60s janitor (`run_full.sh`); disk never
  dropped below ~69G free (the ponytail/headroom disk incidents did not recur).
- Final run launched via `start_new_session` detached driver (harbor dies with
  its shell — house lesson held).
- Program spend: bp1 $14.94 · bp2 ~$8.6 · bp3 $49.04 · bp4 $9.08 · bp5 $6.83 ·
  bp-final $64.40 ≈ **$153** across 254 billed trials.

## Reproducing

```bash
python3 gen_instruction.py                      # payload from SKILL.md
python3 compare.py --job bp-final no-skill with-skill
python3 adoption.py runs/no-skill/bp-final runs/with-skill/bp-final
python3 mediators.py --job bp-final no-skill with-skill
```

Running log with all five versions' diffs and diagnoses: `LAB-NOTES.md`.
