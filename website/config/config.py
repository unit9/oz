#!/usr/bin/env python

from . import ConfigDev

class Config(object):
	@staticmethod
	def getInstance():
		return ConfigDev()