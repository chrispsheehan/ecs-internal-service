output "api_invoke_url" {
  value = data.terraform_remote_state.network.outputs.api_invoke_url
}
