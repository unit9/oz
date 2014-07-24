/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global LayoutAnimation */
/*global LayoutAnimationSlideIn*/

Package('mjframe.animation', [
    Import('mjframe.LayoutAnimation'),

    Class('public LayoutAnimationSlideIn extends LayoutAnimation', {

        _public_static: {
            CSS_TRANSITIONS : false, // CSS transitions seem to perform much worse than JS.
            TRANSITION_TIME : 1500
        },

        _public: {
            init: function(content, direction) {
                this._super(content, direction);

                var $el = $('#' + content.id);
                $el.removeClass('transition');
                $el.css('position', 'absolute');
                var top = direction === LayoutAnimation.DIRECTION_FORWARD ? '100%' : '-100%';
                $el.css('display', '');
                $el.css('top', top);
            },

            playIn: function(content, direction) {
                this._super(content, direction);

                var $el = $('#' + content.id);

                if(LayoutAnimationSlideIn.CSS_TRANSITIONS)
                {
                    setTimeout(function()
                    {
                        $el.addClass('transition');
                        $el.css('top', '0px');
                    }, 1);
                    
                    setTimeout(Poof.retainContext(this, function()
                    {
                        this.dispatch(LayoutAnimation.EVENT_IN_COMPLETE);
                    }), LayoutAnimationSlideIn.TRANSITION_TIME);
                } else
                {
                    $el.stop(true, true);
                    $el.animate({top: 0}, LayoutAnimationSlideIn.TRANSITION_TIME, 'easeInOutQuad', Poof.retainContext(this, function() {
                        this.dispatch(LayoutAnimation.EVENT_IN_COMPLETE);
                    }));
                    // LayoutAnimation.animate($el, '0%', 6000, Poof.retainContext(this, function()
                    // {
                    //     this.dispatch(LayoutAnimation.EVENT_IN_COMPLETE);
                    // }));
                }
            },

            playOut: function(content, direction) {
                this._super(content, direction);

                var top = direction === LayoutAnimation.DIRECTION_FORWARD ? '-100%' : '100%';
                var $el = $('#' + content.id);

                if(LayoutAnimationSlideIn.CSS_TRANSITIONS)
                {
                    $el.css('top', top);
                    setTimeout(Poof.retainContext(this, function()
                    {
                        this.dispatch(LayoutAnimation.EVENT_OUT_COMPLETE);
                    }), LayoutAnimationSlideIn.TRANSITION_TIME);
                } else
                {
                    $('#' + content.id).stop(true, true);
                    $('#' + content.id).animate({top: top}, LayoutAnimationSlideIn.TRANSITION_TIME, 'easeInOutQuad', Poof.retainContext(this, function() {
                        this.dispatch(LayoutAnimation.EVENT_OUT_COMPLETE);
                    }));
                    // LayoutAnimation.animate($el, top, 6000, Poof.retainContext(this, function()
                    // {
                    //     this.dispatch(LayoutAnimation.EVENT_OUT_COMPLETE);
                    // }));
                }
            }
        }
    })
]);
