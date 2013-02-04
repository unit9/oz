$ ->
	Detector.addGetWebGLMessage() if !Detector.webgl

	window.app = new App()