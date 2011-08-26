package com.umiwi.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	

	public class UConfigurationLoader
	{
		
		private static const GET_PATH_URL:String = "http://www.umiwi.com/player/vod/getflvpath.php";
		private static const IIS_PATH:String = "http://www.umiwi.com/player/getrecommend.php"
		private static const GET_LIB_URL:String = "OSMF/library.swf";
		private static const DEFAULT_FLV_ID:String = "5759";
		
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
			var phpRequest:URLRequest=new URLRequest(GET_PATH_URL);
			phpRequest.method=URLRequestMethod.GET;
			var parameter:URLVariables=new URLVariables;
			parameter.randomNum=randomNum;
			parameter.id=parameters["flvID"];
			phpRequest.data=parameter;
			var phpLoader:URLLoader=new URLLoader  ;
			phpLoader.addEventListener(Event.COMPLETE,getFlvInfoComplete);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR,getFlvInfoError);
			try {
				phpLoader.load(phpRequest);
				//logger.info("正在获取视频信息");
			} catch (error:Error) {
				updateMsg("Failed to get info against FlvId.");
			}
		}
		private function getFlvInfoComplete(e:Event):void
		{
			updateMsg("Get info against FlvId successfully.");
			
			var info:XML = new XML(e.target.data);
			var item:XML = info..item[0];
			if(_parameters.src == null || _parameters.src == "")
			{
				_parameters.src = item.@url.toString();
			}
			_parameters.poster = item.@thumb.toString();
			_callback.call(null, _parameters);
			
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
			parameter.randomNum=randomNum;
			parameter.type="vod";
			parameter.id=_parameters.flvID;
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
			var info:XML = new XML(e.target.data);
			_callback.call(null, info);
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
			if (ExternalInterface.available && !ControlUtil.configuration.out)
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
			if (ExternalInterface.available && !ControlUtil.configuration.out)
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
		
	}
}