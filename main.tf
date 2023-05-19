resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "INTERVAL_End" = {
                "description" = "ToString(GetCurrentDateTimeUtc())",
                "type" = "string"
            },
            "INTERVAL_Start" = {
                "description" = "ToString(AddHours(GetCurrentDateTimeUtc(),-24))",
                "type" = "string"
            },
            "QUEUE_ID" = {
                "description" = "Call.CurrentQueue",
                "type" = "string"
            }
        },
        "required" = [
            "INTERVAL_Start",
            "INTERVAL_End",
            "QUEUE_ID"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "totalHits" = {
                "type" = "integer"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n \"interval\": \"$${input.INTERVAL_Start}/$${input.INTERVAL_End}\",\n \"order\": \"asc\",\n \"orderBy\": \"conversationStart\",\n \"paging\": {\n  \"pageSize\": 25,\n  \"pageNumber\": 1\n },\n \"segmentFilters\": [\n  {\n   \"type\": \"and\",\n   \"predicates\": [\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"mediaType\",\n     \"operator\": \"matches\",\n     \"value\": \"callback\"\n    },\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"queueId\",\n     \"operator\": \"matches\",\n     \"value\": \"$${input.QUEUE_ID}\"\n    }\n   ]\n  }\n ],\n \"conversationFilters\": [\n  {\n   \"type\": \"and\",\n   \"predicates\": [\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"conversationEnd\",\n     \"operator\": \"exists\",\n     \"value\": null\n    }\n   ]\n  }\n ]\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/details/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "$${rawResult}"
         
               
    }
}