
from models.Music import Music
from google.appengine.ext import ndb
from google.appengine.api import files

from handlers.BaseHandler import BaseHandler
from utils.geo import geoip_bucket, get_bucket_name

from webapp2_extras import json


class MusicHandler(BaseHandler):

    def post(self):

        data = self.request.get("data")
        try:
            json.decode(data)
        except Exception as e:
            self.appresponse.set_error("Invalid JSON data: {}".format(e))
            return self.render_json()

        remote_addr = self.request.remote_addr or "127.0.0.1"
        location = geoip_bucket(remote_addr)
        bucket = get_bucket_name("music", location)

        music_id = Music.allocate_ids(size=1)[0]
        file_name = '/gs/{}/{}'.format(bucket, music_id)

        writable_file_name = files.gs.create(
            file_name, mime_type="application/json", acl="public_read")
        with files.open(writable_file_name, 'a') as f:
            f.write(data)
        files.finalize(writable_file_name)

        Music(
            key=ndb.Key(Music, music_id),
            gcs_file=file_name,
        ).put()

        self.appresponse.set_result({"id": music_id})
        self.render_json()

    def get(self, music_id):

        music = ndb.Key("Music", int(music_id)).get()
        if not music:
            self.render_404("Music not found")

        self.response.headers["Content-Type"] = "application/json"
        with files.open(music.gcs_file, 'r') as fp:
            buf = fp.read(10**6)
            while buf:
                self.response.out.write(buf)
                buf = fp.read(10**6)
