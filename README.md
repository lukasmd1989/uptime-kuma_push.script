# uptime-kuma_push.script

# Service and Docker Container Monitoring Setup Script for Uptime Kuma

This script automates the setup of monitoring for **system services** and **Docker containers** using [Uptime Kuma](https://github.com/louislam/uptime-kuma). It creates monitoring scripts and configures cron jobs to regularly check the status of specified services or containers and sends push notifications to Uptime Kuma.

## Prerequisites

- **Uptime Kuma**: Set up and running. Obtain Push IDs for the services or containers you want to monitor.
- **Permissions**:
  - The script should be run with appropriate permissions (root or a user with sudo privileges).
  - For Docker container monitoring, ensure the user has permission to execute Docker commands.
- **Dependencies**:
  - `bash`
  - `systemctl` (for service monitoring)
  - `docker` (for Docker container monitoring)
  - `cron`
  - `curl`

## Setup & Usage

1. open shell 
```bash
./setup_monitor.sh
```

Run the script and follow the prompts to set up monitoring for a system service or a Docker container.

```bash
./setup_monitor.sh

