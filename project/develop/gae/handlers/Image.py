from __future__ import with_statement

import imghdr
import base64
import cgi
import json
import logging
import StringIO
import time

from models.Image import Image
from models.ImageJson import ImageJson
from utils.ImageJsonRenderer import ImageJsonRenderer
from utils.geo import geoip_bucket, get_bucket_name
from webapp2_extras import auth
from google.appengine.ext import ndb
from google.appengine.api import files
from google.appengine.api import images
from google.appengine.api import memcache
from handlers.BaseHandler import BaseHandler


class ImageAddHandler(BaseHandler):

    IMG_MIME = {
        "jpeg": "image/jpeg",
        "png": "image/png",
    }

    @staticmethod
    def allocate_image(bucket, kind):
        image_id = Image.allocate_ids(size=1)[0]
        file_name = '/gs/{}/{}'.format(bucket, image_id)
        uri = "/api/image/get/{}".format(image_id)
        image = Image(
            key=ndb.Key(Image, image_id),
            uri=uri,
            approved=True,
            viewed=False,
            gcs_file=file_name,
            kind=kind,
        )
        key = image.put().id()
        return key, image

    @staticmethod
    def store_cutout_json(key, cutout):
        image_json = ImageJson(
            key=ndb.Key(ImageJson, key),  # matches the key for Image
            photo_json=json.dumps(cutout["photo"]),
            overlay_json=json.dumps(cutout["overlay"])
        )
        image_json.put()

    @staticmethod
    def detect_mimetype(data):
        mime_type = ImageAddHandler.IMG_MIME.get(imghdr.what(None, data))
        if not mime_type:
            raise TypeError("Unknown MIME type")
        return mime_type

    @staticmethod
    def store_image_gcs(file_name, mime_type, img):
        writable_file_name = files.gs.create(
            file_name, mime_type=mime_type, acl="public_read")
        with files.open(writable_file_name, 'a') as f:
            f.write(img)
        files.finalize(writable_file_name)

    @staticmethod
    def check_cutout_format(cutout):
        if not ('cutout' in cutout and
                'photo' in cutout['cutout'] and
                'overlay' in cutout['cutout'] and
                'id' in cutout['cutout']['photo'] and
                'id' in cutout['cutout']['overlay'] and
                'position' in cutout['cutout']['photo'] and
                'size' in cutout['cutout']['photo'] and
                'orientation' in cutout['cutout']['photo']):
            raise ValueError(
                "Failed to upload the image (invalid json format). "
                "Expected format is: "
                '{"cutout": {"photo": {'
                '"id": 1, "position": {"left": 0, "top": 0},'
                '"size": {"width": 800, "height": 600},'
                '"orientation": {"rotation": "23"}},'
                '"overlay": {"id": 1}}}')


    def limit_upload_rate(self):
        FORGIVE_TIME = 60 * 5
        FORGIVE_AMOUNT = 10
        key = "imglimit_{}".format(self.request.remote_addr or "127.0.0.1")
        last_uploads = memcache.get(key) or list()
        now = time.time()
        last_uploads = [t for t in last_uploads if now - t < FORGIVE_TIME]
        if len(last_uploads) > FORGIVE_AMOUNT:
            self.appresponse.set_error(
                ("Slow down, cowboy! You can upload only {} "
                 "images per {} minutes.").format(FORGIVE_AMOUNT,
                                                  FORGIVE_TIME // 60),
                status=400)
            self.render_json()
            return False
        last_uploads.append(now)
        memcache.set(key, last_uploads)
        return True


    def post(self):
        '''
        Arguments:
            - kind - string that specifies which type of image it is:
                     cutout (default), zoetrope, cutoutMobile
            - image - base64 string that contains encoded image file
            - file - a file submitted via form with "multipart/form-data"
        Return:
            - id - image ID
            - uri - uri of the image
        '''

        if not self.limit_upload_rate():
            return

        remote_addr = self.request.remote_addr or "127.0.0.1" # unit tests...
        location = geoip_bucket(remote_addr)
        bucket = get_bucket_name("images", location)

        kind = self.request.get("kind")
        if kind not in {"cutout", "zoetrope", "cutoutMobile"}:
            kind = "cutout"

        cutout = None
        try:
            cutout = json.loads(self.request.body)
        except ValueError as e:
            pass

        img64 = self.request.get("image")
        file = self.request.params.get("file")

        if cutout:
            try:
                self.check_cutout_format(cutout)
            except ValueError as e:
                self.appresponse.set_error(e)
                self.render_json()
                return
            kind = "cutout_json"
            cutout = cutout['cutout']
        elif img64:
            try:
                img = base64.b64decode(img64)
            except TypeError:
                self.appresponse.set_error("Failed to upload the image "
                                           "(invalid base64)")
                self.render_json()
                return
        elif isinstance(file, cgi.FieldStorage):
            img = file.file.read()
        else:
            self.appresponse.set_error(
                "Failed to upload the image: "
                "must POST either 'cutout', 'image' or 'file'")
            self.render_json()
            return

        try:
            if cutout:
                key, image = self.allocate_image(bucket, kind)
                self.store_cutout_json(key, cutout)
            elif img:
                mime_type = self.detect_mimetype(img)
                key, image = self.allocate_image(bucket, kind)
                self.store_image_gcs(image.gcs_file, mime_type, img)
            else:
                raise Exception("huh?")

            self.appresponse.set_result({"id": key, "uri": image.uri})
            self.render_json_texthtml()
            # ContentType: application/json doesn't work on Android.
            # Forcing ContentType: text/html
            # TODO: detect Android?
        except TypeError:
            self.appresponse.set_error("Invalid image format")
            self.render_json()
        except Exception as e:
            self.appresponse.set_error("Failed to upload the image: %s" % e,
                                       500)
            self.render_json()


class ImageInfoHandler(BaseHandler):

    def get(self, image_id):
        if not image_id or len(image_id) == 0:
            self.appresponse.set_error("Incorrect id")
            self.render_json()
        else:
            try:
                image_key = ndb.Key("Image", int(image_id))
                image = image_key.get()
                self.appresponse.set_result({
                    "id": image_id,
                    "uri": image.uri,
                    "approved": image.approved,
                    "date": str(image.date_created.replace(microsecond=0)),
                    "date_approved":
                    str(image.date_approved.replace(microsecond=0))
                    if image.date_approved is not None else None,
                    "viewed": image.viewed
                })
                self.render_json()
            except Exception, e:
                self.appresponse.set_error("Error: %s" % e)
                self.render_json()


class ImageRejectHandler(BaseHandler):

    @BaseHandler.login_or_fail
    @BaseHandler.require_moderator
    def put(self, image_id):
        if not image_id or len(image_id) == 0:
            self.appresponse.set_error("Incorrect id")
            self.render_json()
        else:
            try:
                k = ndb.Key("Image", int(image_id))
            except ProtocolBufferDecodeError, e:
                self.appresponse.set_error("Incorrect id")
                self.render_json()
                return

            image = k.get()
            image.approved = False
            image.put()

            self.appresponse.set_result({"id":k.id()})
            self.render_json()


class ImageGetHandler(BaseHandler):

    @staticmethod
    def gcs_storage_uri(gcs_file):
        assert gcs_file.startswith("/gs/")
        return "http://storage.googleapis.com/" + gcs_file[4:]

    @staticmethod
    def send_gcs_file(file_name, stream):
        with files.open(file_name, 'r') as fp:
            buf = fp.read(10**6)
            while buf:
                stream.write(buf)
                buf = fp.read(10**6)

    @staticmethod
    def open_gcs_file(file_name):
        f = StringIO.StringIO()
        ImageGetHandler.send_gcs_file(file_name, f)
        f.seek(0)
        return f

    @staticmethod
    def process_cutout(image):
        image_json = ndb.Key("ImageJson", image.key.id()).get()
        renderer = ImageJsonRenderer()
        render_image = renderer.renderImageFromJson(
            json.loads(image_json.photo_json),
            json.loads(image_json.overlay_json)
        )

        buf = StringIO.StringIO()
        render_image.save(buf, "JPEG")
        imgdata = buf.getvalue()

        ImageAddHandler.store_image_gcs(image.gcs_file, "image/jpeg", imgdata)
        image.kind = "cutout"
        image.put()
        return imgdata

    def get(self, image_id):
        try:
            k = ndb.Key("Image", int(image_id))
        except ProtocolBufferDecodeError, e:
            self.appresponse.set_error("Incorrect id")
            self.render_json()
            return

        image = k.get()

        if not image:
            self.render_404("Image not found")
            return

        if image.approved == False:
            self.appresponse.set_error("Image banned")
            self.render_json()
            return

        if image.kind == "cutout_json":
            imgdata = ImageGetHandler.process_cutout(image)
            # we know it's jpeg
            self.response.headers["Content-Type"] = "image/jpeg"
            self.response.out.write(imgdata)
            return
        else:
            # TODO: ask GCS for content type?
            self.response.headers["Content-Type"] = "image/jpeg"
            ImageGetHandler.send_gcs_file(
                image.gcs_file,
                self.response.out,
            )
