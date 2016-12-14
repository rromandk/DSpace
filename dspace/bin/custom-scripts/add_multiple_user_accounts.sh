#!/bin/bash
###RIUNER custom script
###ADD EXECUTE PERM TO THIS FILE BEFORE EXECUTE

###Change this account array of emails
EMAILS_ACCOUNTS=("user1@example.com" "user2@example.com" "userN@example.com")

###Change this path
DSPACE_INSTALL_DIR=/dspace


###Change the temporary password 'dspace' if prefer
TEMPORARY_PASSWORD="dspace"

for (( index=0; $index<${#EMAILS_ACCOUNTS[@]}; index++ ))
do
   echo "[RUNNING...]Adding user '${EMAILS_ACCOUNTS[$index]}'[RUNNING...]"
   USER_TMP_NAME=`echo ${EMAILS_ACCOUNTS[$index]} | cut -d '@' -f 1`
   $DSPACE_INSTALL_DIR/bin/dspace user -a -g "$USER_TMP_NAME" -m "${EMAILS_ACCOUNTS[$index]}" -l es -p "$TEMPORARY_PASSWORD"
done