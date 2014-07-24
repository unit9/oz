VertexAnimator = (function()
{
    var Animator = function(frameDuration)
    {
        this.sequences = {};
        this.curSequence = null;
        this.curFrameIdx = 0;

        this.transitioning = false;
        this.transBaseFrame = null;

        this.absTime = 0;
        this.prevFrameTime = 0;
        this.defaultFrameDuration = frameDuration || 400;

        this.blendFactor = 0;
        this.frame0 = null;
        this.frame1 = null;
        this.interpolatedPivot = V3.$(0,0,0);
    };


    Animator.prototype.addSequence = function(name, frames, pivots)
    {
        this.sequences[name] = {
            name: name,
            frames: frames,
            pivots: pivots,
            totalDuration: 0
        };
    };


    Animator.prototype.play = function(seqName, transDuration, frameDuration)
    {
        if (this.curSequence) {
            this.transitioning = true;
            this.transDuration = transDuration || 300;
            this.numTransFramesLeft = 30;
        }

        this.absTime = 0;
        this.prevFrameTime = new Date().getTime();

        this.curSequence = this.sequences[seqName];
        this.curFrameIdx = 0;
        this.absTime = 0;

        this.frameDuration = frameDuration || this.defaultFrameDuration;
        this.curSequence.totalDuration = this.curSequence.frames.length * this.frameDuration;
    };

    // Temporary variable used for lerp 
    var d = V3.$(0,0,0);

    Animator.prototype.update = function()
    {
        var dt, t, f, f0, f1, seq = this.curSequence;

        dt = (new Date()).getTime() - this.prevFrameTime;
        this.prevFrameTime += dt;

        this.absTime += dt;

        if (this.transitioning && this.transBaseFrame && this.absTime < this.transDuration) {
            // Restart if transition actually ended
            this.blendFactor = this.absTime / this.transDuration;
            this.frame0 = this.transBaseFrame;
            this.frame1 = seq.frames[0];
        }
        else {
            t = (this.absTime % seq.totalDuration) / seq.totalDuration;
            f = t * seq.frames.length;
            f0 = Math.floor(f);
            f1 = f0 + 1;

            if (f1 == seq.frames.length)
                f1 = 0;

            this.blendFactor = f - f0;
            this.frame0 = seq.frames[f0];
            this.frame1 = seq.frames[f1];

            // Store base frame for future transitions
            this.transBaseFrame = this.frame0;

            // Interpolate pivot
            var p0 = seq.pivots[f0], p1 = seq.pivots[f1];

            V3.sub(p1, p0, d);
            V3.scale(d, this.blendFactor);
            V3.add(p0, d, this.interpolatedPivot);
        }
    };


    return Animator;
})();
