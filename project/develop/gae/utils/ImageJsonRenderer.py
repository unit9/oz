import os

from google.appengine.ext import db
from google.appengine.ext import ndb
from google.appengine.ext import blobstore
from google.appengine.api import images
from google.appengine.api import files

import StringIO
import PIL
from PIL import Image

class ImageJsonRenderer:
	def renderImageFromJson(self, photo_json, overlay_json):
		''' overlay image '''
		overlay_path = os.path.join(os.path.dirname(__file__), '../resources/images/cutout/overlays/{}.png'.format(overlay_json['id']))
		overlay_image = Image.open(overlay_path)

		''' user photo '''
		from handlers.Image import ImageGetHandler
		photo_key = ndb.Key("Image", int(photo_json['id']))
		photo_model = photo_key.get()
		photo_sio = ImageGetHandler.open_gcs_file(
			photo_model.gcs_file)
		photo_image = Image.open(photo_sio)

		''' user photo transformations '''
		photo_width = int(float(photo_json['size']['width']) * overlay_image.size[0])
		photo_height = int(float(photo_json['size']['height']) * overlay_image.size[1])
		photo_offset_x = int(float(photo_json['position']['left']) * overlay_image.size[0])
		photo_offset_y = int(float(photo_json['position']['top']) * overlay_image.size[1])
		photo_rotation = -float(photo_json['orientation']['rotation'])
		photo_orientation = self.get_photo_orientation(images.Image(image_data=photo_sio.getvalue()))

		''' cater for different photo orientations '''
		photo_rotation -= (photo_orientation - 1) * 90
		if photo_orientation % 2 == 0:
			temp_height = photo_height
			photo_height = photo_width
			photo_width = temp_height
			photo_offset_x -= int((photo_width - photo_height) * 0.5)
			photo_offset_y -= int((photo_height - photo_width) * 0.5)

		''' apply transformations '''
		photo_image = photo_image.resize((photo_width, photo_height), Image.ANTIALIAS)
		photo_image = photo_image.rotate(photo_rotation, resample=Image.BICUBIC, expand=1)
		photo_rotation_offset_x = int((photo_width - photo_image.size[0]) * 0.5)
		photo_rotation_offset_y = int((photo_height - photo_image.size[1]) * 0.5)

		''' offset the transformed photo '''
		photo_image_full = Image.new('RGBA', overlay_image.size, (0, 0, 0, 0))
		photo_image_full.paste(photo_image, (photo_offset_x + photo_rotation_offset_x, photo_offset_y + photo_rotation_offset_y))

		''' composite the layers '''
		render_image = Image.composite(overlay_image, photo_image_full, overlay_image)

		''' return the result '''
		return render_image

	def get_photo_orientation(self, image):
		try:
			image.rotate(0)
			image.execute_transforms(parse_source_metadata=True, output_encoding=images.JPEG)
			metadata = image.get_original_metadata()
			return metadata['Orientation']
		except Exception as e:
			return 1

	def applyShareFilter(self, image):
		''' crop the image '''
		image = image.crop((0, 0, image.size[0], image.size[0]))

		''' apply sepia '''
		sepia = self.make_linear_ramp((255, 220, 172))
		image = image.convert('L')
		image.putpalette(sepia)
		image = image.convert('RGB')

		''' rotate '''
		image = image.rotate(-10, resample=Image.BICUBIC, expand=1)
		return image

	def make_linear_ramp(self, white):
		ramp = []
		r, g, b = white
		for i in range(255):
			ramp.extend((r*i/255, g*i/255, b*i/255))
		return ramp
