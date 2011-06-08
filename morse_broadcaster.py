#!/usr/bin/env python  
import roslib
roslib.load_manifest('nav_msgs')
roslib.load_manifest('learning_tf')
import rospy
from nav_msgs.msg import Odometry
import tf

#http://www.ros.org/wiki/navigation/Tutorials/RobotSetup/TF

def handle_pose(odometry):
    br = tf.TransformBroadcaster()
    br.sendTransform((odometry.pose.pose.position.x, 
        odometry.pose.pose.position.y, odometry.pose.pose.position.z),
        (odometry.pose.pose.orientation.x, odometry.pose.pose.orientation.y, 
        odometry.pose.pose.orientation.z, odometry.pose.pose.orientation.w),
        odometry.header.stamp, "/base_link", "/map")

if __name__ == '__main__':
    rospy.init_node('morse_broadcaster')
    rospy.Subscriber('/ATRV/Pose_sensor', Odometry, handle_pose)
    br = tf.TransformBroadcaster()

    while not rospy.is_shutdown():
        br.sendTransform((0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0),
                     rospy.Time.now(),
                     "/base_laser_link",
                     "/base_link")
        br.sendTransform((0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0),
                     rospy.Time.now(),
                     "/odom",
                     "/base_link")
        rospy.sleep(1.)


