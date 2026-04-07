-- ============================================================
-- ShopFlow Channel Mix & Attribution Analysis
-- Performance Marketing Case Study — Q1 2025
-- Dataset: 1,080 rows | 90 days | 3 channels | 12 placements
-- ============================================================

-- Fix date format for DD/MM/YYYY imports
ALTER DATABASE shopflow SET datestyle = 'ISO, DMY';

-- Create table
CREATE TABLE channel_mix (
    date DATE,
    channel VARCHAR(50),
    placement VARCHAR(50),
    impressions INTEGER,
    clicks INTEGER,
    ctr NUMERIC(5,2),
    cpc NUMERIC(10,2),
    amount_spent NUMERIC(10,2),
    purchases INTEGER,
    purchase_value NUMERIC(10,2),
    roas NUMERIC(10,2),
    cpa NUMERIC(10,2),
    search_type VARCHAR(20)
);

-- Verify import: expect 1,080 rows
SELECT COUNT(*) FROM channel_mix;


-- ============================================================
-- LAYER 1 — DESCRIPTIVE: Channel Performance
-- Business question: How did each channel perform last quarter?
-- ============================================================

SELECT channel,
       ROUND(SUM(amount_spent), 2) AS spend,
       SUM(purchases) AS purchases,
       ROUND(SUM(purchase_value), 2) AS revenue,
       ROUND(SUM(purchases)::NUMERIC / SUM(clicks)::NUMERIC * 100, 2) AS cvr,
       ROUND(SUM(amount_spent) / NULLIF(SUM(purchases), 0), 2) AS cpa,
       ROUND(AVG(roas), 2) AS avg_roas
FROM channel_mix
GROUP BY 1
ORDER BY avg_roas DESC;

-- Finding: Google Search delivered the highest ROAS at 2.45x while consuming
-- 38% of total spend, while TikTok generated only 0.36x ROAS on 22% of spend
-- — returning a net loss of €0.64 for every euro invested.


-- ============================================================
-- LAYER 2 — DIAGNOSTIC: Branded vs Non-Branded Search
-- Business question: Is Google's strong performance real or an
-- attribution artifact?
-- ============================================================

SELECT search_type,
       ROUND(SUM(amount_spent), 2) AS spend,
       SUM(purchases) AS purchases,
       ROUND(SUM(purchases)::NUMERIC / SUM(clicks)::NUMERIC * 100, 2) AS cvr,
       ROUND(SUM(amount_spent) / NULLIF(SUM(purchases), 0), 2) AS cpa,
       ROUND(AVG(roas), 2) AS avg_roas
FROM channel_mix
WHERE search_type != 'N/A'
GROUP BY 1
ORDER BY avg_roas DESC;

-- Finding: 75% of Google's conversions (562 of 745) come from branded search
-- — customers who already knew ShopFlow before they Googled. Strip out branded
-- search and Google's ROAS drops from 2.45x to 1.17x, barely breaking even.
-- TikTok and Meta create the awareness that Google captures credit for.


-- ============================================================
-- LAYER 3 — PLACEMENT EFFICIENCY
-- Business question: Which placements are burning money and
-- which are worth scaling?
-- ============================================================

SELECT channel,
       placement,
       SUM(purchases) AS purchases,
       ROUND(AVG(roas), 2) AS avg_roas,
       ROUND(SUM(amount_spent) / NULLIF(SUM(purchases), 0), 2) AS cpa,
       ROUND(SUM(amount_spent), 2) AS spend
FROM channel_mix
GROUP BY 1, 2
ORDER BY avg_roas DESC;

-- Finding: Three placements — Brand Takeover, Display Network, and TopView —
-- consumed €12,569 (10.5% of total budget) while generating only 3 purchases
-- combined. Instagram Stories is the hidden opportunity: strongest Meta
-- performer (1.71x ROAS, €58.48 CPA) with room to scale.


-- ============================================================
-- LAYER 4 — TIME TRENDS: Monthly Performance with Ranking
-- Business question: Is channel performance improving or
-- declining over Q1?
-- ============================================================

SET datestyle = 'ISO, DMY';

WITH monthly AS (
    SELECT channel,
           TO_CHAR(date::DATE, 'Month') AS month,
           ROUND(SUM(amount_spent), 2) AS spend,
           ROUND(AVG(roas), 2) AS avg_roas,
           SUM(purchases) AS purchases
    FROM channel_mix
    GROUP BY 1, 2
)
SELECT *,
       RANK() OVER (PARTITION BY month ORDER BY avg_roas DESC) AS roas_rank
FROM monthly
ORDER BY month, roas_rank;

-- Finding: All three channels show flat or declining ROAS across Q1,
-- suggesting potential seasonal headwinds, market saturation, or increased
-- competitive pressure. Budget reallocation can improve efficiency, but
-- will not reverse a broader demand slowdown.


-- ============================================================
-- LAYER 5 — PRESCRIPTIVE: Budget Reallocation Model
-- Business question: What is the projected revenue impact of
-- reallocating spend from dead placements to top performers?
-- ============================================================

WITH projected AS (
    SELECT channel,
           placement,
           SUM(amount_spent) AS current_spend,
           AVG(roas) AS avg_roas,
           SUM(purchase_value) AS current_revenue,
           CASE
               WHEN placement = 'Brand Takeover' THEN 0
               WHEN placement = 'Display Network' THEN 0
               WHEN placement = 'TopView' THEN 0
               WHEN placement = 'Instagram Stories' THEN SUM(amount_spent) + 5000
               WHEN placement = 'Search Top' THEN SUM(amount_spent) + 4000
               WHEN placement = 'In-Feed' THEN SUM(amount_spent) + 3569
               ELSE SUM(amount_spent)
           END AS projected_spend,
           CASE
               WHEN placement = 'Brand Takeover' THEN 0
               WHEN placement = 'Display Network' THEN 0
               WHEN placement = 'TopView' THEN 0
               WHEN placement = 'Instagram Stories' THEN (SUM(amount_spent) + 5000) * AVG(roas)
               WHEN placement = 'Search Top' THEN (SUM(amount_spent) + 4000) * AVG(roas)
               WHEN placement = 'In-Feed' THEN (SUM(amount_spent) + 3569) * AVG(roas)
               ELSE SUM(amount_spent) * AVG(roas)
           END AS projected_revenue
    FROM channel_mix
    GROUP BY 1, 2
)
SELECT channel,
       placement,
       ROUND(current_spend, 2) AS current_spend,
       ROUND(avg_roas, 2) AS avg_roas,
       ROUND(current_revenue, 2) AS current_revenue,
       ROUND(projected_spend, 2) AS projected_spend,
       ROUND(projected_revenue, 2) AS projected_revenue,
       ROUND(projected_revenue - current_revenue, 2) AS revenue_difference
FROM projected
ORDER BY revenue_difference DESC;

-- Finding: Reallocating €12,569 from three non-performing placements to three
-- high-efficiency placements generates a net projected revenue gain of €20,103
-- — without increasing total budget. The largest gains come from Search Top
-- (+€9,874) and Instagram Stories (+€8,573).
-- Caveat: Projections assume ROAS holds at current levels. Monitor weekly
-- with a 20% decline threshold.


-- ============================================================
-- SQL TECHNIQUES USED
-- ============================================================
-- • CTEs (WITH clause) for intermediate calculations
-- • CASE WHEN for conditional budget reallocation logic
-- • RANK() OVER (PARTITION BY) for window function ranking
-- • NULLIF() to prevent division by zero errors
-- • TO_CHAR() for date extraction and formatting
-- • AVG for ratio metrics (ROAS), SUM for volume metrics (spend, purchases)
-- • Aggregation before division: SUM(purchases)/SUM(clicks), not AVG(rate)
