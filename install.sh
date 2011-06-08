#!/bin/sh
###############################################################################
#
#                             PROTEUS
#
# HOWTO install ROS / OROCOS / MORSE [draft]
#
# cd ~/workspace 
# wget https://github.com/pierriko/proteus/raw/master/install.sh
# sh install.sh
#
# This script targets Ubuntu lucid i386 (10.04LTS)
#
###############################################################################

#sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu lucid main" > /etc/apt/sources.list.d/ros-latest.list'
#wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
#sudo apt-get install ros-diamondback-desktop-full ros-diamondback-orocos-toolchain-ros 

WORKING_DIR=`pwd`

sudo apt-get update
## Dependencies ( 'git-core' because 'git' doesnt exists for lucid )
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git-core mercurial python3.1-dev python-yaml libyaml-dev ruby rubygems doxygen 
#sudo apt-get upgrade

## ROS http://www.ros.org/wiki/diamondback/Installation/Ubuntu/Source
sudo easy_install -U rosinstall
if [ ! -d ros ]; then
  echo "source $WORKING_DIR/ros/setup.bash" >> $WORKING_DIR/setup.sh
fi
rosinstall $WORKING_DIR/ros "http://packages.ros.org/cgi-bin/gen_rosinstall.py?rosdistro=diamondback&variant=desktop-full&overlay=no"
. $WORKING_DIR/setup.sh

## Orocos http://www.ros.org/wiki/orocos_toolchain_ros
cd $WORKING_DIR/ros
if [ ! -d orocos_toolchain_ros ]; then
  git clone http://git.mech.kuleuven.be/robotics/orocos_toolchain_ros.git
  cd orocos_toolchain_ros
  git checkout -b diamondback origin/diamondback
  git submodule init
  git submodule update --recursive
  echo "export ROS_PACKAGE_PATH=$WORKING_DIR/ros/orocos_toolchain_ros:\$ROS_PACKAGE_PATH" >> $WORKING_DIR/setup.sh
  . $WORKING_DIR/setup.sh
  echo "source $WORKING_DIR/ros/orocos_toolchain_ros/env.sh" >> $WORKING_DIR/setup.sh
  # (?) echo "export ORBInitRef='NameService=corbaname::localhost'" >> $WORKING_DIR/setup.sh
else
  cd orocos_toolchain_ros
  git pull && git submodule foreach git pull
fi
rosmake --rosdep-install orocos_toolchain_ros
. $WORKING_DIR/setup.sh
echo "Orocos built, do 'rosrun ocl deployer-gnulinux' to check"

## Morse http://www.openrobots.org/morse/doc/stable/user/installation.html
cd $WORKING_DIR
#
#sudo apt-get install python3.2-dev # http://packages.ubuntu.com/natty/python3.2-dev
#wget http://download.blender.org/release/Blender2.57/blender-2.57b-linux-glibc27-i686.tar.bz2
#tar jxf blender-2.57b-linux-glibc27-i686.tar.bz2
#echo "export MORSE_BLENDER=$WORKING_DIR/blender-2.57b-linux-glibc27-i686/blender" >> $WORKING_DIR/setup.sh
#
BLENDER=blender-2.56a-beta-linux-glibc27-i686
if [ ! -d $BLENDER ]; then
  if [ ! -f $BLENDER.tar.bz2 ]; then
    wget http://download.blender.org/release/Blender2.56abeta/$BLENDER.tar.bz2
  fi
  tar jxf $BLENDER.tar.bz2
  echo "export MORSE_BLENDER=$WORKING_DIR/$BLENDER/blender" >> $WORKING_DIR/setup.sh
  . $WORKING_DIR/setup.sh
fi
if [ ! -d morse ]; then
  git clone https://github.com/pierriko/morse.git
  cd morse
else
  cd morse
  git pull # origin master
  if [ -d build ]; then
    mv build build.`date +%s`
  fi
fi
mkdir build && cd build
cmake -DBUILD_ROS_SUPPORT=ON  .. 
sudo make install
echo "Morse built, do 'morse check' to check"

# Morse/ROS integration
# PyYAML
# sudo apt-get install python3-yaml # if >= maverick (10.10)
cd $WORKING_DIR
PYYAML=PyYAML-3.09
if [ ! -d $PYYAML ]; then
  if [ ! -f $PYYAML.tar.gz ]; then
    wget http://pyyaml.org/download/pyyaml/$PYYAML.tar.gz
  fi
  tar zxf $PYYAML.tar.gz
  cd $PYYAML
  sudo python3.1 setup.py install
fi

echo "ROS-Py3 : patch ROS for a Python 3 support"
echo "( http://www.openrobots.org/morse/doc/stable/user/installation.html#ros )"
# ROS-Py3
cd $WORKING_DIR
if [ ! -d ros-py3 ]; then
  echo "export PYTHONPATH=$WORKING_DIR/ros/ros/core/roslib/src:\$PYTHONPATH" >> $WORKING_DIR/setup.sh
  echo "source $WORKING_DIR/ros-py3/setup.bash" >> $WORKING_DIR/setup.sh
fi
rosinstall $WORKING_DIR/ros-py3 $WORKING_DIR/ros http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall
rosmake ros &&  rosmake ros_comm &&  rosmake common_msgs
. $WORKING_DIR/setup.sh

echo "following is experimental (!)"
echo "morse_ros ( https://github.com/kargm/morse_ros ) continue? [y,N]"
read TEST
if [ "$TEST" = "y" ]; then
  ## TEST
  # cf https://github.com/kargm/morse_ros
  cd $WORKING_DIR/ros
  git clone https://github.com/kargm/morse_ros.git
  export ROS_PACKAGE_PATH=$WORKING_DIR/ros/morse_ros:$ROS_PACKAGE_PATH
  svn checkout https://tum-ros-pkg.svn.sourceforge.net/svnroot/tum-ros-pkg/stacks/ias_nav/
  export ROS_PACKAGE_PATH=$WORKING_DIR/ros/ias_nav:$ROS_PACKAGE_PATH
  git clone http://code.in.tum.de/git/ias-common.git
  export ROS_PACKAGE_PATH=$WORKING_DIR/ros/ias-common:$ROS_PACKAGE_PATH
  rosmake ias_nav
fi
echo "done!"

