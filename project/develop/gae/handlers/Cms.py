from handlers.BaseHandler import BaseHandler


class CmsHandler(BaseHandler):
    def get(self):
        if self.user:
            self.redirect("/cms/home")
        else:
            self.render_response("cms/index.html")


class CmsZoetrope(BaseHandler):
    @BaseHandler.login_or_redirect
    def get(self):
        self.render_response("cms/index.html")


class CmsCutout(BaseHandler):
    @BaseHandler.login_or_redirect
    def get(self):
        self.render_response("cms/index.html")


class CmsLocale(BaseHandler):
    @BaseHandler.login_or_redirect
    def get(self):
        self.render_response("cms/index.html")
