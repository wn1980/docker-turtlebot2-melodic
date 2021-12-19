#!/usr/bin/env bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash

roslaunch turtlebot_bringup minimal.launch &

roslaunch turtlebot_bringup 3dsensor.launch &

tail -f /dev/null
