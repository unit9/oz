#!/usr/bin/env python
from google.appengine.ext import db

class ImageModel(db.Model):
	blob = db.BlobProperty()
	date = db.DateTimeProperty(auto_now_add = True)