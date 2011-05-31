#!/usr/bin/env python
import roslib
roslib.load_manifest('rospy')
roslib.load_manifest('geometry_msgs')
roslib.load_manifest('sensor_msgs')
import rospy
from sensor_msgs.msg import LaserScan
from geometry_msgs.msg import Twist

data = {
    'lastw': 0.0,
    'lastv': 0.1
}

def handle_sick(msg):
    mid = len(msg.ranges) / 2
    cmd = Twist()
    # we go to the highest-range side scanned
    if sum(msg.ranges[:mid]) > sum(msg.ranges[mid:]):
        cmd.angular.z = -.1
    else:
        cmd.angular.z = .1
    # if we found the (or a local?) max (oscilate) go faster
    if cmd.angular.z != data['lastw']:
        data['lastv'] += .1
    cmd.linear.x = data['lastv']
    data['lastw'] = cmd.angular.z
    topic.publish(cmd)

"""
http://www.ros.org/doc/api/sensor_msgs/html/msg/LaserScan.html
"""
if __name__ == '__main__':
    rospy.init_node('test_cmd')
    topic=rospy.Publisher('/ATRV/Motion_Controller', Twist)
    rospy.Subscriber('/ATRV/Sick', LaserScan, handle_sick)
    rate = rospy.Rate(10.0)
    while not rospy.is_shutdown():
        rate.sleep()

