# ShopFlow Channel Mix & Attribution Analysis

**Budget optimization for a Berlin e-commerce company — identifying €20,103 in projected revenue gains through placement-level reallocation, without increasing total spend.**

## Business Problem

ShopFlow spent €119,545 across three channels (Google Search, Meta Ads, TikTok Ads) in Q1 2025. The CMO needed to know where to invest next quarter's budget, but every channel manager was claiming credit for the same conversions. The team relied on last-click attribution in Google Analytics — a model that systematically overvalues the last touchpoint and ignores upper-funnel contribution.

## Key Findings

**1. Last-click attribution masks the truth**
Google Search appeared dominant at 2.45× ROAS, while TikTok looked like a total loss at 0.36×. A junior analyst would cut TikTok immediately.

**2. Branded search tells the real story**
75% of Google's conversions came from branded search — customers who already knew ShopFlow before they Googled. Strip out branded search and Google's ROAS drops from 2.45× to 1.17×, barely breaking even. TikTok and Meta create the brand awareness that Google captures credit for.

**3. €12,569 in wasted spend identified**
Three placements — Brand Takeover (€2,715), Display Network (€4,500), and TopView (€5,353) — consumed 10.5% of total budget while generating only 3 purchases combined.

**4. €20,103 projected revenue gain from reallocation**
Reallocating freed budget to Search Top (+€4,000), Instagram Stories (+€5,000), and In-Feed TikTok (+€3,569) generates a 17% revenue uplift — without increasing total spend.

**5. All channels flat or declining**
ROAS stagnated across all three channels in Q1, suggesting seasonal headwinds or market saturation. Budget reallocation improves efficiency but won't reverse a broader demand slowdown.

## Analytical Framework

| Layer | Question | Approach |
|-------|----------|----------|
| Descriptive | How did each channel perform? | Channel-level KPI comparison |
| Diagnostic | Can we trust these numbers? | Branded vs non-branded search decomposition |
| Placement Efficiency | Where is money being wasted? | 12-placement drill-down with CPA and ROAS |
| Time Trends | Is performance improving or declining? | Monthly breakdown with RANK() window functions |
| Prescriptive | What should we do about it? | Budget reallocation model with projected revenue impact |

## Recommendations

**Immediate (Week 1–2)**
- Cut Brand Takeover, Display Network, and TopView — freeing €12,569
- Reallocate to Instagram Stories, Search Top, and In-Feed TikTok
- Set weekly ROAS monitoring with a 20% decline threshold

**Short-Term (Month 1)**
- Run a 4-week geo-holdout test: pause TikTok in one market to measure its incremental impact on Google and Meta conversions
- A/B test TikTok creatives targeting 25% CVR improvement within 30 days

**Medium-Term (Month 2–3)**
- Migrate from last-click to data-driven attribution within 60 days
- If TikTok creative improvements fail, reallocate based on new attribution data — not last-click

## Dataset

| Attribute | Detail |
|-----------|--------|
| Rows | 1,080 |
| Period | January 1 – March 31, 2025 |
| Channels | Google Search, Meta Ads, TikTok Ads |
| Placements | 12 (4 per channel) |
| Columns | date, channel, placement, impressions, clicks, ctr, cpc, amount_spent, purchases, purchase_value, roas, cpa, search_type |

Synthetic data modelling real e-commerce patterns. Intentionally structured so Google appears strongest and TikTok weakest under last-click attribution — creating a built-in analytical trap that mirrors real-world attribution challenges.

## Tools & SQL Techniques

**Tools:** PostgreSQL 17, pgAdmin 4, Looker Studio

**SQL techniques used:**
- CTEs (WITH clause) for intermediate calculations
- CASE WHEN for conditional budget reallocation logic
- RANK() OVER (PARTITION BY) for window function ranking
- NULLIF() to prevent division by zero errors
- TO_CHAR() for date extraction and formatting
- AVG for ratio metrics (ROAS), SUM for volume metrics (spend, purchases)

## Dashboard

Case study document: https://docs.google.com/document/d/1AnmV4tF9UYSPy86YOqo5FR-3otkNFNlW/edit?usp=sharing&ouid=113948822083193510761&rtpof=true&sd=true

Looker studio visualisation: https://lookerstudio.google.com/reporting/1b308ab5-baa0-4574-8e63-dda8d391fa56



