# Copyright (c) 2016 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
#
# Version:     0.1.0
#
# Authors:     Christophe Bogaert, Keane Robinson
# Copyright:   Copyright (c) 2016 Snowplow Analytics Ltd
# License:     Apache License Version 2.0

connection: "redshift"

# include all views in this project
include: "*.view"

# include all dashboards in this project
include: "*.dashboard"

explore: page_views {
  sql_always_where: ${page_url} NOT LIKE '%video.web.%' ;;
  join: sessions {
    sql_on: ${page_views.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: users {
    sql_on: ${page_views.user_snowplow_domain_id} = ${users.user_snowplow_domain_id} ;;
    relationship: many_to_one
  }

  join: page_views_rollup {
    sql_on: ${page_views_rollup.session_start_raw} = ${sessions.session_start_date} ;;
    relationship: one_to_many
  }

  join: sessions_rollup {
    sql_on: ${sessions_rollup.session_id} = ${sessions.session_id} ;;
    type: left_outer
    relationship: many_to_many
  }
}

explore: sessions {
  join: users {
    sql_on: ${sessions.user_snowplow_domain_id} = ${users.user_snowplow_domain_id} ;;
    relationship: many_to_one
  }
}

explore: users {
  sql_always_where: ${first_page_url} NOT LIKE '%video.web.%' ;;
}

explore: aggregated_table_sample_citizens {}

explore: wait_time_table_sample_citizens {}
