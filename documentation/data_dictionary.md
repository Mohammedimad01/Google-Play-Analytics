# Data Dictionary

## Source
Google Play Store Apps dataset (public, originally scraped from the Play Store).
Snapshot in time, not live data. Two files:

---

## 1. googleplaystore.csv - 10,841 rows, 13 columns

| Column | Type (raw) | Meaning | Known issue to fix in cleaning |
|---|---|---|---|
| App | text | App name | Some duplicates (same app scraped twice) |
| Category | text | Play Store category, e.g. ART_AND_DESIGN | One row has a corrupted category value ("1.9") - a known data-shift error in this file, must be dropped or fixed |
| Rating | float | Star rating, 1-5 | ~1,400 missing values |
| Reviews | text (should be int) | Number of reviews | Stored as text, needs conversion |
| Size | text | App size, e.g. "19M" or "Varies with device" | Needs parsing to numeric MB, "Varies with device" needs a decision (impute or flag) |
| Installs | text | Install bucket, e.g. "10,000+" | Needs comma/plus stripped and converted to numeric (becomes a floor estimate, not exact) |
| Type | text | Free / Paid | 1 missing value |
| Price | text | Price string, e.g. "$4.99" or "0" | Needs $ stripped and converted to numeric |
| Content Rating | text | Age rating, e.g. Everyone, Teen | Minor category cleanup |
| Genres | text | Sub-genre(s), semicolon-separated for multi-genre apps | Will split for genre-level analysis |
| Last Updated | text (date) | Date of last update | Needs conversion to datetime, this powers our "update frequency" KPI |
| Current Ver | text | App version | High cardinality, low analytical value, keep but won't be a primary field |
| Android Ver | text | Minimum required Android version | Low analytical priority |

**Why this table matters most:** almost every KPI in the BRD (rating, installs,
price, update frequency, category) comes directly from this file.

---

## 2. googleplaystore_user_reviews.csv - 64,296 rows, 5 columns

| Column | Type | Meaning | Known issue to fix in cleaning |
|---|---|---|---|
| App | text | App name (join key back to the apps table) | Not every app has reviews; not every review's app exists in the apps table - needs an inner join decision |
| Translated_Review | text | Review text (pre-translated to English) | ~40% rows have NaN (no review text) - these rows are unusable for NLP and should be dropped for that phase only |
| Sentiment | text | Positive / Negative / Neutral, pre-labeled | Pre-computed with TextBlob by the original dataset author, we treat this as a *reference*, not ground truth, and compute our own with VADER in the NLP phase |
| Sentiment_Polarity | float | -1 to 1 | Same caveat as above |
| Sentiment_Subjectivity | float | 0 to 1 (0=fact, 1=opinion) | Same caveat as above |

**Join key:** `App` (exact string match, this is fragile and is itself worth
flagging in our Limitations section, since app names can have small formatting
differences between the two files).
