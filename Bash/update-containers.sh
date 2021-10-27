#!/bin/bash
# Requires .sh script that includes each containers manifesto. If you don't have .sh scripts for initating your individual containers, adjust script.
CONTAINERFILES_LOCATION="/dockers/scripts/dockerfiles"

# don't run multiple versions of the script
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo "This script is already running with PID `pidof -x $(basename $0) -o %PPID`"
        exit
fi

# Abort on all errors, set -x
set -o errexit

echo $(date)

# Get the containers from first argument, else get all containers
CONTAINER_LIST="${1:-$(docker ps -q)}"

for container in ${CONTAINER_LIST}; do
        # Get the image and hash of the running container
        CONTAINER_NAME=$(docker ps -f id="$container" --format '{{.Names}}')
        CONTAINER_IMAGE=$(docker inspect --format "{{.Config.Image}}" --type container "${container}")
        RUNNING_IMAGE=$(docker inspect --format "{{.Image}}" --type container "${container}")
        DEPENDENT_CONTAINERS=$(docker ps -q --filter "label=health_depends_on=$CONTAINER_NAME" --format '{{.Names}}')

        # Pull in latest version of the container and get the hash
        docker pull "${CONTAINER_IMAGE}" 1>/dev/null

        LATEST_IMAGE=$(docker inspect --format "{{.Id}}" --type image "${CONTAINER_IMAGE}")
        echo "CONTAINER: $CONTAINER_NAME"
        echo "LATEST IMAGE: $LATEST_IMAGE"
        echo "RUNNING IMAGE: $RUNNING_IMAGE"

        # Restart the container if the image is different
        if [[ "${RUNNING_IMAGE}" != "${LATEST_IMAGE}" ]]; then
                echo "-Updating $CONTAINER_NAME with $LATEST_IMAGE"

                if [[ $(echo "$DEPENDENT_CONTAINERS" | wc -l) -gt 1 ]];
                then
                        echo "-Dependent containers found, stopping them all"
                        docker stop $DEPENDENT_CONTAINERS 1>/dev/null
                        echo "----Dependent containers stopped: Success"
                fi

                echo "-Recreating $CONTAINER_NAME"
                docker stop $container 1>/dev/null
                docker rm $container 1>/dev/null
                "$CONTAINERFILES_LOCATION/$CONTAINER_NAME.sh" 1>/dev/null

                if [[ $(echo "$DEPENDENT_CONTAINERS" | wc -l) -gt 1 ]];
                then
                        echo "-Recreating dependent containers"
                        sleep 3

                        for dependent_container in ${DEPENDENT_CONTAINERS};
                        do
                                echo "----Recreating $dependent_container"
                                docker rm $dependent_container 1>/dev/null
                                "$CONTAINERFILES_LOCATION/$dependent_container.sh" 1>/dev/null
                                echo "----Recreating $dependent_container: Success"
                        done

                fi
        fi
        echo ""
done


echo "all containers checked"
echo "removing old images"
docker image prune -a -f > /dev/null
echo "--- script done"