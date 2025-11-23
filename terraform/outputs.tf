output "master_public_ip" {
  description = "Public IP of master node"
  value       = aws_instance.master.public_ip
}

output "worker1_public_ip" {
  description = "Public IP of worker 1"
  value       = aws_instance.worker1.public_ip
}

output "worker2_public_ip" {
  description = "Public IP of worker 2"
  value       = aws_instance.worker2.public_ip
}

output "load_balancer_dns" {
  description = "DNS name of load balancer"
  value       = aws_lb.main.dns_name
}