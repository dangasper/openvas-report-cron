#!/bin/bash
# Openvas report cron

# Constant variables
USER=""
PASS=""
RETURNSTATUS=""
TODAY=$(date +%Y-%m-%d)
REPORTLOC=""
REPORTDB=""

# Test OMP connection - uses OMP ping exits script on failure
test_omp() {
	echo "----------- TESTING OMP CONNECTION -------"
	if [ ! "eval omp -u $USER -w $PASS --ping" ]
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
	TaskID=(`omp -u $USER -w $PASS -G | awk '{ print $1 }'`)
	echo "Tasks received"
}

# report parse function - gets task information from passed task id of get_reports() and parses through output to grab last report ID
report_parse() {
	omp -u $USER -w $PASS -iX '<get_tasks task_id="'${1}'"></get_tasks>' | sed -n '/<last_report>/,/<\/last_report>/p' | grep "report id" | awk -F\" '{ print $2 }'
}

# Get reports function - polls OMP using tasks to find last report id
get_reports() {
	echo "----------- GETTING REPORTS -----------"
	c="0"
	for i in ${TaskID[@]}
	do
		ReportID[$c]=`report_parse "$i"`
		c=$[$c+1]
	done
	echo "Reports have been received"

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