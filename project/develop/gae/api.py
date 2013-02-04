import webapp2

from webapp2_extras import routes

from google.appengine.api.app_identity import get_application_id

from models.User import OzUser

from handlers.User import LoginHandler
from handlers.User import LogoutHandler
from handlers.User import UserStatusHandler
from handlers.Image import ImageAddHandler
from handlers.Image import ImageInfoHandler
from handlers.Image import ImageRejectHandler
from handlers.Image import ImageGetHandler
from handlers.Music import MusicHandler
from handlers.SignupHandler import SignupHandler
from handlers.Moderation import ModerationQueueHandler
from handlers.Localisation import LocalisationHandler
from handlers.Localisation import LocalisationListHandler
from handlers.Detect import PlatformDetectHandler
from handlers.Remind import ReminderHandler

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
    routes.PathPrefixRoute('/api', [
        #webapp2.Route(r'/user/create', SignupHandler),
        webapp2.Route(r'/user/login', LoginHandler),
        webapp2.Route(r'/user/status', UserStatusHandler),
        webapp2.Route(r'/user/logout', LogoutHandler),
        webapp2.Route(r'/localisation/'
                      r'<platform:(desktop|mobile)>/',
                      LocalisationListHandler),
        webapp2.Route(r'/localisation/'
                      r'<platform:(desktop|mobile)>/'
                      r'<lang:[A-Za-z0-9\-_]+>',
                      LocalisationHandler),
        webapp2.Route(r'/moderation/queue', ModerationQueueHandler),
        webapp2.Route(r'/moderation/queue/', ModerationQueueHandler),
        webapp2.Route(
            r'/moderation/queue/<kind:(cutout|zoetrope|cutoutMobile)>',
            ModerationQueueHandler),
        webapp2.Route(r'/image/add', ImageAddHandler),
        webapp2.Route(r'/image/info/<image_id:\d+>', ImageInfoHandler),
        webapp2.Route(r'/image/reject/<image_id:\d+>', ImageRejectHandler),
        webapp2.Route(r'/image/get/<image_id:\d+>', ImageGetHandler),
        webapp2.Route(r'/music/', MusicHandler),
        webapp2.Route(r'/music/<music_id:\d+>', MusicHandler),
        webapp2.Route(r'/detect', PlatformDetectHandler),
        webapp2.Route(r'/reminder/<lang:[A-Za-z0-9\-_]+>', ReminderHandler),
    ])
], debug=False, config=config)

def main():
    app.run()

if __name__ == '__main__':
    main()
