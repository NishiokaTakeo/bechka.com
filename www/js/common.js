var CSCommon = {
	
	postRequest: function(reqUrl,dataArray,successProc){
	
		$.ajax({
				type: 'POST' ,
				url: reqUrl ,
				data: dataArray,
				success: successProc ,
				dataType: 'text'
		})  ;
	} ,
		
	change_panel: function(from,to,speed){
		
	
		if(speed == 'fast' || speed == 'normal' || speed == 'slow' || speed > 0){
			$('#' + from).fadeTo(speed,0,function(){
					$('#' + from).css("display","none")  ;
					
					$('#' + to).css("opacity","0") ;
					$('#' + to).css("display","block") ;	
					
				$('#' + to).fadeTo(speed,100,function(){});
			});

		}else {
			$('#' + from).css("display","none")  ;
			$('#' + to).css("display","block") ;	
		}
		
	} ,
	
	locationErrorPage: function(message){
		window.location='http://shippaishare.cluster-style.com/error_page.pl?メッセージ='  + message ;
	} ,
	
} ;

function maskOn(id){
	
	var width = $("html").width() ;
	var height = $("html").height() ;
	
	$(id).css("width",width + "px") ;
	$(id).css("height",height + "px") ;
	
	$(id).animate({ opacity: 0.75 }, 300);
}

function maskOff(id){
	$(id).animate({ opacity: 0 }, 300,function(){$(id).remove() ;});
}

function isNullOrEmpty(obj){
	if( obj == null || obj == ""){
		return true ;
	}else{
		return false;
	}
}

function PrintMessageI(message){

	//存在確認
	var element = document.getElementById("message");
	if( element != null){return;}

	$("body").append('<div id="message"><div class="message_title">メッセージ</div><div class="message_body">'+message+'</div></div>');
	$("#message").addClass("message_I");
	var css="" ;
	var top = 50 ;
	//var left = ($("html").width() / 2 ) - ($("body").width() / 2) ;
	var left =  ($("body").width() / 2) - ($("#message").width() / 2);
	
	$("#message").css("top",top) ;
	$("#message").css("left",left) ;

	$("#message").fadeTo('fast',1);

	//アラーの削除1
	setTimeout(function(){
		$("#message").fadeTo('last',0,function(){$("#message").remove();});
	},1300);
} 

function PrintMessageE(message){

	//存在確認
	var element = document.getElementById("message");
	if( element != null){return;}

	$("body").append('<div id="message"><div class="message_title">エラー</div><div class="message_body">'+message+'</div></div>');
	$("#message").addClass("message_E");
	var css="" ;
	var top = 50 ;
	//var left = ($("html").width() / 2 ) - ($("body").width() / 2) ;
	var left =  ($("body").width() / 2) - ($("#message").width() / 2);
	$("#message").css("top",top) ;
	$("#message").css("left",left) ;

	$("#message").fadeTo('fast',1);

	//アラーの削除1
	setTimeout(function(){
		$("#message").fadeTo('last',0,function(){$("#message").remove();});
	},1300);
} 

function ajax_error(jqXHR, textStatus, errorThrown){
		
		var weekWord = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'] ;
		var monthWord = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'] ;

		var date = new Date();
		var yyyy = date.getFullYear() ;
		var month = date.getMonth();
		var week = date.getDay();
		var day = date.getDate() ;
		var hour = date.getHours() ;
		var min = date.getMinutes() ;
		var sec = date.getSeconds() ;

		var month2 = monthWord[month] ;
		var week2 = weekWord[week] ;

		month = ('00' + month).slice(-2);
		day = ('00' + day).slice(-2);
		hour = ('00' + hour).slice(-2);
		min = ('00' + min).slice(-2);
		sec = ('00' + sec).slice(-2);

		var now = yyyy + '-' + month2 + '-' + day + ' ' + hour + ":"+min+":" + sec
		
		var logstr=	now + " status\t" + jqXHR.status +"\t" + jqXHR.getAllResponseHeaders+"\t"+ jqXHR.responseText + "\n" ;
		
		logstr = encodeURIComponent(logstr) ;
		
		$.ajax({
			type: 'POST' ,
			url: './savelog.cgi',
			data: { 'logdata' : logstr },
			dataType: 'text',
		})  ;
	}

	var BROWSER_FIREFOX = "Firefox" ;
	var BROWSER_OPERA = "Opera";
	var BROWSER_GOOGLE = "Google Chrome";
	var BROWSER_SAFARI= "Safari";
	var BROWSER_IE = "IE";
	
function getBrowser(){
	var userAgent = window.navigator.userAgent.toLowerCase();
	
	if (userAgent.indexOf("msie") > -1) {
		return BROWSER_IE ;
	}else if (userAgent.indexOf("firefox") > -1) {
		return BROWSER_FIREFOX;
	}
	else if (userAgent.indexOf("opera") > -1) {
		return BROWSER_OPERA;
	}
	else if (userAgent.indexOf("chrome") > -1) {
		return BROWSER_GOOGLE;
	}
	else if (userAgent.indexOf("safari") > -1) {
		return BROWSER_SAFARI;
	}
	else {
		return '' ;
	}
}


function addEvent(element,eventType,fn,boolen){

		if( getBrowser() == BROWSER_IE){
			element.attachEvent('on' + eventType,fn) ;
		}else{
		
				if( typeof (boolen) != 'Boolean' ){
					boolen = false;
				}
				
				element.addEventListener(eventType, fn,boolen) ;
		}
}


