from google.appengine.ext import ndb

class Copy(ndb.Model):
    text          = ndb.TextProperty()  # JSON-encoded translation for desktop
    text_mob      = ndb.TextProperty()  # JSON-encoded translation for mobile
    lang          = ndb.StringProperty()  # language code
    lang_name     = ndb.StringProperty()  # English name for language
    date_updated  = ndb.DateTimeProperty(auto_now=True)
