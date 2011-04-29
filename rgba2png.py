#!/usr/bin/env python
import sys
import png
import math
import numpy
import struct

def rgba8_png(raw_file):
  fd = open(raw_file, 'rb')
  buff = fd.read()
  fd.close()
  # buff: bytes(VideoTexture.ImageRender.image) (cf. Blender 2.5 API & MORSE )
  image_size = int(math.sqrt(len(buff) / 4))
  image2d = numpy.reshape([struct.unpack('B', b)[0] for b in buff], (-1, image_size * 4))
  png_writer = png.Writer(width = image_size, height = image_size, alpha = True)
  out_png = open(raw_file + '.png', 'wb')
  png_writer.write(out_png, image2d)
  out_png.close()

#("mencoder", "mf://*.png", "-mf", "fps="+fps+":type=png", "-sws", "6", "-o", videoname, "-ovc", "x264", "-x264encopts", "bitrate="+x264bitrate)

def main(args):
  for f in args[1:]:
    rgba8_png(f)
  help()

def help():
  print('Convert RAW RGBA8 bytes to PNG image')
  print('usage: '+sys.argv[0]+' file1 [file2 [file3 [...]]]')
  print('TIPS: use MEncoder to build a video:')
  print('mencoder mf://*.png -mf fps=2:type=png -sws 6 -o rgba8.avi -ovc x264')
  print('mencoder mf:///tmp/morse_camera*.png -mf fps=2:type=png -flip -o rgba8.avi -ovc x264')

if __name__ == '__main__':
  main(sys.argv)

