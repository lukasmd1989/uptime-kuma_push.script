# uptime-kuma_push.script


Instructions
Create the Combined Automation Script

bash
Code kopieren
nano setup_monitor.sh
Paste the script above into the file.
Save and exit (Ctrl+X, then Y, then Enter).
Make the Script Executable

bash
Code kopieren
chmod +x setup_monitor.sh
Run the Automation Script

bash
Code kopieren
./setup_monitor.sh
Follow the Prompts

What do you want to monitor?

Type 1 for System Service.
Type 2 for Docker Container.
If you choose 1 (System Service):

Enter the name of the service you want to monitor:
For example: sonarr, plexmediaserver, etc.
Enter the Push ID from Uptime Kuma for this service:
Paste the Push ID obtained from Uptime Kuma.
If you choose 2 (Docker Container):

Enter the name of the Docker container you want to monitor:
For example: my_docker_container.
Enter the Push ID from Uptime Kuma for this Docker container:
Paste the Push ID obtained from Uptime Kuma.
The script will:

Validate the service or container name.
Create a monitoring script at /usr/local/bin/check_<name>.sh.
Add a cron job to run the monitoring script every 5 minutes.
