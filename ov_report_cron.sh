#!/bin/bash
# Openvas report cron

# Constant variables
USER=""
PASS=""
HOST=""
RETURNSTATUS=""
TODAY=$(date +%Y-%m-%d)
REPORTLOC=""
REPORTDB=""
PROCESSEDLOC=""

# Test OMP connection - uses OMP ping exits script on failure
test_omp() {
	echo "----------- TESTING OMP CONNECTION -------"
	if [ ! "eval omp -h $HOST -u $USER -w $PASS --ping" ]
	then
		echo "OMP Connection Failed. Exiting script..."
		exit 1
	else
		echo "OMP Connection Test Passed"
	fi
}

# Get tasks function - polls OMP for tasks and stores in an array variable
get_tasks() {
	echo "----------- GETTING TASKS ----------"
	TaskID=(`omp -h $HOST -u $USER -w $PASS -G | awk '{ print $1 }'`)
	echo "Tasks received"
}

# report parse function - gets task information from passed task id of get_reports() and parses through output to grab last report ID
report_parse() {
	omp -h $HOST -u $USER -w $PASS -iX '<get_tasks task_id="'${1}'"></get_tasks>' | sed -n '/<last_report>/,/<\/last_report>/p' | grep "report id" | awk -F\" '{ print $2 }'
}

# Creates reportdb function - creates report db file
create_reportdb() {
	echo ${ReportID[@]} > $REPORTDB
}

locate_reportdb() {
	[ -f "$REPORTDB" ]
}

pull_new_reports() {
	echo "Pulling new reports."
	echo ${NewReportID[@]}
	echo "New reports pulled."
	# Update DB file with current reports pulled.
	echo ${ReportID[@]} > $REPORTDB
}

# new reports function - checks if the reportdb file is available, creates if not, if present then compares report database file against pulled report ids, calls new report pull function
new_reports() {
	if locate_reportdb
	then
		echo "Report DB found, looking for new reports."
		newreports=0
		for j in ${ReportID[@]}
		do
			if [ ! `grep -c $j $REPORTDB` -ge 1 ]
			then
				NewReportID[$newreports]=$j
				newreports=$[$newreports+1]
			fi		
		done
		if [ ${newreports} -ge 1 ]
		then
			echo "$newreports new reports found!"
			pull_new_reports
		else
			echo "No new reports found!"
		fi
	else
		create_reportdb
		echo "Report DB created."
		echo "`echo ${ReportID[@]} | wc -w` new reports found!"
		NewReportID=(${ReportID[@]})
		pull_new_reports
	fi
	
}

# Get reports function - polls OMP using tasks to find last report id, compares to previous pulled reports, grabs new reports
get_reports() {
	echo "----------- GETTING REPORTS -----------"
	
	c="0"
	for i in ${TaskID[@]}
	do
		ReportID[$c]=`report_parse "$i"`
		c=$[$c+1]
	done
	echo "Reports have been received"

	# Check for reports folder before continuing
	if [ ! -d "$REPORTLOC" ]
	then
		mkdir -p $(pwd)/reports/
	fi

	new_reports
}

# Main script start
echo "----------- STARTING REPORT PULL ---------"

# Call test_omp function
test_omp

# Call get_tasks function
get_tasks

# Call get_reports function
get_reports

exit 0