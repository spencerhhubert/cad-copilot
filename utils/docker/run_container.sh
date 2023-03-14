#! /bin/bash
IMAGE="cad-copilot:latest"
CONTAINER="cad-copilot"

sudo docker stop $CONTAINER
sudo docker rm $CONTAINER

sudo docker run -d \
    -v /home/spencer/code/:/code/ \
    --gpus all \
    --name $CONTAINER \
    -it $IMAGE
