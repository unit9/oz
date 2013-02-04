from google.appengine.ext import ndb

import webapp2_extras.appengine.auth.models as auth_models

class OzUser(auth_models.User):
    email = ndb.StringProperty()
    role = ndb.IntegerProperty(default=0)
