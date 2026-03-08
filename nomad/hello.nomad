job "hello-devops" {
  datacenters = ["dc1"]
  type        = "service"

  group "hello" {
    count = 1

    restart {
      attempts = 3
      delay    = "15s"
      interval = "10m"
      mode     = "delay"
    }

    task "hello-container" {
      driver = "docker"

      env {
        SERVICE_MODE         = "true"
        LOG_INTERVAL_SECONDS = "30"
      }

      config {
        image      = "localhost:5001/devops-intern-final:latest"
        force_pull = false
      }

      resources {
        cpu    = 10
        memory = 128
      }

      logs {
        max_files     = 5
        max_file_size = 10
      }
    }
  }
}
