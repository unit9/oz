from webapp2_extras import auth
from handlers.BaseHandler import BaseHandler
from wtforms import Form, TextField, PasswordField, validators

class LoginForm(Form):
    email = TextField('Email', [validators.Required(), validators.Email()])
    password = PasswordField('Password', [validators.Required()])

class LoginHandler(BaseHandler):

    def post(self):
        form = LoginForm(self.request.POST)
        if form.validate():
            try:
                self.auth.get_user_by_password("own:"+form.email.data, form.password.data)
                self.appresponse.set_result({"email": self.user_model.email, "role": self.user_model.role})
                self.render_json()
            except (auth.InvalidAuthIdError, auth.InvalidPasswordError):
                self.appresponse.set_error("Invalid data")
                self.render_json()
        else:
            err = {}
            for k in form.errors.keys():
                err[k] = form.errors[k][0]

            self.appresponse.set_error(err)
            self.render_json()

class LogoutHandler(BaseHandler):
    @BaseHandler.login_or_fail
    def get(self):
        self.auth.unset_session()
        self.redirect("/cms/")

class UserStatusHandler(BaseHandler):
    def get(self):
        if self.user:
            self.appresponse.set_result({"email": self.user_model.email, "role": self.user_model.role})
            self.render_json()
        else:
            self.appresponse.set_error("User not found", 404)
            self.render_json()
