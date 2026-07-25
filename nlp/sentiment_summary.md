# Sentiment Analysis Summary
## Google Play Store Product Intelligence Platform

Full methodology and code live in `notebooks/`. This file is the results,
condensed to what a reader needs without re-running anything.

---

### Method

**VADER** (Valence Aware Dictionary and sEntiment Reasoner) — a rule-based,
lexicon-based sentiment tool, chosen over a trained ML classifier because it
needs zero labeled training data and is specifically tuned for short,
informal text (reviews, social media), which is exactly what this dataset
is. Each review's `compound` score (-1 to +1) was bucketed using VADER's own
recommended thresholds: ≥0.05 → Positive, ≤-0.05 → Negative, otherwise
Neutral.

---

### Validation Against an Independent Method

The dataset arrived with pre-existing sentiment labels computed by a
different tool (TextBlob). Comparing VADER's labels against those
independently:

**Agreement: 76.3%**

This matters because it's a cross-check with no ground-truth labels
available — two different lexicon-based tools agreeing three-quarters of
the time is reasonable evidence the sentiment signal reflects something
real in the text, not one tool's idiosyncrasy. The ~24% disagreement is
concentrated at the Neutral/Positive boundary, which is a genuinely
ambiguous case even for a human reader (e.g. "it's fine, does the job" —
mildly positive or neutral is a judgment call either tool can miss).

---

### What Users Complain About vs. Praise

Word-frequency analysis (stopwords removed) run separately on
VADER-Negative and VADER-Positive reviews:

| Top Complaint Words | Top Praise Words |
|---|---|
| game | game |
| time | like |
| get | good |
| can | great |
| even | love |

**Interpretation:** Complaint words cluster around concrete friction —
"time" and "game" together point toward grinding/wait-time frustration
mechanics rather than technical failure (no strong presence of words like
"crash," "bug," or "broken" in the top complaints). Praise words, by
contrast, are generic positive affect ("like," "good," "great," "love") not
tied to any specific feature.

**Business implication:** users are specific about what frustrates them and
vague about what delights them. This means fixing concrete friction points
is a more actionable lever for Play Store than trying to engineer "delight"
— delight isn't tied to anything concrete in this data, but frustration is.

---

### Category-Level Sentiment (feeds the Sentiment dashboard page)

**Headline finding:** GAME has the highest negative-review rate of any
category at **36%** — despite also being the platform's largest category by
app count (959 apps). This is nearly 60% higher than FINANCE, which sits at
**22%**, one of the lowest negative-review rates among large categories.
This is the single largest, most addressable opportunity identified in this
project — see the Business Report for the full recommendation.

The complete ranked breakdown across all ~34 categories is in the
`category_kpis` BigQuery view and rendered live on the Sentiment page of
both dashboards (Power BI and Looker Studio) — see those for the full table
rather than a static snapshot here, since the dashboard is the
source of truth and stays in sync if the underlying data changes.

---

### Known Limitation

The apps-to-reviews join relies on an exact app-name string match, which
fails for a small number of rows due to minor formatting differences
between the two source files. Unmatched reviews were excluded from
category-level sentiment analysis rather than guessed at, and this is
disclosed in the main Business Report's Limitations section.
