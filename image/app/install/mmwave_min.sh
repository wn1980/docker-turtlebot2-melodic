#!/usr/bin/env bash

set -e

source /opt/ros/$ROS_DISTRO/setup.bash

sudo apt-get update && \
sudo apt-get upgrade -y && \
sudo apt-get install -y \
    ros-${ROS_DISTRO}-navigation \
    ros-${ROS_DISTRO}-hector-slam \
    ros-${ROS_DISTRO}-octomap-server \
    ros-${ROS_DISTRO}-octomap-rviz-plugins \
    ros-${ROS_DISTRO}-vision-opencv \
    ros-${ROS_DISTRO}-depth-image-proc \
    ros-${ROS_DISTRO}-joy \
    ros-${ROS_DISTRO}-serial \

cd /workspace

#if [ ! -d "mmwave_ti_ros" ]; then
#    git clone https://git.ti.com/cgit/mmwave_radar/mmwave_ti_ros/
#fi

#cd /workspace/mmwave_ti_ros/ros_driver/

#catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0
#catkin_make install -DCMAKE_BUILD_TYPE=Release -DCATKIN_ENABLE_TESTING=0

#echo "source /workspace/mmwave_ti_ros/ros_driver/install/setup.bash" >> ~/.bashrc

#cd /workspace/mmwave_ti_ros/autonomous_robotics_ros/

#source /workspace/mmwave_ti_ros/ros_driver/install/setup.bash && catkin_make

#echo "source /workspace/mmwave_ti_ros/autonomous_robotics_ros/devel/setup.bash" >> ~/.bashrc

mkdir -p ~/workspace/turtlebot2_mmwave_ws/src

cd ~/workspace/turtlebot2_mmwave_ws/src

if [ ! -d "turtlebot_mmwave_1843" ]; then
    git clone https://github.com/wn1980/turtlebot_mmwave_1843.git
fi

cd ~/workspace/turtlebot2_mmwave_ws

catkin_make

echo "source ~/workspace/turtlebot2_mmwave_ws/devel/setup.bash" >> ~/.bashrc
