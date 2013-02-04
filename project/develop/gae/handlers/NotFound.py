
from handlers.BaseHandler import BaseHandler

class NotFoundHandler(BaseHandler):

    def get(self):
        self.response.status_int = 404
        self.render_response("web/error_404.html")
