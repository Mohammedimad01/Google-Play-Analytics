# Product Metrics Framework
## Google Play Store Product Intelligence Platform

This framework defines how "success" is measured across the platform, following
the standard North Star / Supporting / Guardrail structure used in product
analytics. Where this dataset only gives us a proxy for a real usage metric
(e.g. no live session logs), that is stated explicitly a good metrics
framework is honest about what it can and can't measure.

---

### North Star Metric

**User Satisfaction Index (USI)**

```
USI = 0.6 × normalized(Average Rating) + 0.4 × normalized(VADER Sentiment Score)
```

**Why this and not just Rating alone:** star ratings are given rarely and can be
gamed (rating prompts, incentivized reviews). Review *text* sentiment is a more
continuous, harder-to-game signal. Combining both means the index can't be
inflated by optimizing one channel alone, an app would need to genuinely
satisfy users in both what they click and what they write.

---

### Supporting Metrics

| Metric | Definition | Why it supports the North Star |
|---|---|---|
| Review Sentiment Rate | % of reviews classified Positive by VADER, per app/category | Leading indicator, sentiment in review text shifts before the aggregate star rating catches up, giving an earlier signal than USI alone |
| Update Cadence | Days since last app update | The one metric in this framework that is directly developer-controllable — a lever Play Store can actually pull (e.g. reminders), unlike Rating which is purely an outcome |
| Category Growth Rate | Change in install-bucket over time, by category | Tells Marketing/PM where user demand is shifting, independent of quality |

---

### Guardrail Metric

**Negative Review Share** — % of reviews classified Negative by VADER

**Why a guardrail is necessary, not optional:** the North Star Metric alone can
look healthy for the wrong reason - for example, if dissatisfied users simply
stop reviewing (or stop using the app) rather than the product improving, USI
can appear stable while the underlying experience is actually declining. The
Negative Review Share is tracked as an independent check: if it rises even
while USI holds steady, that's a signal something is wrong that the North Star
alone would hide.

---

### Known Limitations of This Framework

- No real session/retention data exists in this dataset - Update Cadence and
  Category Growth are used as *proxies* for engagement and demand, not direct
  measurements.
- Installs are Play Store's bucketed ranges (e.g. "10,000+"), not exact counts,
  so any metric using Installs is directional, not precise.
- This framework is designed to be computed per-app and rolled up by category
  the SQL and dashboard layers should always support both levels of detail.
