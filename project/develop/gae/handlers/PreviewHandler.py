
from handlers.BaseHandler import BaseHandler
from handlers.Detect import detect_user_agent
from utils.ogtags import get_og_tags

class PreviewHandler(BaseHandler):

    def get(self, mode, id=None):
        if mode not in {"zoe", "cutout", "music"}:
            raise ValueError("Mode should be one of: zoe, cutout, music")
        ua_str = self.request.headers.get("User-Agent", "")
        ua = detect_user_agent(ua_str)
        context = dict()
        context.update(get_og_tags(self.request))

        # initial scale of 1 is default, unless a phone or tablet is detected
        context["DEVICE_SCALE"] = 1.0
        if ua.get("platform") == "mobile":
            if ua.get("mobile") == "tablet":
                context["DEVICE_SCALE"] = 0.75
            elif ua.get("mobile") == "phone":
                context["DEVICE_SCALE"] = 0.5
            else:
                # TODO: What should be the default if we are not sure?
                context["DEVICE_SCALE"] = 0.5

        self.render_response("web/preview/{}/index.html".format(mode),
                             **context)
