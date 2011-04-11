import os
import bpy
import json

MORSE_COMPONENTS = '/usr/local/share/data/morse/components'

"""
would be nice to be able to generate the components dictionary.
TODO find a way to list the objects from .blend file (*/*.blend/Object/*)
http://webchat.freenode.net/?channels=blendercoders
[18:35] <ideasman_42> pierriko, for this use: 
http://www.blender.org/documentation/250PythonDoc/bpy.types.BlendDataLibraries.html#bpy.types.BlendDataLibraries.load

dictionary-convention:
{
  'component-directory': {
    '.blend-file': ['main-object-name', 'child1-name', ...]
  }
}
"""

MORSE_COMPONENTS_DICT = {
  'robots': {
    'atrv': ['ATRV', 'Wheel.1', 'Wheel.2', 'Wheel.3', 'Wheel.4']
  },
  'sensors': {
    'morse_gyroscope': ['Gyroscope', 'Gyro_box'],
    'morse_GPS': ['GPS', 'GPS_box'],
    'morse_odometry': ['Odometry', 'Odometry_mesh']
  },
  'controllers': {
    'morse_vw_control': ['Motion_Controller'],
    'morse_xyw_control': ['Motion_Controller']
  },
  'middleware': {
    'ros_empty': ['ROS_Empty'],
    'socket_empty': ['Socket_Empty']
  }
}

class ComponentsData(object):
  def __init__(self, path):
    self.path = path
    self._data = {}
    self._update()
  def _update(self):
    for category in os.listdir(self.path):
      pathc = os.path.join(self.path, category)
      if os.path.isdir(pathc):
        self._data[category] = {}
        for blend in os.listdir(pathc):
          pathb = os.path.join(pathc, blend)
          if os.path.isfile(pathb) & blend.endswith('.blend'):
            self._data[category][blend[:-6]] = self.objects(pathb)
  def objects(self, blend):
    """ The problem is now that we don't respect the dictionary-convention, 
    which is: ['main-object-name', 'child1-name', ...] 
    (in order to select the main object in Component class) 
    then, bpy.data.libraries.load(path) is 2.57 OK , but 2.56 NOK!
    """
    objects = []
    with bpy.data.libraries.load(blend) as (src, dest):
      objects = src.objects
    return objects
  def dump(self, dest):
    fdict = open(dest, 'w')
    json.dump(self.data, fdict, indent=1)
    fdict.close()
  @property
  def data(self):
    return self._data

#components = ComponentsData(MORSE_COMPONENTS)
#components.dump('/tmp/morse-components.py')

"""
dictionary-convention:
{
  .blend-middleware: {
    .blend-component: ['MW', 'method', 'path']
  }
}
"""
MORSE_MIDDLEWARE_DICT = {
  'ros_empty': {
    'morse_gyroscope': ['ROS', 'post_message'],
    'morse_vw_control': ['ROS', 'read_twist', 'morse/middleware/ros/read_vw_twist']
  },
  'socket_empty': {
    'morse_gyroscope': ['ROS', 'post_message'],
    'morse_vw_control': ['ROS', 'read_message']
  }
}

class Configuration(object):
  def __init__(self):
    self.middleware = {}
    self.modifier = {}
    self.service = {}
  def write(self):
    cfg = bpy.data.texts['component_config.py']
    cfg.clear()
    cfg.write('component_mw = ' + str(self.middleware) )
    cfg.write('\n')
    cfg.write('component_modifier = ' + str(self.modifier) )
    cfg.write('\n')
    cfg.write('component_service = ' + str(self.service) )
    cfg.write('\n')
  def linkV2(self, component, mwmethod):
    self.middleware[component.name] = mwmethod.config
  def link(self, component, mwmethodcfg):
    self.middleware[component.name] = mwmethodcfg


# http://www.blender.org/documentation/250PythonDoc/bpy.ops.wm.html#bpy.ops.wm.link_append
class Component(object):
  _config = Configuration()
  def __init__(self, category, name):
    objlist = [{'name':obj} for obj in MORSE_COMPONENTS_DICT[category][name]]
    objname = objlist[0]['name'] # name of the main object
    objpath = os.path.join(MORSE_COMPONENTS, category, name + '.blend/Object/')
    bpy.ops.wm.link_append(directory=objpath, link=False, files=objlist)
    self._blendname = name
    self._blendobj = bpy.data.objects[objname]
  def append(self, obj):
    """ Add a child to the current object,
    eg: robot.append(sensor), will set the robot parent of the sensor.
    cf: bpy.ops.object.parent_set()
    """
    opsobj = bpy.ops.object
    opsobj.select_all(action = 'DESELECT')
    opsobj.select_name(name = obj.name)
    bpy.ops.object.make_local()
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
  def location(self, x=0.0, y=0.0, z=0.0):
    self._blendobj.location = (x,y,z)
  def __str__(self):
    return self.name

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
  def configure(self, component):
    self._config.link(component, 
      MORSE_MIDDLEWARE_DICT[self._blendname][component._blendname] )
    self._config.write()


