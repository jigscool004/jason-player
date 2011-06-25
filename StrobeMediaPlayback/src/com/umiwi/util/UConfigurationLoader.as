package com.umiwi.util
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	

	CONFIG::LOGGING
	{
		import org.osmf.player.debug.LogHandler;
		import org.osmf.player.debug.StrobeLoggerFactory;
		import org.osmf.logging.Log;
		import org.osmf.player.debug.StrobeLogger;
	}

	public class UConfigurationLoader
	{
		
		private static const GET_PATH_URL:String = "http://www.umiwi.com/player/vod/getflvpath.php";
		
		CONFIG::LOGGING
		{
			protected var logger:StrobeLogger = Log.getLogger("UConfigurationLoader") as StrobeLogger;
		}
		
		public function UConfigurationLoader()
		{
			Log
			CONFIG::LOGGING
			{
				// Setup the custom logging factory 
				Log.loggerFactory = new StrobeLoggerFactory(new LogHandler(false));
				logger = Log.getLogger("UConfigurationLoader") as StrobeLogger;
			}			
		}
		
		private var _callback:Function;
		private var _parameters:Object;
		
		public function getFlvInfo(parameters:Object, cback:Function):void
		{
			_parameters = parameters;
			_callback = cback
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
				logger.info("正在获取视频信息");
			} catch (error:Error) {
				logger.error("获取视频信息失败");
			}
		}
		private function getFlvInfoComplete(e:Event):void
		{
			logger.info("获取视频信息成功!");
			var info:XML = new XML(e.target.data);
			var item:XML = info..item[0];
			_parameters.src = item.@url.toString();
			_parameters.poster = item.@thumb.toString();
			_callback.call(null, _parameters);
			
		}
		private function getFlvInfoError(e:IOErrorEvent):void
		{
			logger.error("获取视频信息失败");
		}
		
	}
}