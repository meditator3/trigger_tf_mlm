# prints ip's of alb to be used in /etc/hosts

output "alb_ips" {
  value = data.dns_a_record_set.alb.addrs
}