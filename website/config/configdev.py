#!/usr/bin/env python

from webapplication import WebApplicationDesktop
from webapplication import WebApplicationMobile
from api import Api

class ConfigDev(object):
	
	requestHandlers = [
		('/api(/.*)?', Api),
		('/m(/.*)?', WebApplicationMobile),
		('/(.*)', WebApplicationDesktop)
	]