# dActionBoard

## Creative Excellence calculation and requirements


Creative excellence contains 4 blocks:

* Audience
* Creatives
* Bids/Budgets
* Conversions

## Audience

Three types of audience:
- [x]  Remarketing
    - [x] [Campaign](https://developers.google.com/google-ads/api/fields/v9/campaign_criterion#campaign_criterion.user_list.user_list) and [ad_group](https://developers.google.com/google-ads/api/fields/v9/ad_group_criterion#ad_group_criterion.user_list.user_list) level, [non negative](https://developers.google.com/google-ads/api/fields/v9/ad_group_criterion#ad_group_criterion.negative).
 - [x]  [Combined audience](https://developers.google.com/google-ads/api/fields/v9/combined_audience) - [campaign](https://developers.google.com/google-ads/api/fields/v9/campaign_criterion#campaign_criterion.combined_audience.combined_audience) and [ad_group](https://developers.google.com/google-ads/api/fields/v9/ad_group_criterion#ad_group_criterion.combined_audience.combined_audience)


    Should be [optimized targeting](https://developers.google.com/google-ads/api/fields/v9/ad_group#ad_group.explorer_auto_optimizer_setting.opt_in)


## Creatives

- [x] Number of unique [ad_id](https://developers.google.com/google-ads/api/fields/v9/ad_group_ad#ad_group_ad.ad.id) >= 5 (should we perform deduplication?)
- OR
- [x] At least one sitelink. Sitelink should exists on [campaign](https://developers.google.com/google-ads/api/fields/v9/campaign_extension_setting) or [ad_group](https://developers.google.com/google-ads/api/fields/v9/ad_group_extension_setting) levels

## Bids / Budgets

- [x] [campaign.bidding_strategy_type](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.bidding_strategy_type)
- [x] Target Bid:
    - [x] [campaign.target_cpa.target_cpa](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.target_cpa.target_cpa_micros)
    - [x] [campaign.target_cpa.target_roas](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.target_roas.target_roas)
    - [x] [campaign.maximize_conversions.target_cpa](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.maximize_conversions.target_cpa)

- [x] Daily budget

    Some campaigns have total budget, then we need to fetch it and other entities to convert it to daily budget:
    - [x] Total budget - [campaign_budget.total_amount_micros](https://developers.google.com/google-ads/api/fields/v9/campaign_budget#campaign_budget.total_amount_micros)
    - [x] Campaign start_date [campaign.start_date](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.start_date)
    - [x] Campaign end_date [ campaign.end_date](https://developers.google.com/google-ads/api/fields/v9/campaign#campaign.end_date)

## Conversions

- [ ] Has conversion tracking (can be inferred or taken from MCC level (customer.conversion_tracking_setting.cross_account_conversion_tracking_id).
- [ ] Conversion tracking type should be WEBPAGE (found in [conversion_action](https://developers.google.com/google-ads/api/fields/v9/conversion_action)
    TODO: verify that only `WEBPAGE` is allowed

## Performance dimensions


 - [x] geo_performance - geo_performance.sql
  Can be speficified on multiple levels (country, state, province, city, etc.)
 - [x] ad_performance - ad_performance.sql
 - [ ] ad_group_performance - ad_performance.sql
 - [ ] age_performance - age_performance.sql
 - [ ] gender_performance
 - [ ] device_performance - ad_performance.sql
 - [ ] ad_conversion_split
