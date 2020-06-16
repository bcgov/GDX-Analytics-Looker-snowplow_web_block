view: chatbot {
  derived_table: {
    sql: SELECT wp.id, cb.*,
          CASE WHEN action = 'ask_question' THEN 1 ELSE 0 END AS question_count,
          CASE WHEN action = 'get_answer' THEN 1 ELSE 0 END AS answer_count,
          CASE WHEN action = 'open' THEN 1 ELSE 0 END AS open_count,
          CASE WHEN action = 'hello' THEN 1 ELSE 0 END AS hello_count,
          CASE WHEN action = 'close' THEN 1 ELSE 0 END AS close_count,
          CASE WHEN action = 'link_click' THEN 1 ELSE 0 END AS link_click_count,
          CASE WHEN action = 'get_answer' THEN text ELSE NULL END AS intent,
          CASE WHEN action = 'get_answer' THEN SPLIT_PART(text, '-',1)
            ELSE NULL END AS intent_category,
          CASE WHEN action <> 'link_click' THEN NULL
            WHEN hr_url IS NOT NULL AND SPLIT_PART(text, '#',2) = '' THEN hr_url
            WHEN hr_url IS NOT NULL AND SPLIT_PART(text, '#',2) <> '' THEN hr_url || '#' || SPLIT_PART(text, '#',2)
            ELSE text END AS link_click_url
          FROM atomic.ca_bc_gov_chatbot_chatbot_1 AS cb
          JOIN atomic.com_snowplowanalytics_snowplow_web_page_1 AS wp ON cb.root_id = wp.root_id AND cb.root_tstamp = wp.root_tstamp
          LEFT JOIN cmslite.themes ON action = 'link_click' AND text LIKE 'https://www2.gov.bc.ca/gov/content?id=%' AND themes.node_id = SPLIT_PART(SPLIT_PART(SPLIT_PART(text, 'https://www2.gov.bc.ca/gov/content?id=', 2), '?',1 ), '#',1)
          ;;

      distribution_style: all
      persist_for: "2 hours"
    }

    dimension_group: event {
      type: time
      sql: ${TABLE}.root_tstamp ;;
    }
    dimension: id {
      type: string
      sql: ${TABLE}.id ;;
    }
    dimension: action {
      type: string
      sql: ${TABLE}.action ;;
    }
    dimension: link_click_url {
      type: string
      sql: ${TABLE}.link_click_url ;;
      drill_fields: [page_views.chatbot_page_display_url]
      link: {
        label: "Visit Page"
        url: "{{ value }}"
        icon_url: "https://looker.com/favicon.ico"
      }
    }
    dimension: intent {
      drill_fields: [page_views.chatbot_page_display_url]
    }
    dimension: intent_category {
      drill_fields: [intent, page_views.chatbot_page_display_url]
    }
    dimension: text {
      type: string
      sql: ${TABLE}.text ;;
    }
    dimension: agent {
      type: string
      sql: ${TABLE}.agent ;;
    }

    measure: question_count {
      type: sum
      sql: ${TABLE}.question_count ;;
    }
    measure: hello_count {
      type: sum
      sql: ${TABLE}.hello_count ;;
    }
    measure: answer_count {
      type: sum
      sql: ${TABLE}.answer_count ;;
    }
    measure:open_count {
      type: sum
      sql: ${TABLE}.open_count ;;
    }
    measure: close_count {
      type: sum
      sql: ${TABLE}.close_count ;;
    }
    measure: link_click_count {
      type: sum
      sql: ${TABLE}.link_click_count ;;
    }
    measure: chatbot_event_count {
      type: count
    }
    measure: extra_answer_count {
      type: sum
      sql: ${TABLE}.answer_count - ${TABLE}.question_count ;;
    }

  }
