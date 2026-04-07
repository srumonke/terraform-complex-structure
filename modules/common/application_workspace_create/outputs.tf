output "workspaces" {
  description = "Map of created IaCM workspaces"
  value = {
    for key, ws in harness_platform_workspace.this : key => {
      identifier = ws.identifier
      name       = ws.name
    }
  }
}
