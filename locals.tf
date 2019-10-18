# be very careful when changing these. These are used to generated the stateful
# set service name (<name>-#.<name>.<namespace>.svc.cluster.local) which must be
# less than 47 characters!
locals {
  master_pod_name   = "rds-mst"
  slave_pod_name    = "rds-slv"
  sentinel_pod_name = "rds-snt"
}
