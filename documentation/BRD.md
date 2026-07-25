# Business Requirements Document
## Google Play Store Product Intelligence Platform

---

### 1. Business Problem

The Google Play team wants to understand why some apps succeed in the store while
others fail - and to identify concrete, data-backed opportunities to improve two
things at once: **user satisfaction** and **developer success**. Today, Play Store
decisions (which apps to feature, which developer behaviors to encourage, where
policy or tooling could help) are made without a systematic view connecting app
metadata (category, price, size, update cadence) to actual outcomes (ratings,
installs, review sentiment).

This project builds that systematic view: a reproducible analytics pipeline that
takes raw app and review data and turns it into specific, actionable
recommendations.

### 2. Why It Matters

- **For users:** poor-quality or abandoned apps waste time and erode trust in the
  platform as a whole.
- **For developers:** without visibility into what drives ratings and retention,
  developers can't prioritize the right fixes.
- **For Google Play (the business):** app quality and developer health directly
  drive platform engagement, which drives ad and transaction revenue. A platform
  where users can't find sustainably good apps is a platform users leave.

### 3. Stakeholders

| Stakeholder | Their concern |
|---|---|
| Product Manager | Which category/segment opportunities are worth prioritizing |
| UX Team | What in the *experience* (not just the app) drives dissatisfaction |
| Marketing | Which categories/app types are growing, to inform campaigns |
| Google Play Developers | What actions improve their app's rating and installs |
| Executive Leadership | Platform-level health trends, ROI of any intervention |

### 4. Key Decisions This Analysis Should Support

1. Should Play Store prioritize surfacing/promoting certain categories over others?
2. Should there be automated nudges/reminders for developers of stale, low-rated apps?
3. Does pricing strategy (free vs. paid) correlate with quality outcomes in a way
   that should inform monetization guidance to developers?
4. Which complaint themes (from review text) represent the highest-leverage product
   fixes across many apps at once — i.e. platform-level, not single-app, opportunities?

### 5. KPIs / Success Metrics

| KPI | What it tells us |
|---|---|
| Average Rating | Baseline quality signal per app/category |
| Installs | Reach / market penetration |
| Estimated Revenue | Price × Installs (proxy - real revenue isn't in this dataset) |
| Review Sentiment (VADER-scored) | Qualitative satisfaction, beyond the star rating |
| Update Frequency | Developer engagement / maintenance signal |
| Category Growth | Where user demand is shifting |
| User Satisfaction Index (derived) | Composite of rating + sentiment, so no single noisy metric drives conclusions |

### 6. Scope

**In scope:** Google Play Store app metadata + user reviews (see data dictionary),
covering cleaning, exploratory analysis, SQL analytics (BigQuery), statistical
testing, NLP on review text, a Power BI dashboard, and business recommendations.

**Out of scope:** real-time data, apps outside this dataset's snapshot, iOS/App
Store comparison, actual revenue data (not available - we use installs × price as
a labeled *estimate*, not a real number, and we say so explicitly in the report).

### 7. Deliverables

Cleaned datasets, EDA notebook, ~25 SQL analytical queries (BigQuery), statistical
test results with plain-English interpretation, NLP sentiment/complaint analysis,
an interactive Power BI dashboard, a written business report with prioritized
recommendations, and a presentation deck.
