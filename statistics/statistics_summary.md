# Statistics Summary
## Google Play Store Product Intelligence Platform

Full methodology and code live in `notebooks/`. This file is the results,
condensed to what a reader needs without re-running anything.

---

### Test 1 — Free vs. Paid Apps: Do paid apps rate higher?

**Method:** Welch's t-test (does not assume equal variance between groups —
the safer default over a standard Student's t-test).

| Group | n | Mean Rating |
|---|---|---|
| Free apps | 7,592 | 4.166 |
| Paid apps | 604 | 4.260 |

**Result:** t = -3.951, **p = 0.00009**

**Interpretation:** Statistically significant — paid apps rate higher than
free apps, and this is very unlikely to be random chance. The practical gap
(0.094 stars) is small, though, so this is treated as a real but minor
signal, not a primary business lever.

---

### Test 2 — Correlation: Does Size, Price, or Review count relate to Rating?

**Method:** Pearson correlation, tested individually against Rating.

| Variable | r | p-value |
|---|---|---|
| Size_MB | 0.063 | 0.00000 |
| Price | -0.021 | 0.05497 |
| Reviews | 0.055 | 0.00000 |

**Interpretation:** All three r-values are close to zero — essentially no
linear relationship in practical terms. Size and Reviews are flagged
"statistically significant" only because of the large sample size (~7,600-
8,200 observations) — with enough data, even a trivial relationship crosses
the p<0.05 threshold. Price shows no significant relationship at all
(p=0.055, just above the cutoff). **Statistical significance here does not
mean practical importance.**

---

### Test 3 — Regression: What predicts Rating, controlling for everything at once?

**Method:** OLS regression — `Rating ~ Price + Size_MB + Reviews + Installs`

| Variable | coef | p-value | Significant? |
|---|---|---|---|
| const (intercept) | 4.1285 | 0.000 | — |
| Price | -0.0006 | 0.106 | No |
| Size_MB | 0.0013 | 0.000 | Yes (negligible effect size) |
| Reviews | 2.868e-08 | 0.000 | Yes (negligible effect size) |
| Installs | 1.912e-10 | 0.531 | No |

**R² = 0.008** (Adjusted R² = 0.007)

**Interpretation — the most important statistical finding in this project:**
these four variables together explain **under 1%** of why app ratings
differ. Size and Reviews are technically "significant" (p<0.001) but their
real-world effect is negligible — for example, it would take roughly 35
million additional reviews to move a rating by a single point. This is not
a failed model; it's a genuine finding: **rating is driven by factors this
dataset can't measure (actual app quality, bugs, UX) — not by anything on
the app's store listing.** This is the finding that justifies the NLP phase:
if metadata can't explain quality, review text might.

**Model diagnostic note:** the regression output flagged a large condition
number (3.82e+07), indicating likely multicollinearity — Installs and
Reviews are probably highly correlated with each other, since popular apps
tend to have both. This makes it harder for the model to isolate each
variable's individual effect and is disclosed here rather than ignored.

---

### Summary Table

| Question | Answer | Confidence |
|---|---|---|
| Do paid apps rate higher than free? | Yes, modestly (4.26 vs 4.17) | High (p<0.001), small effect |
| Does app size affect rating? | Negligibly | Statistically yes, practically no |
| Does price affect rating? | No | Not significant (p=0.055) |
| Do more reviews mean higher rating? | Negligibly | Statistically yes, practically no |
| Does metadata predict rating overall? | No — R²=0.008 | This is the headline finding |
