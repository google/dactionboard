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
    customer.id AS customer_id,
    conversion_action.id AS conversion_id,
    conversion_action.include_in_conversions_metric AS include_in_conversions,
    conversion_action.name AS name,
    conversion_action.status AS status,
    conversion_action.type AS type,
    conversion_action.origin AS origin,
    conversion_action.category AS category,
    conversion_action.tag_snippets AS tag_snippets
FROM conversion_action
