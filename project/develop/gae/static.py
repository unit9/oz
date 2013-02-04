import webapp2
import collections

from webapp2_extras import routes
from google.appengine.api import memcache

class DownloadModelsHandler(webapp2.RequestHandler):

    @staticmethod
    def cache_put(key, data):
        length = len(data)
        chunk_no = 97
        keys = dict()

        for i in xrange(0, length, 999999):
            keys[chr(chunk_no) + "_" + key] = data[i:i+999999]
            chunk_no += 1

        memcache.set_multi(keys, key_prefix="models_", time=3600)
        memcache.add(key=key, value=keys.keys())

    @staticmethod
    def cache_get(key):
        keys = memcache.get(key)
        if keys is not None:
            keys.sort()
            chunks = memcache.get_multi(keys, key_prefix="models_")
            if chunks is not None and len(keys) == len(chunks):
                data = []
                for k in keys:
                    #data.append(k + ": " + str(len(chunks[k])))
                    data.append(chunks[k])
                return "".join(data)

        return

    def get(self, filename = None):
        if filename is None:
            self.response.status_int = 404
            self.response.write("404 Not Found")
            return

        output = DownloadModelsHandler.cache_get(filename)
        if output is not None:
            self.response.headers["Cache-Control"] = "max-age=86400"
            self.response.headers['Content-Length'] = len(output)
            self.response.headers["Content-Disposition"] = 'attachment; filename=' + filename
            if filename.endswith(".png"):
                self.response.headers["Content-Type"] = "image/png"
            elif filename.endswith(".json"):
                self.response.headers["Content-Type"] = "application/json"
            else:
                self.response.headers["Content-Type"] = "application/octet-stream"
            self.response.write(output)
        else:
            try:
                with open("templates/web/models/" + filename) as model:
                    output = model.read()
                    self.response.headers["Cache-Control"] = "max-age=86400"
                    self.response.headers["Content-Length"] = len(output)
                    if filename.endswith(".png"):
                        DownloadModelsHandler.cache_put(filename, output)
                        self.response.headers["Content-Type"] = "image/png"
                    elif filename.endswith(".json"):
                        self.response.headers["Content-Type"] = "application/json"
                    else:
                        DownloadModelsHandler.cache_put(filename, output)
                        self.response.headers["Content-Disposition"] = 'attachment; filename=' + filename
                        self.response.headers["Content-Type"] = "application/octet-stream"
                    self.response.write(output)
            except IOError as e:
                self.response.status_int = 404
                self.response.write("404 Not Found")


app = webapp2.WSGIApplication([
    webapp2.Route('/models/<filename:(.*)>', DownloadModelsHandler),
], debug=False)

def main():
    app.run()

if __name__ == '__main__':
    main()
