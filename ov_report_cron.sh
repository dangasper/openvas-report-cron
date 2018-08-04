#!/bin/bash
# Openvas report cron

# Constant variables
USER=""
PASS=""
RETURNSTATUS=""
TODAY=$(date +%Y-%m-%d)
REPORTLOC=""


# Get task function - polls OMP for tasks and stores in an array variable
get_tasks() {
	TaskID=(`omp -u $USER -w $PASS -G | awk '{ print $1 }'`)
}