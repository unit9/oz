(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  __t('service').MobileSocket = (function(_super) {

    __extends(MobileSocket, _super);

    function MobileSocket() {
      this.sendMessage = __bind(this.sendMessage, this);
      return MobileSocket.__super__.constructor.apply(this, arguments);
    }

    MobileSocket.prototype.ws = null;

    MobileSocket.prototype.ready = false;

    MobileSocket.prototype.initialize = function(host) {
      if (host == null) {
        host = "ws://10.0.1.16:12344/oz";
      }
      this.ws = new WebSocket(host);
      this.ws.onclose = function(e) {
        return $('body').css({
          'background': "#FF0000"
        });
      };
      this.ws.onopen = function(e) {
        return $('body').css({
          'background': "#00cc00"
        });
      };
      return this;
    };

    MobileSocket.prototype.onSocketClose = function(event) {
      this.ready = false;
      this.trigger(ControllerEvents.SOCKET_CLOSE);
      return this;
    };

    MobileSocket.prototype.onSocketOpen = function(event) {
      this.trigger(ControllerEvents.SOCKET_OPEN);
      return this;
    };

    MobileSocket.prototype.onSocketMessage = function(event) {
      var data;
      data = JSON.parse(e.data);
      if (data.type !== 'response') {
        return;
      }
      switch (data.action) {
        case 'JoinSession':
          if (data.success === true) {
            this.ready = true;
          }
          break;
        case "SendControllerValues":
          this.ready = true;
      }
      return this;
    };

    MobileSocket.prototype.sendMessage = function(msg) {
      this.ws.send(msg);
      return this;
    };

    return MobileSocket;

  })(Backbone.Events);

}).call(this);
