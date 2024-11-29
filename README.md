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
2. create a new file which include the script
   - run as root:
     ```bash
     nano setup_monitor.sh
   - run as user:
     ```bash
     sudo nano setup_monitor.sh
4. paste the code from the github file "setup_monitor.sh" and save the file using CTRL + X and Y
5. make the new file executable
   - run as root:
     ```bash
     chmod +x setup_monitor.sh
   - run as user:
     ```bash
     sudo chmod +x setup_monitor.sh
6. run the script:
   ```bash
   ./setup_monitor.sh
  
