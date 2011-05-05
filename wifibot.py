from morse.builder.morsebuilder import *

# Append ATRV robot to the scene
atrv = Robot('atrv')

# Append an actuator
motion = Controller('morse_vw_control')
motion.translate(z=0.3)
atrv.append(motion)

# Append an odometry sensor
odometry = Sensor('morse_odometry')
odometry.translate(x=-0.1, z=0.83)
atrv.append(odometry)

# Append a proximity sensor
proximity = Sensor('morse_proximity')
proximity.translate(x=-0.2, z=0.83)
atrv.append(proximity)

# Append a GPS sensor
gps = Sensor('morse_GPS')
gps.translate(x=-0.3,z=0.83)
atrv.append(gps)

# Append a sick laser
sick = Sensor('morse_sick')
sick.translate(x=0.18,z=0.94)
atrv.append(sick)
sick.properties(resolution = 1)

# Append a camera
cam = Sensor('morse_camera')
cam.translate(x=0.3,z=1.1)
atrv.append(cam)
cam.properties(cam_width = 128, cam_height = 128)

# Insert the middleware object
ros = Middleware('ros_empty')

# Configure the middlewares
ros.configure(motion)
ros.configure(odometry)
ros.configure(proximity)
ros.configure(gps)
ros.configure(sick)
ros.configure(cam)


