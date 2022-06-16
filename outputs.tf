output "cassandra_pass" {
  description = "cassandra initial admin password"
  value       = random_password.this.result
}
