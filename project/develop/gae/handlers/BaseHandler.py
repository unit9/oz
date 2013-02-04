import os
import webapp2

from models.Response import AppResponse
from models.User import OzUser

from google.appengine.ext import ndb

from webapp2_extras import json
from webapp2_extras import auth
from webapp2_extras import jinja2
from webapp2_extras import sessions


class BaseHandler(webapp2.RequestHandler):

    def dispatch(self):
        self.appresponse = AppResponse()
        # Get a session store for this request.
        self.session_store = sessions.get_store(request=self.request)
        try:
            # Dispatch the request.
            webapp2.RequestHandler.dispatch(self)
        finally:
            # Save all sessions.
            self.session_store.save_sessions(self.response)

    @webapp2.cached_property
    def session(self):
        # Returns a session using the default cookie key.
        return self.session_store.get_session()

    @webapp2.cached_property
    def auth(self):
        return auth.get_auth(request=self.request)

    @webapp2.cached_property
    def user(self):
        user = self.auth.get_user_by_session()
        return user

    @webapp2.cached_property
    def user_model(self):
        user_model, timestamp = self.auth.store.user_model.get_by_auth_token(
                self.user['user_id'],
                self.user['token']) if self.user else (None, None)
        return user_model

    @staticmethod
    def login_or_fail(handler):
        "Requires that a user be logged in to access the resource"
        def check_login(self, *args, **kwargs):
            if not self.user:
                self.appresponse.set_error("You must be logged in", 403)
                return self.render_json()
            else:
                return handler(self, *args, **kwargs)
        return check_login

    @staticmethod
    def login_or_redirect(handler):
        """
        Ensures that the user is logged in, otherwise redirects
        to the cms login page. It's used with cms urls
        """
        def check_login(self, *args, **kwargs):
            if not self.user:
                return self.redirect("/cms/")
            else:
                return handler(self, *args, **kwargs)
        return check_login

    @staticmethod
    def require_root(handler):
        """
        Only root can use these functions
        """
        def check_is_root(self, *args, **kwargs):
            if self.user_model.role != 0:
                self.response.status_int = 403
                self.render_response("auth/privileges.html")
            else:
                return handler(self, *args, **kwargs)
        return check_is_root

    @staticmethod
    def require_moderator(handler):
        """
        Only root and image moderator can use it
        """
        def check_is_mod(self, *args, **kwargs):
            if self.user_model.role == 0 or self.user_model.role == 1:
                return handler(self, *args, **kwargs)
            else:
                self.response.status_int = 403
                self.render_response("auth/privileges.html")
        return check_is_mod

    @staticmethod
    def require_loc(handler):
        """
        Only root and localization mod can use it
        """
        def check_is_loc(self, *args, **kwargs):
            if self.user_model.role == 0 or self.user_model.role == 2:
                return handler(self, *args, **kwargs)
            else:
                self.response.status_int = 403
                self.render_response("auth/privileges.html")
        return check_is_loc


    @webapp2.cached_property
    def jinja2(self):
        return jinja2.get_jinja2(app=self.app)

    def render_response(self, _template, **context):
        rv = self.jinja2.render_template(_template, **context)
        self.response.write(rv)

    def render_json(self):
        self.response.headers["Content-type"] = "application/json"
        self.response.status_int = self.appresponse.status
        self.response.write(self.appresponse.to_json())

    def render_json_texthtml(self):
        self.response.headers["Content-type"] = "text/html"
        self.response.status_int = self.appresponse.status
        self.response.write(self.appresponse.to_json())

    def render_404(self, error):
        self.response.status_int = 404;
        data = {"error": error}
        self.response.write(json.encode(data))

    def handle_exception(self, exception, debug):
        if debug or 1:
            raise
        else:
            self.appresponse.set_error("Internal error")
            self.render_json()
