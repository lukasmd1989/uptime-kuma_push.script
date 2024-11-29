#!/bin/bash

# Combined automation script to set up monitoring with Uptime Kuma

# Function to check if a system service exists
check_service() {
    SERVICE_NAME=$1
    if systemctl list-units --type=service | grep -w "$SERVICE_NAME.service" > /dev/null; then
        echo "Service '$SERVICE_NAME' found."
        return 0
    else
        echo "Service '$SERVICE_NAME' not found."
        return 1
    fi
}

# Function to check if a Docker container exists
check_container() {
    CONTAINER_NAME=$1
    if docker ps -a --format '{{.Names}}' | grep -w "$CONTAINER_NAME" > /dev/null; then
        echo "Docker container '$CONTAINER_NAME' found."
        return 0
    else
        echo "Docker container '$CONTAINER_NAME' not found."
        return 1
    fi
}

# Step 1: Ask what to monitor
echo "What do you want to monitor?"
echo "1) System Service"
echo "2) Docker Container"
read -p "Enter 1 or 2: " MONITOR_TYPE

if [ "$MONITOR_TYPE" = "1" ]; then
    # Monitoring a system service
    # Ask for the service name
    read -p "Enter the name of the service you want to monitor: " INPUT_SERVICE

    # Validate the service name
    if check_service "$INPUT_SERVICE"; then
        SERVICE_NAME="$INPUT_SERVICE"
    else
        echo "Attempting to find similar service names..."
        POSSIBLE_SERVICES=$(systemctl list-units --type=service | grep "$INPUT_SERVICE" | awk '{print $1}' | sed 's/.service//')
        if [ -n "$POSSIBLE_SERVICES" ]; then
            echo "Did you mean one of these services?"
            echo "$POSSIBLE_SERVICES"
            read -p "Please enter the correct service name from the list above: " SERVICE_NAME
            if ! check_service "$SERVICE_NAME"; then
                echo "Service '$SERVICE_NAME' not found. Exiting."
                exit 1
            fi
        else
            echo "No similar services found. Exiting."
            exit 1
        fi
    fi

    # Ask for the Push ID
    read -p "Enter the Push ID from Uptime Kuma for this service: " PUSH_ID

    # Create the monitoring script
    MONITOR_SCRIPT="/usr/local/bin/check_${SERVICE_NAME}.sh"

    cat <<EOF > "$MONITOR_SCRIPT"
#!/bin/bash

# Monitoring script for service $SERVICE_NAME

# Variables
SERVICE_NAME="$SERVICE_NAME"
PUSH_ID="$PUSH_ID"

# Do not edit below this line
PUSH_URL="https://up.dittmer.cc/api/push/\${PUSH_ID}?status="

# Start time in milliseconds
START_TIME=\$(date +%s%3N)

# Check if the service is active
if systemctl is-active --quiet "\$SERVICE_NAME"; then
    STATUS="up"
    MESSAGE="OK"
else
    STATUS="down"
    MESSAGE="\$SERVICE_NAME is not running"
fi

# End time in milliseconds
END_TIME=\$(date +%s%3N)

# Calculate the elapsed time (ping) in milliseconds
PING_TIME=\$((END_TIME - START_TIME))

# Send the push request with status, message, and ping
curl -k -s "\${PUSH_URL}\${STATUS}&msg=\${MESSAGE}&ping=\${PING_TIME}" > /dev/null
EOF

    # Make the monitoring script executable
    chmod +x "$MONITOR_SCRIPT"

    echo "Monitoring script created at $MONITOR_SCRIPT"

elif [ "$MONITOR_TYPE" = "2" ]; then
    # Monitoring a Docker container
    # Ask for the container name
    read -p "Enter the name of the Docker container you want to monitor: " CONTAINER_NAME

    # Validate the Docker container name
    if check_container "$CONTAINER_NAME"; then
        :
    else
        echo "Attempting to find similar container names..."
        POSSIBLE_CONTAINERS=$(docker ps -a --format '{{.Names}}' | grep "$CONTAINER_NAME")
        if [ -n "$POSSIBLE_CONTAINERS" ]; then
            echo "Did you mean one of these containers?"
            echo "$POSSIBLE_CONTAINERS"
            read -p "Please enter the correct container name from the list above: " CONTAINER_NAME
            if ! check_container "$CONTAINER_NAME"; then
                echo "Docker container '$CONTAINER_NAME' not found. Exiting."
                exit 1
            fi
        else
            echo "No similar containers found. Exiting."
            exit 1
        fi
    fi

    # Ask for the Push ID
    read -p "Enter the Push ID from Uptime Kuma for this Docker container: " PUSH_ID

    # Create the monitoring script
    MONITOR_SCRIPT="/usr/local/bin/check_${CONTAINER_NAME}.sh"

    cat <<EOF > "$MONITOR_SCRIPT"
#!/bin/bash

# Monitoring script for Docker container $CONTAINER_NAME

# Variables
CONTAINER_NAME="$CONTAINER_NAME"
PUSH_ID="$PUSH_ID"

# Do not edit below this line
PUSH_URL="https://up.dittmer.cc/api/push/\${PUSH_ID}?status="

# Start time in milliseconds
START_TIME=\$(date +%s%3N)

# Check if the Docker container is running
if docker ps --filter "name=\${CONTAINER_NAME}" --filter "status=running" | grep -w "\${CONTAINER_NAME}" > /dev/null; then
    STATUS="up"
    MESSAGE="OK"
else
    STATUS="down"
    MESSAGE="\${CONTAINER_NAME} is not running"
fi

# End time in milliseconds
END_TIME=\$(date +%s%3N)

# Calculate the elapsed time (ping) in milliseconds
PING_TIME=\$((END_TIME - START_TIME))

# Send the push request with status, message, and ping
curl -k -s "\${PUSH_URL}\${STATUS}&msg=\${MESSAGE}&ping=\${PING_TIME}" > /dev/null
EOF

    # Make the monitoring script executable
    chmod +x "$MONITOR_SCRIPT"

    echo "Monitoring script created at $MONITOR_SCRIPT"

else
    echo "Invalid option selected. Exiting."
    exit 1
fi

# Step 4: Update cron
echo "Adding cron job to run the monitoring script every 5 minutes."

# Add the cron job
CRON_JOB="*/5 * * * * $MONITOR_SCRIPT"
(crontab -l 2>/dev/null | grep -v -F "$MONITOR_SCRIPT" ; echo "$CRON_JOB") | crontab -

echo "Cron job added."
echo "Setup complete. Monitoring is now configured."
