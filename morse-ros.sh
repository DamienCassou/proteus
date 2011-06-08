#!/bin/sh

#
# Morse & ROS install (Python 3.1)
# Ubuntu Lucid (10.04 i386)
#

WORKING_DIR=`pwd`

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu lucid main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt-get update
if [ ! -d /opt/ros/diamondback ]; then
  echo "#!/bin/sh" > $WORKING_DIR/setup.sh
  echo "source /opt/ros/diamondback/ros/setup.bash" >> $WORKING_DIR/setup.sh
fi
sudo apt-get install build-essential g++ cmake python-setuptools wget subversion git-core mercurial python3.1-dev python-yaml libyaml-dev ruby rubygems doxygen ros-diamondback-desktop-full ros-diamondback-orocos-toolchain-ros 

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
  echo "source $WORKING_DIR/ros-py3/setup.bash" >> $WORKING_DIR/setup.sh
  echo "export JAVA_HOME=/usr/lib/jvm/java-6-openjdk" >> $WORKING_DIR/setup.sh
fi

sudo easy_install -U rosinstall
rosinstall $WORKING_DIR/ros-py3 /opt/ros/diamondback http://ias.cs.tum.edu/~kargm/ros_py3.rosinstall http://rosjava.googlecode.com/hg/rosjava.rosinstall
rosmake ros &&  rosmake ros_comm && rosmake common_msgs
. $WORKING_DIR/setup.sh

echo "Android SDK : still needed for http://rosjava.googlecode.com "
echo "( http://developer.android.com/sdk )"
cd $WORKING_DIR
if [ ! -d android-sdk-linux_x86 ]; then
  if [ ! -f android-sdk_r11-linux_x86.tgz ]; then
    wget http://dl.google.com/android/android-sdk_r11-linux_x86.tgz
  fi
  tar zxf android-sdk_r11-linux_x86.tgz
  ./android-sdk-linux_x86/tools/android &
  echo "(*) please install: "
  echo "  [*] Android SDK Platform-tools, revision 5"
  echo "  [*] SDK Platform Android 2.3.3, API 10"
  for prop in `find $WORKING_DIR/ros-py3/rosjava/android/ -name "default.properties"`; do
    echo "sdk.dir=$WORKING_DIR/android-sdk-linux_x86" >> $prop; echo -n "."
  done
  echo "(*) please edit target=android-10"
  find $WORKING_DIR/ros-py3/rosjava/android/ -name "default.properties" | xargs gedit &
fi

echo "(*) once you installed the SDK through the android tool, execute:"
echo "source $WORKING_DIR/setup.sh"
echo "roscd rosjava"
echo "ant dist"
echo
echo
apt-get moo
