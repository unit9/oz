$ ->
	detect = new BrowserDetection

	detect.onSuccess = () =>
		console.log 'everything is ok'

	detect.onError = ( error ) =>
		console.log error
