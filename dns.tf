resource "google_dns_managed_zone" "neli" {
  name     = "neli"
  dns_name = "nelidoc.com."

  description = "Dns zone to host prod workloads"

  lifecycle {
    prevent_destroy = true
  }
}
