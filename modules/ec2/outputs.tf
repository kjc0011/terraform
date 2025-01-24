output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

# 웹 서버 보안 그룹 ID 출력 추가
output "web_security_group_id" {
  value = aws_security_group.web.id
}