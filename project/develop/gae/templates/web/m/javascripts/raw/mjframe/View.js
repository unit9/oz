/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global View */
/*global LayoutAnimation */
/*global Template */
/*global Copy */
/*global TML */
/*global NavigationManager */

Package('mjframe', [
    Import('mjframe.LayoutAnimation'),
    Import('mjframe.Template'),
    Import('mjframe.Copy'),
    Import('mjframe.TML'),

    Class('public abstract View', {
        _public_static: {
            EVENT_INIT: 'View.EventInit',
            EVENT_SHOW: 'View.EventShow',
            EVENT_HIDE: 'View.EventHide',

            REMOVE_ON_HIDE : true,

            viewId: 0
        },

        _public: {
            compiled: false,
            copy: null,
            containerObject: null,
            contentObject: null,
            $container: null,
            $content: null,
            templatePath: null,
            animation: null,

            View: function() {
            },

            init: function(containerId, templatePath, copy) {
                this.compiled = false;
                if (containerId !== null) {
                    this.containerObject = document.getElementById(containerId);
                } else {
                    this.containerObject = document.body;
                }

                if(!this.contentObject || View.REMOVE_ON_HIDE)
                {
                    this.contentObject = document.createElement('div');
                    if(this.contentObject && this.containerObject)
                    {
                        this.contentObject.style.zIndex = 0;
                        this.contentObject.id = 'view' + (View.viewId ++);
                        this.containerObject.appendChild(this.contentObject);
                    }

                    if('$' in window)
                    {
                        this.$container = $(this.containerObject);
                        this.$content = $(this.contentObject);
                    }
                    this.templatePath = templatePath;
                    this.$el = $(this.contentObject);

                    this.$el.hide();
                    this.copy = copy;

                    Template.load(this.templatePath, this.contentObject.id, Poof.retainContext(this, this.onTemplateReady));
                } else
                {
                    this.onTemplateReady();
                }
            },

            show: function(direction) {
                this.log('showing view', this.name, '(' + direction + ')');
                this.beforeShow();

                if(typeof(direction) === 'undefined') {
                    direction = LayoutAnimation.DIRECTION_FORWARD;
                }

                if(this.animation === null) {
                    this.$el.css('display', '');
                    this.onShow();
                } else {
                    this.animation.on(LayoutAnimation.EVENT_IN_COMPLETE, Poof.retainContext(this, this.onShow));
                    this.animation.init(this.contentObject, direction);
                    this.animation.playIn(this.contentObject, direction);
                }
            },

            hide: function(direction) {
                this.beforeHide();

                if(typeof(direction) === 'undefined') {
                    direction = LayoutAnimation.DIRECTION_FORWARD;
                }

                if(this.animation === null) {
                    this.contentObject.style.display = 'none';
                    this.onHide();
                } else {
                    this.animation.on(LayoutAnimation.EVENT_OUT_COMPLETE, Poof.retainContext(this, this.onHide));
                    this.animation.playOut(this.contentObject, direction);
                }
            },

            bindEvents: function() {
            },

            compilePageLinks: function() {
                $(this.contentObject).find('a[page]').each(function() {
                    $(this).off('click');
                    this.setAttribute('href', this.getAttribute('page'));
                    $(this).click(function(event) {
                        event.preventDefault();
                        NavigationManager.getInstance().goTo($(this).attr('page'));
                    });
                });
            },

            compile : function()
            {
                if(this.compiled)
                {
                    return;
                }

                this.contentObject.innerHTML = TML.compile([this.data, window], this.contentObject.innerHTML);

                this.compiled = true;
            },

            destroy: function() {
                $(this.contentObject).find('a').off('click');
                if(View.REMOVE_ON_HIDE)
                {
                    this.containerObject.removeChild(this.contentObject);
                    this.contentObject = null;
                } else
                {
                    this.contentObject.style.display = 'none';
                }
            },

            loadCopy: function() {
                if(Copy.useSharedCopy && Copy.sharedCopyClass)
                {
                    Copy.sharedCopyClass.getInstance().load(Poof.retainContext(this, this.onCopyLoaded));
                } else
                {
                    Copy.load(window.config.defaultLocale, window.PLATFORM, this.copy, Poof.retainContext(this, this.onCopyLoaded));
                }
            },

            onTemplateReady: function() {
                if(this.copy !== null && typeof(this.copy) !== 'undefined') {
                    this.loadCopy();
                } else {
                    this.onViewReady();
                }
            },

            onViewReady: function() {
                this.compile();
                this.bindEvents();
                this.compilePageLinks();
                this.onReady();
            },

            onReady: function() {
                this.dispatch(View.EVENT_INIT);
            },

            onCopyLoaded: function(copyClassInfo) {
                var packageInfo = copyClassInfo.packageName.split('.');
                var classObj = window.Package;
                var i, length;

                for(i = 0, length = packageInfo.length ; i < length ; i ++ )
                {
                    classObj = classObj[packageInfo[i]];
                }
                classObj = classObj[copyClassInfo.className || copyClassInfo.name];

                this.copy = classObj.getInstance();
                this.contentObject.innerHTML = this.copy.compile(this.contentObject.innerHTML);
                this.onViewReady();
            },

            onShow: function() {
                if(this.animation)
                {
                    this.animation.off(LayoutAnimation.EVENT_IN_COMPLETE);
                }
                this.dispatch(View.EVENT_SHOW);
            },

            onHide: function() {
                if(this.animation)
                {
                    this.animation.off(LayoutAnimation.EVENT_OUT_COMPLETE);
                }
                this.destroy();
                this.dispatch(View.EVENT_HIDE);
            },

            beforeShow: function() {

            },

            beforeHide: function() {

            }
        }
    })
]);
