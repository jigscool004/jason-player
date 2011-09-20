package {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.ui.ContextMenu;
	import fl.data.DataProvider;
	import fl.managers.StyleManager;
	import fl.managers.StyleManager;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.Security;
    import flash.system.LoaderContext;
    import flash.filters.ColorMatrixFilter;

	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;


	import flash.events.AsyncErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.media.SoundTransform;
	import flash.geom.Rectangle;
	import flash.filters.*;
	
	import flash.utils.setTimeout
	import flash.utils.clearTimeout
	import flash.utils.setInterval
	import flash.utils.clearInterval
	import flash.external.ExternalInterface;
	import flash.display.Bitmap;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
	
	public class flvPlayer extends MovieClip 
	{
		private var iisIP:String;
		private var fmsIP:String;
		private var iisPath:String;
		private var fmsPath:String;
		private var flvID:String;
		private var flvName:String;
		private var tmpOriginFlvPath:String;
		private var originFlvPath:String;
		
		private var bufferCount:uint = 0;
		
		private var flvPath:String;
		private var flvListArr:Array;
		private var myNC:NetConnection;
		private var myNS:NetStream;
		private var myTmpNC:NetConnection;;
		private var myTmpNS:NetStream;
		private var totalTimes:Number;
		private var originTotalByteSize:Number;


		private var isPlaying:Boolean;
		private var ifFllScreen:Boolean;
		private var swfStage:Stage;
		private var lastPlayedTime:Number;
		private var nowloaded:Number;
		private var nowProgress:Number;
		private var lastProgress:Number;
		private var switching:Boolean;
		private var flvInfo:Object;
		private var playState:String;
		private var hasIgnoredByteSize:Number;
		private var hasIgnoredTime:Number
		private var canDragFreely:Boolean;
		private var hasVolume:Boolean;
		private var nowVolume:Number;
		private var lastMetaDataDate:String;
		private var newMetaDataDate:String;
		private var originVideoWidth:Number;
		private var originVideoHeight:Number;
		private var aspectRatioOfVideo:Number;
		private var hasGotFileSize:Boolean
		private var hasGotMetaData:Boolean
		private var fileType:String
		private var fileDownLoadStartTime:Number
		private var fileDownLoadEndTime:Number
		private var autoHideToolBarTimeOutID:uint
		private var autoHideToolBarIntervalID:uint
		private var hideToolBarIntervalID:uint
		private var disToolBarIntervalID:uint
		private var bottomHeight:Number
		private var swfWidth:int
		private var swfHeight:int
		private var adWidth:int,adHeight:int;
		private var autoPlay:String;
        private var showRecommend:Boolean = true;
		private var adIntervalID:uint
		private var playTimes:Number
		private var lastTime:Number;
		private var adPlaying:Boolean = false;
		private var ad_swf_url:String;
		private var ad_player_id:String;
		private var ad_keywords:String;
		private var loader:Loader;
		private var loadingFLV:Boolean = false;
		private var enableAd:Boolean = false;
		private var disableAD:Boolean = true; //是否播放过广告
		private var isOut:Boolean = false;
		private var isUmiwi:Boolean = true;
		
		public function flvPlayer() 
		{
			setCommonStyle();
			updateMsg('flvPlayer()');
			init();
			resizeDisplay();
			bufferingMC.x=Math.round((localVideoMC.width-bufferingMC.width)/2);
			bufferingMC.y=Math.round((localVideoMC.height-bufferingMC.height)*0.7);
		}
		private function setCommonStyle() {
			var myTF:TextFormat=new TextFormat  ;
			myTF.size=12;
			myTF.color=0xFFFFFF;
			StyleManager.setStyle("textFormat",myTF);
			var myTF1:TextFormat=new TextFormat  ;
			myTF1.color=0x000000;
			myTF1.size=12;
			//msgMC.msg.setStyle("textFormat",myTF1);
			ad.visible = false;
		}

		private function init() 
		{
			updateMsg('init()');

			Security.allowDomain("*.csbew.com");
			Security.allowDomain("*.acs86.com");
			Security.allowDomain("*.umiwi.com");
			
			var myMenu:ContextMenu= new ContextMenu();
			myMenu.hideBuiltInItems();
			this.contextMenu=myMenu;
			var swfURL = this.loaderInfo.url;
			isUmiwi = (swfURL.indexOf('www.umiwi.com') != -1);
			
			//trace(swfURL);
			
			iisPath="http://www.umiwi.com/player/";
			
			
			updateMsg('iisPath='+iisPath);
			//初始化视频文件长度为最长
			totalTimes=int.MAX_VALUE;
			//初始化文件大小
			originTotalByteSize=0;
			hasIgnoredByteSize=0;
			hasIgnoredTime=0
			//是否已获得文件大小
			hasGotFileSize=false
			//是否已获取metadata
			hasGotMetaData=false

			//是否全屏
			ifFllScreen=false;

			//是否可自由拖动
			canDragFreely=false;
			
			//下载文件的起始点
			fileDownLoadStartTime=0
			fileDownLoadEndTime=0



			//是否在播放,仅用来判断播放按钮的状态
			isPlaying=false;
			//播放状态
			playState="stop";
			//是否静音
			hasVolume=true;
			
			toolBar.cursorBtn.isDraging=false
			
			toolBar.seekTimeDisMC.visible=false
			
			toolBar.toolTipMC.visible=false
			
			//缓冲图标不可见
			//bufferingMC.visible=false
			
			//初始化大播放按钮不可见
			bigPlayBtn.visible=false;
			//场景底部预留给工具条的高度
			bottomHeight=toolBar.toolBarBack.height
			
			
			bufferingMC.visible = false;
			


			swfStage=localVideoMC.stage;
			swfStage.scaleMode=StageScaleMode.NO_SCALE;
			swfStage.align=StageAlign.TOP_LEFT;
			swfStage.addEventListener(Event.RESIZE,function()
			{
				centerBufferingMC();
				resizeDisplay();
			});
			toolBar.brightNessBtn.adjustBar.visible=false;
			//初始化qualityBar按钮不可见
			toolBar.qualityBar.highQualityBtn.visible=toolBar.qualityBar.mediumQualityBtn.visible=toolBar.qualityBar.lowQualityBtn.visible=false;
			//初始化推荐视频不可见
			miniatureMC.visible=false;
			//初始化进度条不可见
			toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=false;
			
			//播放次数,用于协助处理广告和自动播放时的按钮状态
			playTimes=0
			
			//获取参数
			autoPlay=this.loaderInfo.parameters.autoPlay
			flvID=this.loaderInfo.parameters.flvID;	
			updateMsg('flvID='+flvID);
			if(autoPlay==null){
				autoPlay="1"
			}
            
            if(loaderInfo.parameters.showRecommend == "0" || loaderInfo.parameters.showRecommend == "false")
            {
                showRecommend = false;
            }else
            {
                showRecommend = true;
            }

			
			//是否自动播放
			//autoPlay="0"
			if (!flvID) flvID="5759";
			
			toolBar.umiwilink.visible = true;//isOut = (this.loaderInfo.parameters.out == '1');
			toolBar.umiwilink.buttonMode = true;
			toolBar.umiwilink.addEventListener(MouseEvent.CLICK,function()
			{
				var d = new Date();
				var m = d.getMonth()+1;
				var year = d.getFullYear();
				var day = d.getDate();
				if ( m < 10) m = '0'+m;
				if ( day < 10) day = '0'+day;
				year = year%100;
				navigateToURL(new URLRequest('http://www.umiwi.com/?utm_source=umv&utm_medium=videoshare&utm_content='+flvID+'&utm_campaign='+year+m+day));
			});
			
			if (flvID==null) 
			{
				updateMsg("need flvID");
			} else 
			{
				updateMsg('begin get flv and recommend flv');
				getFlvInfo();
				getRecommendFlv();
				
				setInterval(show_down_rate,1000);
				//if (autoPlay == '1')
				//{
					showBuffering();
				//}
				
			}
            
            if(loaderInfo.parameters.colorFilter == "reverse")
            {
                var filterObj:ColorMatrixFilter = new ColorMatrixFilter();    
                filterObj.matrix = new Array(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0);  
                
                
                
                for(var i:int=0; i<toolBar.numChildren; i++)
                {
                    toolBar.getChildAt(i).filters = [filterObj];
                }
                //toolBar.filters = [filterObj]; 
                
                //bufferingMC.filters = [filterObj]; 
                
                
                var matrix:Array = new Array();
                matrix = matrix.concat([1, 0, 0, 0, 0]); // red
                matrix = matrix.concat([0, 1, 0, 0, 0]); // green
                matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
                matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
                var rawFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
                toolBar.umiwilink.filters = [rawFilter];
                toolBar.umiwilink.gotoAndStop(3);
            }
		}
		
		private function loadAd(callback,param)
		{
			updateMsg('begin load ad');
			
			ad.visible = true;
			ad.alpha = 0;
			adPlaying = true;
			
			loader = new Loader();
			updateMsg('loading ad...');
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event)
			{
				e.target.content.x = (ad.width - adWidth > 0)?(ad.width - adWidth)/2:0;
				e.target.content.y = (localVideoMC.height - adHeight > 0)?(localVideoMC.height - adHeight)/2:0;
				
				updateMsg('load ad completed');
				var _ad:Object = loader.content;
				
				_ad.addEventListener('load_complete',function(e:Object)
				{
					updateMsg('ad event load_complete');
					callback(param);
				});
				
				_ad.addEventListener('pause',function()
				{
					updateMsg('ad event pause');
				});
				
				_ad.addEventListener('play',function(e:Object)
				{
					updateMsg('ad event play');
					adPlaying = false;
					ad.visible = false;
					if (myNS && playState != "stop")
					{
						updateMsg('ad has myNS, resume()');
						myNS.resume();
					}
					else
					{
						updateMsg('ad no myNS, call getStream('+param+')');
						callback(param);
					}
				});
				
				_ad.initPlayerData(null);
				_ad.initAdData({playerId: ad_player_id,keyWords:ad_keywords});
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function()
			{
				updateMsg('ad load IO_Error');
				adPlaying = false;
				callback(param);
			});
			
			try
			{
				loader.load(new URLRequest(ad_swf_url));
			}
			catch(e:Error)
			{
				adPlaying = false;
				callback(param);
			}
			this.addChild(loader);
		}
		
		private function getFlvInfo() 
		{
			//getflvpath.php?id=1
			var randomNum:Number=int(Math.random()*10000);
			var phpPath:String=iisPath+"/vod/getflvpath.php";
			updateMsg(phpPath);
			var phpRequest:URLRequest=new URLRequest(phpPath);
			phpRequest.method=URLRequestMethod.GET;
			var parameter:URLVariables=new URLVariables  ;
			//这里的ChatID需要传过来
			parameter.randomNum=randomNum;
			parameter.id=flvID;
			phpRequest.data=parameter;
			var phpLoader:URLLoader=new URLLoader  ;
			phpLoader.addEventListener(Event.COMPLETE,getFlvInfoComplete);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR,getFlvInfoError);
			try {
				phpLoader.load(phpRequest);
				updateMsg("正在获取视频信息");
			} catch (error:Error) {
				updateMsg("获取视频信息失败");
			}
		}
		
		private function getFlvInfoComplete(e:Event) {
			updateMsg("获取视频信息成功!");
	
			var myXML:XML=XML(e.target.data);
			
			//从xml中提取数据
			var tmpQuality:String=myXML.item.@quality;
			var tmpURL:String=myXML.item.@url;		
			var tmpThumb:String = myXML.item.@thumb;
			ad_swf_url = myXML.ad.@swf;
			ad_player_id = myXML.ad.@player_id;
			ad_keywords = myXML.ad.@keywords;
			adWidth = parseInt(myXML.ad.@width);
			adHeight = parseInt(myXML.ad.@height);
			disableAD = (myXML.ad.@hidden == "true");
			
			var tmpBtn=toolBar.qualityBar.mediumQualityBtn;								
			tmpBtn.flvPath=tmpURL;

			flvListArr = [{quality:tmpQuality,url:tmpURL,NO:2,Btn:tmpBtn}];

			if (autoPlay == '1')
			{
				getMediumQualityFLV();
			}
			else
			{
				loadThumb(tmpThumb);
			}
		}
		
		private function getFlvInfoError(e:IOErrorEvent) {
			updateMsg("获取视频信息失败");
		}
		
		
		private function loadThumb(url:String):void
		{
			updateMsg("载入大图:"+url);
			toolBar.playTime.alpha = 0;
			toolBar.totalTime.alpha = 0;
			
			var loader:Loader=new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(evt:Event)
			{
				updateMsg("载入大图完成");
				if (isUmiwi)
				{
					var img:Bitmap = new Bitmap(evt.target.content.bitmapData);
					img.smoothing = true;
					localVideoMC.backOfVideo.thumbClip.addChild(img);
				}
				localVideoMC.backOfVideo.thumbClip.alpha = 0;
				fadeIn(localVideoMC.backOfVideo.thumbClip,500);
				fadeOut(bufferingMC,200);
				resizeDisplay();
				bigPlayBtn.visible = true;
				bigPlayBtn.buttonMode = true;
				bigPlayBtn.addEventListener(MouseEvent.MOUSE_DOWN,initStartPlay);
				toolBar.playBtn.visible = true;
				toolBar.playBtn.buttonMode = true;
				toolBar.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,initStartPlay);
			});
			try
			{
				loader.load(new URLRequest(url));
			}
			catch(e:Error)
			{
				updateMsg("载入大图错误");
			}
			if (!isUmiwi) localVideoMC.backOfVideo.thumbClip.addChild(loader);
		}
		
		
		
		private function initStartPlay(e:Event)
		{
			autoPlay = '1';
			toolBar.playTime.alpha = 1;
			toolBar.totalTime.alpha = 1;
			getMediumQualityFLV();
			showBuffering();
			bigPlayBtn.removeEventListener(MouseEvent.MOUSE_DOWN,initStartPlay);
			toolBar.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,initStartPlay);
		}

		private function initBtn() {
			toolBar.volumeBar.buttonMode=true;
			toolBar.volumeBar.useHandCursor=true;
			toolBar.playBtn.buttonMode=true;
			toolBar.playBtn.useHandCursor=true;
			toolBar.stopBtn.buttonMode=true;
			toolBar.stopBtn.useHandCursor=true;
			toolBar.fullScrBtn.buttonMode=true;
			toolBar.umiwilink.buttonMode = true;
			toolBar.fullScrBtn.useHandCursor=true;
			toolBar.volumeBtn.buttonMode=true;
			toolBar.volumeBtn.useHandCursor=true;
			toolBar.volumeBtn.addEventListener(MouseEvent.MOUSE_DOWN,closeVolume);
			toolBar.volumeBar.addEventListener(MouseEvent.MOUSE_DOWN,volumeAdjust);
			
			//质量切换
			toolBar.qualityBar.highQualityBtn.buttonMode=true;
			toolBar.qualityBar.highQualityBtn.useHandCursor=true;

			toolBar.qualityBar.mediumQualityBtn.buttonMode=true;
			toolBar.qualityBar.mediumQualityBtn.useHandCursor=true;

			toolBar.qualityBar.lowQualityBtn.buttonMode=true;
			toolBar.qualityBar.lowQualityBtn.useHandCursor=true;

			toolBar.qualityBar.highQualityBtn.addEventListener(MouseEvent.MOUSE_DOWN,getHighQualityFLV);
			toolBar.qualityBar.mediumQualityBtn.addEventListener(MouseEvent.MOUSE_DOWN,getMediumQualityFLV);
			toolBar.qualityBar.lowQualityBtn.addEventListener(MouseEvent.MOUSE_DOWN,getLowQualityFLV);
			

			toolBar.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,ifPlay);
			toolBar.stopBtn.addEventListener(MouseEvent.MOUSE_DOWN,stopPlay);

			bigPlayBtn.buttonMode=true;
			bigPlayBtn.useHandCursor=true;
			bigPlayBtn.addEventListener(MouseEvent.MOUSE_DOWN,ifPlay);
			

			miniatureMC.replayBtn.buttonMode=true;
			miniatureMC.replayBtn.useHandCursor=true;
			miniatureMC.replayBtn.addEventListener(MouseEvent.MOUSE_DOWN,ifPlay);
			miniatureMC.replayBtn.visible=false;

			//搜寻
			toolBar.seekBar.addEventListener(MouseEvent.MOUSE_DOWN,seekFlvByClick);
			toolBar.seekBar.addEventListener(MouseEvent.MOUSE_MOVE,disSeekTime);
			toolBar.seekBar.addEventListener(MouseEvent.MOUSE_OUT,hideSeekTime);
			//全屏
			toolBar.fullScrBtn.addEventListener(MouseEvent.MOUSE_DOWN,toggleFullScreen);
			swfStage.addEventListener(Event.RESIZE, resizeDisplay);			

			//亮度调节
			toolBar.brightNessBtn.disAdjustBarBtn.buttonMode=true;
			toolBar.brightNessBtn.disAdjustBarBtn.useHandCursor=true;
			toolBar.brightNessBtn.disAdjustBarBtn.addEventListener(MouseEvent.MOUSE_DOWN,ifDisAdjustBar);
			toolBar.brightNessBtn.adjustBar.addEventListener(MouseEvent.ROLL_OUT,hideAdjustBar);


			toolBar.brightNessBtn.adjustBar.dragBar.buttonMode=true;
			toolBar.brightNessBtn.adjustBar.dragBar.useHandCursor=true;

			toolBar.brightNessBtn.adjustBar.dragBar.addEventListener(MouseEvent.MOUSE_DOWN,brightNessAdjust);
			toolBar.brightNessBtn.adjustBar.dragBar.addEventListener(MouseEvent.MOUSE_MOVE,setBrightNess);
			stage.addEventListener(MouseEvent.MOUSE_UP,stopBrightNessAdjust);

			//双击全屏
			localVideoMC.fullScrBtn.doubleClickEnabled=true;
			localVideoMC.fullScrBtn.addEventListener(MouseEvent.DOUBLE_CLICK,toggleFullScreen);
			//视频窗口单击功能
			localVideoMC.fullScrBtn.addEventListener(MouseEvent.MOUSE_DOWN,ifPlay);
			//游标拖动
			toolBar.cursorBtn.addEventListener(MouseEvent.MOUSE_DOWN,cursorBtnAdjust);
			toolBar.cursorBtn.addEventListener(MouseEvent.MOUSE_MOVE,setCursorBtn);
			stage.addEventListener(MouseEvent.MOUSE_UP,stopCursorBtnAdjust);
			
			//按钮提示
			
			//toolBar.playBtn.addEventListener(MouseEvent.MOUSE_MOVE,disToolTipMC);			
			//toolBar.playBtn.addEventListener(MouseEvent.MOUSE_OUT,hideToolTipMC);
			
			//toolBar.stopBtn.addEventListener(MouseEvent.MOUSE_MOVE,disToolTipMC);
			//toolBar.stopBtn.addEventListener(MouseEvent.MOUSE_OUT,hideToolTipMC);
			
			toolBar.brightNessBtn.disAdjustBarBtn.addEventListener(MouseEvent.MOUSE_MOVE,disToolTipMC);
			toolBar.brightNessBtn.disAdjustBarBtn.addEventListener(MouseEvent.MOUSE_OUT,hideToolTipMC);
			
			toolBar.volumeBtn.addEventListener(MouseEvent.MOUSE_MOVE,disToolTipMC);
			toolBar.volumeBtn.addEventListener(MouseEvent.MOUSE_OUT,hideToolTipMC);
			
			toolBar.fullScrBtn.addEventListener(MouseEvent.MOUSE_MOVE,disToolTipMC);
			toolBar.fullScrBtn.addEventListener(MouseEvent.MOUSE_OUT,hideToolTipMC);
			
		}
		
		public function tmpAsyncError(e:AsyncErrorEvent) { }
		
		
		private function initNC()
		{
			updateMsg('initNC()');
			
			if (myNC) 
			{
				updateMsg('已经有NC');
				myNC.close();
				myNC.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				myNC.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				myNC.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
				myNC=null;
			}
			myNC= new NetConnection();
			myNC.client=this;
			myNC.objectEncoding=ObjectEncoding.AMF3;
			myNC.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			myNC.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			myNC.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
			myNC.connect(null);
		}
		
		private function netStatusHandler(e:NetStatusEvent):void {
			updateMsg(e.info.code);
			try
			{
				if (myNS && myNS.time > 0)
					ExternalInterface.call("player_signal",e.info.code,flvPath,myNS.time);
				else
					ExternalInterface.call("player_signal",e.info.code,flvPath,0);
			}catch(e:Error){ }
			switch (e.info.code) {
				case "NetConnection.Connect.Success" :
					updateMsg("NC连接成功...");
					//先检验是否需要切换
					//getStream(flvPath);
					
					getStream(flvPath);
					break;
				case "NetStream.Play.StreamNotFound" :
					updateMsg("NC未找到视频文件...");
					isPlaying=false;
					playState="stop";
					toolBar.playBtn.gotoAndStop(1);
					break;
				case "NetStream.Play.Start" :
					if (adPlaying)
					{
						myNS.pause();
						//adPlaying = false;
					}
					updateMsg("NC正在播放...");
					isPlaying=true;
					playState="play";
					toolBar.playBtn.gotoAndStop(2);
					if (!hasGotFileSize) {
						originTotalByteSize=myNS.bytesTotal;
						hasGotFileSize=true
					}
					//updateMsg("originTotalByteSize:"+originTotalByteSize);
					bigPlayBtn.visible=false;
					fadeOut(localVideoMC.backOfVideo.thumbClip,200);
					miniatureMC.visible=false;
					playTimes++
					if(playTimes==1){
						initBtn()
						if(autoPlay=="0"){
							toolBar.playBtn.gotoAndStop(1);
							myNS.pause();
							isPlaying=false
							updateMsg("播放暂停...");
							bigPlayBtn.visible=true;
							playState="pause";
							//toolBar.toolTipMC.tipTxt.text="播放"		
							hideBuffering();
						}
						
				    }
					break;
				case "NetStream.Buffer.Empty" :
				    showBuffering();
					updateMsg("NC正在缓冲...");
					break;
				case "NetStream.Buffer.Full" :
					updateMsg("NC正在播放...");
					isPlaying=true;
					playState="play";
					toolBar.playBtn.gotoAndStop(2);
					if (!hasGotFileSize) {
						originTotalByteSize=myNS.bytesTotal;
						hasGotFileSize=true
					}
					updateMsg("originTotalByteSize:"+originTotalByteSize);
					bigPlayBtn.visible=false;
					miniatureMC.visible=false;
					
					hideBuffering();
					
					break;

				case "NetStream.Buffer.Flush" :
					break;
				case "NetStream.Play.Stop" :
					myNS.close();
					isPlaying=false;
					playState="stop";
					toolBar.playBtn.gotoAndStop(1);
					//bigPlayBtn.visible=true;
					toolBar.cursorBtn.x=3;
					updateMsg("视频播放完毕...");
					try{
						ExternalInterface.call("video_play_over");
					}catch(e:Error) { }
					
					//显示推荐视频
                    if(showRecommend)
                    {
                        miniatureMC.visible=true;
                    }
					
					//显示重播按钮
					miniatureMC.replayBtn.visible=true;

					hasIgnoredByteSize=0;
					hasIgnoredTime=0
					hideBuffering();
					break;
				case "NetStream.Seek.InvalidTime" :
					myNS.pause();
					switching=true;
					break;
			}
		}
		private function securityErrorHandler(event:SecurityErrorEvent):void {

			updateMsg("安全性错误...");
		}
		public function asyncError(event:AsyncErrorEvent) {
			updateMsg("异步错误...");
		}

		public function show_down_rate()
		{
			if (myNS && myNS.bytesLoaded)
			{
				try{
					ExternalInterface.call("player_signal",'DownRate',flvPath,myNS.time,myNS.bytesLoaded);
				}catch(e:Error){ }
			}
		}

		//先播放低质量视频

		private function getStream(flvPath:String)
		{
			updateMsg("in function getStream("+flvPath+")");
			if ( enableAd && flvPath.indexOf('?start') == -1 
				&& disableAD == false 
				&& !isOut )
				//&& ExternalInterface.available  )
			{
				try
				{
					loadAd(doGetStream,flvPath);
				}
				catch(e:Error)
				{
					doGetStream(flvPath);
				}
			}
			else
			{
				doGetStream(flvPath);
			}
		}

		private function doGetStream(flvPath:String) 
		{
			updateMsg('doGetStream:'+flvPath);
			if (myNS) {
				this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
				myNS.close();
				myNS.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				myNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
				myNS=null;
				localVideoMC.tmpVideo.attachNetStream(null);
				localVideoMC.tmpVideo.clear();
				hideBuffering();
			}

			myNS=new NetStream(myNC);
			myNS.client=this;
			myNS.bufferTime=5;
			myNS.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			myNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
			localVideoMC.tmpVideo.attachNetStream(myNS);
			localVideoMC.tmpVideo.smoothing=true
			myNS.play(flvPath);

			
			//切换到新视频时，如果视频是不可自由拖放的，先暂停，等下载到播放点时重新播放
			if (switching&&!canDragFreely) {
				myNS.pause();
				toolBar.playBtn.gotoAndStop(1);				
				updateMsg("播放暂停...");
				bigPlayBtn.visible=true;
				playState="pause";
			}
			
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			//调节音量
			var mySound:SoundTransform=myNS.soundTransform;
			if (hasVolume) {
				nowVolume=toolBar.volumeBar.maskMC.width/toolBar.volumeBar.width;
				mySound.volume=nowVolume*2;
				myNS.soundTransform=mySound;
			} else {
				mySound.volume=0;
				myNS.soundTransform=mySound;
				toolBar.volumeBar.maskMC.width=0;
			}
		}
		
		
		public function onMetaData(info:Object)
		{
			//开始分析
			//originFlvPath=flvPath;
			if(!hasGotMetaData)
			{
				totalTimes=info.duration;
				updateMsg("NC on MetaData,Totaltime:"+totalTimes)
				toolBar.totalTime.text=convertTime(totalTimes);
				//初始化类型为flv，不可拖放
				fileType="flv"
				canDragFreely=false;
				
				//可自由拖放的FLV
				if (info.hasKeyframes) 
				{
					fileType="flv";
				}
				//可自由拖放的mp4
				if (info.seekpoints) 
				{
					fileType="mp4";
				}
				var i:int;
				var seekPoint:Number
				switch(fileType){
					case "flv":
					  if (info.hasKeyframes) {						  
						  flvInfo=new Object();
						  flvInfo.times=info.keyframes.times;
						  flvInfo.filePositions=info.keyframes.filepositions;
						  for(i=0;i<flvInfo.filePositions.length;i++){
						  //updateMsg(flvInfo.filePositions[i])
						  }
						  canDragFreely=true;
						  newMetaDataDate=info.metadatadate;
						  seekPoint=int(lastProgress*flvInfo.filePositions.length);
						  if (seekPoint < 0)  seekPoint=0;
						 //根据搜索点获取搜索帧
						 var seekPosition:Number=flvInfo.filePositions[seekPoint];
						 updateMsg("seekPoint:"+seekPoint)
						
							if(seekPosition>0)
							{
								updateMsg('seek:'+seekPosition);
								flvPath=originFlvPath+"?start="+seekPosition;	
							}
							else
							{
								flvPath=originFlvPath 
							}
						
						 
						 
						 //开始搜索
						 //flvPath=originFlvPath+"?start="+seekPosition;
						
						 //要忽略掉这部分的字节数，以使下载进度条长度符合事实
						 //hasIgnoredByteSize=seekPosition;
						 hasIgnoredByteSize=lastProgress*originTotalByteSize
						 updateMsg("hasIgnoredByteSize:"+hasIgnoredByteSize)
						 initNC();
						 lastProgress=0;
						 }else{
						  flvPath=originFlvPath;
						  switching=true;
						  initNC();
					   }
					break;
					case "mp4":					
						updateMsg('can drag freely');
					  canDragFreely=true;
					  flvInfo=new Object();
					  flvInfo.times=new Array()
					  flvInfo.filePositions=new Array()
					  for(i=0;i<info.seekpoints.length;i++)
					  {
							flvInfo.times[i]=info.seekpoints[i].time
							flvInfo.filePositions[i]=info.seekpoints[i].offset						  
					  }
					  for(i=0;i<flvInfo.filePositions.length;i++){
						 // updateMsg(flvInfo.filePositions[i])
					  }
					  seekPoint=int(lastProgress*flvInfo.times.length);					 
					  seekPosition=flvInfo.times[seekPoint];			
					  updateMsg("seekPoint:"+seekPoint)
					  
					  //hasIgnoredByteSize=flvInfo.filePositions[seekPoint];	
					  hasIgnoredTime=lastProgress*totalTimes
					  hasIgnoredByteSize=lastProgress*originTotalByteSize
					  //updateMsg("hasIgnoredByteSize:"+hasIgnoredByteSize);
					  flvPath=originFlvPath;
					  if (seekPosition > 0) flvPath+="?start="+seekPosition;		
					   
					break;
					
					
				}
					
				//调整长宽
				originVideoWidth=info.width;
				originVideoHeight=info.height;
				if (aspectRatioOfVideo!=originVideoWidth/originVideoHeight) {
					resizeDisplay();
					aspectRatioOfVideo=originVideoWidth/originVideoHeight;
				}
			}
			hasGotMetaData=true				
		}
		
		public function onXMPData(info:Object) {
			for (var propName:String in info) {
				//updateMsg(propName + " = " + info[propName]);
			}
		}

		public function onLastSecond(info:Object) {
			updateMsg('onLastSecond');
		}

		private function enterFrameHandler(event:Event) {		
			switch(fileType){
				case "flv":
				  nowProgress=(myNS.time/totalTimes);				  
				  if (nowProgress>1) {
					  nowProgress=1;
					}
				  if(nowProgress>0){
					  toolBar.cursorBtn.x=toolBar.playBar.x+nowProgress*toolBar.seekBar.width-7;
					}else{
					  toolBar.cursorBtn.visible=false
					}
				  toolBar.playBar.width=nowProgress*toolBar.seekBar.width;				  
				  //显示播放时间
				  toolBar.playTime.text=convertTime(myNS.time);
				  //游标定位
				  
				  
					  
				  if(canDragFreely){
					  if (originTotalByteSize>0) {
						  //updateMsg("已下载:"+myNS.bytesLoaded)
						  nowloaded=(hasIgnoredByteSize+myNS.bytesLoaded)/originTotalByteSize;
						  if (nowloaded>1) {
							  nowloaded=1;
							}
						  toolBar.downLoadBar.width=nowloaded*toolBar.seekBar.width;
					  }
					  if (nowloaded>0) {
						  toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=true;
						}
					  //获取目前可以seek的最终时间
					  fileDownLoadEndTime=fileDownLoadStartTime+(myNS.bytesLoaded/originTotalByteSize)*totalTimes
					  //updateMsg("可拖放的开始时间:"+fileDownLoadStartTime)
					  //updateMsg("可拖放的结束时间:"+fileDownLoadEndTime)
					
					  
					}
				   if(!canDragFreely){
					   nowloaded=myNS.bytesLoaded/originTotalByteSize;	
					   if (nowloaded>1) {
						   nowloaded=1;
						}
						toolBar.downLoadBar.width=nowloaded*toolBar.seekBar.width;
						if (nowloaded>0) {
							toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=true;
						}
						//对于不可拖放的视频，当数据下载量大于上次播放百比分时，开始播放
						if (nowloaded>lastProgress&&switching) {
							myNS.seek(lastPlayedTime);
							myNS.resume();
							switching=false;
						}
					}				   
				break;				
				case "mp4":
					
				  	nowProgress=(hasIgnoredTime+myNS.time)/totalTimes;
				  	if (nowProgress>1)  nowProgress=1;
				
					if (nowProgress>0)
					{
					  	toolBar.cursorBtn.x=toolBar.playBar.x+nowProgress*toolBar.seekBar.width-7;
					}
					else
					{
					  toolBar.cursorBtn.visible=false
					}
					
				  toolBar.playBar.width=nowProgress*toolBar.seekBar.width;
				  //显示播放时间
				  toolBar.playTime.text=convertTime(hasIgnoredTime+myNS.time);
				  if (Math.round(hasIgnoredTime+myNS.time) != lastTime)
				  {
					  try{
					  	ExternalInterface.call("video_play_update", (hasIgnoredTime+myNS.time)*1);
					  }catch(e:Error){ }
					 //updateMsg(Math.round(hasIgnoredTime+myNS.time).toString());
				  }
				  lastTime = Math.round(hasIgnoredTime+myNS.time);
				  
				  if(canDragFreely){
					  if (originTotalByteSize>0) {
						  nowloaded=(hasIgnoredByteSize+myNS.bytesLoaded)/originTotalByteSize;	
						  //updateMsg("已下载:"+myNS.bytesLoaded+'时间：'+myNS.time)
						  if (nowloaded>1) {
							  nowloaded=1;
							}
						if (nowloaded>0) {
							toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=true;
						}
						toolBar.downLoadBar.width=nowloaded*toolBar.seekBar.width;
					   }
					  //if (nowloaded>0) {
						  
					   //}
					   //获取目前可以seek的最终时间
					  fileDownLoadEndTime=fileDownLoadStartTime+(myNS.bytesLoaded/originTotalByteSize)*totalTimes
					  //updateMsg("可拖放的开始时间:"+fileDownLoadStartTime)
					  //updateMsg("可拖放的结束时间:"+fileDownLoadEndTime)
				   }			
				   if(!canDragFreely){
					   nowloaded=myNS.bytesLoaded/originTotalByteSize
					   if (nowloaded>1) {
						   nowloaded=1;
						 }
					   toolBar.downLoadBar.width=nowloaded*toolBar.seekBar.width;
					   if (nowloaded>0) {
						  toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=true;
						 }
					   //对于不可拖放的视频，当数据下载量大于上次播放百比分时，开始播放
					   if (nowloaded>lastProgress&&switching) {
						   myNS.seek(lastPlayedTime);
						   myNS.resume();
						   switching=false;
						 }
					}				   
				break;
				
			}
					
		}
		private function convertTime(tmpTime:Number) {
			//显示播放时间
			var tmpTime:Number;
			var tmpHour:Number;
			var tmpMinute:Number;
			var tmpSecond:Number;
			var tmpTimeToString:String;
			var tmpHourToString:String;
			var tmpMinuteToString:String;
			var tmpSecondToString:String;
			tmpHour=int(tmpTime/3600);
			if (tmpHour<10) {
				tmpHourToString="0"+tmpHour;
			} else {
				tmpHourToString=tmpHour.toString();
			}
			tmpMinute=int(tmpTime/60)-tmpHour*60;
			if (tmpMinute<10) {
				tmpMinuteToString="0"+tmpMinute;
			} else {
				tmpMinuteToString=tmpMinute.toString();
			}
			tmpSecond=int(tmpTime%60);
			if (tmpSecond<10) {
				tmpSecondToString="0"+tmpSecond;
			} else {
				tmpSecondToString=tmpSecond.toString();
			}
			tmpTimeToString=tmpHourToString+":"+tmpMinuteToString+":"+tmpSecondToString;
			return tmpTimeToString;
		}
		//功能铵钮区
		private function closeVolume(e:Event) {
			hasVolume=! hasVolume;
			var mySound:SoundTransform=myNS.soundTransform;
			if (hasVolume) {
				mySound.volume=nowVolume*2;
				myNS.soundTransform=mySound;
				toolBar.volumeBar.maskMC.width=nowVolume*toolBar.volumeBar.width;
			} else {
				mySound.volume=0;
				myNS.soundTransform=mySound;
				toolBar.volumeBar.maskMC.width=0;
			}
			toolBar.toolTipMC.visible=false

		}

		private function volumeAdjust(e:Event) {
			updateMsg(e.target.mouseX);
			updateMsg(e.target.name);
			e.target.maskMC.width=e.target.mouseX;
			updateMsg("**"+(e.target.mouseX/e.target.width));
			nowVolume=e.target.mouseX/e.target.width;
			var mySound:SoundTransform=myNS.soundTransform;
			mySound.volume=nowVolume*2;
			myNS.soundTransform=mySound;
			hasVolume=true;

		}
		private function ifDisAdjustBar(e:Event) {
			toolBar.brightNessBtn.adjustBar.visible=! toolBar.brightNessBtn.adjustBar.visible;
			if (toolBar.brightNessBtn.adjustBar.visible)
			{
				toolBar.toolTipMC.visible = false;
			}
		}
		private function hideAdjustBar(e:Event) {
			toolBar.brightNessBtn.adjustBar.visible=false;
		}


		private function brightNessAdjust(e:Event) {
			var dragArea:Rectangle=new Rectangle(5.5,-7,0,-40);
			toolBar.brightNessBtn.adjustBar.dragBar.startDrag(false,dragArea);
		}

		private function setBrightNess(e:Event) {
			//updateMsg(toolBar.brightNessBtn.adjustBar.dragBar.y);
			var tmpValue:Number=toolBar.brightNessBtn.adjustBar.dragBar.y+6;
			var brightness:Number = -(tmpValue/48)* 255;
			var filterArray:Array=[1, 0, 0, 0, brightness,
			 0, 1, 0, 0, brightness,
			 0, 0, 1, 0,brightness,
			 0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			localVideoMC.tmpVideo.filters=[colorMatrix];



		}

		private function stopBrightNessAdjust(e:Event) {
			toolBar.brightNessBtn.adjustBar.dragBar.stopDrag();
			var tmpValue:Number=toolBar.brightNessBtn.adjustBar.dragBar.y+6;
			var brightness:Number = -(tmpValue/48)* 255;
			var filterArray:Array=[1, 0, 0, 0, brightness,
			 0, 1, 0, 0, brightness,
			 0, 0, 1, 0,brightness,
			 0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			localVideoMC.tmpVideo.filters=[colorMatrix];

		}
		
		
		
			
			
		private function cursorBtnAdjust(e:Event) {
			this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);			
			this.addEventListener(Event.ENTER_FRAME,cursorEnterframe);	
			var dragArea:Rectangle=new Rectangle(3,toolBar.cursorBtn.y,toolBar.seekBar.width-7,0);
			toolBar.cursorBtn.startDrag(false,dragArea);
			toolBar.cursorBtn.isDraging=true
			
		}

		private function setCursorBtn(...arg) {
			//cursorEnterframe()
		}

		private function stopCursorBtnAdjust(e:Event) {
			if(toolBar.cursorBtn.isDraging){					
			var tmpSeekPercent:Number=((toolBar.cursorBtn.x-3)/toolBar.seekBar.width);	
			seekFLV(tmpSeekPercent)			
			}			
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			this.removeEventListener(Event.ENTER_FRAME,cursorEnterframe);
			toolBar.cursorBtn.stopDrag();
			toolBar.cursorBtn.isDraging=false

		}
		private function cursorEnterframe(...arg){
			var seekPercent:Number=((toolBar.cursorBtn.x-10)/toolBar.seekBar.width);			
			toolBar.playTime.text=convertTime(seekPercent*totalTimes);
			toolBar.playBar.width=seekPercent*toolBar.seekBar.width;
		}
		
		private function ifPlay(e:Event) {
			isPlaying=! isPlaying;
			updateMsg(playState);
			if (isPlaying) {
				toolBar.playBtn.gotoAndStop(2);

				updateMsg("正在播放...");
				bigPlayBtn.visible=false;
				miniatureMC.visible=false;
				miniatureMC.replayBtn.visible=false;




				switch (playState) {
					case "stop" :
						flvPath=originFlvPath;
						initNC();

						break;
					case "pause" :
						myNS.resume();
						playState="play";
						break;
				}
				toolBar.toolTipMC.tipTxt.text="暂停"



			} else {
				toolBar.playBtn.gotoAndStop(1);
				myNS.pause();
				updateMsg("播放暂停...");
				bigPlayBtn.visible=true;
				playState="pause";
				toolBar.toolTipMC.tipTxt.text="播放"
				//bufferingMC.gotoAndStop(1)
				//bufferingMC.visible=false
				hideBuffering();

			}
		}


		private function stopPlay(e:Event) {

			myNS.close();
			isPlaying=false;
			playState="stop";
			toolBar.playBtn.gotoAndStop(1);			
			//bigPlayBtn.visible=true;
			toolBar.cursorBtn.x=3;
			updateMsg("停止...");

			if(showRecommend)
            {
                //显示推荐视频
                miniatureMC.visible=true;
            }

			//显示重播按钮
			miniatureMC.replayBtn.visible=true;

			hasIgnoredByteSize=0;
			hasIgnoredTime=0
			
			toolBar.toolTipMC.visible=false
			//bufferingMC.gotoAndStop(1)
			//bufferingMC.visible=false
			hideBuffering();

		}



		private function seekFlvByClick(e:Event) {
			//得到搜索百分比
			var seekPercent:Number=((toolBar.seekBar.mouseX)/590);			
			
			trace(toolBar.seekBar.mouseX+'/'+toolBar.seekBar.width);
			seekFLV(seekPercent);
			//游标定位
			if(nowProgress>0){
				 toolBar.cursorBtn.x=toolBar.seekBar.x+seekPercent*toolBar.seekBar.width-7;				 
				 }else{
				 toolBar.cursorBtn.visible=false
				}
			toolBar.playBar.width=nowProgress*toolBar.seekBar.width;
				
			showBuffering();
			
			
		}
		private function seekFLV(seekPercent:Number)
		{
			updateMsg('seekFLV:'+seekPercent);
			//如果不可自由拖放，则按普通seek方式处理
			if (seekPercent<nowloaded&&! canDragFreely) 
			{
					  seekPosition=seekPercent*totalTimes;
					  myNS.seek(seekPosition);
			}
			
			
			//否则，进行特殊处理
			var seekPosition:Number;
			var seekPoint:Number
			var tmpSeekTime:Number
			switch(fileType){
				case "flv":				   
				  if (canDragFreely) {
					  //先计算是否可以用普通的seek方式
					  tmpSeekTime=seekPercent*totalTimes;
					  if(tmpSeekTime>fileDownLoadStartTime && tmpSeekTime<fileDownLoadEndTime){
						 myNS.seek(tmpSeekTime);
					   }else{
						 seekPoint=int(seekPercent*flvInfo.filePositions.length);
						 seekPosition=flvInfo.filePositions[seekPoint];
						 //hasIgnoredByteSize=seekPosition;						
						 hasIgnoredByteSize=seekPercent*originTotalByteSize
						 flvPath=originFlvPath+"?start="+seekPosition;	
						 updateMsg("*************"+flvPath)
						 initNC();	
						 //更新目前可以seek的起始时间
						 fileDownLoadStartTime=flvInfo.times[seekPoint];
						}					  
					}				 
				break;
				
				case "mp4":				 
				  if (canDragFreely) {
					   //先计算是否可以用普通的seek方式
					  tmpSeekTime=seekPercent*totalTimes-hasIgnoredTime;
					  if(tmpSeekTime>fileDownLoadStartTime && tmpSeekTime<fileDownLoadEndTime){
						 myNS.seek(tmpSeekTime);
						}else{
						seekPoint=int(seekPercent*flvInfo.times.length);	
						seekPosition=flvInfo.times[seekPoint];	
						hasIgnoredTime=seekPosition
						//hasIgnoredByteSize=flvInfo.filePositions[seekPoint];						
						hasIgnoredByteSize=seekPercent*originTotalByteSize
						flvPath=originFlvPath+"?start="+seekPosition;
						initNC();
						//更新目前可以seek的起始时间
						 fileDownLoadStartTime=seekPosition-hasIgnoredTime;
						}
					  
					  
				  
				  
				  
					  
					 
					}			
				break;					
					
				}		
			
		}
			
		private function disSeekTime(e:MouseEvent){
			var seekPercent:Number=((toolBar.seekBar.mouseX)/590);	
			toolBar.seekTimeDisMC.seekTimeTxt.text=convertTime(seekPercent*totalTimes)
			toolBar.seekTimeDisMC.x=this.mouseX+18;
			toolBar.seekTimeDisMC.visible=true
			
		}	
		private function hideSeekTime(e:MouseEvent){			
			toolBar.seekTimeDisMC.visible=false
			
		}	

		private function resizeDisplay(...arg) {
			//先停止工具条效果
			if(autoHideToolBarTimeOutID){
				clearTimeout(autoHideToolBarTimeOutID)
				autoHideToolBarTimeOutID=0					
			}			
			
			if(autoHideToolBarIntervalID){
				clearInterval(autoHideToolBarIntervalID)
				autoHideToolBarIntervalID=0				
			}		
			this.removeEventListener(MouseEvent.MOUSE_MOVE,ifDisToolBar)
			if(disToolBarIntervalID){
				clearInterval(disToolBarIntervalID)
				disToolBarIntervalID=0				
			}
			if(hideToolBarIntervalID){
				clearInterval(hideToolBarIntervalID)
				hideToolBarIntervalID=0				
			}			
			
			
			swfWidth=swfStage.stageWidth;
			swfHeight=swfStage.stageHeight;
			//重新判断是否全屏
			switch (stage.displayState) {
				case "normal" :					
					toolBar.fullScrBtn.gotoAndStop(1);
					bottomHeight=toolBar.toolBarBack.height
					break;
				case "fullScreen" :					
					toolBar.fullScrBtn.gotoAndStop(2);
					bottomHeight=0
					//5s后自动隐藏工具栏
					autoHideToolBarTimeOutID=setTimeout(autoHideToolBar,3000);
					break;				
			}
			
			
			//trace('swfWidth='+swfWidth);
			toolBar.umiwilink.visible = (swfWidth >= 478);
			toolBar.brightNessBtn.visible = (swfWidth >= 346);
			toolBar.playTime.visible = toolBar.totalTime.visible = toolBar.timeBg.visible = toolBar.timeSlash.visible = (swfWidth >= 310);
			var newVideoHeight:Number=swfHeight-bottomHeight;
			localVideoMC.backOfVideo.width=swfWidth;
			localVideoMC.backOfVideo.height=newVideoHeight;
			
			localVideoMC.backOfVideo.thumbClip.width = localVideoMC.backOfVideo.logo.width;
			localVideoMC.backOfVideo.thumbClip.height = localVideoMC.backOfVideo.logo.height;
			localVideoMC.backOfVideo.thumbClip.x = localVideoMC.backOfVideo.logo.x;
			localVideoMC.backOfVideo.thumbClip.y = localVideoMC.backOfVideo.logo.y;
			
			
			localVideoMC.fullScrBtn.width=swfWidth;
			localVideoMC.fullScrBtn.height=newVideoHeight;		
			var maxVideoWidth:Number=localVideoMC.backOfVideo.width;
			var maxVideoHeight:Number=localVideoMC.backOfVideo.height;

			//调整视频对象的长宽
			localVideoMC.tmpVideo.width=maxVideoWidth;
			localVideoMC.tmpVideo.height=originVideoHeight*(maxVideoWidth/originVideoWidth);

			if (localVideoMC.tmpVideo.height>maxVideoHeight) {
				localVideoMC.tmpVideo.height=maxVideoHeight;
				localVideoMC.tmpVideo.width=originVideoWidth*(maxVideoHeight/originVideoHeight);
			}
			localVideoMC.tmpVideo.x=(localVideoMC.backOfVideo.width-localVideoMC.tmpVideo.width)/2;
			localVideoMC.tmpVideo.y=(localVideoMC.backOfVideo.height-localVideoMC.tmpVideo.height)/2;
			//广告部分
			ad.width = stage.width;
			ad.height = stage.height;
			
			
			toolBar.y=swfHeight-toolBar.height - 3;			
			toolBar.toolBarBack.width=swfWidth;
			toolBar.fullScrBtn.x=toolBar.toolBarBack.width-37;
			toolBar.volumeBar.x=toolBar.fullScrBtn.x-60;
			toolBar.volumeBtn.x=toolBar.volumeBar.x-18.35;
			toolBar.volume_bg_mask.x = toolBar.volumeBtn.x + (toolBar.volumeBtn.width - toolBar.volume_bg_mask.width);
			toolBar.brightNessBtn.x=toolBar.volumeBtn.x-36.15;
			toolBar.cursorBtn.y = toolBar.seekBar.y;
			toolBar.umiwilink.x = toolBar.brightNessBtn.x - 133;
			toolBar.qualityBar.x=(toolBar.toolBarBack.width-toolBar.qualityBar.width)/2;			
			
			//toolBar.totalTime.x=toolBar.toolBarBack.width-71.4;

			//缩放时进度条不可见
			toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=false;
			toolBar.seekBar.width=toolBar.barbg.width=toolBar.playBar.width=toolBar.downLoadBar.width=localVideoMC.backOfVideo.width-20;
			
			bigPlayBtn.x=(localVideoMC.width-bigPlayBtn.width) - 50;
			bigPlayBtn.y=(localVideoMC.height-bigPlayBtn.height) - 37;
			
			


			miniatureMC.x=(localVideoMC.width-miniatureMC.width)/2;
			miniatureMC.y=(localVideoMC.height-miniatureMC.height)/2;
			
            if(swfWidth < 480)
            {
                toolBar.umiwilink.visible = false;
            }	
			
			
		}
		private function toggleFullScreen(event:MouseEvent):void
		{
			updateMsg(stage.displayState);
			
			/*如果是外站，那么弹到umiwi视频页面*/
			if (isOut)
			{
				var d = new Date();
				var m = d.getMonth()+1;
				var year = d.getFullYear();
				var day = d.getDate();
				if ( m < 10) m = '0'+m;
				if ( day < 10) day = '0'+day;
				year = year%100;
				navigateToURL(new URLRequest('http://www.umiwi.com/video/detail'+flvID+'?utm_source=umv&utm_medium=videoshare&utm_content='+flvID+'&utm_campaign='+year+m+day));
				myNS.pause();
				toolBar.playBtn.gotoAndStop(1);	
				bigPlayBtn.visible=true;
				playState="pause";
				return;
			}
			
			
			switch (stage.displayState) {
				case "normal" :
					stage.displayState="fullScreen";
					toolBar.fullScrBtn.gotoAndStop(2);
					break;
				case "fullScreen" :
					stage.displayState="normal";
					toolBar.fullScrBtn.gotoAndStop(1);
					break;
				default :
					stage.displayState="normal";
					toolBar.fullScrBtn.gotoAndStop(1);
			}
		}



		private function prepareNewProcedure() {
			//进度条不可见
			toolBar.cursorBtn.visible=toolBar.seekBar.visible=toolBar.playBar.visible=toolBar.downLoadBar.visible=false;
			//获取文件时间
			lastMetaDataDate=newMetaDataDate;
			if(myNS){
				lastPlayedTime=myNS.time;
			}else{
				lastPlayedTime=0
			}			
			//先获取上次的播放进度
			if(!nowProgress){
				nowProgress=0
			}
			lastProgress=nowProgress;
			toolBar.qualityBar.highQualityBtn.mouseEnabled=false
			toolBar.qualityBar.mediumQualityBtn.mouseEnabled=false
			toolBar.qualityBar.lowQualityBtn.mouseEnabled=false
		}

		private function getHighQualityFLV(...arg) 
		{
			prepareNewProcedure();
			toolBar.qualityBar.mediumQualityBtn.mouseEnabled=true
			toolBar.qualityBar.lowQualityBtn.mouseEnabled=true

			toolBar.qualityBar.highQualityBtn.gotoAndStop(2);
			toolBar.qualityBar.mediumQualityBtn.gotoAndStop(1);
			toolBar.qualityBar.lowQualityBtn.gotoAndStop(1);
			
			//先检验是否需要切换
			//tmpOriginFlvPath=toolBar.qualityBar.highQualityBtn.flvPath;
			originFlvPath=toolBar.qualityBar.highQualityBtn.flvPath;
			//initTmpNC()
			initNC();
		}
		private function getMediumQualityFLV(...arg) 
		{
			if (loadingFLV) return;
			loadingFLV = true;
			updateMsg('getMedium FLV');
			prepareNewProcedure();
			toolBar.qualityBar.highQualityBtn.mouseEnabled=true
			toolBar.qualityBar.lowQualityBtn.mouseEnabled=true
			toolBar.qualityBar.highQualityBtn.gotoAndStop(1);
			toolBar.qualityBar.mediumQualityBtn.gotoAndStop(2);
			toolBar.qualityBar.lowQualityBtn.gotoAndStop(1);

			
			//flvPath = 'kaifu.mp4';
			//toolBar.qualityBar.mediumQualityBtn.flvPath = 'kaifu.mp4';
			//先检验是否需要切换
			//tmpOriginFlvPath=toolBar.qualityBar.mediumQualityBtn.flvPath;
			originFlvPath=toolBar.qualityBar.mediumQualityBtn.flvPath;
			flvPath = originFlvPath;
			//initTmpNC();
			initNC();
			//getTmpStream();
		}
		private function getLowQualityFLV(...arg) {
			prepareNewProcedure();
			toolBar.qualityBar.highQualityBtn.mouseEnabled=true
			toolBar.qualityBar.mediumQualityBtn.mouseEnabled=true
			toolBar.qualityBar.highQualityBtn.gotoAndStop(1);
			toolBar.qualityBar.mediumQualityBtn.gotoAndStop(1);
			toolBar.qualityBar.lowQualityBtn.gotoAndStop(2);

			//先检验是否需要切换
			//tmpOriginFlvPath=toolBar.qualityBar.lowQualityBtn.flvPath;
			originFlvPath=toolBar.qualityBar.lowQualityBtn.flvPath;
			//initTmpNC()
			initNC();
		}
		
		
		


		private function updateMsg(tmpMsg:String) {
			
			//msg.text=tmpMsg;
			try
			{
				ExternalInterface.call("player_console",tmpMsg);
			}
			catch(e:Error){ }
			//msg.alpha = 0;
			
			trace('更新信息:'+tmpMsg);
			
		}




		private function getRecommendFlv() {
			//getflvpath.php?id=1
			var randomNum:Number=int(Math.random()*10000);
			var phpPath:String=iisPath+"/getrecommend.php";
			updateMsg(phpPath);
			var phpRequest:URLRequest=new URLRequest(phpPath);
			phpRequest.method=URLRequestMethod.GET;
			var parameter:URLVariables=new URLVariables  ;
			//这里的ChatID需要传过来
			parameter.randomNum=randomNum;
			parameter.type="vod";
			parameter.id=flvID;
			phpRequest.data=parameter;
			var phpLoader:URLLoader=new URLLoader  ;
			phpLoader.addEventListener(Event.COMPLETE,getRecommendFlvComplete);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR,getRecommendFlvError);
			try {
				phpLoader.load(phpRequest);
				updateMsg("正在获取视频信息");
			} catch (error:Error) {
				updateMsg("获取视频信息失败");
			}
		}
		private function getRecommendFlvComplete(e:Event) {
			updateMsg("获取相关视频信息成功!");
			var myXML:XML=XML(e.target.data);
			var flvCount:Number=myXML.descendants("*").length();


			var recommendFlvListArr:Array=new Array();
			for (var i=0; i<flvCount; i++)
			{
				var tmpThumburl:String=myXML.descendants("*")[i].@thumburl;
				var tmpTitle:String=myXML.descendants("*")[i].@title;
				var tmpLink:String=myXML.descendants("*")[i].@link;
				var tmpDuration:String=myXML.descendants("*")[i].@duration;
				var tmpPlaycount:String=myXML.descendants("*")[i].@playcount;
				recommendFlvListArr.push({thumburl:tmpThumburl,title:tmpTitle,link:tmpLink,duration:tmpDuration,playcount:tmpPlaycount});
			}

			for (i=0; i <recommendFlvListArr.length; i++) 
			{
				loadPic(recommendFlvListArr[i].thumburl,miniatureMC["loader"+(i%4)].childLoader);
				miniatureMC["loader"+(i%3)].title.text=recommendFlvListArr[i].title;
				miniatureMC["loader"+(i%3)].visible=true;
				miniatureMC["loader"+(i%3)].otherMsg.text="时长:"+convertTime(recommendFlvListArr[i].duration)+"   播放:"+recommendFlvListArr[i].playcount;
				miniatureMC["loader"+(i%3)].link = recommendFlvListArr[i].link;
				miniatureMC["loader"+(i%3)].wrapper.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent)
				{
					navigateToURL(new URLRequest(e.currentTarget.parent.link));
				});
			}
		}
		
		/**
		* 载入推荐视频图片
		*/
		private function loadPic(url:String,mc:MovieClip):void
		{
			if (mc.getChildAt(0)!=null)
			{
				mc.removeChildAt(0);
			}
			var loader:Loader=new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(evt:Event)
			{
				if (isUmiwi)
				{
					var img:Bitmap = new Bitmap(evt.target.content.bitmapData);
					img.smoothing = true;
					img.width = 104;
					img.height = 78;
					mc.addChild(img);
				}
				else
				{
					loader.width = 104;
					loader.height = 78;
				}
			});
            try {
                loader.load(new URLRequest(url), new LoaderContext(true));
            } catch (error:Error) {
                updateMsg("Failed to get recommended thumbnail.");
            }
			if (!isUmiwi) mc.addChild(loader);
		}
		
		private function getRecommendFlvError(e:IOErrorEvent) {
			updateMsg("获取推荐视频信息失败...");
		}

		private function httpStatusHandler(e:HTTPStatusEvent):void {
			//updateMsg("加载推荐视频图片失败！HTTP STATUS");	
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		//工具提示
		private function disToolTipMC(e:MouseEvent){						
			switch(e.target.name){
				case "playBtn":				
				if(isPlaying){
					toolBar.toolTipMC.tipTxt.text="暂停"
				}else{
					toolBar.toolTipMC.tipTxt.text="播放"
				}								
				toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
				toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2			
				toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2				
				toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.x=e.target.x+toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.y=e.target.y-toolBar.toolTipMC.height
				toolBar.toolTipMC.visible=true
				break;
				case "stopBtn":				
				toolBar.toolTipMC.tipTxt.text="停止"				
				toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
				toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2			
				toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2				
				toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.x=e.target.x+toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.y=e.target.y-toolBar.toolTipMC.height
				if(playState=="stop"){
					toolBar.toolTipMC.visible=false
				}else{
					toolBar.toolTipMC.visible=true			
				}				
				break;
				case "disAdjustBarBtn":				
				toolBar.toolTipMC.tipTxt.text="亮度调节"
				toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
				toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2			
				toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2				
				toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.x=e.target.parent.x+toolBar.toolTipMC.toolTipBack1.width/2-15
				toolBar.toolTipMC.y=e.target.parent.y-toolBar.toolTipMC.height
				toolBar.toolTipMC.visible=true
				break;
				case "volumeBtn":				
				toolBar.toolTipMC.tipTxt.text="静音"				
				toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
				toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2			
				toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2				
				toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
				toolBar.toolTipMC.x=e.target.x+toolBar.toolTipMC.toolTipBack1.width/2-5
				toolBar.toolTipMC.y=e.target.y-toolBar.toolTipMC.height
				if(hasVolume){
					toolBar.toolTipMC.visible=true
				}else{
					toolBar.toolTipMC.visible=false
				}
				break;
				case "fullScrBtn":
				if(stage.displayState=="fullScreen"){					
					toolBar.toolTipMC.tipTxt.text="退出全屏"
					toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
					toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2	
					toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2	
					toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
					toolBar.toolTipMC.x=e.target.x+toolBar.toolTipMC.toolTipBack1.width/2-15
					toolBar.toolTipMC.y=e.target.y-toolBar.toolTipMC.height
					toolBar.toolTipMC.visible=true
				}else{					
					toolBar.toolTipMC.tipTxt.text="全屏"
					toolBar.toolTipMC.toolTipBack2.width=toolBar.toolTipMC.tipTxt.length*14
					toolBar.toolTipMC.toolTipBack1.width=toolBar.toolTipMC.toolTipBack2.width+2
					toolBar.toolTipMC.toolTipBack2.x=-toolBar.toolTipMC.toolTipBack2.width/2
					toolBar.toolTipMC.toolTipBack1.x=-toolBar.toolTipMC.toolTipBack1.width/2
					toolBar.toolTipMC.x=e.target.x+toolBar.toolTipMC.toolTipBack1.width/2
					toolBar.toolTipMC.y=e.target.y-toolBar.toolTipMC.height
				}			
				toolBar.toolTipMC.visible=true
				break;			
				
			}
			
		}
		
		private function autoHideToolBar(){
			clearTimeout(autoHideToolBarTimeOutID)		
			autoHideToolBarTimeOutID=0			
			updateMsg("开始自动隐藏工具条")
			autoHideToolBarIntervalID=setInterval(autoHideToolBarFun,5)
			
			
		}
		
			
		private function autoHideToolBarFun(){			
			toolBar.y+=(swfHeight-toolBar.y)/5
			if(Math.abs(swfHeight-toolBar.y)<0.5){
				clearInterval(autoHideToolBarIntervalID)
				autoHideToolBarIntervalID=0				
				toolBar.y=swfHeight		
				this.addEventListener(MouseEvent.MOUSE_MOVE,ifDisToolBar)
			}
		}
		//工具条的显示和隐藏仅在全屏状态下有效
		private function ifDisToolBar(...arg){
			if(stage.displayState=="fullScreen"){
				if(this.mouseY>(swfHeight-toolBar.height-50)){
					disToolBar()
					//e.updateAfterEvent()
				}else{
					hideToolBar()
					//e.updateAfterEvent()
				}
			}
			
			
		}
			
			
		private function disToolBar(){			
			if(stage.displayState=="fullScreen"){
				if(!disToolBarIntervalID){					
					disToolBarIntervalID=setInterval(moveToolBarToTop,5)	
				}
				if(hideToolBarIntervalID){
					clearInterval(hideToolBarIntervalID)
					hideToolBarIntervalID=0					
				}			
				
			}
			
			
		}
		
		private function hideToolBar(){
			if(stage.displayState=="fullScreen"){
				if(disToolBarIntervalID){					
					clearInterval(disToolBarIntervalID)
					disToolBarIntervalID=0					
				}
				if(!hideToolBarIntervalID){
					hideToolBarIntervalID=setInterval(moveToolBarToBottom,5)
				}			
				
			}
			
			

		}
		private function moveToolBarToTop(){
			updateMsg("disToolBarIntervalID"+disToolBarIntervalID)
			toolBar.y-=(toolBar.y-(swfHeight-toolBar.height))/5
			if(Math.abs(toolBar.y-(swfHeight-toolBar.height))<0.5){
				clearInterval(disToolBarIntervalID)
				disToolBarIntervalID=0				
				toolBar.y=swfHeight-toolBar.height
			}
			
		}
		
		
		private function moveToolBarToBottom(){
			updateMsg("hideToolBarIntervalID"+hideToolBarIntervalID)
			toolBar.y+=(swfHeight-toolBar.y)/5
			if(Math.abs(swfHeight-toolBar.y)<0.5){
				clearInterval(hideToolBarIntervalID)
				hideToolBarIntervalID=0				
				toolBar.y=swfHeight		
				
			}
		}
			
			
		private function hideToolTipMC(e:MouseEvent){
			toolBar.toolTipMC.visible=false
		}	



		private function centerBufferingMC()
		{
			bufferingMC.x=Math.round((localVideoMC.width-bufferingMC.width)/2);
			bufferingMC.y=Math.round((localVideoMC.height-bufferingMC.height)/1.5);
		}
		
		private function showBuffering()
		{
			fadeIn(bufferingMC,300);
		}
		
		private function hideBuffering()
		{
			fadeOut(bufferingMC,500,centerBufferingMC);
		}
		

		//淡出一个对象, o为对象，time为时间（毫秒）
		private function fadeOut(o:MovieClip,time:uint,callback:Function=null,firstTime:Boolean = true)
		{
			if (firstTime)
			{
				o.visible = true;
				if (o.fading)
				{
					try{clearTimeout(o.fadeTimer);} catch(e:Error){ }
				}
			}
			o.fading = true;
			var _step:Number = 40/time;
			o.alpha-=_step;
			if (o.alpha <= 0)
			{
				o.fading = false;
				o.alpha = 0;
				o.visible = false;
				if (callback != null) callback.call(o);
				return;
			}
			else
			{
				o.fadeTimer = setTimeout(function()
				{
					fadeOut(o,time,callback,false);
				},40);
			}
		}
		
		private function fadeIn(o:Object,time:uint,firstTime:Boolean = true)
		{
			if (firstTime)
			{
				o.visible = true;
				if (o.fading)
				{
					try{clearTimeout(o.fadeTimer);} catch(e:Error){ }
				}
			}
			o.fading = true;
			var _step:Number = 40/time;
			o.alpha+=_step;
			if (o.alpha >= 1)
			{
				o.fading = false;
				o.alpha = 1;
				return;
			}
			else
			{
				o.fadeTimer = setTimeout(function()
				{
					fadeIn(o,time,false);
				},40);
			}
		}
		

	}


}