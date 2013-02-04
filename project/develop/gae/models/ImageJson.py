from google.appengine.ext import ndb

class ImageJson(ndb.Model):
    photo_json = ndb.StringProperty()
    overlay_json = ndb.StringProperty()
    date_created = ndb.DateTimeProperty(auto_now_add=True)
