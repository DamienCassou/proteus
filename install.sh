#!/bin/sh

WORKING_DIR=`pwd`

###
### ROS / OROCOS / MORSE 
### install script [draft]

## Dependencies
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git mercurial python3.1-dev libpython3.1 python-yaml libyaml-dev 

## ROS http://www.ros.org/wiki/diamondback/Installation/Ubuntu/Source
sudo easy_install -U rosinstall
rosinstall $WORKING_DIR/ros "http://packages.ros.org/cgi-bin/gen_rosinstall.py?rosdistro=diamondback&variant=ros-base&overlay=no"
echo "source $WORKING_DIR/ros/setup.bash" >> ~/.bashrc
. ~/.bashrc

## Orocos http://www.ros.org/wiki/orocos_toolchain_ros
cd $WORKING_DIR/ros
git clone http://git.mech.kuleuven.be/robotics/orocos_toolchain_ros.git
cd orocos_toolchain_ros
git checkout # checkout master, for branch: -b diamondback
git submodule init
git submodule update --recursive
export ROS_PACKAGE_PATH=$WORKING_DIR/ros/orocos_toolchain_ros:$ROS_PACKAGE_PATH
rosmake orocos_toolchain_ros
echo "Orocos built, do 'morse check' to verify"

## Morse http://www.openrobots.org/morse/doc/user/installation.html
cd $WORKING_DIR
wget http://download.blender.org/release/Blender2.56abeta/blender-2.56a-beta-linux-glibc27-i686.tar.bz2
tar jxf blender-2.56a-beta-linux-glibc27-i686.tar.bz2
export MORSE_BLENDER=$WORKING_DIR/blender-2.56a-beta-linux-glibc27-i686/blender
git clone https://github.com/laas/morse.git
cd morse
mkdir build && cd build
cmake ..
sudo make install
echo "Morse built, do 'morse check' to verify"

# Morse/ROS integration
# http://www.openrobots.org/morse/doc/latest/user/middlewares/ros/ros_installation.html
# PyYAML
cd $WORKING_DIR
wget http://pyyaml.org/download/pyyaml/PyYAML-3.09.tar.gz
tar zxf PyYAML-3.09.tar.gz
cd PyYAML-3.09
python setup.py install
# ROS-Py3
cd $WORKING_DIR
rosinstall $WORKING_DIR/ros-py3 $WORKING_DIR/ros http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall
rosmake ros &&  rosmake ros_comm &&  rosmake common_msgs
export PYTHONPATH=$WORKING_DIR/ros/ros/core/roslib/src:${PYTHONPATH}

echo "done!"

