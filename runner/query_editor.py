# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import utils
import re


def read_query(path):
    with open(path, "r") as f:
        query = f.readlines()
    return query


# read Ads query from file
def get_query_elements(path):
    query_lines = read_query(path)
    query_text = "".join(query_lines)
    fields = []
    column_names = []
    pointers = {}
    nested_fields = {}
    resource_indices = {}
    # iterate over each line of file to extract field_names and column_names
    for line in query_lines:
        # exclude SELECT keyword
        if line.upper().startswith("SELECT"):
            continue
        # exclude everything that goes after FROM statement
        if line.upper().startswith("FROM"):
            break
        # get fields and aliases
        line_elements_raw = re.split(" [Aa][Ss] ", line)
        # extract unselectable fields
        resource_elements = re.split("~", line_elements_raw[0])
        line_elements = re.split("->", line_elements_raw[0])
        fields_with_nested = re.split(":", line_elements[0])
        # if there's `type` element rename it to `type_` in order to fetch it
        if len(resource_elements) == 1:
            field_name = re.sub("\\.type", ".type_",
                                utils.get_element(fields_with_nested, 0))
        else:
            field_name = utils.get_element(resource_elements, 0)
        try:
            pointers[field_name] = utils.get_element(line_elements, 1)
        except:
            pass
        try:
            nested_field = utils.get_element(fields_with_nested, 1)
            if nested_fields.get(field_name):
                nested_fields.get(field_name).append(nested_field)
            else:
                nested_fields[field_name] = [nested_field]
        except:
            pass
        fields.append(field_name)
        try:
            column_name = utils.get_element(line_elements_raw, 1)
        except:
            column_name = field_name
        try:
            resource_indices[field_name] = utils.get_element(resource_elements, 1)
        except:
            pass
        column_names.append(column_name)
    return (query_text, fields, column_names, pointers, nested_fields, resource_indices)
