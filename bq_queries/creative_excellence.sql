-- Copyright 2022 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
CREATE OR REPLACE TABLE {output_dataset}.creative_excellence
AS (
WITH
    /* Creatives block */
    AdsTable AS (
      SELECT
          campaign_id,
          COUNT(DISTINCT ad_id) AS n_ads
      FROM `{bq_dataset}.ad_matching`
      GROUP BY 1
    ),
    SitelinksAdGroupTable AS (
      SELECT
          campaign_id,
          SUM(ARRAY_LENGTH(SPLIT(sitelinks, "|"))) AS n_ad_group_sitelinks
      FROM `{bq_dataset}.sitelinks_ad_group`
      GROUP BY 1
    ),
    SitelinksCampaignTable AS (
      SELECT
          campaign_id,
          SUM(ARRAY_LENGTH(SPLIT(sitelinks, "|"))) AS n_campaign_sitelinks
      FROM `{bq_dataset}.sitelinks_campaign`
      GROUP BY 1
    ),
    SitelinksTable AS (
      SELECT
          campaign_id,
          SUM(n_ad_group_sitelinks) + SUM (n_campaign_sitelinks) AS total_n_sitelinks
      FROM SitelinksCampaignTable
      FULL JOIN SitelinksAdGroupTable
          USING(campaign_id)
      GROUP BY 1
    ),

    /* Audience Block */
    AudienceAdGroupTable AS (
        SELECT
            customer_id,
            campaign_id,
            custom_audience,
            user_list,
            "ad_group" AS level
        FROM `{bq_dataset}.ad_group_criterion`
        WHERE type = "CUSTOM_AUDIENCE"
    ),
    AudienceCampaignTable AS (
        SELECT
            customer_id,
            campaign_id,
            custom_audience,
            user_list,
            "campaign" AS level
        FROM `{bq_dataset}.campaign_criterion`
        WHERE type = "CUSTOM_AUDIENCE"
    ),
    AudienceTable AS (
        SELECT * FROM AudienceAdGroupTable
        UNION ALL
        SELECT * FROM AudienceCampaignTable
    ),
    CombinedAudience AS (
        SELECT DISTINCT
            A.customer_id
        FROM AudienceTable AS A
        LEFT JOIN `{bq_dataset}.custom_audience` AS C
            ON SPLIT(A.custom_audience, "/")[SAFE_OFFSET(3)] = CAST(C.audience_id AS STRING)
        WHERE C.type = "SEARCH"
    ),
    RemarketingTable AS (
        SELECT DISTINCT customer_id FROM AudienceTable
        WHERE user_list IS NOT NULL
    ),
    CampaignOptimizedTargetingCriteria AS (
        SELECT DISTINCT customer_id, campaign_id
        FROM `{bq_dataset}.ad_group_criterion`
        WHERE is_auto_targeting
    ),
    OptimizedTargetingCriteria AS (
        SELECT DISTINCT customer_id
        FROM CampaignOptimizedTargetingCriteria
    ),
    TargetingCriteriaTable AS (
        SELECT
            customer_id,
            CAST(
                MAX(
                IF(O.customer_id > 0 AND (
                    C.customer_id > 0 OR R.customer_id > 0
                ), 1, 0
                )
            )
            AS BOOL) AS is_audience_optimized
        FROM CombinedAudience AS C
        FULL JOIN RemarketingTable  AS R
            USING(customer_id)
        FULL JOIN OptimizedTargetingCriteria AS O
            USING(customer_id)
            GROUP BY 1
    ),

    /* Budget/Bid Ratio Block */
    BudgetDailyTable AS (
        SELECT
            campaign_id,
            bidding_strategy,
            target_cpa,
            cost,
            conversions,
            IF(
                budget_period = "DAILY", budget_amount,
                total_budget / (
                    DATE_DIFF(DATE(end_date), DATE(start_date), DAY))
                  ) AS daily_budget
        FROM `{bq_dataset}.campaign`
    ),
    BidBudgetTable AS (
        SELECT
            campaign_id,
            CASE
                WHEN bidding_strategy = "TARGET_CPA"
                    AND SAFE_DIVIDE(daily_budget, target_cpa) >= 15 THEN ">15"
                            WHEN bidding_strategy = "TARGET_CPA" THEN "<15"
                            WHEN bidding_strategy = "MAXIMIZE_CONVERSIONS"
                    AND conversions = 0 THEN  "Not applicable"
                            WHEN bidding_strategy = "MAXIMIZE_CONVERSIONS"
                    AND SAFE_DIVIDE(
                  daily_budget,
                  SAFE_DIVIDE(cost, conversions)
                    ) >= 10 THEN ">10"
                WHEN bidding_strategy = "MAXIMIZE_CONVERSIONS" THEN "<10"
                ELSE NULL
                END AS bid_budget_ratio
        FROM BudgetDailyTable
    ),
    /*Website Conversion Tracking Block*/
    WebPageConversionsTable AS (
        SELECT
            customer_id,
            conversion_id,
            include_in_conversions
        FROM `{bq_dataset}.conversion_action`
        WHERE
            origin = "WEBSITE" AND tag_snippets != ""
            OR type = "WEBPAGE"
    ),
    AccountWebPageConversionTrackingTable AS (
        SELECT DISTINCT
            customer_id,
            TRUE AS is_account_webpage_tracking
        FROM WebPageConversionsTable
        WHERE include_in_conversions
    ),
    CampaignAllConversionTrackingSelectiveOptimizationTable AS (
        SELECT
            campaign_id,
            COUNT(DISTINCT AllConversions.conversion_id) AS n_conversions
        FROM `{bq_dataset}.campaign`,
        UNNEST(SPLIT(selective_optimization_conversion_actions, "|")) AS conversion_id
        LEFT JOIN `{bq_dataset}.conversion_action` AS AllConversions
            ON conversion_id = CAST(AllConversions.conversion_id AS STRING)
        WHERE selective_optimization_conversion_actions != ""
        GROUP BY 1
    ),
    CampaignAllConversionTrackingCustomGoalsTable AS (
        SELECT
            campaign_id,
            COUNT(DISTINCT AllConversions.conversion_id) AS n_conversions
        FROM `{bq_dataset}.conversion_goal_campaign_config`,
        UNNEST(SPLIT(actions, "|")) AS conversion_id
        LEFT JOIN `{bq_dataset}.conversion_action` AS AllConversions
            ON conversion_id = CAST(AllConversions.conversion_id AS STRING)
        WHERE actions != ""
        GROUP BY 1
    ),
    CampaignWebPageConversionTrackingSelectiveOptimizationTable AS (
        SELECT
            campaign_id,
            COUNT(DISTINCT WebPageConversions.conversion_id) AS n_webpage_conversions
        FROM `{bq_dataset}.campaign`,
        UNNEST(SPLIT(selective_optimization_conversion_actions, "|")) AS conversion_id
        LEFT JOIN `{bq_dataset}.conversion_action` AS WebPageConversions
            ON conversion_id = CAST(WebPageConversions.conversion_id AS STRING)
        WHERE selective_optimization_conversion_actions != ""
        GROUP BY 1
    ),
    CampaignWebPageConversionTrackingCustomGoalsTable AS (
        SELECT
            campaign_id,
            COUNT(DISTINCT WebPageConversions.conversion_id) AS n_webpage_conversions
        FROM `{bq_dataset}.conversion_goal_campaign_config`,
        UNNEST(SPLIT(actions, "|")) AS conversion_id
        LEFT JOIN `{bq_dataset}.conversion_action` AS WebPageConversions
            ON conversion_id = CAST(WebPageConversions.conversion_id AS STRING)
        WHERE actions != ""
        GROUP BY 1
    ),
    CampaignAllConversionTrackingTable AS (
        SELECT
            campaign_id
        FROM CampaignAllConversionTrackingCustomGoalsTable
        WHERE n_conversions > 0
        UNION DISTINCT
        SELECT
            campaign_id
        FROM CampaignAllConversionTrackingSelectiveOptimizationTable
        WHERE n_conversions > 0
    ),
    CampaignWebPageConversionTrackingTable AS (
        SELECT
            campaign_id
        FROM CampaignWebPageConversionTrackingCustomGoalsTable
        WHERE n_webpage_conversions > 0
        UNION DISTINCT
        SELECT
            campaign_id
        FROM CampaignWebPageConversionTrackingSelectiveOptimizationTable
        WHERE n_webpage_conversions > 0
    ),
    WebPageConversionTrackingtable AS (
        SELECT
            campaign_id,
            IF(CW.campaign_id IS NOT NULL,
                TRUE,
                IFNULL(is_account_webpage_tracking, FALSE)
                    AND CN.campaign_id IS NULL) AS is_webpage_tracking
        FROM `{bq_dataset}.campaign` AS C
        LEFT JOIN CampaignAllConversionTrackingTable AS CN
            USING(campaign_id)
        LEFT JOIN CampaignWebPageConversionTrackingTable AS CW
            USING(campaign_id)
        LEFT JOIN AccountWebPageConversionTrackingTable AS A
            USING(customer_id)
    ),
    CreativeExcellenceTable AS (
      SELECT
          C.campaign_id AS campaign_id,
          C.bidding_strategy AS bidding_strategy,
          C.start_date AS start_date,
          C.end_date AS end_date,
          IF(CO.campaign_id > 0, TRUE, FALSE) AS has_auto_targeting,
          IF(S.total_n_sitelinks > 0, TRUE, FALSE) AS has_sitelinks,
          /* buckets */
          IFNULL(W.is_webpage_tracking, FALSE) AS conversions_bucket,
          IFNULL(B.bid_budget_ratio, "") AS budget_bid_ratio_bucket,
          IFNULL(T.is_audience_optimized, FALSE) AS audience_bucket,
          IF(
        IFNULL(S.total_n_sitelinks, 0) > 0 OR IFNULL(A.n_ads, 0) >= 5,
        "Creative >= 5 OR Has sitelink", "Creative < 5"
          ) AS creatives_bucket,
          /* boolean flags */
          IFNULL(W.is_webpage_tracking, FALSE) AS is_conversions_optimized,
          IF(
        B.bid_budget_ratio IN (">15", ">10"),
        TRUE, FALSE) AS is_bid_budget_optimized,
          IFNULL(T.is_audience_optimized, FALSE) AS is_audience_optimized,
          IF(
        IFNULL(S.total_n_sitelinks, 0) > 0 OR IFNULL(A.n_ads, 0) >= 5,
        TRUE, FALSE
          ) AS is_creative_optimized,
          cost
         FROM `{bq_dataset}.campaign` AS C
         LEFT JOIN WebPageConversionTrackingtable AS W
            USING(campaign_id)
         LEFT JOIN BidBudgetTable AS B
            USING(campaign_id)
         LEFT JOIN SitelinksTable AS S
            USING(campaign_id)
         LEFT JOIN AdsTable AS A
            USING(campaign_id)
         LEFT JOIN CampaignOptimizedTargetingCriteria AS CO
            USING(campaign_id, customer_id)
         LEFT JOIN TargetingCriteriaTable AS T
            USING(customer_id)
    ),
    MappingTable AS (
      SELECT DISTINCT
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        campaign_status,
        bidding_strategy,
      FROM {bq_dataset}.mapping
    )
SELECT
    M.account_id,
    M.account_name,
    M.campaign_id,
    M.campaign_name,
    M.campaign_status,
    M.bidding_strategy,
    start_date,
    end_date,
    creatives_bucket,
    audience_bucket,
    budget_bid_ratio_bucket,
    conversions_bucket,
    is_audience_optimized,
    is_bid_budget_optimized,
    is_conversions_optimized,
    is_creative_optimized,
    (
        CAST(is_audience_optimized AS INT) +
        CAST(is_bid_budget_optimized AS INT) +
        CAST(is_conversions_optimized AS INT) +
        CAST(is_creative_optimized AS INT)
        ) / 4 AS perc_bp_score,
    IF(
        is_audience_optimized
        AND is_bid_budget_optimized
        AND is_conversions_optimized
        AND is_creative_optimized,
        "Check Advanced Best Practices.",
        CONCAT(
        "Optimize: ",
        IF(is_audience_optimized, "", "| Audience "),
        IF(is_bid_budget_optimized, "", "| Budget/Bid "),
        IF(is_conversions_optimized, "", "| Conversions "),
        IF(is_creative_optimized, "", "| Creatives")
        )) AS summary,
    has_auto_targeting,
    has_sitelinks,
    ROUND(cost / 1e6, 2) AS cost_last_7_days
FROM CreativeExcellenceTable
LEFT JOIN MappingTable AS M
    USING(campaign_id));
