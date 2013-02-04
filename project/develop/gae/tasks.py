import webapp2

from webapp2_extras import json
from models.Image import Image

from datetime import datetime
from datetime import timedelta

from google.appengine.ext.blobstore import BlobInfo
from google.appengine.api.datastore_errors import EntityNotFoundError

class DeleteImagesHandler(webapp2.RequestHandler):

    def get(self):
        expired = datetime.now() - timedelta(90)
        images = Image.query(Image.date_created < expired).fetch()
        self.response.headers["Content-type"] = "application/json"
        for image in images:
            try:
                info = BlobInfo.get(image.blob)
                info.delete()
                image.key.delete()
            except EntityNotFoundError:
                pass
            except AttributeError:
                pass
        self.response.write('{"result": true}')


app = webapp2.WSGIApplication([
    webapp2.Route('/tasks/clean', DeleteImagesHandler),
], debug=False)

def main():
    app.run()

if __name__ == '__main__':
    main()
