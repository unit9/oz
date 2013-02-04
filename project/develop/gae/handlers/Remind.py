
from handlers.Localisation import LocalisationHandler
from handlers.BaseHandler import BaseHandler

from icalendar import Calendar, Event
from datetime import datetime, timedelta


class ReminderHandler(BaseHandler):

    def get(self, lang):
        strings = LocalisationHandler.get_strings("desktop", lang)
        now = datetime.now()

        cal = Calendar()
        cal.add("prodid", "-//Find Your Way to Oz//example.com//")
        cal.add("version", "2.0")
        cal.add("method", "REQUEST")
        cal.add("calscale", "GREGORIAN")

        event = Event()
        event.add("organizer", "Oz The Great and Powerful")
        event.add("summary", "DISNEY OZ")
        event.add("dtstart", now + timedelta(weeks=1))
        event.add("dtend", now + timedelta(weeks=1, hours=1))
        event.add("dtstamp", now)
        event["uid"] = "{date}T{time}/{elevendigits}@{domain}".format(
            date="".join(map(str, now.timetuple()[0:3])),
            time="".join(map(str, now.timetuple()[3:6])),
            elevendigits="27346262376",  # WTF are these for
            domain="example.com"
        )
        event.add("priority", 5)
        cal.add_component(event)

        self.response.headers["Content-type"] = "text/calendar"
        self.response.headers["Content-Disposition"] = \
            "attachment; filename=reminder.ics"
        self.response.status_int = 200
        self.response.write(cal.to_ical())
