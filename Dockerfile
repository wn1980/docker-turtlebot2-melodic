FROM ros:melodic-perception-bionic

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    git \
    wget \
    nano && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ros-${ROS_DISTRO}-desktop-full \
    ros-${ROS_DISTRO}-linux-peripheral-interfaces \
    ros-${ROS_DISTRO}-diagnostics \
    ros-${ROS_DISTRO}-navigation \
    ros-${ROS_DISTRO}-hector-slam \
    ros-${ROS_DISTRO}-octomap-server \
    ros-${ROS_DISTRO}-octomap-rviz-plugins \
    ros-${ROS_DISTRO}-vision-opencv \
    ros-${ROS_DISTRO}-depth-image-proc \
    ros-${ROS_DISTRO}-joy \
    python-rosdep && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    bash-completion \
    #less \
    htop \
    tmux \
    terminator \
    #fluxbox \
    jwm \
    xfonts-base \
    xauth \
    x11-xkb-utils \
    xkb-data \
    dbus-x11 \
    net-tools \
    usbutils \
    sudo \
    tigervnc-standalone-server \
    #tigervnc-xorg-extension \
    #novnc \
    python3-numpy \
    python-pip && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python - && \
    pip install -U --no-cache-dir supervisor supervisor_twiddler && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install noVNC
ENV NO_VNC_HOME=/opt/noVNC

RUN rm -Rf $NO_VNC_HOME && \
    mkdir -p $NO_VNC_HOME/utils/websockify && \
    wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME && \
    wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

COPY ./index.html $NO_VNC_HOME

RUN rm /etc/apt/apt.conf.d/docker-clean

# install code-server
ENV VERSION=3.12.0
RUN wget https://github.com/cdr/code-server/releases/download/v${VERSION}/code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    dpkg -i code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    rm -f code-server_${VERSION}_$(dpkg --print-architecture).deb

# install vscode
#RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
#    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
#    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
#    rm -f packages.microsoft.gpg

#RUN apt-get install -y apt-transport-https && \
#    apt-get update && \
#    apt-get install -y code # or code-insiders

RUN rm /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init

RUN mkdir -p /workspace

# setup user
RUN useradd -m developer && \
    usermod -aG sudo developer && \
    usermod --shell /bin/bash developer && \
    chown -R developer:developer /workspace && \
    ln -sfn /workspace /home/developer/workspace && \
    echo developer ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

ENV USER=developer

ENV HOME /home/developer

ENV SHELL /bin/bash

USER $USER

WORKDIR /home/developer

# init rosdep
RUN rosdep fix-permissions && rosdep update

# colorize less
#RUN echo "export LESS='-R'" >> ~/.bash_profile && \
#    echo "export LESSOPEN='|pygmentize -g %s'" >> ~/.bash_profile

# enable bash completion
RUN echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc && \
    #git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
    #~/.bash_it/install.sh --silent && \
    #rm ~/.bashrc.bak && \
    #bash -i -c "bash-it enable completion git" && \
    echo "source ~/.bashrc" >> ~/.bash_profile 

# update tigervnc
COPY ./app/install/tigervnc.sh /

RUN sudo /tigervnc.sh && sudo rm -f /tigervnc.sh

# compile turtlebot2 packages from sources
RUN sudo apt-get update && sudo apt-get upgrade -y 

COPY ./app/install/turtlebot2.sh /

RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    mkdir -p ~/turtlebot_ws/src && \
	cd ~/turtlebot_ws && \
    bash /turtlebot2.sh && \
    #curl -sLf https://raw.githubusercontent.com/gaunthan/Turtlebot2-On-Melodic/master/install_basic.sh | bash - && \
    catkin_make install -DCMAKE_BUILD_TYPE=Release && \
	#catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/$ROS_DISTRO -DCATKIN_ENABLE_TESTING=0 && \
	#cd /root && rm -rf turtlebot_ws && \
    sudo rm -f /turtlebot2.sh

COPY ./app /app

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

RUN echo "source ~/turtlebot_ws/install/setup.bash" >> ~/.bashrc

VOLUME /tmp/.X11-unix

ENV DISPLAY ":1"

EXPOSE 11311 8558 9901

CMD ["sudo", "-E", "/usr/local/bin/supervisord", "-c", "/app/supervisord.conf"]
