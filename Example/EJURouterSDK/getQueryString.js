function getQueryString() {
//	var url = document.location.search;
//	url = url.substring(1,url.length)
//	var str = {}
//	var keyvalues = url.split('&');
//	for(var i=0;i<keyvalues.length;i++){
//		var keyAndValue = keyvalues[i].split('=');
//		var key = keyAndValue[0]
//		var value = keyAndValue[1]
//		if(key != ''){
//			str[key] = value
//		}
//	}
//	console.log(str)
//	var query = '接收到参数：'+decodeURI(JSON.stringify(str))
//    
//	var body = document.getElementsByTagName('body')[0]
//	var label = document.createElement('div')
//    label.textContent = query
//	body.appendChild(label)
    var json = JSON.stringify(router_params)
    var body = document.getElementsByTagName('body')[0]
    var label = document.createElement('div')
    label.textContent = json
    body.appendChild(label)
}
