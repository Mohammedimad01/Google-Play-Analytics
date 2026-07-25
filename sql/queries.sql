-- ============================================================
-- Google Play Store Product Intelligence Platform
-- SQL Analytics — BigQuery
-- Dataset: sublime-calling-503310-q3.play_store
-- ============================================================

-- ============================================================
-- TIER 1: BASIC (SELECT, WHERE, GROUP BY)
-- ============================================================

-- 1. How many apps per category?
SELECT Category, COUNT(*) AS app_count
FROM `play_store.apps`
GROUP BY Category
ORDER BY app_count DESC;

-- 2. What's the overall average rating and total install count?
SELECT AVG(Rating) AS overall_avg_rating, SUM(Installs) AS total_installs
FROM `play_store.apps`;

-- 3. Which apps are free vs paid, and how many of each?
SELECT Type, COUNT(*) AS count
FROM `play_store.apps`
GROUP BY Type;

-- 4. Top 20 most-installed apps (simple filter + sort)
SELECT App, Category, Installs, Rating
FROM `play_store.apps`
WHERE Installs IS NOT NULL
ORDER BY Installs DESC
LIMIT 20;

-- 5. Apps with a rating below 3.0 (quality problem apps)
SELECT App, Category, Rating, Installs
FROM `play_store.apps`
WHERE Rating < 3.0
ORDER BY Installs DESC;

-- 6. Average price by category, for categories where paid apps exist
SELECT Category, AVG(Price) AS avg_price
FROM `play_store.apps`
WHERE Price > 0
GROUP BY Category
ORDER BY avg_price DESC;

-- ============================================================
-- TIER 2: INTERMEDIATE (JOINS, CASE, HAVING)
-- ============================================================

-- 7. Join apps + reviews: average sentiment polarity per category
SELECT a.Category, AVG(r.Sentiment_Polarity) AS avg_sentiment_polarity
FROM `play_store.apps` a
JOIN `play_store.reviews` r ON a.App = r.App
GROUP BY a.Category
ORDER BY avg_sentiment_polarity DESC;

-- 8. Categories with more than 200 apps AND average rating above 4.2
--    (HAVING filters on the aggregated result, WHERE cannot do this)
SELECT Category, COUNT(*) AS app_count, AVG(Rating) AS avg_rating
FROM `play_store.apps`
GROUP BY Category
HAVING app_count > 200 AND avg_rating > 4.2
ORDER BY avg_rating DESC;

-- 9. Bucket apps into quality tiers using CASE
SELECT
  App, Category, Rating,
  CASE
    WHEN Rating >= 4.5 THEN 'Excellent'
    WHEN Rating >= 4.0 THEN 'Good'
    WHEN Rating >= 3.0 THEN 'Average'
    WHEN Rating IS NULL THEN 'Unrated'
    ELSE 'Poor'
  END AS quality_tier
FROM `play_store.apps`;

-- 10. Count of apps per quality tier per category (CASE inside aggregation)
SELECT
  Category,
  COUNTIF(Rating >= 4.5) AS excellent_count,
  COUNTIF(Rating < 3.0) AS poor_count
FROM `play_store.apps`
GROUP BY Category
ORDER BY poor_count DESC;

-- 11. Apps whose review sentiment disagrees with their star rating
--     (high rating but a lot of negative-sentiment reviews — a real red flag)
SELECT a.App, a.Rating,
       COUNTIF(r.Sentiment = 'Negative') AS negative_reviews,
       COUNT(*) AS total_reviews
FROM `play_store.apps` a
JOIN `play_store.reviews` r ON a.App = r.App
GROUP BY a.App, a.Rating
HAVING a.Rating >= 4.0 AND negative_reviews > total_reviews * 0.3
ORDER BY negative_reviews DESC;

-- 12. Left join to find apps that have zero reviews in our reviews table
SELECT a.App, a.Category, a.Installs
FROM `play_store.apps` a
LEFT JOIN `play_store.reviews` r ON a.App = r.App
WHERE r.App IS NULL
ORDER BY a.Installs DESC
LIMIT 20;

-- ============================================================
-- TIER 3: ADVANCED (WINDOW FUNCTIONS)
-- ============================================================

-- 13. Rank apps within their category by rating (ROW_NUMBER — one clear winner)
SELECT App, Category, Rating,
       ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Rating DESC) AS rank_in_category
FROM `play_store.apps`
WHERE Rating IS NOT NULL;

-- 14. Top 3 apps per category by installs (classic "top-N per group" pattern)
WITH ranked AS (
  SELECT App, Category, Installs,
         RANK() OVER (PARTITION BY Category ORDER BY Installs DESC) AS install_rank
  FROM `play_store.apps`
)
SELECT * FROM ranked WHERE install_rank <= 3
ORDER BY Category, install_rank;

-- 15. Dense rank rating tiers within category (ties share a rank, no gaps)
SELECT App, Category, Rating,
       DENSE_RANK() OVER (PARTITION BY Category ORDER BY Rating DESC) AS rating_tier
FROM `play_store.apps`
WHERE Rating IS NOT NULL;

-- 16. Each app's rating vs its category average (the core "window function" idea)
SELECT App, Category, Rating,
       AVG(Rating) OVER (PARTITION BY Category) AS category_avg_rating,
       Rating - AVG(Rating) OVER (PARTITION BY Category) AS diff_from_avg
FROM `play_store.apps`
WHERE Rating IS NOT NULL
ORDER BY diff_from_avg DESC;

-- 17. NTILE: split all apps into 4 install-volume quartiles
SELECT App, Installs,
       NTILE(4) OVER (ORDER BY Installs DESC) AS install_quartile
FROM `play_store.apps`;

-- 18. LAG: compare each app's rating to the previous app (by install rank) in its category
SELECT App, Category, Installs, Rating,
       LAG(Rating) OVER (PARTITION BY Category ORDER BY Installs DESC) AS prev_app_rating
FROM `play_store.apps`;

-- 19. LEAD: same idea, looking forward instead of back
SELECT App, Category, Installs, Rating,
       LEAD(Rating) OVER (PARTITION BY Category ORDER BY Installs DESC) AS next_app_rating
FROM `play_store.apps`;

-- 20. FIRST_VALUE: the top-rated app's name, attached to every row in its category
SELECT App, Category, Rating,
       FIRST_VALUE(App) OVER (PARTITION BY Category ORDER BY Rating DESC) AS category_best_app
FROM `play_store.apps`
WHERE Rating IS NOT NULL;

-- 21. Running total of installs within a category, ordered by rating (cumulative reach of "good" apps first)
SELECT App, Category, Rating, Installs,
       SUM(Installs) OVER (PARTITION BY Category ORDER BY Rating DESC
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_installs
FROM `play_store.apps`
WHERE Rating IS NOT NULL;

-- ============================================================
-- TIER 4: BUSINESS QUESTIONS (from the BRD, combining everything above)
-- ============================================================

-- 22. Price elasticity proxy: does higher price correlate with lower installs, by category?
SELECT Category,
       CORR(Price, Installs) AS price_installs_correlation
FROM `play_store.apps`
WHERE Price > 0
GROUP BY Category
ORDER BY price_installs_correlation;

-- 23. Update frequency vs rating: do recently-updated apps rate higher?
SELECT
  CASE
    WHEN DATE_DIFF(DATE('2018-08-01'), Last_Updated, DAY) <= 90 THEN 'Updated last 90 days'
    WHEN DATE_DIFF(DATE('2018-08-01'), Last_Updated, DAY) <= 365 THEN 'Updated last year'
    ELSE 'Stale (1yr+)'
  END AS update_recency,
  AVG(Rating) AS avg_rating,
  COUNT(*) AS app_count
FROM `play_store.apps`
WHERE Rating IS NOT NULL
GROUP BY update_recency
ORDER BY avg_rating DESC;

-- 24. "Worst performing developers" proxy — using Genres as a stand-in since we have no developer field
--     (be ready to explain this substitution in an interview — it's an honest data limitation)
SELECT Genres, AVG(Rating) AS avg_rating, COUNT(*) AS app_count
FROM `play_store.apps`
WHERE Rating IS NOT NULL
GROUP BY Genres
HAVING app_count >= 20
ORDER BY avg_rating ASC
LIMIT 10;

-- 25. Highest revenue-potential category (Installs × Price, clearly labeled as an ESTIMATE)
SELECT Category,
       SUM(Installs * Price) AS estimated_revenue_potential
FROM `play_store.apps`
WHERE Type = 'Paid'
GROUP BY Category
ORDER BY estimated_revenue_potential DESC
LIMIT 10;
