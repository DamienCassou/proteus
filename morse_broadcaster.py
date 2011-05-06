#!/usr/bin/env python  
import roslib
roslib.load_manifest('learning_tf')
import rospy
import tf

#http://www.ros.org/wiki/navigation/Tutorials/RobotSetup/TF

if __name__ == '__main__':
    rospy.init_node('morse_broadcaster')
    br = tf.TransformBroadcaster()
    rate = rospy.Rate(10.0)

    while not rospy.is_shutdown():
        br.sendTransform((0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0),
                     rospy.Time.now(),
                     "/base_laser_link",
                     "/map")
        rate.sleep()


