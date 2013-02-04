(function() {
  var MobileController,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MobileController = (function(_super) {

    __extends(MobileController, _super);

    function MobileController() {
      this.submit = __bind(this.submit, this);

      this.initialize = __bind(this.initialize, this);
      return MobileController.__super__.constructor.apply(this, arguments);
    }

    MobileController.prototype.service = null;

    MobileController.prototype.tagName = 'body';

    MobileController.prototype.initialize = function(socket) {
      this.service = socket;
      this.service.on(ControllerEvents.SOCKET_OPEN, this.onSocketOpen);
      this.service.on(ControllerEvents.SOCKET_CLOSE, this.onSocketClose);
      return $('#connectButton').click(submit);
    };

    MobileController.prototype.onSocketOpen = function(event) {
      this.$el.css({
        background: '#00cc00'
      });
      return this;
    };

    MobileController.prototype.onSocketClose = function(event) {
      this.$el.css({
        background: '#FF0000'
      });
      return this;
    };

    MobileController.prototype.submit = function(evt) {
      evt.preventDefault();
      return this.service.send(JSON.stringify({
        action: 'JoinSession',
        params: {
          id: $('#controllerCode').val()
        }
      }));
    };

    return MobileController;

  })(Backbone.View);

}).call(this);
