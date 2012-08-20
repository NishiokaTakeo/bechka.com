var CSDetail  ={
	maxCommentCnt: 10 ,
	
	change_regist_comment_panel : function(){
		
	
	} ,

	
	registComment: function(type,from,to){

		var inputBlock='';
		var viewBlock='';
		var compBlock='';
		var messageBlock='' ;
		
		if( type == 'N' ){
			inputBlock='regist_negative_comment';
			viewBlock='negative_comment_list';
			compBlock='comp_negative_comment';
			messageBlock='display_negative_message_comment' ;		
		}else{
			inputBlock='regist_positive_comment';
			viewBlock='positive_comment_list';
			compBlock='comp_positive_comment';
			messageBlock='display_positive_message_comment' ;				
		}
	
		var arrayList= new Object();
		var comment = $('#'+ inputBlock +' form[name="regist_form"]').find('textarea[name="coment"]').val();
		var id = $('#'+ inputBlock +' form[name="regist_form"]').find('input[name="id"]').val();
		var successFunc = CSDetail.successCommentRegist(type,comment,inputBlock,compBlock,viewBlock) ;

		if( isNullOrEmpty(comment) ){
			$('#'+messageBlock).append('コメントを入力して下さい。');
			CSCommon.change_panel(inputBlock , messageBlock,'slow') ;	
			setTimeout(function(){
				CSCommon.change_panel(messageBlock , inputBlock,'slow') ;	
			},2000) ;		
			return false;	
		}
		
		$('input[name="button"]').attr('disable','disable');
				
		arrayList['comment'] = comment;
		arrayList['type'] = type;
		arrayList['id'] = id;	
		
		CSCommon.postRequest('/regist_comment.pl',arrayList,successFunc) ;
		
		$('input[name="button"]').attr('disable','');
		//CSCommon.change_panel(from,to) ;
	},

	successCommentRegist:function(type,comment,inputBlock,compBlock,viewBlock){

		var retFunc= function(data, textStatus, jqXHR){
		
			if( isNullOrEmpty(data)){
				CSCommon.change_panel(inputBlock , compBlock,'normal') ;

				setTimeout(function(){
					CSCommon.change_panel(compBlock , viewBlock,'slow') ;	
				},3000) ;
				
				//追加した内容を設定
				//もし1番のりだったら煽りの内容を削除
				

				
				//コメント < 表示件数
				if(type == 'N'){
					$("#negative_comment_encourage").remove();
					$("#negative_comments").after("<dd>" + comment + "</dd>");
				}else{
					$("#positive_comment_encourage").remove();
					$("#positive_comments").after("<dd>" + comment + "</dd>");
				}

			}else{
				//alert("現在サイトメンテナンス中です。しばらくお待ちください。");
				CSCommon.locationErrorPage('そのページは削除されたか存在しないページです。') ;	
			}
			
			//入力内容を初期化
			$('textarea[name="coment"]').val("");
		};
		
		return retFunc;
	},
	
	displayComment: function(type,id){
		
		var naiyou = $('#'+id).text() ;
		var negativeCommentID = 'display_negative_comment' ;
		var negativeCommentBodyID = 'display_negative_comment_body' ;
		var positiveCommentID = 'display_positive_comment' ;
		var positiveCommentBodyID = 'display_positive_comment_body' ;
		
		if( type == 'N'){
			this._displayCooment('positive_block',negativeCommentID,negativeCommentBodyID,naiyou) ;
		}else{
			this._displayCooment('negative_block',positiveCommentID,positiveCommentBodyID,naiyou) ;		
		}
	},
	
	_displayCooment: function(blockID,commentID,CommentBodyID,naiyou){
			$('#' + commentID).fadeTo('slow',0,function(){
				$('#'+CommentBodyID).empty();
				var activeID = $('#'+blockID).find('div[style*="block"]').attr('id') ;
				$('#'+CommentBodyID).append(naiyou) ;
				CSCommon.change_panel(activeID , commentID,'normal') ;						
			});
	} ,
} ;


