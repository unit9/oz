if !@hasOwnProperty("console")
	console = {}
	console.log = (msg)=>
		postMessage({type:"console",action:"log",msg:msg});
	console.warn = (msg)=>
		postMessage({type:"console",action:"warn",msg:msg});
	console.error = (msg)=>
		postMessage({type:"console",action:"error",msg:msg});
	console.info = (msg)=>
		postMessage({type:"console",action:"info",msg:msg});