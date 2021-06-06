FROM ros:melodic-ros-core

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    git \
    wget \
    tmux \
    terminator \
    python-pip && \
    pip install -U --no-cache-dir supervisor supervisor_twiddler && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ros-${ROS_DISTRO}-kobuki-* \
    ros-${ROS_DISTRO}-ecl-streams \
    ros-${ROS_DISTRO}-yocs-velocity-smoother \
    ros-${ROS_DISTRO}-depthimage-to-laserscan \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-gazebo-ros-control \
    ros-${ROS_DISTRO}-depth-image-proc \
    ros-${ROS_DISTRO}-urdf-tutorial \
    ros-${ROS_DISTRO}-inux-peripheral-interfaces \
    ros-${ROS_DISTRO}-diagnostics \
    ros-${ROS_DISTRO}-move-base* \
    ros-${ROS_DISTRO}-map-server* \
    ros-${ROS_DISTRO}-amcl* \
    ros-${ROS_DISTRO}-navigation* \
    ros-${ROS_DISTRO}-openni2-camera \
    ros-${ROS_DISTRO}-openni2-launch \
    ros-${ROS_DISTRO}-joy && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    mkdir -p ~/turtlebot_ws/src && \
	cd ~/turtlebot_ws && \
    curl -sLf https://raw.githubusercontent.com/gaunthan/Turtlebot2-On-Melodic/master/install_basic.sh | bash && \
	catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0 && \
	cd /root && rm -rf turtlebot_ws

# install code-server
RUN wget https://github.com/cdr/code-server/releases/download/v3.10.2/code-server_3.10.2_$(dpkg --print-architecture).deb && \
    dpkg -i code-server_3.10.2_$(dpkg --print-architecture).deb

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

COPY ./app /app

EXPOSE 8558 11311

CMD [ "sudo", "-E", "/usr/local/bin/supervisord", "-c", "/app/supervisord.conf"]