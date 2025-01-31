output "webapp_id" {
  value = azurerm_linux_web_app.gowtest.id
}

output "image_tag" {
  value = jsondecode(data.http.docker_io.response_body).results[0].name
}