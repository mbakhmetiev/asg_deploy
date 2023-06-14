variable "server_port" {
  description = "The port, server will use for HTTP requests"
  type = number
  default = 8080
}
variable "console_port" {
  description = "The port, alb will use for incoming prisma console"
  type = number
  default = 443
}
variable "alb_port" {
  description = "The port, alb will use for HTTP requests"
  type = number
  default = 80
}
