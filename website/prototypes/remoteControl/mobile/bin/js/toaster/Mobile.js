(function() {

  $(function() {
    window.debug = function(str) {
      return $("#debug").append("<p>" + str);
    };
    return $(window).load(function() {
      var controller, socket;
      socket = new MobileSocket;
      return controller = new MobileController(socket);
    });
  });

}).call(this);
