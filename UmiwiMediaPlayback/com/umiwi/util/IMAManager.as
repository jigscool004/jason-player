package com.umiwi.util
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Timer;

	public class IMAManager
	{
		
		
		private var adsState:String;
		public var adsLoader:Loader;
		private var adsTimer:Timer = new Timer(ADS_TIMEOUT, 1);
		private static const ADS_TIMEOUT:int = 30000;
		private var umiwiMediaPlayback:UmiwiMediaPlayback;
		
		public function IMAManager(playback:Sprite)
		{
			umiwiMediaPlayback = playback as UmiwiMediaPlayback;
			
			adsTimer = new Timer(ADS_TIMEOUT, 1);
			adsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAdsLoadTimeout);
		}
		
		
		public function go(target:MovieClip = null):void { 
			Security.allowDomain("pagead2.googlesyndication.com"); 
			
			// Prepare to load Google SWF 
			var request:URLRequest = new URLRequest("http://pagead2.googlesyndication.com/" +  
				"pagead/scache/googlevideoadslibraryas3.swf"); 
			var loader:Loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, sendAdRequest); 
			
			// load Google SWF 
			loader.load(request); 

			umiwiMediaPlayback.addAdsContainer(loader); 
			UConfigurationLoader.updateMsg("Add ads loader to player");
			
			adsLoader = loader;
			adsTimer.start();
			adsState == null
		} 
		
		private function sendAdRequest(event:Event) { 
			var googleAds:Object = event.target.content; 
			
			// Create request params object 
			var request:Object = new Object(); 
			request.videoId = ControlUtil.configuration.flvID; 
			request.videoPublisherId = "ca-video-afvtest"; 
			//request.videoPublisherId = "ca-video-pub-8477572604480528"; 
			request.videoFlvUrl = ControlUtil.configuration.src; 
			//request.videoDescriptionUrl = "http://chuangye.umiwi.com/2011/0714/15892.shtml";
			request.videoDescriptionUrl = ControlUtil.configuration.descriptionUrl;
			request.channels = ["1234567890", "9876543210"]; // Must be an array of strings 
			request.pubWidth = umiwiMediaPlayback.mediaContainer.width; 
			request.pubHeight = umiwiMediaPlayback.mediaContainer.height; 
			//request.adType = "fullscreen"; 
			request.adType = "graphical_fullscreen";
			
			request.adTimePosition = 0;
			request.maxTotalAdDuration = 15000;
			
			// Fetch an ad, specify callback method 
			googleAds.requestAds(request, onAdsRequestResult); 
			UConfigurationLoader.updateMsg("Start to request ads");
		} 
		
		private function onAdsRequestResult(callbackObj:Object):void { 
			trace("onAdsRequestResult: callbackObj.success = " + callbackObj.success);     
			if (callbackObj.success) { 
				var player:MovieClip = callbackObj.ads[0].getAdPlayerMovieClip(); 
				player.setSize(umiwiMediaPlayback.mediaContainer.width,  umiwiMediaPlayback.mediaContainer.height); 
				player.setX(0); 
				player.setY(0); 
				player.load(); 
				player.playAds();  
				
				player.resumeContentVideo = delegate(this, resumeStream); 
				player.onStateChange = delegate(this, adsStateChange);
				
			} 
			else { 
				UConfigurationLoader.updateMsg("Error: " + callbackObj.errorMsg); 
			} 
		}
		
		public function resumeStream():void {  
			umiwiMediaPlayback.stopPlayerQuietly();
			umiwiMediaPlayback.enablePlayControl();
			umiwiMediaPlayback.player.play();
			UConfigurationLoader.updateMsg("Google Ad over, play video.");
		} 
		
		public var initAdsBuffer:Boolean = false;
		public function adsStateChange(oldState:String, newState:String):void {
			adsState = newState;
			if (newState == "completed") { 
				//enableToolBar(true);
				/*				toolBar.mouseChildren = true;
				bigPlayBtn.mouseEnabled = true;
				player.play();
				//loadMedia();
				UConfigurationLoader.updateMsg("Google Ad over, play video.");*/
				adsTimer.reset();
			} 
			if (newState == "buffering" || oldState == "buffering")
			{
				initAdsBuffer = true;
				umiwiMediaPlayback.startPlayerQuietly();
			}
		} 
		
		private function onAdsLoadTimeout(event:TimerEvent):void
		{
			adsTimer.reset();
			if(adsState == null || adsState == "buffering")
			{
				if(adsLoader)
				{
					try
					{
						umiwiMediaPlayback.removeChild(adsLoader);
					}
					catch (error:Error){
						UConfigurationLoader.updateMsg("Remove ads failed: " + error.message);
					}
					resumeStream();
					UConfigurationLoader.updateMsg("Google Ad load content timeout (30s), play video.");
				}
			}
			
		}
		
		// Helper function 
		public static function delegate(scope:Object, handler:Function):Function { 
			var fn:Function = function() { 
				return handler.apply(scope, arguments); 
			} 
			return fn; 
		} 
	}
}