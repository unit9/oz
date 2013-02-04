import tornado.httpserver
import tornado.websocket
import tornado.ioloop
import tornado.web

import os
import sys
import json
import string
import random

from tornado.ioloop import IOLoop

HOSTS = {}

class WSHandler(tornado.websocket.WebSocketHandler):

    ''' 
    [!] CONNECT

    Desktop
    init connection: {"action":"connect","client":"desktop"}
    response: {"status": "connected", "code": "123456"}
              {"status": "reconnect", "server": "ws://unit9.com:123456/ws"}

    Mobile
    init connection: {"action": "connect", "client":"mobile", "code": "123456"}
    response: {"status": "connected"}
              {"status": "reconnect", "server": "ws://unit9.com:123456/ws"}

    Error: {"status": "error", "message": "This is the error"}

    [!] COMMUNICATION

    send message: {"action":"send", "message": "hello there"}

    It's a bi-directional communication, server acts as a relay sending information
    from desktop to mobile and vise-versa. When client wants to quit communication
    they just need to close the socket.
    '''

    global HOSTS

    def __init__(self, boom, woom):
        tornado.websocket.WebSocketHandler.__init__(self, boom, woom)
        self.ioloop = tornado.ioloop.IOLoop.instance()
        self.hosts = HOSTS
        self.hostType = "desktop"
        self.code = ""

    def allow_draft76(self):
        return True

    # on_open connection
    def open(self):
        pass

    def on_message(self, message):
        try:
            info = json.loads(message)
        except ValueError, e:
            self.write_message('{"status": "error", "message": "' + str(e) + '"}' )
            self.close()
            return
        except TypeError, e:
            self.write_message('{"status": "error", "message": "' + str(e) + '"}' )
            self.close()
            return

        if not "action" in info:
            self.write_message('{"status": "error", "message": "Action missing"}')
            self.close()
            return

        if info["action"] == "connect":
            if not "client" in info:
                self.write_message('{"status": "error", "message": "Client missing"}')
                self.close()
                return

            if info["client"] == "desktop":
                self.code = ''.join(random.choice(string.ascii_uppercase) for i in xrange(5))
                self.write_message('{"status": "connected", "code": "' + str(self.code) + '"}')
                self.hosts[self.code] = {"desktop": self}
            elif info["client"] == "mobile":
                if not "code" in info:
                    self.write_message('{"status":"error", "message": "Code missing"')
                    self.close()
                    return
                elif not info["code"] in self.hosts:
                    self.write_message('{"status": "error", "message": "Desktop client missing"}')
                    self.close()
                    return

                self.code = info["code"]
                self.hostType = "mobile"
                self.write_message('{"status": "connected", "code": "' + str(self.code) + '"}')
                self.hosts[self.code]["mobile"] = self
        elif info["action"] == "send":
            if "message" not in info:
                self.write_message('{"status":"error", "message": "Missing message field"}')
                return

            payload = {"action": "message", "payload": info["message"]}
            p = json.dumps(payload)

            if self.hostType == "mobile":
                try:
                    self.hosts[self.code]['desktop'].write_message(p)
                except AttributeError, e:
                    pass
            else:
                try:
                    self.hosts[self.code]['mobile'].write_message(p)
                except AttributeError, e:
                    pass
        else:
            self.write_message(p)

    def on_close(self):
        pass


application = tornado.web.Application([
    (r'/ws', WSHandler),
])


if __name__ == "__main__":
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit()
    except OSError, e:
        sys.exit(1)

    os.setsid()
    os.umask(0)

    try:
        pid = os.fork()
        if pid > 0:
            sys.exit()
    except OSError, e:
        sys.exit(1)

    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(55432)
    tornado.ioloop.IOLoop.instance().start()
