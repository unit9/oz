var paths = {
    "vendors"          : "vendor/vendor.min",
    "analytics"        : "http://www.google-analytics.com/ga"
};

var libs = [];
for(var n in paths) libs.push(n);

requirejs.config({

    baseUrl: '/js',

    paths: paths,

    shim: {
        'three' : {
            exports: 'THREE'
        }
    }
});

require(libs, function()
{
    require(['app.min']);
});
