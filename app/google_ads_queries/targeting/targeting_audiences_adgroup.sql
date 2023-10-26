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
SELECT
    ad_group.id AS ad_group_id,
    ad_group_criterion.type AS type,
    user_interest.taxonomy_type AS user_interest_type,
    user_interest.name AS user_interest_name,
    ad_group_criterion.display_name AS display_name
FROM ad_group_criterion
WHERE
    ad_group_criterion.type IN (
        "COMBINED_AUDIENCE",
        "CUSTOM_AUDIENCE",
        "CUSTOM_AFFINITY",
        "CUSTOM_INTENT",
        "USER_LIST",
        "USER_INTEREST"
    )
    AND ad_group_criterion.status = "ENABLED"
    AND ad_group_criterion.negative = FALSE
