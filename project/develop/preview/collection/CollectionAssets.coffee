class CollectionAssets extends Backbone.Collection

    model : AssetModel
    fullSize : null
    image : null
    image2 : null

    image1FullSize : null
    image2FullSize : null

    get : (id) =>

        ss = {}
        ss.frame = @at(0).get('animations')[id][0]
        ss.coord = @at(0).get('frames')[ss.frame]
        ss.x = ss.coord[0]
        ss.y = ss.coord[1]
        ss.width = ss.coord[2]
        ss.height = ss.coord[3]
        
        # Return
        ss

    getImage : =>
        imgURL = "/img/preview/" + @at(0).get('images')

        imgs = {}
        imgs.image = imgURL.replace('.png', '_1x.png')
        if(window.devicePixelRatio == 2)
            imgs.image2 = imgURL.replace('.png', '_2x.png')

        return imgs