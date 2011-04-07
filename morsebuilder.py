import bpy

MORSE_COMPONENTS = '/usr/local/share/data/morse/components'

"""
http://www.blender.org/documentation/250PythonDoc/bpy.ops.wm.html#bpy.ops.wm.link_append
would be nice to be able to generate this map.
TODO find way to list the objects from .blend file (*/*.blend/Object/*)
for category in os.listdir(MORSE_COMPONENTS):
  if category isdir
    map[cat]={}
    for file in os.listdir(MORSE_COMPONENTS + '/' + category):
      # TODO 
      if file endWith .blend
        map[cat][file[:-6]] = blendObjectsList(file)

###

convention:
{
  'component-path': {
    '.blend-file': [{'name':'main-object-name'}, {'name':'child1-name'}, ... ]
  }
}
"""
MORSE_COMPONENTS_MAP = {
  'robots': {
    'atrv': [{'name':'ATRV'}, {'name':'Wheel.1'}, {'name':'Wheel.2'}, 
      {'name':'Wheel.3'}, {'name':'Wheel.4'}]
  },
  'sensors': {
    'morse_gyroscope': [{'name':'Gyroscope'}, {'name':'Gyro_box'}],
    'morse_GPS': [{'name':'GPS'}, {'name':'GPS_box'}],
    'morse_odometry': [{'name':'Odometry'}, {'name':'Odometry_mesh'}]
  },
  'controllers': {
    'morse_vw_control': [{'name':'Motion_Controller'}],
    'morse_xyw_control': [{'name':'Motion_Controller'}]
  },
  'middleware': {
    'ros_empty': [{'name':'ROS_Empty'}],
    'socket_empty': [{'name':'Socket_Empty'}]
  }
}

# morse.scripting
class Component(object):
  def __init__(self, category, name):
    blendata = MORSE_COMPONENTS_MAP[category][name]
    bpy.ops.wm.link_append(directory=MORSE_COMPONENTS + '/' + category + 
      '/' + name + '.blend/Object/', files=blendata)
    bpy.ops.object.make_local()
    oname = blendata[0]['name']
    self._blendobj = bpy.data.objects[oname]
  def append(self, obj):
    opsobj = bpy.ops.object
    opsobj.select_all(action = 'DESELECT')
    opsobj.select_name(name = obj.name)
    opsobj.select_name(name = self.name)
    opsobj.parent_set()
  @property
  def name(self):
    return self._blendobj.name
  @name.setter
  def name(self, value):
    self._blendobj.name = value
  @property
  def location(self):
    return self._blendobj.location
  @location.setter
  def location(self, value):
    self._blendobj.location = value

class Robot(Component):
  def __init__(self, name):
    # Call the constructor of the parent class
    super(self.__class__,self).__init__('robots', name)

class Sensor(Component):
  def __init__(self, name):
    # Call the constructor of the parent class
    super(self.__class__,self).__init__('sensors', name)

class Controller(Component):
  def __init__(self, name):
    # Call the constructor of the parent class
    super(self.__class__,self).__init__('controllers', name)

class Middleware(Component):
  def __init__(self, name):
    # Call the constructor of the parent class
    super(self.__class__,self).__init__('middleware', name)

class Config(object):
  def __init__(self):
    self.middleware = {}
    self.modifier = {}
    self.service = {}
  def init(self):
    cfg = bpy.data.texts['component_config.py']
    cfg.clear()
    cfg.write('component_mw = ' + str(self.middleware) )
    cfg.write('\n')
    cfg.write('component_modifier = ' + str(self.modifier) )
    cfg.write('\n')
    cfg.write('component_service = ' + str(self.service) )
    cfg.write('\n')


# Test the API
# http://www.openrobots.org/morse/doc/latest/user/tutorial.html
# Add ATRV robot to the scene
robot = Robot('atrv')
# Link an actuator
actuator = Controller('morse_vw_control')
actuator.location=(0,0,0.3)
robot.append(actuator)
# Link a Gyroscope sensor
sensor = Sensor('morse_gyroscope')
sensor.location=(0,0,0.83)
robot.append(sensor)
# Insert the middleware object
mws = Middleware('socket_empty')
mwr = Middleware('ros_empty')
conf = Config()
# Modify component_config.py
conf.middleware = {
  'Gyroscope': ['ROS', 'post_message'],
  'Motion_Controller': ['ROS', 'read_twist', 
    'morse/middleware/ros/read_vw_twist']
}
conf.init()


