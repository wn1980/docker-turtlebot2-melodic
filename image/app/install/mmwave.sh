#!/usr/bin/env bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash

cd ~/

if [ ! -d "mmwave_ti_ros" ]; then
    git clone https://git.ti.com/cgit/mmwave_radar/mmwave_ti_ros/

    sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y \
        ros-${ROS_DISTRO}-navigation \
        ros-${ROS_DISTRO}-hector-slam \
        ros-${ROS_DISTRO}-octomap-server \
        ros-${ROS_DISTRO}-octomap-rviz-plugins \
        ros-${ROS_DISTRO}-vision-opencv \
        ros-${ROS_DISTRO}-depth-image-proc \
        ros-${ROS_DISTRO}-joy
fi

cd ~/mmwave_ti_ros/ros_driver/

#catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0
catkin_make install -DCMAKE_BUILD_TYPE=Release -DCATKIN_ENABLE_TESTING=0

echo "source ~/mmwave_ti_ros/ros_driver/install/setup.bash" >> ~/.bashrc

cd ~/mmwave_ti_ros/autonomous_robotics_ros/

source ~/mmwave_ti_ros/ros_driver/devel/setup.bash && catkin_make

echo "source ~/mmwave_ti_ros/autonomous_robotics_ros/devel/setup.bash" >> ~/.bashrc
