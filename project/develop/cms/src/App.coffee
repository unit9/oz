view = null

$ ->

	_.templateSettings = 
        interpolate : /\{\{(.+?)\}\}/g

    # ROOT
    view = (window || document)
    
    # GLOBAL
    view.oz = {}

    # INIT APP
    view.oz.role = '0'
    view.oz.appRouter   = new AppRouter
    view.oz.appView     = new AppView