from handlers.BaseHandler import BaseHandler
from wtforms import Form, TextField, PasswordField, SelectField, validators

class SignupForm(Form):
    email = TextField('Email',
                    [validators.Required(),
                     validators.Email()])
    role = SelectField('Role', coerce=int, choices=[
        (0, "root"),
        (1, "image"),
        (2, "localization"),
    ], default=1)
    password = PasswordField('Password',
                    [validators.Required(),
                     validators.EqualTo('password_confirm',
                                    message="Passwords must match.")])
    password_confirm = PasswordField('Confirm Password',
                        [validators.Required()])

class SignupHandler(BaseHandler):
    "Creates new users"

    @BaseHandler.login_or_fail
    @BaseHandler.require_root
    def post(self):
        form = SignupForm(self.request.POST)

        error = None
        if form.validate():
            success, info = self.auth.store.user_model.create_user(
                "own:" + form.email.data,
                unique_properties=['email'],
                email= form.email.data,
                role=form.role.data,
                password_raw= form.password.data)

            if success:
                self.auth.get_user_by_password("own:"+form.email.data,
                                                form.password.data)
                return self.redirect("/cms/")
            else:
                err = ""
                for k in info:
                    err = err + k + "<br />\n"
                self.response.write(err)
        else:
            err = ""
            for k in form.errors.keys():
                err = err + str(k) + ": " +  str(form.errors[k]) + "<br />\n"
            self.response.write(err)
        if err:
            self.response.status_int = 400
