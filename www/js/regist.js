
var CSRegist = {
	_title_id: 'input[name="タイトル"]',
	_naiyou_id: 'textarea[name="内容"]',
	_tag_id: 'input[name="タグ"]',
	_errBox: '#err_box' ,

	_defaultTitleInput : true ,
	_defaultNaiyouInput : true ,
	_defaultTagInput : true ,

	_preview_title_id: '#preview_title',
	_preview_naiyou_id: '#preview_body',

	_success_box: '#success_box',

	_lock_mode: false,

	//ページ読み込み終わったときの処理
	ready:function(){
		$(document).ready(function(){
			CSRegist.pageInit();
			setInterval("CSRegist.reloadRreview()",500);
		});
	} ,

	//
	//プレビューを更新
	//
	reloadRreview: function(){

		if( this._defaultTitleInput == false){
			$(this._preview_title_id).empty();

			$(this._preview_title_id).append(
				$(this._title_id).val()
			);
		}

		if( this._defaultNaiyouInput == false){
			$(this._preview_naiyou_id).empty();

			$(this._preview_naiyou_id).append(
				$(this._naiyou_id).val()
			);
		}
	} ,
	pageInit: function(){
		//テキストボックスに値をセット
		$(this._title_id).val("タイトルを入力してください。");
		$(this._naiyou_id).val("内容を入力してください。");
		$(this._tag_id).val("内容に関連するキーワード（タグ）を入力してください。");

		//色をグレーに変更。
		$(this._title_id).css("color","#cccccc");
		$(this._naiyou_id).css("color","#cccccc");
		$(this._tag_id).css("color","#cccccc");


		//テキストボックスにマウ↓場合は値をクリア。色を黒に変更
		$(this._title_id).focus(function(){
			CSRegist.changeInput(CSRegist._title_id);
		});

		$(this._naiyou_id).focus(function(){
			CSRegist.changeInput(CSRegist._naiyou_id);
		});

		$(this._tag_id).focus(function(){
			CSRegist.changeInput(CSRegist._tag_id);
		});
	} ,

	changeInput: function(target){

		switch (target) {
			case this._title_id :
				if( CSRegist._defaultTitleInput == true){
					$(target).val("");
					$(target).css("color","");
					CSRegist._defaultTitleInput = false;
				}
			break;
			case this._naiyou_id :
				if( CSRegist._defaultNaiyouInput == true){
					$(target).val("");
					$(target).css("color","");
					CSRegist._defaultNaiyouInput = false;
				}
			break;
			case this._tag_id :
				if( CSRegist._defaultTagInput == true){
					$(target).val("");
					$(target).css("color","");
					CSRegist._defaultTagInput = false;
				}
			break;
		}
	} ,

	check: function(){
		ok = true;
		$(this._errBox).empty();
		if( this._defaultTitleInput == true  || $(this._title_id).val() == ""){
			$(this._errBox).append("タイトルを入力してください。<br />") ;
			ok = false;
		}

		if( CSRegist._defaultNaiyouInput == true || $(this._naiyou_id).val() == "" ){
			$(this._errBox).append("内容を入力してください。<br />") ;
			ok = false;
		}

		if( CSRegist._defaultTagInput == true || $(this._tag_id).val() == ""){
			$(this._errBox).append("内容に関連するキーワード（タグ）を入力してください。<br />") ;
			ok = false;
		}


		return ok;
	},
	regist: function(){

		var title = $(this._title_id).val();
		var naiyou = $(this._naiyou_id).val();
		var tag = $(this._tag_id).val();


		var postData = {'タイトル' : title , '内容': naiyou, 'タグ': tag} ;

		//ボタン2度押しを防ぐ
		if( this._lock_mode == false){
			this.btnLock();
		}
		else{
			return ;
		}

		//var tag = $('input[name="登録"]').attr("disable","disabled");
		if(	$(CSRegist._errBox).css('display') != 'none' ){
			$(CSRegist._errBox).fadeTo('slow',0,function(){
				$(CSRegist._errBox).css('display','none');

				//チェック
				if( CSRegist.check() == true ){
					$.ajax({
						type: 'POST' ,
						url: "./regist.pl" ,
						data: postData,
						success: CSRegist.success ,
						dataType: 'text'
					})  ;
				}else{
					//ここで表示
					$(CSRegist._errBox).fadeTo(1000,1,function(){

					});
					$(CSRegist._errBox).css('display','visible');
				}

			});
		}else{

			//チェック
			if( CSRegist.check() == true ){
				$.ajax({
					type: 'POST' ,
					url: "./regist.pl" ,
					data: postData,
					success: CSRegist.success ,
					dataType: 'text'
				})  ;
			}else{
				//ここで表示
				$(CSRegist._errBox).fadeTo(1000,1,function(){

				});
				$(CSRegist._errBox).css('display','visible');
			}
		}
	},

	 success: function(data, textStatus, jqXHR){

			if( data > 0 ) {
				alert("エラー::"+data);
			}else{

				if(	$(CSRegist._success_box).css('display') != 'none' ){

					$(CSRegist._success_box).fadeTo('slow',0,function(){
						$(CSRegist._success_box).css('display','none');
//ここで表示
						$(CSRegist._success_box).css('display','visible');
						$(CSRegist._success_box).fadeTo(1000,1,function(){

						});

					});


				}else{
					//ここで表示
					$(CSRegist._success_box).fadeTo(1000,1,function(){

					});
					$(CSRegist._success_box).css('display','visible');
				}
				//alert("登録が完了");

				//ボタンのロックを解除
				CSRegist.btnRelease();
			}

		},

		btnLock: function(){
			this._lock_mode=true;
		},
		btnRelease: function(){
			this._lock_mode=false;
		}

}