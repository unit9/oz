from google.appengine.ext import ndb

class Music(ndb.Model):
    gcs_file = ndb.StringProperty()  # filename ref to a JSON-encoded object
