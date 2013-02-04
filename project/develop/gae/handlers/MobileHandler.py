from BaseHandler import BaseHandler

class MobileHandler(BaseHandler):
    def get(self, path):
        context = {
        	'googleAppEngineRuntime': 'true'
        }
        self.render_response("web/m/index.html", **context)