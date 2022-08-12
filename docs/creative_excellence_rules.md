# Creative Excellence Explained

The goal of creative excellence is to highlight which campaigns in the account might be improved by following optimization advises.

Creative excellence contains 4 blocks:

* Audience
* Creatives
* Bids/Budgets
* Conversions


Each block counts as 25% of overall 100% creative excellence.

## Audience

In order for campaign to meet **audience** creative excellence criteria it should safisty two rules:
* At least one campaign in account should use Remarketing or Combine Audience (of type *SEARCH*) as a targeting criteria.
* At least one campaign should use [optimized targeting](https://developers.google.com/google-ads/api/fields/v11/ad_group#ad_group.explorer_auto_optimizer_setting.opt_in)


## Creatives

In order for campaign to meet *creatives* creative excellence criteria it should safisty either one of two rules:

* Number of unique [ad_id](https://developers.google.com/google-ads/api/fields/v11/ad_group_ad#ad_group_ad.ad.id) in campaign should be greater or equal 5.
* Campaign should have at least one sitelink. Sitelink can exists on [campaign](https://developers.google.com/google-ads/api/fields/v11/campaign_extension_setting) or [ad_group](https://developers.google.com/google-ads/api/fields/v11/ad_group_extension_setting) levels

## Bids / Budgets

In order for campaign to meet **bid/budget** creative excellence criteria it should safisty one of the following rules (depending on campaign bidding strategy type):

* For campaigns with bidding strategy *Target CPA* the ratio between daily budget and bid should be greater than 15 (`budget / target_cpa >= 15`)
* For campaigns with bidding strategy *Maximize Conversions*  the ratio between daily budget and average CPA over the last 7 days should be greater than 10 (`budget / (cost_last_7_days / conversions_last_7_days)) >= 10`)

Some campaigns don't have a daily budget but a total one, we need to convert it to daily budget in order to calculate the **bid/budget** creative excellence.

We get [campaign_budget.total_amount_micros](https://developers.google.com/google-ads/api/fields/v11/campaign_budget#campaign_budget.total_amount_micros)
and [campaign.start_date](https://developers.google.com/google-ads/api/fields/v11/campaign#campaign.start_date)
and [campaign.end_date](https://developers.google.com/google-ads/api/fields/v11/campaign#campaign.end_date) and divide total budget by the difference between start and end_date (`daily_budget = total_budget / (end_date - start_date) + 1`)

## Conversions

In order for campaign to meet **conversions** creative excellence criteria it should optimize toward a conversion of type `WEBPAGE`.


Such conversion optimization might come from multple levels:

* From account or MCC (when conversion action of type `WEBPAGE` is included in conversions)
* From campaign selective optimization (when campaign specifically optimizes towards a conversion action of type `WEBPAGE`)
* From campaign custom goal optimization (when campaign optimizes towards a custom goal which contains as least one conversion actions of type `WEBPAGE`)

Campaign optimizations have priority over account and MCC ones - if campaign is optimizes towards conversion action with a type other that `WEBPAGE` or custom goal that does not contain a conversion action with type `WEBPAGE` that it will be marked as *non-excellent* even if `WEBPAGE` conversion action is present in account / MCC.
