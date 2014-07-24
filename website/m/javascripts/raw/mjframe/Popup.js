/*global Package */
/*global Import */
/*global Class */
/*global ClassUtils */

/*global LayoutAnimationFade */
/*global View */
/*global Template */
/*global PageManager */
/*global iOS_getWindowSize */

Package('mjframe',
[
    Import('mjframe.Page'),
    Import('mjframe.animation.LayoutAnimationFade'),

    Class('public abstract Popup extends Page',
    {
        _public:
        {
            Popup : function()
            {
                this._super();
                this.animation = new LayoutAnimationFade();
            },

            init : function(containerId, templateUrl)
            {
                this.containerObject = document.getElementById('popup');
                this.contentObject = document.createElement('div');
                this.contentObject.id = 'view' + (View.viewId ++);
                this.containerObject.appendChild(this.contentObject);
                this.templatePath = 'popup.' + this._class._classInfo.name;
                this.$el = $(this.contentObject);

                this.$el.hide();
                this.copy = this._class._classInfo.name;

                Template.load(this.templatePath, this.contentObject.id, Poof.retainContext(this, this.onTemplateReady));
            },

            show : function(direction)
            {
                this._super(direction);

                $('#popup').removeClass('hidden');

                if (window.PLATFORM === 'mobile') {
                    $('#page').hide();
                }
            },

            hide: function(direction) {
                this._super(direction);

                if (window.PLATFORM === 'mobile') { // was commented
                    $('#popup').addClass('hidden');
                }
            },

            close : function()
            {
                PageManager.getInstance().hidePopups();
            },

            compile : function()
            {
                this._super();

                $('.button-popup-close').click(Poof.retainContext(this, this.onCloseClick));
            },

            onCloseClick : function(event)
            {
                event.preventDefault();
                this.close();
            },

            onHide : function()
            {
                this._super();
                //$('#popup').addClass('hidden');
            },

            beforeShow: function() {
                this._super();

                if (window.PLATFORM !== 'mobile') {
                    return;
                }

                var $f = $('body > footer');

                this.oldClass = $f.attr('class');
                $f.attr('class', '').hide().fadeIn(1000, 'easeInOutQuint');

                $('body').addClass('has-popup');

                $('#popup').css('minHeight', iOS_getWindowSize().height);
            },

            beforeHide: function() {
                this._super();

                if (window.PLATFORM !== 'mobile') {
                    return;
                }

                console.log('before hide');

                $('body').removeClass('has-popup');
                console.log(this.oldClass);
                $('body > footer').attr('class', this.oldClass).show();

                if (window.PLATFORM === 'mobile') {
                    $('#page').show();
                }
            }
        }
    })
]);
