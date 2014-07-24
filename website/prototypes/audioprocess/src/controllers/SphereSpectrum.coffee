class SphereSpectrum

    canvas  : document.getElementById "canvas"
    ctx     : canvas.getContext "2d"
    alpha   : 0
    beta    : 0
    pts     : []

    constructor: ->



    randomPoint: =>

        x = Math.random() - 0.5
        y = Math.random() - 0.5
        z = Math.random() - 0.5

        k = Math.sqrt x*x + y*y + z*z
        
        while k < 0.2 || k > 0.3
            x = Math.random() - 0.5
            y = Math.random() - 0.5
            z = Math.random() - 0.5
            k = Math.sqrt x*x + y*y + z*z
        
        { x: x/k, y: y/k, z: z/k }

    pickPoints: =>

        for i in [0..1000]
            @pts.push randomPoint()
###
function spreadPoints()
{
    pts[0] = randomPoint();
    for (var i=1; i<1000; i++)
    {
        var best = null;
        for (var j=0; j<10; j++)
        {
            var p = randomPoint();
            var md = null;
            for (var k=0; k<pts.length; k++)
            {
                var d = dist2(p, pts[k]);
                if (md == null || md > d) md = d;
            }
            if (best == null || best[0] < md)
                best = [md, p]
        }
        pts.push(best[1]);
    }
}

function map2d(p)
{
    var ca = Math.cos(alpha), sa = Math.sin(alpha);
    var cb = Math.cos(beta), sb = Math.sin(beta);
    var xx = (p.x*ca+p.y*sa)*cb + p.z*sb;
    var yy = p.y*ca-p.x*sa;
    var zz = p.z*cb - (p.x*ca+p.y*sa)*sb;
    return {xs:400 + 800*xx/(3+zz),
            ys:400 + 800*yy/(3+zz),
            zs:zz};
}

function dist2(a, b)
{
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    var dz = a.z - b.z;
    return dx*dx + dy*dy + dz*dz;
}

function repaint()
{
    var w = canvas.offsetWidth;
    var h = canvas.offsetHeight;
    canvas.width = w;
    canvas.height = h;
    var sf = w/4;
    ctx.fillStyle = "#000000";
    for (var i=0; i<pts.length; i++)
    {
        var p = map2d(pts[i]);
        var r = 30 / (10 + p.zs);
        ctx.beginPath();
        ctx.arc(p.xs, p.ys, r, 0, 2*Math.PI, true);
        ctx.fill();
    }
}

pickPoints();
repaint();

var last = (new Date()).getTime();

setInterval(function()
            {
                var now = (new Date()).getTime();
                alpha += (now - last) / 1000;
                beta += (now - last) / 3100;
                last = now;
                repaint();
            }, 20);
###