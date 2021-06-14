#!/usr/bin/env bash

set -e

source /opt/ros/$(dir /opt/ros)/setup.bash

#sudo cp files/49-teensy.rules /etc/udev/rules.d/

ROSDISTRO="$(rosversion -d)"
BASE=$1
SENSOR=$2
ARCH="$(uname -m)"
echo $ARCH
echo "
______ _____________   _________ ________ _______ ________ _______ ________
___  / ____  _/___  | / /__  __ \___  __ \__  __ \___  __ )__  __ \___  __/
__  /   __  /  __   |/ / _  / / /__  /_/ /_  / / /__  __  |_  / / /__  /   
_  /_____/ /   _  /|  /  / /_/ / _  _, _/ / /_/ / _  /_/ / / /_/ / _  /    
/_____//___/   /_/ |_/   \____/  /_/ |_|  \____/  /_____/  \____/  /_/     
                    
                            http://linorobot.org                                                                          
"
if [ "$3" != "test" ]
    then
        if [ "$*" == "" ]
            then
                echo "No arguments provided"
                echo
                echo "Example: $ ./install.sh 2wd xv11"
                echo
                exit 1
                
        elif [[ "$1" != "2wd" && "$1" != "4wd" && "$1" != "mecanum" && "$1" != "ackermann" ]]
            then
                echo "Invalid linorobot base: $1"
                echo
                echo "Valid Options:"
                echo "2wd"
                echo "4wd"
                echo "ackermann"
                echo "mecanum"
                echo
                exit 1

        elif [[ "$2" != "xv11" && "$2" != "rplidar" && "$2" != "ydlidar" && "$2" != "hokuyo" && "$2" != "kinect" && "$2" != "realsense" ]]
            then
                echo "Invalid linorobot sensor: $2"
                echo
                echo "Valid Options:"
                echo "hokuyo"
                echo "kinect"
                echo "lms1xx"
                echo "realsense"
                echo "rplidar"
                echo "xv11"
                echo "ydlidar"
                echo
                exit 1
        
        elif [[ "$ARCH" != "x86_64" && "$2" == "realsense" ]]
            then
                echo "Intel Realsense R200 is not supported in $ARCH architecture."
                exit 1

        fi

        echo
        echo -n "You are installing ROS-$ROSDISTRO Linorobot for $BASE base with a $SENSOR sensor. Enter [y] to continue. " 
        read reply
        if [[ "$reply" != "y" && "$reply" != "Y" ]]
            then
                echo "Wrong input. Exiting now"
                exit 1
        fi
fi

echo
echo "INSTALLING NOW...."
echo

sudo apt-get update
sudo apt-get install -y \
avahi-daemon \
openssh-server \
python-setuptools \
python-dev \
build-essential #python-gudev

#sudo easy_install pip
#sudo python2.7 -m pip install -U platformio
#sudo rm -rf $HOME/.platformio/

source /opt/ros/$ROSDISTRO/setup.bash

LINODIR=~/workspace
cd $LINODIR

if [ ! -d "linorobot_ws/src" ]; then
    mkdir -p linorobot_ws/src
    cd $LINODIR/linorobot_ws/src
    catkin_init_workspace
fi

cd $LINODIR/linorobot_ws/src

sudo apt-get install -y \
ros-$ROSDISTRO-roslint \
ros-$ROSDISTRO-rosserial \
ros-$ROSDISTRO-rosserial-arduino \
ros-$ROSDISTRO-imu-filter-madgwick \
ros-$ROSDISTRO-gmapping \
ros-$ROSDISTRO-map-server \
ros-$ROSDISTRO-navigation \
ros-$ROSDISTRO-robot-localization \
ros-$ROSDISTRO-teleop-twist-keyboard \
ros-$ROSDISTRO-tf2 \
ros-$ROSDISTRO-tf2-ros \
ros-$ROSDISTRO-rqt \
ros-$ROSDISTRO-rqt-common-plugins

if [[ "$3" == "test" ]]
    then
        sudo apt-get install -y \
        ros-$ROSDISTRO-xv-11-laser-driver \
        ros-$ROSDISTRO-rplidar-ros \
        ros-$ROSDISTRO-urg-node \
        ros-$ROSDISTRO-lms1xx \
        ros-$ROSDISTRO-freenect-launch \
        ros-$ROSDISTRO-depthimage-to-laserscan \
        ros-$ROSDISTRO-teb-local-planner 

        cd $LINODIR/linorobot_ws/src
        git clone https://github.com/EAIBOT/ydlidar.git

else
    if [[ "$SENSOR" == "hokuyo" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-urg-node
            hokuyoip=
            echo ""
            echo -n "Input your hokuyo IP. Press Enter to skip (Serial Based LIDAR): "
            read hokuyoip
            echo "export LIDARIP=$hokuyoip" >> $HOME/.bashrc

    elif [[ "$SENSOR" == "kinect" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-freenect-launch
            sudo apt-get install -y ros-$ROSDISTRO-depthimage-to-laserscan
            
    elif [[ "$SENSOR" == "lms1xx" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-lms1xx
            echo ""
            echo -n "Input your LMS1xx IP: "
            read lms1xxip
            echo "export LIDARIP=$lms1xxip" >> $HOME/.bashrc

    elif [[ "$SENSOR" == "realsense" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-realsense-camera
            sudo apt-get install -y ros-$ROSDISTRO-depthimage-to-laserscan

    elif [[ "$SENSOR" == "rplidar" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-rplidar-ros

    elif [[ "$SENSOR" == "xv11" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-xv-11-laser-driver

    elif [[ "$SENSOR" == "ydlidar" ]]
        then
            cd $LINODIR/linorobot_ws/src
            if [ ! -d "linorobot_ws/src" ]; then
                git clone https://github.com/YDLIDAR/ydlidar_ros.git
            if
    fi

    if [[ "$BASE" == "ackermann" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-teb-local-planner
    fi
fi

cd $LINODIR/linorobot_ws/src
git clone https://github.com/linorobot/linorobot.git
git clone https://github.com/linorobot/imu_calib.git
git clone https://github.com/linorobot/lino_pid.git
git clone https://github.com/linorobot/lino_udev.git
git clone https://github.com/linorobot/lino_msgs.git

cd $LINODIR/linorobot_ws/src/linorobot
TRAVIS_BRANCH="echo $TRAVIS_BRANCH"
if [ "$TRAVIS_BRANCH" = "devel" ]; then git checkout devel; fi

# add keyboard_teleop
cat > "launch/keyboard.launch" <<EOF
<launch>
  <node pkg="teleop_twist_keyboard" type="teleop_twist_keyboard.py" name="teleop" output="screen">
      <param name="speed" type="double" value="0.3"/>
      <param name="turn" type="double" value="0.5" />
      <!--
      <remap from="cmd_vel" to="key_teleop/cmd_vel"/>
      -->
  </node>
</launch>
EOF


#cd $HOME/linorobot_ws/src/linorobot/teensy/firmware
#export PLATFORMIO_CI_SRC=$PWD/src/firmware.ino
#platformio ci --project-conf=./platformio.ini --lib="./lib/ros_lib" --lib="./lib/config"  --lib="./lib/motor"  --lib="./lib/kinematics"  --lib="./lib/pid"  --lib="./lib/imu" --lib="./lib/encoder"

echo "source $LINODIR/linorobot_ws/devel/setup.bash" >> $HOME/.bashrc
echo "export LINOLIDAR=$SENSOR" >> $HOME/.bashrc
echo "export LINOBASE=$BASE" >> $HOME/.bashrc
source $HOME/.bashrc

cd $LINODIR/linorobot_ws
catkin_make --pkg lino_msgs
catkin_make

echo
echo "INSTALLATION DONE!"
echo
