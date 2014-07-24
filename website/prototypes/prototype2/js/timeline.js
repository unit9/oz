timeline = (function()
{
    var curState = 0,
        timer = null,
        speedY = 0,
        speedZ = 0;

    var updateState1 = function()
    {
        var dz = 0 - creature.pos[2];

        dz *= 0.1;
        if (dz > 4)
            dz = 4;

        creature.rot[0] = dz * Math.PI * 0.07;
        creature.pos[2] += dz;

        if (creature.pos[2] > -1)
            timeline.gotoState(2);
    };

    
    var updateState4 = function()
    {
        if (speedY < 3)
            speedY *= 1.3;

        if (speedZ < 5)
            speedZ *= 1.2;

        creature.rot[0] = speedZ * Math.PI * 0.07;
        creature.pos[2] += speedZ;
        creature.pos[1] += speedY;
    };

    return {
        start: function()
        {
            this.gotoState(1);
        },


        gotoState: function(state)
        {
            if (timer != null)
                clearTimeout(timer);

            console.log('Switching to timeline state', state);

            curState = state;
            switch (curState) {
                case 1:
                    jfAnimator.play('fly');
                    break;

                case 2:
                    document.getElementById('mouse-target').style.display = 'block';
                    jfAnimator.play('idle');
                    break;

                case 3:
                    this.delayState(4, 2000);
                    jfAnimator.play('react', 200);
                    break;

                case 4:
                    speedY = 0.005;
                    speedZ = 0.05;
                    jfAnimator.play('fly', 200);
                    break;
            }
        },


        update: function()
        {
            // TODO: Perform state-specific actions
            switch (curState) {
                case 1:
                    updateState1();
                    break;
                case 4:
                    updateState4();
                    break;
            }
        },


        delayState: function(state, delay)
        {
            timer = setTimeout(function() {
                this.gotoState(state);
            }.bind(this), delay);
        }
    };
})();
