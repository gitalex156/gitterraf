output "instance_ip" {
  value       = yandex_compute_instance.app_instance.network_interface[0].nat_ip_address
  description = "External IP address of the virtual machine."
}
