import webapp2

from webapp2_extras import routes

from google.appengine.api.app_identity import get_application_id

from handlers.HomeHandler import HomeHandler
from handlers.MobileHandler import MobileHandler
from handlers.PreviewHandler import PreviewHandler
from handlers.NotFound import NotFoundHandler

config = {}
config['webapp2_extras.sessions'] = {
    'secret_key': 'lkm)@JRFNP@#jkm0iuj3298HP@!r9jf2',
}
config['webapp2_extras.jinja2'] = {
    'template_path': 'templates'
}

# TODO : change route as we're changing the nav on front-end

app = webapp2.WSGIApplication([
    (r'^/m(/.*)?$', MobileHandler),
    webapp2.Route(r'/preview/<mode:(zoe|cutout|music)>/<id:\d+>',
                  PreviewHandler),
] + [(path, HomeHandler) for path in [
    "/",
    "/zoetrope/?",
    "/cutout/?",
    "/music/?",
    "/storm/?",
    "/stormtest/?",
    "/final/?",
]] + [
    (r'.*', NotFoundHandler),
], debug=False, config=config)

def main():
    app.run()

if __name__ == '__main__':
    main()
