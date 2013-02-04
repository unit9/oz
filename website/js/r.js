var paths = {
    "three"                 : "vendor/three/three.min",
    "jquery.pause"          : "vendor/jquery.pause.min",
    "transit"               : "vendor/jquery.transit.min",
    "tween"                 : "vendor/Tween",
    'preloadJS'             : "vendor/preloadjs-0.2.0.min",
    "dat.gui"               : "vendor/dat.gui.min",
    "stats"                 : "vendor/Stats",
    "plugins"               : "plugins",
    "sonic"                 : "vendor/sonic",
    "analytics"             : "http://www.google-analytics.com/ga",
    "easeljs"               : "vendor/easeljs-0.5.0.min",
    "tweenmax"              : "vendor/gsap/TweenMax.min",
    "gsap"                  : "vendor/gsap/jquery.gsap.min",
    "seedrandom"            : "vendor/seedrandom-min",
    "ccapture"              : "vendor/CCapture",
    "whammy"                : "vendor/Whammy",
};

// var threeModules = [
    // "vendor/three/src/extras/LensFlarePlugin",
    // "vendor/three/src/extras/AudioListenerObject",
    // "vendor/three/src/extras/AudioObject",
    // "vendor/three/src/extras/ShaderExtras",
    // "vendor/three/src/extras/CustomImageLoader",
    // "vendor/three/src/extras/CustomImageUtils",
    // "vendor/three/src/extras/postprocessing/EffectComposer",
    // "vendor/three/src/extras/postprocessing/RenderPass",
    // "vendor/three/src/extras/postprocessing/BloomPass",
    // "vendor/three/src/extras/postprocessing/ShaderPass",
    // "vendor/three/src/extras/postprocessing/MaskPass",
    // "vendor/three/src/extras/postprocessing/SavePass",
    // "vendor/three/src/extras/postprocessing/FilmPass",
    // "vendor/three/src/extras/postprocessing/BokehShader",
    // "vendor/three/src/extras/postprocessing/ShaderGodRays",
    // "vendor/three/src/extras/ShaderUtils",
    // "vendor/three/src/renderers/WebGLRenderer",
    // "vendor/three/src/extras/Hud"
// ];

var libs = [];
for(var n in paths) libs.push(n);

requirejs.config({
    baseUrl: '/js',
    paths: paths
});

require(libs, function()
{
    require(['app']);
});
