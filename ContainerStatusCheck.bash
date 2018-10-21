###########################################################
#             This script checks on the statuses          #
#               of the containers used by                 #
#                   A Data Science group                  #
#                                                         #
#              Maintainer: Sahar Mirshamsi                #
###########################################################


############## Setting up the environment #################
#!/bin/bash

############## Defining containers' variables #############
Containers=($(sudo docker ps -a --format "{{.Names}}"))
St=($(sudo docker ps -a --format "{{.Status}}"))
Statuses=($(echo ${St[@]}|grep -o -e "Up" -e "Exited")) #grabbing only the first word of status
machineName=$(head /etc/hostname|awk '{print $1}')

############## Defining emails' variables #################
IPAddress=$(wget -qO- http://ipecho.net/plain ; echo)
fromAddress="sahar.mirshamsi@gmail.com"
emailList="sahar.mirshamsi@gmail.com"
subject=$(echo "Urgent: DataScience Container Down! Action REQUIRED")

body="This is an automated email! 
Container named ${Containers[i]} on machine $machineName is down, contact DataScience team immediately! This machines' ip address is $IPAddress
\n
What to do: The script has attempted to restart the containner, check to make sure it has been successful! Check out below page, you may need to restart the existing container and check the log file to look for what caused the error! Also, make sure all the services are running.
\n
https://bitbucket.org/smirshamsi/ds-docker/src/cfcc6e7a0fb4451bf2f33887ecd9b1741ac8d3ec?at=master
\n
possibly useful command: sudo docker ps -a , sudo docker restart <Container Name>
"

############## Checking the statuses and ####################
#####sending email if needed and attempts to restart ########
################### the container ###########################
time=$(date --rfc-3339='seconds')
for ((i=0;i<${#Containers[@]};++i)); do
        echo "at" $time ${Containers[i]}" is in status "${Statuses[i]}
        if [[ ${Statuses[i]} == *"Exit"* ]]; then
                echo -e "$body"|mail -s "$subject" -r $fromAddress -F $fromAddress $emailList
                sudo docker restart ${Containers[i]}
        fi
done
