var paths = {
    "modernizr"      : "vendor/modernizr-2.6.2.min",
    "jquery"         : "vendor/jquery-1.8.3.min",
    "underscore"     : "vendor/underscore-1.3.3.min",
    "backbone"       : "vendor/backbone-0.9.2.min",
    "json2"          : "vendor/json2",
    "BrowserDetect"  : "vendor/BrowserDetect"
};


var libs = [];
for(var n in paths) libs.push(n);

requirejs.config({

    baseUrl: '/js',

    paths: paths,

    shim: {

        'backbone': {
            deps: ['underscore', 'jquery']
        }

    }
});

require(libs, function()
{
    require(['appDetect']);
});