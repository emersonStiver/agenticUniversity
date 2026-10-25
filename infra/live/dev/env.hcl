locals {
 environment = "dev"
 log_retention_days = 14
 nat_gateway_mode = "single"
 deletion_protection = false
 fargate_spot = true
 default_task_cpu = 256
 default_task_memory = 512 
}

