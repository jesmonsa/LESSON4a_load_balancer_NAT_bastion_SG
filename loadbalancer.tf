# Public Load Balancer
resource "oci_load_balancer" "PublicLoadBalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = oci_identity_compartment.Prod_01.id
  subnet_ids = [
    oci_core_subnet.LBSubnet.id
  ]
  display_name = "PublicLoadBalancer"
  network_security_group_ids = [oci_core_network_security_group.WebSecurityGroup.id]
}

# LoadBalancer Listener
resource "oci_load_balancer_listener" "PublicLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.PublicLoadBalancer.id
  name                     = "LoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.PublicLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "PublicLoadBalancerBackendset" {
  name             = "LBBackendset"
  load_balancer_id = oci_load_balancer.PublicLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# LoadBalanacer Backend for WebServer1 Instance
resource "oci_load_balancer_backend" "PublicLoadBalancerBackend1" {
  load_balancer_id = oci_load_balancer.PublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.PublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.Webserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# LoadBalanacer Backend for WebServer2 Instance
resource "oci_load_balancer_backend" "PublicLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer.PublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.PublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.Webserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


