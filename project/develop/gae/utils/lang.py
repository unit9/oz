
import re
from collections import OrderedDict

def parse_accept_language(accept_language):
    """parse_accept_language(accept_language) -> ordered dict of (language: q)

    Parse the value of the Accept-Language header and return it as a
    dict, where keys are language codes, and values correspond to
    user's preference ([0.0-1.0]).

    """

    langs = OrderedDict() # lang -> score

    for lang in re.split(", *", accept_language):
        lang = lang.strip()
        hasq = lang.find(";q=")

        q = 1.0
        if hasq > -1:
            code = lang[:hasq]
            q = float(lang[hasq+4:])
        else:
            code = lang
        langs[code] = q

    return OrderedDict(sorted(langs.items(), key=lambda kv: -kv[1]))
