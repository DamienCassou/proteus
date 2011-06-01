#!/bin/sh
###############################################################################
#
#                             PROTEUS
#
# HOWTO
# cd ~/workspace 
# wget https://github.com/pierriko/proteus/raw/master/install.sh
# sh install.sh
#
###############################################################################

WORKING_DIR=`pwd`

###
### ROS / OROCOS / MORSE 
### install script [draft]

## Dependencies
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git-core mercurial python3.1-dev python-yaml libyaml-dev 

## ROS http://www.ros.org/wiki/diamondback/Installation/Ubuntu/Source
sudo easy_install -U rosinstall
rosinstall $WORKING_DIR/ros "http://packages.ros.org/cgi-bin/gen_rosinstall.py?rosdistro=diamondback&variant=desktop-full&overlay=no"
echo "source $WORKING_DIR/ros/setup.bash" >> ~/.bashrc
. ~/.bashrc

## Orocos http://www.ros.org/wiki/orocos_toolchain_ros
cd $WORKING_DIR/ros
git clone http://git.mech.kuleuven.be/robotics/orocos_toolchain_ros.git
cd orocos_toolchain_ros
git checkout -b diamondback origin/diamondback
git submodule init
git submodule update --recursive
#git submodule foreach 'git fetch'
echo "export ROS_PACKAGE_PATH=$WORKING_DIR/ros/orocos_toolchain_ros:\$ROS_PACKAGE_PATH" >> ~/.bashrc
. ~/.bashrc
rosmake orocos_toolchain_ros
echo "source $WORKING_DIR/orocos_toolchain_ros/env.sh" >> ~/.bashrc
. ~/.bashrc
echo "Orocos built, do 'rosrun ocl deployer-gnulinux' to check"

## Morse http://www.openrobots.org/morse/doc/user/installation.html
cd $WORKING_DIR
#sudo apt-get install python3.2-dev # http://packages.ubuntu.com/natty/python3.2-dev
#wget http://download.blender.org/release/Blender2.57/blender-2.57b-linux-glibc27-i686.tar.bz2
#tar jxf blender-2.57b-linux-glibc27-i686.tar.bz2
#echo "export MORSE_BLENDER=$WORKING_DIR/blender-2.57b-linux-glibc27-i686/blender" >> ~/.bashrc
wget http://download.blender.org/release/Blender2.56abeta/blender-2.56a-beta-linux-glibc27-i686.tar.bz2
tar jxf blender-2.56a-beta-linux-glibc27-i686.tar.bz2
echo "export MORSE_BLENDER=$WORKING_DIR/blender-2.56a-beta-linux-glibc27-i686/blender" >> ~/.bashrc
. ~/.bashrc
git clone https://github.com/pierriko/morse.git
cd morse
mkdir build && cd build
cmake -DBUILD_ROS_SUPPORT=ON  .. 
sudo make install
echo "Morse built, do 'morse check' to check"

# Morse/ROS integration
# http://www.openrobots.org/morse/doc/latest/user/middlewares/ros/ros_installation.html
# PyYAML
# sudo apt-get install python3-yaml # 11.04 (natty)
cd $WORKING_DIR
wget http://pyyaml.org/download/pyyaml/PyYAML-3.09.tar.gz
tar zxf PyYAML-3.09.tar.gz
cd PyYAML-3.09
sudo python3.1 setup.py install

echo "ROS-Py3 : patch ROS for a Python 3 support"
echo "( http://www.openrobots.org/morse/doc/latest/user/middlewares/ros/ros_installation.html )"
# ROS-Py3
cd $WORKING_DIR
rosinstall $WORKING_DIR/ros-py3 $WORKING_DIR/ros http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall
rosmake ros &&  rosmake ros_comm &&  rosmake common_msgs
echo "export PYTHONPATH=$WORKING_DIR/ros/ros/core/roslib/src:\$PYTHONPATH" >> ~/.bashrc
. ~/.bashrc

echo "getting our Python script"
wget https://github.com/pierriko/proteus/raw/master/proteus.py

echo "morse_ros ( https://github.com/kargm/morse_ros ) continue? [y,N]"
read TEST
if [ "$TEST" = "y" ]; then
  ## TEST
  # cf https://github.com/kargm/morse_ros
  cd $WORKING_DIR/ros
  git clone https://github.com/kargm/morse_ros.git
  export ROS_PACKAGE_PATH=$WORKING_DIR/work/ros/morse_ros:$ROS_PACKAGE_PATH
  cd $WORKING_DIR/ros
  svn checkout https://tum-ros-pkg.svn.sourceforge.net/svnroot/tum-ros-pkg/stacks/ias_nav/
  export ROS_PACKAGE_PATH=$WORKING_DIR/work/ros/ias_nav:$ROS_PACKAGE_PATH
  git clone http://code.in.tum.de/git/ias-common.git
  export ROS_PACKAGE_PATH=$WORKING_DIR/work/ros/ias-common:$ROS_PACKAGE_PATH
  rosmake ias_nav
fi
echo "done!"

