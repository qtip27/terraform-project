#NETWORK FIREWALL WITH IPS RULES
resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.drop_icmp.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_domains.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.suricata_rules.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_icmp" {
  capacity = 1
  name     = "drop-icmp"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_domains" {
  capacity = 100
  name     = "block-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [aws_vpc.mtc_vpc.cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".facebook.com", ".twitter.com", ".instagram.com"]
      }
    }
  }

}


resource "aws_networkfirewall_rule_group" "suricata_rules" {
  capacity = 100
  name     = "suricata-rules"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [aws_vpc.mtc_vpc.cidr_block]
        }
      }
    }
    rules_source {
      rules_string = file("local.rules")
    }
  }
}


resource "aws_networkfirewall_firewall" "inspection_vpc_anfw" {
  name                = "NetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = aws_vpc.mtc_vpc.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.mtc_public_subnet[*].id

    content {
      subnet_id = subnet_mapping.value
    }
  }

}

resource "aws_cloudwatch_log_group" "anfw_alert_log_group" {
  name = "/aws/network-firewall/alert"
}

resource "random_string" "bucket_random_id" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "mtc_flow_bucket" {
  bucket = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
}

resource "aws_s3_bucket_acl" "mtc_private" {
  bucket = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "mtc_versioning" {
  bucket = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "anfw_flow_bucket_public_access_block" {
  bucket = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_networkfirewall_logging_configuration" "anfw_alert_logging_configuration" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc_anfw.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.anfw_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.mtc_flow_bucket.bucket
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}
