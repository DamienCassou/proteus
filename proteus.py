import bpy

MORSE_DATA = '/home/pierrick/work/morse/data/morse'
MORSE_COMPONENTS = MORSE_DATA + '/components'

#bpy.ops.wm.open_mainfile(filepath = MORSE_DATA + '/morse_default.blend')

# Link the robot (ATRV)
bpy.ops.wm.link_append(directory = MORSE_COMPONENTS + 
  '/robots/atrv.blend/Object/', files=[{'name':'ATRV'}, {'name':'Wheel.1'},
  {'name':'Wheel.2'}, {'name':'Wheel.3'}, {'name':'Wheel.4'}])

# http://www.openrobots.org/morse/doc/latest/user/tutorial.html
# Link an actuator
bpy.ops.object.select_all(action = 'DESELECT')
bpy.ops.wm.link_append(directory = MORSE_COMPONENTS + 
  '/controllers/morse_vw_control.blend/Object/', filename = 'Motion_Controller')
bpy.ops.object.make_local()
bpy.ops.object.select_name(name = 'ATRV')
bpy.ops.object.parent_set()
# change default position (0,0,0)
bpy.data.objects['Motion_Controller'].location=(0,0,0.3)
# Link a Gyroscope sensor
bpy.ops.wm.link_append(directory = MORSE_COMPONENTS + 
  '/sensors/morse_gyroscope.blend/Object/', files=[{'name':'Gyroscope'}, 
  {'name':'Gyro_box'}])
bpy.ops.object.make_local()
bpy.ops.object.select_name(name = 'ATRV')
bpy.ops.object.parent_set()
bpy.data.objects['Gyroscope'].location=(0,0,0.7)
bpy.data.objects['Gyro_box'].location=(0,0,0.83)
# Insert the middleware object
bpy.ops.wm.link_append(directory = MORSE_COMPONENTS + 
  '/middleware/socket_empty.blend/Object/', filename = 'Socket_Empty')
bpy.data.objects['Socket_Empty'].location=(0,0,1)

# TODO modify component_config.py


'''
TODO look for "macro recording" in Blender
TIPS use Blender in debug mode (-d) to watch bpy calls
  blender -d 2>/dev/null | grep bpy

cf:
 - http://www.blender.org/documentation/250PythonDoc/bpy.ops.wm.html#bpy.ops.wm.link_append
 - http://www.blender.org/documentation/250PythonDoc/bpy.ops.object.html#bpy.ops.object.parent_set
 - http://wiki.blender.org/index.php/Robotics:Contents
 - http://www.openrobots.org/morse/doc/latest/user/tutorial.html

/usr/local/bin/morse:339
    #Replace the current process by Blender
    #os.execle(blender_exec, blender_exec, scene, env)
    if os.path.exists("proteus.py"):
        print("*** PROTEUS: loading Blender with proteus.py (-P) ***\n")
        # TODO os.execle(blender_exec, blender_exec, "-P", "proteus.py", env)
        os.execle(blender_exec, blender_exec, scene, "-P", "proteus.py", env)
    else:
        os.execle(blender_exec, blender_exec, scene, env)

'''

