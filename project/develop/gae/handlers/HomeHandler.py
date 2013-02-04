
from BaseHandler import BaseHandler
from Detect import detect_user_agent

from utils.ogtags import get_og_tags

class HomeHandler(BaseHandler):

    def get(self):
        if self.request.path == "/":
            ua_str = self.request.headers.get("User-Agent", "")
            ua = detect_user_agent(ua_str)
            if ua.get("platform") == "mobile":
                return self.redirect("/m/")
        context = get_og_tags(self.request)
        self.render_response("web/index.html", **context)
