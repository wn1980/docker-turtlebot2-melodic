#!/usr/bin/env bash
#REF: https://github.com/gaunthan/Turtlebot2-On-Melodic

set -e

# necessary on a fresh bionic install
sudo apt-get install git -y

mkdir -p ~/turtlebot_ws/src

cd ~/turtlebot_ws/src

git clone https://github.com/turtlebot/turtlebot.git
git clone https://github.com/turtlebot/turtlebot_msgs.git
git clone https://github.com/turtlebot/turtlebot_apps.git
git clone https://github.com/turtlebot/turtlebot_simulator.git
git clone https://github.com/turtlebot/turtlebot_viz.git

#git clone https://github.com/yujinrobot/kobuki_msgs.git

git clone --single-branch --branch melodic https://github.com/yujinrobot/kobuki.git
mv kobuki/kobuki_description kobuki/kobuki_node \
  kobuki/kobuki_keyop kobuki/kobuki_safety_controller \
  kobuki/kobuki_bumper2pc kobuki/kobuki_auto_docking ./
rm -rf kobuki

git clone --single-branch --branch melodic https://github.com/yujinrobot/kobuki_desktop.git
mv kobuki_desktop/kobuki_gazebo_plugins kobuki_desktop/kobuki_dashboard ./
rm -rf kobuki_desktop

git clone https://github.com/yujinrobot/yujin_ocs.git
#mv yujin_ocs/yocs_cmd_vel_mux yujin_ocs/yocs_controllers ./
mv yujin_ocs/yocs_controllers ./
rm -rf yujin_ocs

sudo apt-get install  -y \
  ros-${ROS_DISTRO}-kobuki-core \
  ros-${ROS_DISTRO}-kobuki-msgs \
  ros-${ROS_DISTRO}-ecl-streams \
  ros-${ROS_DISTRO}-yocs-cmd-vel-mux \
  ros-${ROS_DISTRO}-yocs-velocity-smoother \
  ros-${ROS_DISTRO}-depthimage-to-laserscan \
  ros-${ROS_DISTRO}-vision-opencv \
  ros-${ROS_DISTRO}-openni2-launch \
  ros-${ROS_DISTRO}-rqt-robot-dashboard \
  ros-melodic-joy

  # make and install
  cd ~/turtlebot_ws
  
  source /opt/ros/$ROS_DISTRO/setup.bash

  catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0 

	rm -rf ~/turtlebot_ws 
