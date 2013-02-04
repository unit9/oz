class AppRouter extends Backbone.Router

    @EVENT_HASH_CHANGED : "EVENT_HASH_CHANGED"

    routes:

        ":page"     : "hashChanged"
        ":page/"    : "hashChanged"

        "*actions"  : "hashChanged"

    start: =>

        Backbone.history.start { pushState: true, root: _globals.ROOT }

    hashChanged: ( page = null ) =>

        @trigger AppRouter.EVENT_HASH_CHANGED, page

    navigateTo: (where) =>

        @navigate "/" + where + "/", { trigger: true }

