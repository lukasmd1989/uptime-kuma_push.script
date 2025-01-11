#!/bin/bash

# Function to list and select a system service
select_service() {
    echo "Fetching a list of running services..."
    # List running services and present them as a numbered menu
    SERVICES=$(systemctl list-units --type=service --state=running --no-pager | awk '{print $1}' | sed 's/.service//')
    echo "Select a service to monitor:"
    select SERVICE_NAME in $SERVICES; do
        if [ -n "$SERVICE_NAME" ]; then
            echo "You selected: $SERVICE_NAME"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Function to create a monitoring script for a system service
create_service_monitor() {
    # Prompt user to select a running service
    select_service

    echo "Enter the Push ID from Uptime Kuma for this service:"
    read PUSH_ID

    MONITOR_SCRIPT="/usr/local/bin/check_${SERVICE_NAME}.sh"

    # Create the monitoring script
    cat <<EOF > $MONITOR_SCRIPT
#!/bin/bash
if systemctl is-active --quiet $SERVICE_NAME; then
    curl -s "https://your-uptime-kuma-server/api/push/$PUSH_ID?status=up" > /dev/null
else
    curl -s "https://your-uptime-kuma-server/api/push/$PUSH_ID?status=down" > /dev/null
fi
EOF

    # Make the script executable
    chmod +x $MONITOR_SCRIPT
    echo "Monitoring script created at $MONITOR_SCRIPT"

    # Add a cron job to run the script every 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * $MONITOR_SCRIPT") | crontab -
    echo "Added cron job to run the monitoring script every 5 minutes."

    echo "Setup complete. Monitoring is now configured."
}

# Function to create a monitoring script for a Docker container
create_docker_monitor() {
    echo "Enter the name of the Docker container you want to monitor:"
    read CONTAINER_NAME

    # Check if the container exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Docker container '$CONTAINER_NAME' found."

        echo "Enter the Push ID from Uptime Kuma for this Docker container:"
        read PUSH_ID

        MONITOR_SCRIPT="/usr/local/bin/check_${CONTAINER_NAME}.sh"

        # Create the monitoring script
        cat <<EOF > $MONITOR_SCRIPT
#!/bin/bash
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    curl -s "https://your-uptime-kuma-server/api/push/$PUSH_ID?status=up" > /dev/null
else
    curl -s "https://your-uptime-kuma-server/api/push/$PUSH_ID?status=down" > /dev/null
fi
EOF

        # Make the script executable
        chmod +x $MONITOR_SCRIPT
        echo "Monitoring script created at $MONITOR_SCRIPT"

        # Add a cron job to run the script every 5 minutes
        (crontab -l 2>/dev/null; echo "*/5 * * * * $MONITOR_SCRIPT") | crontab -
        echo "Added cron job to run the monitoring script every 5 minutes."

        echo "Setup complete. Monitoring is now configured."
    else
        echo "Docker container '$CONTAINER_NAME' not found. Please check the container name and try again."
    fi
}

# Main script logic
echo "What do you want to monitor?"
echo "1) System Service"
echo "2) Docker Container"
read -p "Enter 1 or 2: " CHOICE

case $CHOICE in
    1)
        create_service_monitor
        ;;
    2)
        create_docker_monitor
        ;;
    *)
        echo "Invalid choice. Please run the script again and select either 1 or 2."
        ;;
esac
