output "ec2_public_ip" {
  value = aws_instance.webapp_host.public_ip
}

output "webapp_ecr_repo_url" {
  value = aws_ecr_repository.webapp_repo.repository_url
}

output "mysql_ecr_repo_url" {
  value = aws_ecr_repository.mysql_repo.repository_url
}