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


connection: "redshift_pacific_time"
# Set the week start day to Sunday. Default is Monday
week_start_day: sunday

# include all views in this project
include: "/Views/*.view"

# include all include files
include: "/Includes/*.view"

# include all dashboards in this project
include: "/Dashboards/*.dashboard"

# hidden theme_cache explore supports suggest_explore for theme and subtheme filters
explore: theme_cache {
  hidden: yes
}

# hidden cicy_cache explore supports suggest_explore for the geo filters
explore: geo_cache {
  hidden: yes
}

# hidden site_cache explore supports suggest_explore for the site filter
explore: site_cache {
  hidden: yes

  access_filter: {
    field: page_urlhost
    user_attribute: urlhost
  }
}

explore: page_views {
  persist_for: "10 minutes"
  # exclude when people are viewing files on locally downloaded or hosted copies of webpages
  #sql_always_where: (${page_urlhost} <> 'localhost' OR ${page_urlhost} IS NULL)
  #    AND ${page_url} NOT LIKE '%$/%'
  #    AND ${page_url} NOT LIKE 'file://%' AND ${page_url} NOT LIKE '-file://%' AND ${page_url} NOT LIKE 'mhtml:file://%' ;;

  # adding this access filter to be used by the CMS Lite embed code generator
  #    to allow for page-level dashboards
  access_filter: {
    field: node_id
    user_attribute: node_id
  }
  access_filter: {
    field: page_urlhost
    user_attribute: urlhost
  }
  access_filter: {
    field: page_exclusion_filter
    user_attribute: exclusion_filter
  }
  access_filter: {
    field: app_id
    user_attribute: app_id
  }

  #access filter based on the first part of the URL (eg https://site.com/section/page.html)
  access_filter: {
    field: page_section
    user_attribute: section
  }
  access_filter: {
    field: page_sub_section
    user_attribute: sub_section
  }
  access_filter: {
    field: cmslite_themes.theme_id
    user_attribute: theme
  }

  # sql_always_where: ${page_url} NOT LIKE '%video.web.%' ;; -- Causing problems with video.gov analytics
  join: sessions {
    type: left_outer
    sql_on: ${sessions.session_id} = ${page_views.session_id};;
    relationship: many_to_many
  }

  join: users {
    sql_on: ${page_views.domain_userid} = ${users.domain_userid} ;;
    relationship: many_to_one
  }

  join: cmslite_themes {
    type: left_outer
    sql_on: ${page_views.node_id} = ${cmslite_themes.node_id} ;;
    relationship: one_to_one
  }

  join: gdx_analytics_whitelist {
    type: left_outer
    sql_on: ${page_views.page_urlhost} = ${gdx_analytics_whitelist.urlhost} ;;
    relationship: many_to_one
  }

  join: cmslite_metadata {
    type: left_outer
    sql_on: ${page_views.node_id} = ${cmslite_metadata.node_id};;
    relationship: one_to_one
  }

join: myfs_component_name {
  type:  left_outer
  sql_on: ${page_views.page_view_id} = ${myfs_component_name.id} ;;
  relationship: one_to_one
}

join: myfs_estimates {
  type:  left_outer
  sql_on: ${page_views.page_view_id} = ${myfs_estimates.id} ;;
  relationship: one_to_one
}

  join: performance_timing {
    type: left_outer
    sql_on: ${page_views.page_view_id} = ${performance_timing.page_view_id} ;;
    relationship: one_to_one
  }

}
explore: myfs_estimates {
  persist_for: "10 minutes"

  label: "MyFS Estimates"

  join: page_views {
    type:  left_outer
    sql_on: ${page_views.page_view_id} = ${myfs_estimates.id} ;;
    relationship: one_to_one
  }
}

explore: chatbot {
  persist_for: "2 hours"

  label: "Chatbot"

  join: page_views {
    type:  left_outer
    sql_on: ${page_views.page_view_id} = ${chatbot.id} ;;
    relationship: one_to_one
  }
  join: cmslite_themes {
    type: left_outer
    sql_on: ${page_views.node_id} = ${cmslite_themes.node_id} ;;
    relationship: one_to_one
  }

  access_filter: {
    field: page_views.page_urlhost
    user_attribute: urlhost
  }
}

explore: sessions {
  persist_for: "10 minutes"

  # exclude when people are viewing files on locally downloaded or hosted copies of webpages
  # Note that we are using first_page here instead of page, as there is no "page" for sessions
  #sql_always_where: (${first_page_urlhost} <> 'localhost' OR ${first_page_urlhost} IS NULL)
  #    AND ${first_page_url} NOT LIKE '%$/%'
  #    AND ${first_page_url} NOT LIKE 'file://%' AND ${first_page_url} NOT LIKE '-file://%' AND ${first_page_url} NOT LIKE 'mhtml:file://%';;

  join: users {
    sql_on: ${sessions.domain_userid} = ${users.domain_userid} ;;
    relationship: many_to_one
  }

  join: cmslite_themes {
    type: left_outer
    sql_on: ${sessions.first_page_node_id} = ${cmslite_themes.node_id} ;;
    relationship: one_to_one
  }

  access_filter: {
    field: node_id
    user_attribute: node_id
  }
  access_filter: {
    field: first_page_urlhost
    user_attribute: urlhost
  }
  access_filter: {
    field: first_page_exclusion_filter
    user_attribute: exclusion_filter
  }
  access_filter: {
    field: app_id
    user_attribute: app_id
  }

  #access filter based on the first part of the URL (eg https://site.com/section/page.html)
  access_filter: {
    field: first_page_section
    user_attribute: section
  }
  access_filter: {
    field: first_page_sub_section
    user_attribute: sub_section
  }
  access_filter: {
    field: cmslite_themes.theme_id
    user_attribute: theme
  }
}

explore: users {
  persist_for: "10 minutes"



  # sql_always_where: ${first_page_url} NOT LIKE '%video.web.%' ;; -- Causing problems with Dan's video analytics
}

explore: clicks{
  persist_for: "10 minutes"

  # exclude when people are viewing files on locally downloaded or hosted copies of webpages
  #sql_always_where: (${page_urlhost} <> 'localhost' OR ${page_urlhost} IS NULL)
  #    AND ${page_url} NOT LIKE '%$/%'
  #    AND ${page_url} NOT LIKE 'file://%' AND ${page_url} NOT LIKE '-file://%' AND ${page_url} NOT LIKE 'mhtml:file://%' ;;

  join: cmslite_themes {
    type: left_outer
    sql_on: ${clicks.node_id} = ${cmslite_themes.node_id} ;;
    relationship: one_to_one
  }
  access_filter: {
    field: node_id
    user_attribute: node_id
  }
  access_filter: {
    field: page_urlhost
    user_attribute: urlhost
  }
  access_filter: {
    field: page_exclusion_filter
    user_attribute: exclusion_filter
  }
  access_filter: {
    field: app_id
    user_attribute: app_id
  }
  #access filter based on the first part of the URL (eg https://site.com/section/page.html)
  access_filter: {
    field: page_section
    user_attribute: section
  }
  access_filter: {
    field: page_sub_section
    user_attribute: sub_section
  }
  access_filter: {
    field: cmslite_themes.theme_id
    user_attribute: theme
  }
}

explore: searches {
  persist_for: "10 minutes"
  # exclude when people are viewing files on locally downloaded or hosted copies of webpages
  #sql_always_where: (${page_urlhost} <> 'localhost' OR ${page_urlhost} IS NULL)
  #    AND ${page_url} NOT LIKE '%$/%'
  #    AND ${page_url} NOT LIKE 'file://%' AND ${page_url} NOT LIKE '-file://%' AND ${page_url} NOT LIKE 'mhtml:file://%';;

  join: cmslite_themes {
    type: left_outer
    sql_on: ${searches.node_id} = ${cmslite_themes.node_id} ;;
    relationship: one_to_one
  }
  access_filter: {
    field: node_id
    user_attribute: node_id
  }
  access_filter: {
    field: page_urlhost
    user_attribute: urlhost
  }
  access_filter: {
    field: page_exclusion_filter
    user_attribute: exclusion_filter
  }
  access_filter: {
    field: app_id
    user_attribute: app_id
  }

  #access filter based on the first part of the URL (eg https://site.com/section/page.html)
  access_filter: {
    field: page_section
    user_attribute: section
  }
  access_filter: {
    field: page_sub_section
    user_attribute: sub_section
  }
  access_filter: {
    field: cmslite_themes.theme_id
    user_attribute: theme
  }


}

explore: cmslite_metadata {
  persist_for: "60 minutes"

  access_filter: {
    field: node_id
    user_attribute: node_id
  }
}

explore: esb_se_pathways {
  persist_for: "60 minutes"
  label: "ESB SE Pathways"

  join: page_views {
    type: left_outer
    sql_on: ${page_views.page_urlquery} LIKE 'id=' + ${esb_se_pathways.id} + '%';;
    relationship: many_to_one
  }
}

explore: youtube_embed_video {
  persist_for: "60 minutes"

  join: page_views {
    type: left_outer
    sql_on: ${page_views.page_view_id} = ${youtube_embed_video.page_view_id} ;;
    relationship: many_to_one
  }
  access_filter: {
    field: page_views.page_urlhost
    user_attribute: urlhost
  }
}
explore: forms {
  persist_for: "60 minutes"

  join: page_views {
    type: left_outer
    sql_on: ${page_views.page_view_id} = ${forms.page_view_id} ;;
    relationship: many_to_one
  }
}

explore: asset_downloads {
  persist_for: "60 minutes"

  access_filter: {
    field: asset_downloads.asset_host
    user_attribute: urlhost
  }

  join: cmslite_metadata {
    type: left_outer
    sql_on: ${asset_downloads.asset_url} = ${cmslite_metadata.hr_url} ;;
    relationship: one_to_one
  }
}

explore: performance_timing {
  persist_for: "60 minutes"

  access_filter: {
    field: page_views.page_urlhost
    user_attribute: urlhost
  }

  join: page_views {
    type:  left_outer
    sql_on: ${performance_timing.page_view_id} = ${page_views.page_view_id} ;;
    relationship: one_to_one
  }
}


### Datagroups

datagroup: aa_datagroup_cmsl_loaded {
  label: "Updates with todays date at 4:55AM"
  description: "Triggers CMS Lite Metadata dependent Aggregate Aware tables to rebuild after each new day and after nightly cmslitemetadata microservice has run."
  sql_trigger: SELECT DATE(timezone('America/Vancouver', now() - interval '295 minutes')) ;;
}

### Aggregate Awareness Tables

explore: +clicks {
  aggregate_table: aa__offsite_clicks__7_complete_days__row_count {
    query: {
      dimensions: [
        clicks.target_url,
        clicks.target_display_url,
        clicks.click_type,
        clicks.offsite_click,
        clicks.node_id,
        clicks.page_exclusion_filter,
        clicks.app_id,
        clicks.page_section,
        clicks.page_sub_section,
        clicks.geo_city_and_region,
        cmslite_themes.theme,
        cmslite_themes.subtheme,
        cmslite_themes.theme_id,
        cmslite_themes.node_id,
        cmslite_themes.topic,
        clicks.page_title,
        clicks.page_display_url,
        clicks.page_urlhost,
        clicks.click_time_date,
        clicks.offsite_click_binary
      ]
      measures: [clicks.row_count]
      filters: [
        clicks.click_time_date: "7 days ago for 7 days"
      ]
    }

    materialization: {
      datagroup_trigger: aa_datagroup_cmsl_loaded
    }
  }
}

explore: +searches {
  aggregate_table: aa__top_gov_searches__7_complete_days__row_count {
    query: {
      dimensions: [
        searches.search_terms_gov,
        cmslite_themes.node_id,
        cmslite_themes.theme_id,
        cmslite_themes.theme,
        cmslite_themes.topic,
        cmslite_themes.subtheme,
        searches.search_terms,
        searches.node_id,
        searches.page_display_url,
        searches.page_title,
        searches.page_urlhost,
        searches.page_exclusion_filter,
        searches.app_id,
        searches.page_section,
        searches.page_sub_section,
        searches.geo_city_and_region,
        searches.search_time_date
      ]
      measures: [searches.row_count]
      filters: [
        searches.search_time_date: "7 days ago for 7 days"
      ]
    }

    materialization: {
      datagroup_trigger: aa_datagroup_cmsl_loaded
    }
  }
}

explore: +page_views {
  aggregate_table: aa__top_pages__7_complete_days__row_count{
    query: {
      dimensions: [
        page_views.page_urlhost,
        page_views.node_id,
        page_views.page_exclusion_filter,
        page_views.app_id,
        page_views.page_section,
        page_views.page_sub_section,
        cmslite_themes.theme_id,
        cmslite_themes.theme,
        cmslite_themes.subtheme,
        cmslite_themes.topic,
        page_views.geo_city_and_region,
        page_views.page_title,
        page_views.page_display_url,
        page_views.page_view_start_date
      ]
      measures: [page_views.row_count]
      filters: [
        page_views.page_view_start_date: "7 days ago for 7 days"
      ]
    }

    materialization: {
      datagroup_trigger: aa_datagroup_cmsl_loaded
    }
  }
}
explore: +page_views {  # This matches the previous AA, but adds to referrer fields.
                        # This increases the row couunt by about 1.75x, but supports more reports
  aggregate_table: aa__page_views_with_referrers__7_complete_days__row_count{
    query: {
      dimensions: [
        page_views.page_urlhost,
        page_views.page_referrer,
        page_views.node_id,
        page_views.page_exclusion_filter,
        page_views.app_id,
        page_views.page_section,
        page_views.page_sub_section,
        page_views.referrer_medium,
        cmslite_themes.theme_id,
        cmslite_themes.theme,
        cmslite_themes.subtheme,
        cmslite_themes.topic,
        page_views.geo_city_and_region,
        page_views.page_title,
        page_views.page_display_url,
        page_views.page_view_start_date
      ]
      measures: [page_views.row_count]
      filters: [
        page_views.page_view_start_date: "7 days ago for 7 days"
      ]
    }

    materialization: {
      datagroup_trigger: aa_datagroup_cmsl_loaded
    }
  }
}

explore: +page_views {
  aggregate_table: aa__top_landing_pages__7_complete_days__row_count{
    query: {
      dimensions: [
        page_views.page_urlhost,
        page_views.page_referrer,
        page_views.node_id,
        page_views.page_exclusion_filter,
        page_views.app_id,
        page_views.page_section,
        page_views.page_sub_section,
        cmslite_themes.theme_id,
        cmslite_themes.theme,
        cmslite_themes.subtheme,
        cmslite_themes.topic,
        page_views.geo_city_and_region,
        page_views.page_title,
        page_views.page_display_url,
        page_views.page_view_start_date
      ]
      measures: [page_views.row_count]
      filters: [
        page_views.page_view_start_date: "7 days ago for 7 days",
        page_views.page_view_in_session_index: "1"
      ]
    }

    materialization: {
      datagroup_trigger: aa_datagroup_cmsl_loaded
    }
  }
}
