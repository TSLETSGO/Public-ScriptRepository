#!/bin/bash

CONTAINER_NAME=$1
DEPENDENT_CONTAINERS=$(docker ps -q --filter "label=health_depends_on=$1")

# don't run multiple versions of the script
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo "This script is already running with PID `pidof -x $(basename $0) -o %PPID`"
        exit
fi

if [ $(docker ps --filter "name=$CONTAINER_NAME" | grep -c "(healthy)") -eq 0 ] && [ $(docker ps --filter "name=$CONTAINER_NAME$then
        echo "$CONTAINER_NAME is non-healthy"
        while [ $(docker ps --filter "name=$CONTAINER_NAME" | grep -c "(healthy)") -eq 0 ];
        do
                if [ $(docker ps --filter "name=$CONTAINER_NAME" | grep -c "starting") -eq 0 ];
                then
                        echo "Restarting $CONTAINER_NAME"
                        docker restart $CONTAINER_NAME

                        # Restart dependent containers
                        if [ $(echo "$DEPENDENT_CONTAINERS" | wc -l) -gt 1 ];
                        then
                                echo "dependent containers found - restarting them"
                                sleep 3
                                docker restart $DEPENDENT_CONTAINERS
                        fi
                fi
                sleep 30
        done
        echo "restart completed, container is now marked as healthy"
fi