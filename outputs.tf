output "master_service" {
  description = "The routable name for the master service."
  value       = "${kubernetes_service.redis_master.metadata.0.name}"
}

output "master_ip" {
  description = "The ip address of the master service."
  value       = "${kubernetes_service.redis_master.spec.0.cluster_ip}"
}

output "master_port" {
  description = "The port to connect to the redis master."
  value       = "${kubernetes_service.redis_master.spec.0.port.0.port}"
}

output "sentinel_services" {
  description = "The routable names for the sentinel service."
  value       = "${data.template_file.redis_sentinel_host_names.*.rendered}"
}

output "sentinel_port" {
  description = "The port for the sentinel service."
  value       = "${kubernetes_service.redis_sentinel.spec.0.port.0.port}"
}

output "sentinel_monitored_master" {
  description = "The name of redis master being monitored by redis."
  value       = "${data.template_file.sentinel_node_config.vars.master_name}"
}
