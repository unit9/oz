window.___gcfg=
{
    lang      : (navigator.language || navigator.userLanguage),
    parsetags : "explicit"
};

window._gaq = [['_setAccount','UA-37524215-3'],['_trackPageview']];

var paths = {
    "modernizr"      : "/js/vendor/modernizr-2.6.2.min",
    'preloadJS'      : "/js/vendor/preloadjs-0.2.0.min",
    "jquery"         : "/js/vendor/jquery-1.8.3.min",
    "underscore"     : "/js/vendor/underscore-1.3.3.min",
    "backbone"       : "/js/vendor/backbone-0.9.2.min",
    "sonic"          : "/js/vendor/sonic",
    "twitter"        : "//platform.twitter.com/widgets",
    "analytics"      : "//www.google-analytics.com/ga",
    "gplus"          : "//apis.google.com/js/plusone"
};

requirejs.config({

    paths: paths,

    shim: {
        'backbone': {
            deps: ['underscore', 'jquery']
        }
    }
});

var libs = [];
for(var n in paths) libs.push(n);

require(libs, function ()
{
    require(['/js/preview.js']);
});
