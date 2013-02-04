#!/usr/bin/env python
import webapp2
from google.appengine.ext import db
from model.ImageModel import ImageModel
from google.appengine.api import datastore_errors

class ApiImageHandler(webapp2.RequestHandler):

	def get(self):
		image = None

		try:
			image = db.get(self.request.get('id'))
		except datastore_errors.BadKeyError:
			self.error(404)

		if image and image.blob:
			self.response.headers['Content-Type'] = 'image/jpeg'
			self.response.out.write(image.blob)
		else:
			self.error(404)

	def post(self):
		image = ImageModel()
		photo = self.request.get('photo')
		image.blob = db.Blob(photo)
		image.put()
		self.response.out.write('{"id": "%s"}' % image.key());