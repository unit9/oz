
from handlers.Localisation import LocalisationHandler

from utils.lang import parse_accept_language

# jinja tag name -> l10n key
OG_TAGS_L10N = {
    "OG_TITLE":       "seo_og_title",
    "OG_DESCRIPTION": "seo_og_description",
    "OG_SITE_NAME":   "seo_og_site_name",
    "SEO_AUTHOR":     "seo_author",
    "TWITTER_HANDLE": "seo_twitter_handle",
    "SETTINGS_TITLE": "settings_title",
    "SETTINGS_LOW":   "settings_button_low",
    "SETTINGS_HIGH":  "settings_button_high",
    "RUSSIAN_PG":     "russian_pg",
}

OG_TAGS_L10N_OVERRIDES = {
    "/": {
        # override only where translation key is different
        "OG_TITLE": "seo_og_title",
    },
    "/index.html":        {},
    "/carnival/cutout":   {},
    "/carnival/zoetrope": {},
    "/technology":        {},
    "/final":             {},
}

OG_TAGS_DEFAULTS = {
    "SETTINGS_TITLE": "CHOOSE YOUR PATH:",
    "SETTINGS_LOW":   "Standard: Optimized for speed",
    "SETTINGS_HIGH":  "HD: Optimized for graphics",
}

def get_og_tags(request):
    path = request.path
    if path.endswith("/") and path != "/":
        path = path.rstrip("/")

    platform, lang = "desktop", LocalisationHandler.DEFAULT_LANG
    acceptable = parse_accept_language(
        request.headers.get("Accept-Language", "").lower())
    lang = LocalisationHandler.pick_best_lang(platform, acceptable)
    strings = LocalisationHandler.get_strings(platform, lang)

    tags = dict()

    override_l10n = OG_TAGS_L10N_OVERRIDES.get(path, {})
    for tag_name, key in OG_TAGS_L10N.items():
        tags[tag_name] = strings.get(key)
        if tag_name in override_l10n:
            tags[tag_name] = strings.get(override_l10n[tag_name])

    for tag_name, value in OG_TAGS_DEFAULTS.items():
        # might be empty string, otherwise we'd just use dict.setdefault
        if not tags.get(tag_name):
            tags[tag_name] = value

    tags["OG_URL"] = request.host_url

    return tags
