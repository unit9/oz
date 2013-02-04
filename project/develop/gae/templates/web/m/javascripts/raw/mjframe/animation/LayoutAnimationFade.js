/*global Package */
/*global Import */
/*global Class */
/*global LayoutAnimation */

Package('mjframe.animation',
[
    Import('mjframe.LayoutAnimation'),

    Class('public LayoutAnimationFade extends LayoutAnimation',
    {
        _public:
        {
            init: function(content, direction)
            {
                this._super(content, LayoutAnimation.DIRECTION_FORWARD);
                $('#' + content.id).css('position', 'absolute');
            },

            playIn: function(content, direction)
            {
                this._super(content, LayoutAnimation.DIRECTION_FORWARD);

                $(content).css('opacity', '0');
                $(content).css('display', 'block');
                $(content).animate({opacity: 1}, 1000, 'easeInOutQuint', Poof.retainContext(this, function()
                {
                    this.dispatch(LayoutAnimation.EVENT_IN_COMPLETE);
                }));
            },

            playOut: function(content, direction)
            {
                this._super(content, LayoutAnimation.DIRECTION_FORWARD);

                $(content).animate({opacity: 0}, 1000, 'easeInOutQuint', Poof.retainContext(this, function()
                {
                    this.dispatch(LayoutAnimation.EVENT_OUT_COMPLETE);
                }));
            }
        }
    })
]);
