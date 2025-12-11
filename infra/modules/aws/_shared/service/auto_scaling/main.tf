resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.max_scaled_task_count
  min_capacity       = var.initial_task_count
  resource_id        = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${var.ecs_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_in" {
  name               = "${var.project_name}-${var.task_name}-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      scaling_adjustment          = var.scaling_in_adjustment
      metric_interval_upper_bound = 0
    }

    cooldown                = var.auto_scale_cool_down_period_in
    metric_aggregation_type = "Average"
  }
}

resource "aws_appautoscaling_policy" "scale_out" {
  name               = "${var.project_name}-${var.task_name}-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      scaling_adjustment          = var.scaling_out_adjustment
      metric_interval_lower_bound = 0
    }

    cooldown                = var.auto_scale_cool_down_period_out
    metric_aggregation_type = "Average"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.project_name}-${var.task_name}-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = local.evaluation_periods_in
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.auto_scale_cool_down_period_in
  statistic           = "Average"
  threshold           = var.cpu_scale_in_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_in.arn]
  dimensions = {
    ClusterName = data.aws_ecs_cluster.cluster.cluster_name
    ServiceName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.project_name}-${var.task_name}-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.evaluation_periods_out
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.auto_scale_cool_down_period_out
  statistic           = "Average"
  threshold           = var.cpu_scale_out_threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_out.arn]
  dimensions = {
    ClusterName = data.aws_ecs_cluster.cluster.cluster_name
    ServiceName = var.ecs_name
  }
}
