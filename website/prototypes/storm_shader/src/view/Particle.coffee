class Particle

    scene       : null
    particle    : null
    angle       : 0
    speedRot    : 1.1
    origin      : {x: 0, y: -100, z: 0}

    highest     : 500
    radius      : 500

    upSpeed     : Math.PI * 2 / 10000
    upCounter   : 0

    constructor: ( _scene, _speedRot ) ->

        @scene = _scene
        @speedRot = _speedRot

        @build()

    build: =>

        pgeom = new THREE.PlaneGeometry 50.0, 50.0

        @particle = new THREE.Mesh pgeom, new THREE.MeshBasicMaterial({color:0xFF0000, side: THREE.DoubleSide, wireframe: true})
        @particle.position.y = @origin.y

        @scene.add @particle

    update: =>

        movPercent = Math.abs( Math.sin( @upCounter ) * 100)

        @rad = @angle * (Math.PI / 180)
        
        @particle.position.x = @origin.x + @radius * Math.cos(@rad)
        @particle.position.z = @origin.z + @radius * Math.sin(@rad)
        @particle.position.y = (( movPercent * (@highest-@origin.y) ) / 100 ) + @origin.y

        @upCounter += @upSpeed

        @radius = (( movPercent * (500-10) ) / 100 ) + 10

        @angle += @speedRot