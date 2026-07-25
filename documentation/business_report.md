# Business Report
## Google Play Store Product Intelligence Platform

---

### Executive Summary

Google Play's success depends on two linked outcomes: users finding
consistently good apps, and developers being able to act on clear signals
about what drives quality. This analysis of 9,659 apps and ~64,000 user
reviews finds that **app metadata alone (price, size, install count, review
count) explains under 1% of rating variance** — meaning the traditional
signals available on an app's store listing tell us almost nothing about
whether it will satisfy users. The real signal lives in review **text**,
not in app metadata. Three findings translate this into concrete action,
detailed below, centered on one large, addressable opportunity: the GAME
category, Play Store's largest by app count, also has its highest
negative-review rate (36%).

### Problem Statement

The Google Play team needs a systematic, data-backed way to identify what
separates successful apps from struggling ones, in order to improve both
user satisfaction and developer outcomes. This report answers that using a
full pipeline: data cleaning, exploratory analysis, SQL analytics on
BigQuery, statistical hypothesis testing, and NLP-based review analysis —
detailed in full in the accompanying BRD.

### Methodology

1. **Data Cleaning (Python/pandas):** corrected a corrupted category row,
   converted text-formatted numeric fields (Installs, Price, Reviews) to
   proper types, and made a deliberate decision to leave missing Ratings as
   null rather than impute them, since Rating is a core outcome variable.
2. **Exploratory Analysis:** category-level aggregation (not individual-app
   analysis) to answer platform-level questions, since the business
   questions are about categories and segments, not single apps.
3. **SQL Analytics (BigQuery):** 25 queries spanning basic aggregation
   through window functions (RANK, LAG/LEAD, running totals), used to
   answer the BRD's specific business questions (top categories, worst
   genres, price elasticity, update-recency effects).
4. **Statistical Testing:** Welch's t-test (free vs. paid ratings),
   Pearson correlation, and OLS regression — each interpreted for
   *practical* significance, not just statistical significance (a
   distinction detailed in Limitations).
5. **NLP:** VADER sentiment analysis on review text, cross-validated
   against the dataset's pre-existing TextBlob sentiment labels (76.3%
   agreement), plus keyword frequency analysis on negative reviews.
6. **Dashboards:** parallel builds in Power BI (industry standard) and
   Looker Studio (Google-native, built on BigQuery views), so findings are
   accessible through both toolchains.

### Key Insights

**Insight 1 — Metadata doesn't predict quality; review text does.**
A regression of Rating on Price, Size, Reviews, and Installs produced
R²=0.008 — these four variables explain under 1% of why ratings differ.
Size and Reviews were statistically significant (p<0.001) but with
negligible effect sizes (e.g. it would take ~35 million additional reviews
to move a rating by one full point) — a clear case of statistical
significance without practical significance, a distinction worth stating
explicitly rather than overselling a "significant" result.

**Insight 2 — GAME is the platform's highest-risk category at scale.**
GAME has the most apps (959) of any category and the highest negative
review rate (36%) — nearly 60% higher than FINANCE (22%). Complaint
keyword analysis points toward frustration themes ("time," "game" appearing
disproportionately in negative reviews), consistent with grinding/wait-time
mechanics rather than technical failure.

**Insight 3 — Paid apps rate modestly but significantly higher than free
apps** (4.26 vs. 4.17, Welch's t-test p<0.001). The statistical
significance is real (large sample size), but the practical gap is small —
this is a minor signal, not a primary lever.

**Insight 4 — Sentiment analysis validates against an independent method.**
VADER-derived sentiment agreed with the dataset's pre-existing TextBlob
labels 76.3% of the time — reasonable agreement for two different
lexicon-based tools on short, informal review text, giving confidence the
sentiment signal reflects something real rather than one tool's artifact.

### Recommendations

| Finding | Recommendation | Expected Impact |
|---|---|---|
| GAME has outsized negative-review share | Prioritize GAME developers in an update-reminder/quality-guidance program; investigate grinding/wait-time complaint themes as a targeted developer resource | Largest platform-wide lift to the User Satisfaction Index, since GAME is the largest category |
| Metadata doesn't predict rating | Shift Play Store's quality-monitoring approach from metadata heuristics to review-sentiment monitoring (this project's USI and Negative Review Share metrics) | Earlier detection of quality problems — sentiment shifts before aggregate rating does |
| Paid vs. free gap is real but small | Treat as a minor signal only; don't prioritize pricing-policy changes over the review-sentiment lever above | Avoids over-investing in a low-impact intervention |

### Limitations

- **Installs are bucketed, not exact** (e.g. "10,000+"), so all
  install-based metrics are directional floors, not precise counts.
- **No real revenue data** — "revenue potential" in the SQL analysis is an
  Installs × Price estimate, explicitly labeled as such, not actual
  transaction data.
- **No developer identifier field** — "worst performing developers" (a BRD
  question) was answered using Genres as a proxy, an honest substitution
  given the dataset's constraints, not a perfect answer to the original
  question.
- **Join fragility between apps and reviews:** the two source files join on
  exact app-name string match, which fails for some apps due to minor
  formatting differences — these unmatched reviews were excluded from any
  category-level sentiment analysis rather than guessed at.
- **Dataset is a single point-in-time snapshot** — there is no true
  install-growth-over-time data; any chart resembling a time trend (e.g.
  "installs by last-updated date") reflects the *current* install volume of
  apps grouped by *when they were last updated*, not historical growth,
  and is labeled accordingly on the dashboard.
- **Statistical vs. practical significance:** with ~7,000+ observations,
  several relationships reach p<0.05 while having negligible real-world
  effect size (e.g. Size_MB vs. Rating, r=0.063) — these are reported with
  that distinction made explicit rather than treated as important findings.

### Future Work

With additional data, this analysis could be extended with: real developer
identifiers (to properly answer the "worst performing developers"
question), time-series install/revenue data (to measure actual growth, not
a proxy), and app-level crash/performance telemetry (to separate technical
complaints from UX/design complaints in the NLP phase).
