$ ->

	loaderRender = =>
		requestAnimationFrame( loaderRender )
		preloader.update()

	preloader = new SpinParticlesLoader
	loaderRender()

	