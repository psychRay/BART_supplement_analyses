#!/bin/bash

# Variables
REMOTE_SERVER="172.16.212.144"
REMOTE_USER="iCAN"
BASE_REMOTE_PATH="/brain/iCAN_admin/home/JiangMin/Results/First_Level/2016"
LOCAL_PATH="E:/ImportantDOCs/currentWKdir/work_postdoc/BART_supplement"

# Uncomment and fill in if using sshpass
# PASSWORD="qinlab2016"

# Uncomment if using sshpass
# SSHPASS_CMD="sshpass -p $PASSWORD"

# Fetch the list of subject IDs from the remote server
# Using sshpass
# SUBJECT_IDS=$($SSHPASS_CMD ssh $REMOTE_USER@$REMOTE_SERVER "ls $BASE_REMOTE_PATH")

# Without sshpass
SUBJECT_IDS=$(ssh $REMOTE_USER@$REMOTE_SERVER "ls $BASE_REMOTE_PATH")

# Loop through each subject ID and download the files
for SUBJECT_ID in $SUBJECT_IDS; do
    # Create local directory
    mkdir -p "$LOCAL_PATH/$SUBJECT_ID"

    # Full path to the remote folder for the current subject ID
    REMOTE_PATH="$BASE_REMOTE_PATH/$SUBJECT_ID/fmri/stats_spm8/BART/stats_spm8_swcar"

    # Download files
    # Uncomment the appropriate line depending on whether you're using sshpass or not
	
    # Using sshpass
    #$SSHPASS_CMD sftp -oBatchMode=no -b - $REMOTE_USER@$REMOTE_SERVER <<EOF
	
	# Without sshpass
	sftp -oBatchMode=no -b - $REMOTE_USER@$REMOTE_SERVER <<EOF
cd $REMOTE_PATH
get -r * $LOCAL_PATH/$SUBJECT_ID/
bye
EOF
done