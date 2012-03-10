package com.umiwi.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	

	public class UConfigurationLoader
	{
		
		private static const GET_VIDEO_URL:String = "http://api.v.umiwi.com/getvideoinfo.do";
		private static const IIS_PATH:String = "http://api.v.umiwi.com/recommendvideo.do"
		private static const GET_LIB_URL:String = "OSMF/library.swf";
		private static const DEFAULT_FLV_ID:String = "m154";
        
        private static const TEST_URL:String = "http://api.v.umiwi.com/getvideoinfo.do?videoid=5759"
		
		public static var isOut:Boolean;
		public static var firstBufferCompleted:Boolean = false;
		
		public function UConfigurationLoader()
		{			
		}
		
		private var _callback:Function;
		private var _parameters:Object;
		
		public function getFlvInfo(parameters:Object, cback:Function):void
		{
			_parameters = parameters;
			_callback = cback;
			if(!_parameters.flvID) 
			{
				_parameters.flvID=DEFAULT_FLV_ID;
			}
			//http://www.umiwi.com/player/vod/getflvpath.php?id=6509&randomNum=4897
			var randomNum:Number=int(Math.random()*10000);
			var getVideoRequest:URLRequest=new URLRequest(GET_VIDEO_URL);
			getVideoRequest.method=URLRequestMethod.GET;
			var parameter:URLVariables=new URLVariables;
			parameter.videoid=parameters["flvID"];
			getVideoRequest.data=parameter;
            //var phpRequest:URLRequest=new URLRequest(TEST_URL);
            //getVideoRequest.method=URLRequestMethod.GET;
			var phpLoader:URLLoader=new URLLoader  ;
			phpLoader.addEventListener(Event.COMPLETE,getFlvInfoComplete);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR,getFlvInfoError);
			try {
				phpLoader.load(getVideoRequest);
				//logger.info("正在获取视频信息");
			} catch (error:Error) {
				updateMsg("Failed to get info against FlvId.");
			}
		}
		private function getFlvInfoComplete(e:Event):void
		{
			//updateMsg("Get info against FlvId successfully.");
			
			var info:XML = new XML(e.target.data);
			var item:XML = info..item[0];
			if(_parameters.src == null || _parameters.src == "")
			{
				_parameters.src = item.@url.toString();
			}
			_parameters.poster = item.@thumb.toString();
            parseSource(_parameters.src);
            getIcon(info);
            getBooleanContent(info, "isMember");
            getBooleanContent(info, "hasMBR");
            getDomain(info);
            getXMLStringContent(info, "htmlURL");
            getXMLStringContent(info, "flashURL");
            getXMLStringContent(info, "videoURL");
            getXMLStringContent(info, "title");
            getXMLStringContent(info, "intro");
            getAlbum(info);
			_callback.call(null, _parameters);
			
		}
        
        /*
        
        http://vod2.umiwi.com/vod1/free/2012/02/20/695f0039095e7c45553fc87de2d89275.ssm/695f0039095e7c45553fc87de2d89275.f4m
        域名是vod2.umiwi.com
        文件名是vod1/free/2012/02/20/695f0039095e7c45553fc87de2d89275.ssm
        调用方式应该是
        http://58.68.129.69/API/getjpgAPI.php?vhost=vod2.umiwi.com&fileName=vod1/free/2012/02/20/695f0039095e7c45553fc87de2d89275.ssm
            &startTime=10&picWidth=320&picHeight=300&picName=picturename.jpg
        
        
        rtmp://r1.vod.umiwi.com/xueyuan/vip/2012/02/22/88334b79a7e767f75e8ee594bc588617.mp4?token=abcdefghijklm
        域名是r1.vod.umiwi.com
        文件名是xueyuan/vip/2012/02/22/88334b79a7e767f75e8ee594bc588617.mp4
        调用方式应该是
        http://58.68.129.69/API/getjpgAPI.php?vhost=r1.vod.umiwi.com&fileName=xueyuan/vip/2012/02/22/88334b79a7e767f75e8ee594bc588617.mp4
            &startTime=10&picWidth=320&picHeight=300&picName=picturename.jpg
        
        */
        private function parseSource(src:String):void
        {
            var isHttp:Boolean = (src.indexOf("http") == 0);
            var doubleSlash:int = src.indexOf("//");
            var srcContent:String = src.substr(doubleSlash + 2);
            var fistSlash:int = srcContent.indexOf("/");
            var lastSlash:int = srcContent.lastIndexOf("/");
            Constants.configuration.hostName = srcContent.substring(0, fistSlash);
            updateMsg("host name is " + Constants.configuration.hostName);
            
            var fileName:String
            if(isHttp)
            {
                var src1:String = srcContent.substring(fistSlash + 1, lastSlash - 1);
                var lastDot:int = src1.lastIndexOf(".");
                fileName = src1.substring(0, lastDot);
                fileName += ".mp4";
            }
            //RTMP
            else
            {
                fileName = srcContent.substring(fistSlash + 1);
                
                if(_parameters.token)
                {
                    _parameters.src += "?token=" + _parameters.token;
                }
                updateMsg("RTMP URL is " + _parameters.src);
            }
            
            Constants.configuration.fileName = fileName;
            updateMsg("file name is " + fileName);
        }
        
        private function getIcon(info:XML):void
        {
            var item:XML = info.icon[0];
            var param:Object = {};
            if(item != null)
            {
                for each(var a:XML in item.attributes())
                {
                    var attributeName:String = a.name();
                    param[attributeName] = item.attribute(attributeName).toString();
                }
                Constants.configuration.logo = param;
            }
        }
        
        private function getBooleanContent(info:XML, xpath:String):void
        {
            var item:XML = info.isMember[0];
            if(item != null)
            {
                var booleanString = item.toString();
                if(booleanString == "true")
                {
                    Constants.configuration[xpath] = true;
                }
            }
        }
        
        private function getDomain(info:XML):void
        {
            var items:XMLList = info.domain.item;
            var params:Array = [];
            if(items != null && items.length()>0)
            {
                for each(var item:XML in items)
                {
                    params.push(item.toString());
                }
                Constants.configuration.domains = params;
            }
        }
        
        private function getXMLStringContent(info:XML, xpath:String):void
        {
            var item:XML = info.elements(xpath)[0];
            if(item != null)
            {
                Constants.configuration[xpath] = item.toString();
            }
        }
        
        private function getAlbum(info:XML):void
        {
            var items:XMLList = info.album.item;
            if(items != null && items.length()>0)
            {
                var item:XML;
                var obj:Object
                for each(item in items)
                {
                    obj = {label:item.@title.toString(), link:item.@link.toString()};
                    Constants.configuration.albumDataProvider.addItem(obj);
                }
            }
        }
        
		private function getFlvInfoError(e:IOErrorEvent):void
		{
			updateMsg("Failed to get info against FlvId.");
		}
		
		public function getRecommendFlv(parameters:Object, cback:Function) {
			_parameters = parameters;
			_callback = cback;
			if(!_parameters.flvID) 
			{
				_parameters.flvID=DEFAULT_FLV_ID;
			}
			
			
			var randomNum:Number=int(Math.random()*10000);
			//updateMsg(phpPath);
			var phpRequest:URLRequest=new URLRequest(IIS_PATH);
			phpRequest.method=URLRequestMethod.GET;
			var parameter:URLVariables=new URLVariables  ;
			//这里的ChatID需要传过来
			parameter.videoid=_parameters.flvID;
            parameter.max=4;
			phpRequest.data=parameter;
			var phpLoader:URLLoader=new URLLoader  ;
			phpLoader.addEventListener(Event.COMPLETE,getRecommendFlvComplete);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR,getRecommendFlvError);
			try {
				phpLoader.load(phpRequest);
				updateMsg("Getting recommended video.");
			} catch (error:Error) {
				updateMsg("Failed to get recommended video.");
			}
		}
		private function getRecommendFlvComplete(e:Event) {
			updateMsg("Get recommended video successfully.");
            try
            {
                var info:XML = new XML(e.target.data);
                _callback.call(null, info);
            }
            catch(error:Error)
            {
                updateMsg(error.message);
            }

		}
		
		private function getRecommendFlvError(e:IOErrorEvent):void
		{
			updateMsg("Failed to get recommended video.");
		}
        
		private var myURLLoader:URLLoader;
		public function getLibrary(cback:Function):void
		{
			_callback = cback;
			var myURLReq:URLRequest = new URLRequest();
			myURLReq.url = "osmf_1.0.0.16316.swz";
			//myURLReq.digest = "3B0AA28C7A990385E044D80F5637FB036317BB41E044D80F5637FB036317BB41";
			myURLLoader = new URLLoader();
			myURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			myURLLoader.addEventListener("complete", getLibComplete);

			try {
				myURLLoader.load(myURLReq);
				updateMsg("Getting osmf swz.");
			} catch (error:Error) {
				//logger.error("获取视频信息失败");
			}
		}
		private function getLibComplete(e:Event):void
		{
			updateMsg("Get osmf swz successfully.");
				var someLoader:Loader = new Loader();
				//addChild(someLoader);
				someLoader.loadBytes((ByteArray)(myURLLoader.data)); 
				someLoader.contentLoaderInfo.addEventListener(Event.INIT, onFinalLoaded);

			
		}
		
		private function onFinalLoaded(e:Event):void{
			_callback.call(null);
		}
		private function getLibError(e:IOErrorEvent):void
		{
			updateMsg("Failed to get osmf swz.");
		}
		
		public static function traceChildren(containter:DisplayObjectContainer, depth:String = ""):void{
			for (var i:uint = 0; i < containter.numChildren; i++){
				var obj:Object = containter.getChildAt(i);
				trace(depth + obj.toString());
				if(obj is DisplayObjectContainer) {
					traceChildren(obj as DisplayObjectContainer, depth + "    ");
				}
			}
		}
		
		public static function updateMsg(message:String) {
			trace (message);
			if (ExternalInterface.available && !Constants.configuration.out)
			{
				try{
					// Create Javascript function to call the Firebug console log method and append the message.
					message = "function(){if (window.console) console.log('" + message;
					// Close the Firebug console log method and the Javascript function.
					message +=  "');}";
					// Request running the function.
					ExternalInterface.call(message);
				}
				catch(_:Error)
				{
					trace(_.toString());
				}
			}
		}
		
		public static function callExternal(message:String) {
			trace (message);
			if (ExternalInterface.available && !Constants.configuration.out)
			{
				try{
					ExternalInterface.call(message);
				}
				catch(_:Error)
				{
					trace(_.toString());
				}
			}
		}
		
        public static function saveConfig(id:String, content:Object):void
        {
            var mySo:SharedObject = SharedObject.getLocal("umiwi");
            mySo.data[id] = content;
        }
        
        public static function loadConfig(id:String):Object
        {
            var content:Object;
            var mySo:SharedObject = SharedObject.getLocal("umiwi");
            if(mySo)
            {
                content = mySo.data[id];
            }
            return content;
        }
	}
}