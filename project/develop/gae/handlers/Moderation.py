from datetime import datetime
from models.Image import Image
from webapp2_extras import auth
from handlers.BaseHandler import BaseHandler
from google.appengine.ext import ndb
from google.appengine.datastore.datastore_query import Cursor
from google.net.proto.ProtocolBuffer import ProtocolBufferDecodeError

class ModerationQueueHandler(BaseHandler):

    @BaseHandler.login_or_fail
    @BaseHandler.require_moderator
    def get(self, kind = None):
        '''
        Queue with images that were not viewed by the moderator. Every iteration updates the view
        time which marks the item as viewed and approved.
        Arguments:
            next: cursor to fetch the next batch of images or none if it's the start of the queue
        Returns:
            images: list of image objects
            next: cursor to fetch the next batch of images or none if there are no more
            previous: cursor to fetch the previous batch of images
        '''
        num = 12
        result = []
        update = []

        if kind == "cutout":
            q_next = Image.query(Image.kind == "cutout").order(Image.date_created)
            q_prev = Image.query(Image.kind == "cutout").order(-Image.date_created)
        elif kind == "zoetrope":
            q_next = Image.query(Image.kind == "zoetrope").order(Image.date_created)
            q_prev = Image.query(Image.kind == "zoetrope").order(-Image.date_created)
        elif kind == "cutoutMobile":
            q_next = Image.query(Image.kind == "cutoutMobile").order(Image.date_created)
            q_prev = Image.query(Image.kind == "cutoutMobile").order(-Image.date_created)
        else:
            q_next = Image.query().order(Image.date_created)
            q_prev = Image.query().order(-Image.date_created)

        # fetch page number
        curs = Cursor(urlsafe=self.request.get('next'))

        images, next_curs, more_next = q_next.fetch_page(num, start_cursor=curs)
        next = next_curs.urlsafe() if more_next and next_curs else ""
        for image in images:
            dadd = str(image.date_created.replace(microsecond=0))
            dappr = str(image.date_approved.replace(microsecond=0)) if image.date_approved else ""
            result.append({"id": image.key.id(), "uri": image.uri, "approved": image.approved, "date": dadd, "date_approved": dappr, "viewed": image.viewed})
            if not image.viewed:
                image.viewed = True
                image.date_approved = datetime.now()
                update.append(image)

        if len(update) > 0:
            ndb.put_multi(update)
            del update

        prev_images, prev_curs, more_prev = q_prev.fetch_page(num, start_cursor=curs.reversed())
        prev = prev_curs.urlsafe() if more_prev and prev_curs else ""

        self.appresponse.set_result({"next": next, "prev": prev, "images": result})
        self.render_json()
