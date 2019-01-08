view: shared_fields_common {

  ### Application

  dimension: app_id {
    description: "The application identifier from which the event originated."
    type: string
    sql: ${TABLE}.app_id ;;
    group_label: "Application"
  }

  # dcs_id
  # The DCS identifieir is the webtrends profile identifier
  # this is only available for WebTrends data
  dimension: dcs_id {
    description: "The Webtrends profile identifier."
    type: string
    sql: ${TABLE}.dcs_id ;;
    group_label: "Application"
  }

  ### Browser

  dimension: useragent {
    description: "The useragent string for this session."
    hidden: yes
    type: string
    sql: ${TABLE}.useragent ;;
    group_label: "Browser"
  }

  dimension: browser_name {
    description: "The browser name. Depending on the browser, name often matches the family, but can also include major version numbers."
    type: string
    sql: ${TABLE}.br_name ;;
    group_label: "Browser"
  }

  dimension: browser_family {
    description: "The major family of browser, regardless of name or version. e.g., Chrome, Safari, Internet Explorer, etc."
    type: string
    sql: ${TABLE}.br_family ;;
    group_label: "Browser"
  }

  dimension: browser_version {
    description: "The specific version number of the browser."
    type: string
    sql: ${TABLE}.br_version ;;
    group_label: "Browser"
  }

  dimension: browser_type {
    description: "Browser types can be mobile or non-mobile."
    type: string
    sql: ${TABLE}.br_type ;;
    group_label: "Browser"
  }

  dimension: browser_engine {
    description: "The browser rendering engine name. e.g.: Blink, WebKit, Trident."
    type: string
    sql: ${TABLE}.br_renderengine ;;
    group_label: "Browser"
  }

  dimension: browser_language {
    description: "The language the browser is set to for localization."
    type: string
    sql: ${TABLE}.br_lang ;;
    group_label: "Browser"
  }

  # browser_view_height is not in Sessions

  dimension: browser_view_height {
    description: "The browser viewport height in pixels."
    type: number
    sql: ${TABLE}.br_viewheight ;;
    group_label: "Browser"
  }

  # browser_view_width is not in Sessions
  dimension: browser_view_width {
    description: "The browser viewport width in pixels."
    type: number
    sql: ${TABLE}.br_viewwidth ;;
    group_label: "Browser"
  }

# Location

  dimension: geo_country {
    type: string
    sql: ${TABLE}.geo_country ;;
    group_label: "Location"
  }

  dimension: geo_region {
    type: string
    sql: ${TABLE}.geo_region ;;
    group_label: "Location"
  }

  dimension: geo_region_name {
    type: string
    sql: ${TABLE}.geo_region_name ;;
    group_label: "Location"
  }

  dimension: geo_city {
    type: string
    sql: ${TABLE}.geo_city ;;
    group_label: "Location"
  }

  dimension: geo_zipcode {
    type: zipcode
    sql: ${TABLE}.geo_zipcode ;;
    group_label: "Location"
  }

  dimension: geo_latitude {
    type: number
    sql: ${TABLE}.geo_latitude ;;
    group_label: "Location"
    # use geo_location instead
    hidden: yes
  }

  dimension: geo_longitude {
    type: number
    sql: ${TABLE}.geo_longitude ;;
    group_label: "Location"
    # use geo_location instead
    hidden: yes
  }

  dimension: geo_timezone {
    type: string
    sql: ${TABLE}.geo_timezone ;;
    group_label: "Location"
    # use os_timezone instead
    hidden: yes
  }

  dimension: geo_location {
    type: location
    sql_latitude: ${geo_latitude} ;;
    sql_longitude: ${geo_longitude} ;;
    group_label: "Location"
  }

  ### Session

  # session_id: string
  # Table reference - VARCHAR(255)
  #
  # session_id is a unique identifier for a session based on the device IP address and timestamp.
  # It comes from:
  # derived.sessions session_id
  # > derived.page_views_webtrends session_id
  #   > derved.events domain_sessionid
  #     > webtrends.events wt_co_f
  #
  # References:
  #
  # * https://github.com/snowplow-proservices/ca.bc.gov-schema-registry/blob/master/webtrends_migration/redshift/03_copy_data_into_derived_events.sql
  # * https://github.com/snowplow-proservices/ca.bc.gov-schema-registry/blob/master/webtrends_migration/redshift/05_derived_sessions_webtrends.sql
  # * https://help.webtrends.com/legacy/en/dcapi/dc_api_identifying_visitors.html
  dimension: session_id {
    description: "A unique identifier for a given user session, based on IP and timestamp."
    type: string
    sql: ${TABLE}.session_id ;;
    group_label: "Session"
  }

  # session_index: number
  # Table reference: INTEGER
  #
  # session_index is the user's current session number indexed from 1.
  # In this context, users are identified using a User ID set by Snowplow using 1st party cookie.
  #
  # from 05_derived_sessions_webtrends.sql:
  # ROW_NUMBER() OVER (PARTITION BY a.user_snowplow_domain_id ORDER BY a.page_view_start) AS session_index
  #
  # References:
  # * https://github.com/snowplow-proservices/ca.bc.gov-schema-registry/blob/master/webtrends_migration/redshift/05_derived_sessions_webtrends.sql
  dimension: session_index {
    description: "A page load index, starting at 1 on the first page visited. Can be used in path analysis."
    type: number
    sql: ${TABLE}.session_index ;;
    group_label: "Session"
#     hidden: yes
  }

  # first_or_returning_session: string
  #
  # A label to discern a user's "first session" from every subsequent "returning session".
  dimension: first_or_returning_session {
    type: string

    case: {
      when: {
        sql: ${session_index} = 1 ;;
        label: "First session"
      }

      when: {
        sql: ${session_index} > 1 ;;
        label: "Returning session"
      }

      else: "Error"
    }

    group_label: "Session"
    hidden: yes
  }

  ### User

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
    group_label: "User"
  }

  dimension: domain_userid {
    type: string
    sql: ${TABLE}.domain_userid ;;
    group_label: "User"
  }

  dimension: network_userid {
    type: string
    sql: ${TABLE}.network_userid ;;
    group_label: "User"
    hidden: yes
  }

### Referer

  dimension: referer_urlscheme {
    type: string
    sql: ${TABLE}.refr_urlscheme ;;
    group_label: "Referer"
    hidden: yes
  }

  dimension: referer_urlhost {
    type: string
    sql: ${TABLE}.refr_urlhost ;;
    group_label: "Referer"
  }

  # dimension: referer_urlport {
  # type: number
  # sql: ${TABLE}.refr_urlport ;;
  # group_label: "Referer"
  # hidden: yes
  # }

  dimension: referer_urlpath {
    type: string
    sql: ${TABLE}.refr_urlpath ;;
    group_label: "Referer"
  }

  dimension: referer_urlquery {
    type: string
    sql: ${TABLE}.refr_urlquery ;;
    group_label: "Referer"
  }

  # dimension: referer_urlfragment {
  # type: string
  # sql: ${TABLE}.refr_urlfragment ;;
  # group_label: "Referer"
  # }

  dimension: referer_medium {
    type: string
    sql: ${TABLE}.refr_medium ;;
    group_label: "Referer"
  }

  dimension: referer_source {
    type: string
    sql: ${TABLE}.refr_source ;;
    group_label: "Referer"
  }

  dimension: referer_term {
    type: string
    sql: ${TABLE}.refr_term ;;
    group_label: "Referer"
  }

  ### Marketing

  dimension: marketing_medium {
    type: string
    sql: ${TABLE}.mkt_medium ;;
    group_label: "Marketing"
  }

  dimension: marketing_source {
    type: string
    sql: ${TABLE}.mkt_source ;;
    group_label: "Marketing"
  }

  dimension: marketing_term {
    type: string
    sql: ${TABLE}.mkt_term ;;
    group_label: "Marketing"
  }

  dimension: marketing_content {
    type: string
    sql: ${TABLE}.mkt_content ;;
    group_label: "Marketing"
  }

  dimension: marketing_campaign {
    type: string
    sql: ${TABLE}.mkt_campaign ;;
    group_label: "Marketing"
  }

  dimension: marketing_clickid {
    type: string
    sql: ${TABLE}.mkt_clickid ;;
    group_label: "Marketing"
  }

  dimension: marketing_network {
    type: string
    sql: ${TABLE}.mkt_network ;;
    group_label: "Marketing"
  }

  dimension: marketing_channel {
    type: string
    sql: ${TABLE}.channel ;;
    group_label: "Marketing"
  }

  ### IP

  dimension: ip_address {
    description: "The user's IP address, with the final octet replaced with \"1\" to remove personally identifiable information."
    type: string
    sql: ${TABLE}.user_ipaddress ;;
    group_label: "IP"
  }

  dimension: is_government {
    description: "Yes if the IP address maps to a known BC Government network."
    # the filter is put in this view because the IP is defined here in this view
    # ATTENTION: This is_government filter is replicated by both page_views.view.lkml and sessions.view.lkml. ANY update to this code block must also be reflected in the corresponding code block of the other lkml file
    type: yesno
    # the filter is checking to see if the IP is in the gov network
    sql: ${ip_address} LIKE '142.22.%' OR ${ip_address} LIKE '142.23.%' OR ${ip_address} LIKE '142.24.%' OR ${ip_address} LIKE '142.25.%' OR ${ip_address} LIKE '142.26.%' OR ${ip_address} LIKE '142.27.%' OR ${ip_address} LIKE '142.28.%' OR ${ip_address} LIKE '142.29.%' OR ${ip_address} LIKE '142.30.%' OR ${ip_address} LIKE '142.31.%' OR  ${ip_address} LIKE '142.32.%' OR ${ip_address} LIKE '142.33.%' OR ${ip_address} LIKE '142.34.%' OR ${ip_address} LIKE '142.35.%' OR ${ip_address} LIKE '142.36.%' ;;
  }

  # dimension: ip_isp {
  # type: string
  # sql: ${TABLE}.ip_isp ;;
  # group_label: "IP"
  # }

  # dimension: ip_organization {
  # type: string
  # sql: ${TABLE}.ip_organization ;;
  # group_label: "IP"
  # }

  # dimension: ip_domain {
  # type: string
  # sql: ${TABLE}.ip_domain ;;
  # group_label: "IP"
  # }

  # dimension: ip_net_speed {
  # type: string
  # sql: ${TABLE}.ip_net_speed ;;
  # group_label: "IP"
  # }

  ### OS

  # dimension: os {
  # type: string
  # sql: ${TABLE}.os ;;
  # group_label: "OS"
  # }

  dimension: os_name {
    type: string
    sql: ${TABLE}.os_name ;;
    group_label: "OS"
  }

  dimension: os_family {
    type: string
    sql: ${TABLE}.os_family ;;
    group_label: "OS"
  }

  dimension: os_version {
    type: string
    sql: ${TABLE}.os_version ;;
    group_label: "OS"
  }

  # dimension: os_minor_version {
  # type: string
  # sql: ${TABLE}.os_minor_version ;;
  # group_label: "OS"
  # }

  # dimension: os_build_version {
  # type: string
  # sql: ${TABLE}.os_build_version ;;
  # group_label: "OS"
  # }

  dimension: os_manufacturer {
    type: string
    sql: ${TABLE}.os_manufacturer ;;
    group_label: "OS"
  }

  dimension: os_timezone {
    type: string
    sql: ${TABLE}.os_timezone ;;
    group_label: "OS"
  }

  ### Page

  dimension: page_absolute_uri {
    label: "Page Absolute URI"
    description: "Absolute URI is comprised of the scheme, authority, path, and query"
    sql: CASE
           WHEN ${page_urlquery} = ''
             THEN 'http://' || ${page_url}
           ELSE 'http://' || ${page_url} || '?' || RTRIM(${page_urlquery},'&')
         END;;
    group_label: "Page"
  }

  dimension: page_url {
    description: "The web page URL."
    type: string
    sql: ${TABLE}.page_url ;;
    group_label: "Page"
  }

  dimension: node_id {
    description: "The CMS Lite node identifier for Gov pages."
    type: string
    sql: ${TABLE}.node_id;;
    group_label: "Page"
  }

  # dimension: page_url_scheme {
  # type: string
  # sql: ${TABLE}.page_url_scheme ;;
  # group_label: "Page"
  # hidden: yes
  # }

  dimension: page_urlhost {
    description: "The web page domain or host."
    type: string
    sql: ${TABLE}.page_urlhost ;;
    group_label: "Page"
  }

  # dimension: page_url_port {
  # type: number
  # sql: ${TABLE}.page_url_port ;;
  # group_label: "Page"
  # hidden: yes
  # }

  dimension: page_urlpath {
    description: "The path of the page, after the domain."
    type: string
    sql: ${TABLE}.page_urlpath ;;
    group_label: "Page"
  }

  dimension: page_urlquery {
    description: "The querystring of the URL."
    type: string
    sql: ${TABLE}.page_urlquery ;;
    group_label: "Page"
  }

  # dimension: page_url_fragment {
  # type: string
  # sql: ${TABLE}.page_url_fragment ;;
  # group_label: "Page"
  # }

  dimension: page_title {
    description: "The web page title."
    type: string
    sql: ${TABLE}.page_title ;;
    group_label: "Page"
  }

  dimension: search_field {
    description: "The raw search query parameters"
    type: string
    # sql: decode(split_part(${page_url},'/search/',2),'%20', ' ');;
    sql: REPLACE(split_part(${page_url},'/search/',2), '%20', ' ')
      ;;
  }

  dimension: page_referer {
    type: string
    sql: ${TABLE}.page_referrer ;;
    group_label: "Referer"
  }

  dimension: page_width {
    type: number
    sql: ${TABLE}.page_width ;;
    group_label: "Page"
  }

  dimension: page_height {
    type: number
    sql: ${TABLE}.page_height ;;
    group_label: "Page"
  }



  ### Device

  dimension: device_type {
    description: "A label that describes the viewing device type as Mobile or Computer."
    type: string
    sql: ${TABLE}.dvce_type ;;
    group_label: "Device"
  }

  dimension: device_is_mobile {
    description: "True if the viewing device is mobile; False otherwise."
    type: yesno
    sql: ${TABLE}.dvce_ismobile ;;
    group_label: "Device"
  }

}