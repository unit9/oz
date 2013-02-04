
import httpagentparser
import re

from handlers.BaseHandler import BaseHandler


def dict_getpath(obj, *keys):
    """dict_getpath(obj, *keys) -> some value

    `obj` is a tree of nested dictionaries (or actually, anything that
    implements __getitem__, so also lists and tuples). `keys` is a
    sequence of keys or indices that point at a value nested somewhere
    in `obj`. The value pointed at by `keys` is returned.

    May raise KeyError, IndexError or TypeError, depending on how
    badly things went in __getitem__.

    """
    if not keys:
        return obj
    try:
        return dict_getpath(obj[keys[0]], *keys[1:])
    except TypeError:
        # KeyError is naturally raised by dict.__getitem__, TypeError
        # happens when a string is sliced with a string.
        raise KeyError(keys[0])


def match_rules(subject, rules):
    for keys, pattern in rules:
        try:
            if re.match(pattern, dict_getpath(subject, *keys)):
                return True
        except KeyError:
            continue
    return False


def classify_platform(ua, ua_str):
    """classify_platform(ua, ua_str) -> one of: "desktop", "mobile", None

    Make a guess whether the given user agent info (as returned by
    httpagentparser.detect) represents a desktop or mobile device.

    """
    mobile_rules = [
        # Android devices
        (("dist", "name"), "Android"),
        # Apple devices
        (("dist", "name"), "IPhone"),
        (("dist", "name"), "IPad"),
        # Windows Mobile devices
        (("os", "version"), "Mobile"),
        (("os", "version"), "Phone OS.*"),
        (("os", "version"), "CE"),
        # Opera Mobile
        (("browser", "name"), "Opera Mobile"),
        # BlackBerry
        (("os", "name"), "Blackberry"),
    ]
    if match_rules(ua, mobile_rules):
        return "mobile"
    return "desktop"


def classify_mobile(ua, ua_str):
    """classify_mobile(ua, ua_str) -> one of: "phone", "tablet", None

    Try to tell apart phones and tablets. None is returned when uncertain.

    """
    phone_rules = [
        (("dist", "name"), "IPhone"),
    ]
    tablet_rules = [
        (("dist", "name"), "IPad"),
    ]
    if match_rules(ua, phone_rules):
        return "phone"
    if match_rules(ua, tablet_rules):
        return "tablet"
    if ua.get("dist", {}).get("name") == "Android":
        # Android is too tricky. Phones say "Mobile Safari", while
        # tablets say just "Safari" As httpagentparser doesn't care
        # about the difference, we have to parse the UA string
        # manually.
        if "Mobile Safari" in ua_str:
            return "phone"
        else:
            return "tablet"
    return None


def detect_user_agent(ua_str):
    ua = httpagentparser.detect(ua_str)
    ua["platform"] = classify_platform(ua, ua_str)
    ua["mobile"] = classify_mobile(ua, ua_str)
    ua.setdefault("os", {})
    ua.setdefault("dist", {})
    ua.setdefault("browser", {})
    return ua


class PlatformDetectHandler(BaseHandler):

    def get(self):
        """.

        Return a JSON structure describing the detected user agent.
        The structure looks more or less like this:

        "result": {
            "platform": "mobile",
            "os": {"name": "RandomOS"},
            "dist": {"name": "MyAwesomeDistro"},
            "browser":{"name": "MyBrowser", "version": "12.34"}
        }

        Keys "platform", "browser", "os", "dist" are guaranteed to be
        present.

        "platform" will vary between "desktop" and "mobile" based on a
        guess. All other keys will include all data that could be
        guessed from the UA string, which in some cases may mean they
        will be pointing at empty objects.

        Example frontend code for detecting mobile Chrome:

        var ua = JSON.parse(data).result;
        if (ua.platform == "mobile" && ua.browser.name == "Chrome") {
            ...
        }

        """
        ua_str = self.request.headers.get("User-Agent", "")
        ua = detect_user_agent(ua_str)
        self.appresponse.set_result(ua)
        self.render_json()
