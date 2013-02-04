import webapp2

from google.appengine.api.app_identity import get_application_id

from models.User import OzUser

from handlers.Cms import CmsHandler
from handlers.Cms import CmsCutout
from handlers.Cms import CmsZoetrope
from handlers.Cms import CmsLocale
from handlers.User import LogoutHandler

config = {}
config['webapp2_extras.sessions'] = {
    'secret_key': 'lkm)@JRFNP@#jkm0iuj3298HP@!r9jf2',
}
config['webapp2_extras.auth'] = {
        'user_model': OzUser,
}
config['webapp2_extras.jinja2'] = {
    'template_path': 'templates'
}

app = webapp2.WSGIApplication([
    webapp2.Route('/cms', CmsHandler),
    webapp2.Route('/cms/', CmsHandler),

    webapp2.Route('/cms/home', CmsZoetrope),
    webapp2.Route('/cms/home/', CmsZoetrope),

    webapp2.Route('/cms/cutoutDesktop', CmsCutout),
    webapp2.Route('/cms/cutoutDesktop/', CmsCutout),
    webapp2.Route('/cms/cutoutMobile', CmsCutout),
    webapp2.Route('/cms/cutoutMobile/', CmsCutout),

    webapp2.Route('/cms/zoetrope', CmsZoetrope),
    webapp2.Route('/cms/zoetrope/', CmsZoetrope),

    webapp2.Route('/cms/localeDesktop', CmsLocale),
    webapp2.Route('/cms/localeDesktop/', CmsLocale),
    webapp2.Route('/cms/localeMobile', CmsLocale),
    webapp2.Route('/cms/localeMobile/', CmsLocale),

    webapp2.Route('/cms/logout', LogoutHandler),
    webapp2.Route('/cms/logout/', LogoutHandler),

], debug=False, config=config)


def main():
    app.run()

if __name__ == '__main__':
    main()
