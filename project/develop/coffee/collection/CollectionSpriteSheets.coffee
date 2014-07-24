class CollectionSpriteSheets extends Backbone.Collection

    model : SpriteSheetModel

    add : (models, options) ->
        m = JSON.parse models.result
        m.id = models.id
        super(m, options)

    get : (from, id) =>

        model = (@where({id : from}))[0]

        ss = {}

        image = window.oz.baseAssets.get(model.id + "Assets")

        ss.image = image.src
        ss.fullSize = [image.result.width, image.result.height]

        if window.devicePixelRatio == 2
            ss.image2x = window.oz.baseAssets.get(model.id + "Assets2x").src

        ss.frame = model.get('animations')[id][0]
        ss.coord = model.get('frames')[ss.frame]
        ss.x = ss.coord[0]
        ss.y = ss.coord[1]
        ss.width = ss.coord[2]
        ss.height = ss.coord[3]
        
        # Return
        ss