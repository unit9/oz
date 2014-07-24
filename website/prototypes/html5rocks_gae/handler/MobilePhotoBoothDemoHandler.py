#!/usr/bin/env python
import os
import webapp2
from google.appengine.ext.webapp import template

class MobilePhotoBoothDemoHandler(webapp2.RequestHandler):

	def get(self):
		context = {}
		path = os.path.join(os.path.dirname(__file__), '../demos/mobile_photo_booth/index.html')
		self.response.out.write(template.render(path, context))
