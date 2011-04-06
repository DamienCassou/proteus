import bpy

MORSE_COMPONENTS = '/usr/local/share/data/morse/components'

# map VirtualName -> (components_relative_path, files)

MORSE_COMPONENTS_MAP = {
  'ATRV': ('/robots/atrv.blend/Object/', [{'name':'ATRV'}, {'name':'Wheel.1'},
    {'name':'Wheel.2'}, {'name':'Wheel.3'}, {'name':'Wheel.4'}]),
  'Gyroscope': ('/sensors/morse_gyroscope.blend/Object/', [{'name':'Gyroscope'}, 
    {'name':'Gyro_box'}]),
  'GPS': ('/sensors/morse_GPS.blend/Object/', [{'name':'GPS'}, 
    {'name':'GPS_box'}]),
  'Odometry': ('/sensors/morse_odometry.blend/Object/', [{'name':'Odometry'}, 
    {'name':'Odometry_mesh'}]),
  'VW_Controller': ('/controllers/morse_vw_control.blend/Object/', 
    [{'name':'Motion_Controller'}]),
  'XYW_Controller': ('/controllers/morse_xyw_control.blend/Object/', 
    [{'name':'Motion_Controller'}]),
  'ROS': ('/middleware/ros_empty.blend/Object/', [{'name':'ROS_Empty'}]),
  'Socket': ('/middleware/socket_empty.blend/Object/', [{'name':'Socket_Empty'}])
}

# morse.scripting
class MorseObject(object):
  def __init__(self, vname):
    blendata = MORSE_COMPONENTS_MAP[vname]
    self.name = blendata[1][0]['name']
    if vname in MORSE_COMPONENTS_MAP:
      bpy.ops.wm.link_append(directory=MORSE_COMPONENTS + blendata[0], 
        files=blendata[1])
    #else:
    #  raise Exception('unknown name ' + name)
    self._blendobj = bpy.data.objects[self.name]
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

class MorseSimulation(object):
  def __init__(self):
    self.comp_mw = {}
    self.comp_mod = {}
    self.comp_srv = {}
  def init(self):
    cfg = bpy.data.texts['component_config.py']
    cfg.clear()
    cfg.write('component_mw = ' + str(self.comp_mw) )
    cfg.write('\n')
    cfg.write('component_modifier = ' + str(self.comp_mod) )
    cfg.write('\n')
    cfg.write('component_service = ' + str(self.comp_srv) )
    cfg.write('\n')


# Test the API
# http://www.openrobots.org/morse/doc/latest/user/tutorial.html
# Add ATRV robot to the scene
robot = MorseObject('ATRV')
# Link an actuator
actuator = MorseObject('VW_Controller')
robot.append(actuator)
# Link a Gyroscope sensor
sensor = MorseObject('Gyroscope')
robot.append(sensor)
# Insert the middleware object
mws = MorseObject('Socket')
mwr = MorseObject('ROS')
sim = MorseSimulation()
# Modify component_config.py
sim.comp_mw = {
  'Gyroscope': ['ROS', 'post_message'],
  'Motion_Controller': ['ROS', 'read_twist', 
    'morse/middleware/ros/read_vw_twist']
}
sim.init()


