
from google.appengine.api.app_identity import get_application_id

import pygeoip

geoip_lookup = pygeoip.Database("GeoIP.dat").lookup

def geoip_bucket(ip):
    if ":" in ip:
        # Since geolocation and IPv6 don't sleep in one bed, better be
        # safe than sorry and assume we must store the data in EU.
        return "eu"
    return "eu" if geoip_lookup(ip).continent == "EU" else "us"

def get_bucket_name(model, location):
    assert model in {"images", "music"}
    assert location in {"eu", "us"}
    return "{}_{}_{}".format(
        get_application_id(),
        model,
        location,
    )
