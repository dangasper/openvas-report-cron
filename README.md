# openvas-report-cron
Cron script to grab openvas reports

What this script aims to do is be setup as a cron script to grab the latest reports of scheduled tasks in OpenVAS using the OpenVAS OMP protocol. After doing so it will use curl to HTTP POST to an API endpoint for further processing. Lastly the reports after being processed, are moved to a designated storage folder and compressed.
