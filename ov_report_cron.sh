#!/bin/bash
# Openvas report cron

# Constant variables
USER=""
PASS=""
RETURNSTATUS=""
TODAY=$(date +%Y-%m-%d)
REPORTLOC=""


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

# Get task function - polls OMP for tasks and stores in an array variable
get_tasks() {
	echo "----------- Getting Tasks ----------"
	TaskID=(`omp -u $USER -w $PASS -G | awk '{ print $1 }'`)
}


# Main script start
echo "----------- STARTING REPORT PULL ---------"

# Call test_omp function
test_omp

# Call get_tasks function
get_tasks

exit 0


