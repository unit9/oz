
from os import path
import logging

from models.Copy import Copy
from handlers.BaseHandler import BaseHandler
from google.appengine.ext import ndb

from webapp2_extras import json

PLATFORMS = {
    "desktop": "text",
    "mobile": "text_mob",
}

DEFAULT_LANG_PATH = path.join(
    path.dirname(__file__),
    "..", "resources", "l10n"
)


def axxxb(strings):
    TOLERANCE = 1.25
    dummy_text = {"lang": "max", "strings": {}}
    for key, value in strings.items():
        dummy_text["strings"][key] = "A{}B".format(
            "M" * int(len(value) * TOLERANCE))
    return dummy_text


def normalise_lang(lang):
    return lang.replace("_", "-")


class LocalisationHandler(BaseHandler):

    DEFAULT_LANG = "en-us"
    MAX_LANG = "max"

    @staticmethod
    def get_strings(platform, lang):
        """get_strings(platform, lang) -> dict with translations

        Grab the localised copy and return a dict with translations.
        Any key might be missing, meaning untranslated strings.

        """
        lang = normalise_lang(lang)
        text_attr = PLATFORMS[platform]

        try:
            copy = Copy.query(Copy.lang == lang).fetch(1)[0]
            if not getattr(copy, text_attr):
                raise AttributeError(text_attr)
        except (IndexError, AttributeError) as e:
            # no locale found, fetch the default
            try:
                copy = Copy.query(
                    Copy.lang == LocalisationHandler.DEFAULT_LANG
                ).fetch(1)[0]
                if not getattr(copy, text_attr):
                    raise AttributeError(text_attr)
            except (IndexError, AttributeError) as e:
                logging.error((
                    "Translation not found (platform: {}; lang: {}) "
                    "and no default translation. "
                    "Serving hardcoded default. "
                    "Please import the translation data ASAP!")
                              .format(platform, lang))
                fname = path.join(
                    DEFAULT_LANG_PATH, "default-{}.txt".format(platform))
                with open(fname) as f:
                    return json.decode(f.read())["strings"]

        try:
            translation = json.decode(getattr(copy, text_attr))
        except Exception:
            raise TypeError("Invalid JSON for '{}'".format(lang))
        try:
            return translation["strings"]
        except KeyError:
            raise TypeError("Translation for '{}' has no text".format(lang))


    @staticmethod
    def pick_best_lang(platform, acceptable):
        available = LocalisationListHandler.get_available_languages(platform)
        for lang in acceptable:
            if lang in available:
                return lang
            lang_group = lang.split("-", 1)[0]
            try:
                return min((lang for lang in available
                            if lang.startswith(lang_group)),
                           # choose shortest language code first,
                           # then go alphabetically
                           key=lambda lang: (len(lang), lang))
            except ValueError:
                continue
        return LocalisationHandler.DEFAULT_LANG

    @BaseHandler.login_or_fail
    @BaseHandler.require_loc
    def put(self, platform, lang):
        """
        Creates or updates a locale (a copy). The `platform` and
        `lang` parameters are taken from the URL. All other parameters
        are optional and come via PUT body. Their absence means not to
        update a field.

        Examples:

        PUT /api/localisation/en
        lang_name: "English"
        text: '{"lang": "en", "strings": {"Hello": "Hello!"}}'

        PUT /api/localisation/es
        lang_name: "Spanish"

        PUT /api/localisation/es
        text: '{"lang": "es", "strings": {"Hello": "Hola!"}}'

        Arguments:
            text: text of the new copy, JSON-formatted.
            lang_name: full english name of the language specified via `lang`.

        """

        lang = normalise_lang(lang)
        text_attr = PLATFORMS[platform]

        text = self.request.get("text")
        lang_name = self.request.get("lang_name")
        if text:
            try:
                json.decode(text)
            except Exception as e:
                self.appresponse.set_error("Invalid JSON data: {}".format(e))
                return self.render_json()

        copy_list, curs, next_curs = (Copy.query(Copy.lang == lang)
                                      .order(-Copy.date_updated)
                                      .fetch_page(1))
        copy = Copy() if not copy_list else copy_list[0]

        copy.lang = lang
        if text:
            setattr(copy, text_attr, text)
            # TODO: for testing only, remember to throw this away when done
            if lang == self.DEFAULT_LANG:
                xtext = json.encode(axxxb(json.decode(text)["strings"]))
                xcopy_list = Copy.query(Copy.lang == self.MAX_LANG).fetch(1)
                xcopy = Copy() if not xcopy_list else xcopy_list[0]
                xcopy.lang = self.MAX_LANG
                xcopy.lang_name = "MaxDummy"
                setattr(xcopy, text_attr, xtext)
                xcopy.put()

        if lang_name:
            copy.lang_name = lang_name
        copy.put()

        self.appresponse.set_result(True)
        self.render_json()

    def get(self, platform, lang):
        """
        Get localised copy
        Returns:
            attachment: copy_{platform}_{lang}.txt,
                        a file with strings for `platform`, `lang`
        """

        lang = normalise_lang(lang)
        text_attr = PLATFORMS[platform]

        lang = self.pick_best_lang(platform, [lang])

        copy_list, curs, next_curs = (Copy.query(Copy.lang == lang)
                                 .order(-Copy.date_updated)
                                 .fetch_page(1))

        if not copy_list or not getattr(copy_list[0], text_attr):
            self.appresponse.set_error(
                "I swear, we were sure we do support this language...")
            self.render_json()
            return
        copy = copy_list[0]

        self.response.headers['Content-Type'] = "text/plain"
        self.response.headers['Content-Disposition'] = \
            "attachment; filename=copy_{}_{}.txt".format(platform, lang)
        self.response.out.write(getattr(copy, text_attr))


    @BaseHandler.login_or_fail
    @BaseHandler.require_loc
    def delete(self, platform, lang):
        """
        Delete localised copy for given `platform` and `lang`. If both
        desktop and mobile are deleted, the language is dropped
        entirely.
        """

        lang = normalise_lang(lang)
        text_attr = PLATFORMS[platform]

        if lang == self.DEFAULT_LANG:
            # this is the default copy, we can't allow this
            self.appresponse.set_error(
                "Can't delete English, it's too important. "
                "Related: https://www.youtube.com/watch?v=o7rpVRnuAcQ",
                403,
            )
            self.render_json()
            return

        copy_list, curs, next_curs = (Copy.query(Copy.lang == lang)
                                      .order(-Copy.date_updated)
                                      .fetch_page(1))

        if not copy_list:
            self.render_404("Copy not found")
            return
        copy = copy_list[0]

        setattr(copy, text_attr, None)
        if not copy.text and not copy.text_mob:
            copy.key.delete()

        self.appresponse.set_result(True)
        self.render_json()


class LocalisationListHandler(BaseHandler):

    @BaseHandler.login_or_fail
    @BaseHandler.require_loc
    def get(self, platform):
        """
        Get a list of existing and WIP translations.

        `platform` comes via URL.

        Returns:
            locales: a list of locales with entries that look like this:
                     {
                         "lang": "en",
                         "lang_name": "English",
                         "has_text": true
                     }
                     lang_name can be absent (null).
                     has_text is either true or false, depends on the
                              state of the database and marks a given
                              language as requested for translation.

        """

        text_attr = PLATFORMS[platform]

        copy_list = Copy.query().fetch()

        self.appresponse.set_result({"locales": [
            {"lang":      copy.lang,
             "lang_name": copy.lang_name,
             "has_text":  bool(getattr(copy, text_attr))}
            for copy in
            sorted(
                copy_list,
                key=lambda copy: (
                    copy.lang_name
                    if copy.lang != LocalisationHandler.DEFAULT_LANG
                    # English has to go first. Coincidentally, "AAH"
                    # comes alphabetically before any other language.
                    # https://www.youtube.com/watch?v=I_izvAbhExY
                    else "AAH AAH AAH AAH STAYIN' ALIVE STAYIN' ALIVE"))
        ]})
        self.render_json()

    @staticmethod
    def get_available_languages(platform):
        """
        Return a set of all languages currently available for a platform.
        """
        text_attr = PLATFORMS[platform]
        copy_list = Copy.query().fetch()
        return {copy.lang for copy in copy_list
                if getattr(copy, text_attr, None)}
