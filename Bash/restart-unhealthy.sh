#!/bin/bash
CONTAINERSYSTEM=docker # docker/podman
CONTAINER_NAME=$1
DEPENDENT_CONTAINERS=$($CONTAINERSYSTEM ps -q --filter "label=health_depends_on=$1")

# don't run multiple versions of the script
if [[ "$(pidof -x $(basename $0) -o %PPID)" ]]; then
        echo "This script is already running with PID $(pidof -x $(basename $0) -o %PPID)"
        exit
fi

if [ $($CONTAINERSYSTEM ps --filter "name=$CONTAINER_NAME" | grep -c "(healthy)") -eq 0 ] && [ $($CONTAINERSYSTEM ps --filter "name=$CONTAINER_NAME" | grep -c "(health: starting)") -eq 0 ]; then
        echo "$CONTAINER_NAME is non-healthy"
        while [ $($CONTAINERSYSTEM ps --filter "name=$CONTAINER_NAME" | grep -c "(healthy)") -eq 0 ]; do
                if [ $($CONTAINERSYSTEM ps --filter "name=$CONTAINER_NAME" | grep -c "starting") -eq 0 ]; then
                        echo "Restarting $CONTAINER_NAME"
                        $CONTAINERSYSTEM restart $CONTAINER_NAME

                        # Restart dependent containers
                        if [ $(echo "$DEPENDENT_CONTAINERS" | wc -l) -gt 1 ]; then
                                echo "dependent containers found - restarting them"
                                sleep 3
                                $CONTAINERSYSTEM restart $DEPENDENT_CONTAINERS
                        fi
                fi
                sleep 30
        done
        echo "restart completed, container is now marked as healthy"
fi
