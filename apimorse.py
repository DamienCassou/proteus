import bpy

MORSE_DATA = '/home/pierrick/work/morse/data/morse'
MORSE_COMPONENTS = MORSE_DATA + '/components'

# morse.scripting
class MorseObject(object):
  # TODO static list of all objects ?
  def __init__(self, directory, name, files=None):
    self.name = name
    if files != None:
      bpy.ops.wm.link_append(directory=directory, files=files)
    else:
      bpy.ops.wm.link_append(directory=directory, filename=name)
    self._blendobj = bpy.data.objects[name]
  def append(self, obj):
    opsobj = bpy.ops.object
    opsobj.select_all(action = 'DESELECT')
    opsobj.select_name(name = obj.name)
    opsobj.make_local()
    opsobj.select_name(name = self.name)
    opsobj.parent_set()
  @property
  def location(self):
    return self._blendobj.location
  @location.setter
  def location(self, value):
    self._blendobj.location = value

class MorseRobot(MorseObject):
  def __init__(self, name):
    if name == "ATRV":
      # Call the constructor of the parent class
      super(self.__class__,self).__init__(MORSE_COMPONENTS + 
        '/robots/atrv.blend/Object/', name, [{'name':'ATRV'}, {'name':'Wheel.1'},
        {'name':'Wheel.2'}, {'name':'Wheel.3'}, {'name':'Wheel.4'}])

class MorseSensor(MorseObject):
  def __init__(self, name):
    if name == "Gyroscope":
      # Call the constructor of the parent class
      super(self.__class__,self).__init__(MORSE_COMPONENTS + 
        '/sensors/morse_gyroscope.blend/Object/', name, [{'name':'Gyroscope'}, 
        {'name':'Gyro_box'}])

class MorseActuator(MorseObject):
  def __init__(self, name):
    if name == "Motion_Controller":
      # Call the constructor of the parent class
      super(self.__class__,self).__init__(MORSE_COMPONENTS + 
        '/controllers/morse_vw_control.blend/Object/', name)

class MorseMiddleware(MorseObject):
  def __init__(self, name):
    if name == "ROS":
      # Call the constructor of the parent class
      super(self.__class__,self).__init__(MORSE_COMPONENTS + 
        "/middleware/ros_empty.blend/Object/", "ROS_Empty")
    elif name == "Socket":
          # Call the constructor of the parent class
      super(self.__class__,self).__init__(MORSE_COMPONENTS + 
        "/middleware/socket_empty.blend/Object/", "Socket_Empty")

class MorseSimulation(object):
  def __init__(self):
    self.comp_mw = {}
    self.comp_mod = {}
    self.comp_srv = {}
  def init(self):
    cfg = bpy.data.texts['component_config.py']
    cfg.clear()
    cfg.write("component_mw = " + str(self.comp_mw) )
    cfg.write("\n")
    cfg.write("component_modifier = " + str(self.comp_mod) )
    cfg.write("\n")
    cfg.write("component_service = " + str(self.comp_srv) )
    cfg.write("\n")


# Test the API
# http://www.openrobots.org/morse/doc/latest/user/tutorial.html
# Add ATRV robot to the scene
robot = MorseRobot("ATRV")
# Link an actuator
actuator = MorseActuator("Motion_Controller")
robot.append(actuator)
# Link a Gyroscope sensor
sensor = MorseSensor("Gyroscope")
robot.append(sensor)
# Insert the middleware object
mws = MorseMiddleware("Socket")
mwr = MorseMiddleware("ROS")
sim = MorseSimulation()
# Modify component_config.py
sim.comp_mw = {
  "Gyroscope": ["ROS", "post_message"],
  "Motion_Controller": ["ROS", "read_twist", 
    "morse/middleware/ros/read_vw_twist"]
}
sim.init()


