#!/usr/bin/env bash

set -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)

sudo usermod -u $USER_ID -o -m -d /home/developer developer > /dev/null 2>&1
sudo groupmod -g $GROUP_ID developer > /dev/null 2>&1
sudo chown -R developer:developer /workspace

ln -sfn /workspace /home/developer/workspace

source /opt/ros/$ROS_DISTRO/setup.bash

cd /home/developer

exec $@
