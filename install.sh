#!/bin/sh
###############################################################################
#
#                             PROTEUS
#
###############################################################################

WORKING_DIR=`pwd`

###
### ROS / OROCOS / MORSE 
### install script [draft]

## Dependencies
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git-core mercurial python3.1-dev libpython3.1 python-yaml libyaml-dev 

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
echo "export ROS_PACKAGE_PATH=$WORKING_DIR/ros/orocos_toolchain_ros:\$ROS_PACKAGE_PATH" >> ~/.bashrc
. ~/.bashrc
rosmake orocos_toolchain_ros
echo "source $WORKING_DIR/orocos_toolchain_ros/env.sh" >> ~/.bashrc
. ~/.bashrc
echo "Orocos built, do 'rosrun osl deployer-gnulinux' to check"

## Morse http://www.openrobots.org/morse/doc/user/installation.html
cd $WORKING_DIR
wget http://download.blender.org/release/Blender2.56abeta/blender-2.56a-beta-linux-glibc27-i686.tar.bz2
tar jxf blender-2.56a-beta-linux-glibc27-i686.tar.bz2
echo "export MORSE_BLENDER=$WORKING_DIR/blender-2.56a-beta-linux-glibc27-i686/blender" >> ~/.bashrc
. ~/.bashrc
git clone https://github.com/laas/morse.git
cd morse
mkdir build && cd build
cmake -DBUILD_ROS_SUPPORT=ON  .. 
sudo make install
echo "Morse built, do 'morse check' to check"

# Morse/ROS integration
# http://www.openrobots.org/morse/doc/latest/user/middlewares/ros/ros_installation.html
# PyYAML
cd $WORKING_DIR
wget http://pyyaml.org/download/pyyaml/PyYAML-3.09.tar.gz
tar zxf PyYAML-3.09.tar.gz
cd PyYAML-3.09
sudo python3.1 setup.py install
# ROS-Py3
cd $WORKING_DIR
rosinstall $WORKING_DIR/ros-py3 $WORKING_DIR/ros http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall
rosmake ros &&  rosmake ros_comm &&  rosmake common_msgs
echo "export PYTHONPATH=$WORKING_DIR/ros/ros/core/roslib/src:\$PYTHONPATH" >> ~/.bashrc
. ~/.bashrc

echo "done!"

echo "Test https://github.com/kargm/morse_ros , ctrl+c to stop , any key to continue"
read

## TEST
# cf https://github.com/kargm/morse_ros
cd $WORKING_DIR/ros
git https://github.com/kargm/morse_ros.git
export ROS_PACKAGE_PATH=$WORKING_DIR/work/ros/morse_ros:$ROS_PACKAGE_PATH
cd $WORKING_DIR/ros
svn checkout https://tum-ros-pkg.svn.sourceforge.net/svnroot/tum-ros-pkg/stacks/ias_nav/
export ROS_PACKAGE_PATH=$WORKING_DIR/work/ros/ias_nav:$ROS_PACKAGE_PATH
rosmake ias_nav

