#!/bin/sh

#
# Morse & ROS & rosjava (Android) install (Python 3.1)
# Ubuntu Lucid (10.04 i386)
#

WORKING_DIR=`pwd`

echo "========================================"
echo "            Install ROS"
echo "========================================"

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu lucid main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt-get update
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git-core mercurial python3.1-dev python-yaml libyaml-dev ruby rubygems doxygen ros-diamondback-desktop-full openjdk-6-jdk ant1.8 

echo "========================================"
echo "            Install Blender"
echo "========================================"

# Morse http://www.openrobots.org/morse/doc/stable/user/installation.html
cd $WORKING_DIR
BLENDER=blender-2.56a-beta-linux-glibc27-i686
if [ ! -d $BLENDER ]; then
  if [ ! -f $BLENDER.tar.bz2 ]; then
    wget http://download.blender.org/release/Blender2.56abeta/$BLENDER.tar.bz2
  fi
  tar jxf $BLENDER.tar.bz2
  echo "export MORSE_BLENDER=$WORKING_DIR/$BLENDER/blender" >> $WORKING_DIR/setup.sh
  . $WORKING_DIR/setup.sh
fi

echo "========================================"
echo "            Install Morse"
echo "========================================"

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

echo "========================================"
echo "            Install PyYAML (Python3)"
echo "========================================"

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

echo "========================================"
echo "            Patch ROS (Python3 support)"
echo "========================================"
echo "( http://www.openrobots.org/morse/doc/stable/user/installation.html#ros )"
# ROS-Py3
cd $WORKING_DIR
if [ ! -d ros-addons ]; then
  echo "source $WORKING_DIR/ros-addons/setup.bash" >> $WORKING_DIR/setup.sh
fi

sudo easy_install -U rosinstall
rosinstall $WORKING_DIR/ros-addons /opt/ros/diamondback http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall http://rosjava.googlecode.com/hg/rosjava.rosinstall
. $WORKING_DIR/setup.sh
rosmake ros ros_comm common_msgs sensor_msgs geometry_msgs 

echo "========================================"
echo "            Install ROSJava"
echo "========================================"

roscd rosjava
ant dist

echo "done"
apt-get moo

