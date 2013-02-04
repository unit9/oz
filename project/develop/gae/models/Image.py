from google.appengine.ext import ndb

class Image(ndb.Model):
    uri = ndb.StringProperty()
    gcs_file = ndb.StringProperty()
    kind = ndb.StringProperty()
    viewed = ndb.BooleanProperty()
    approved = ndb.BooleanProperty()
    date_created = ndb.DateTimeProperty(auto_now_add=True)
    date_approved = ndb.DateTimeProperty()
