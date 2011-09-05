package com.umiwi.util
{
	import com.google.ads.instream.api.Ad;
	import com.google.ads.instream.api.AdErrorEvent;
	import com.google.ads.instream.api.AdEvent;
	import com.google.ads.instream.api.AdLoadedEvent;
	import com.google.ads.instream.api.AdSizeChangedEvent;
	import com.google.ads.instream.api.AdTypes;
	import com.google.ads.instream.api.AdsLoadedEvent;
	import com.google.ads.instream.api.AdsLoader;
	import com.google.ads.instream.api.AdsManager;
	import com.google.ads.instream.api.AdsManagerTypes;
	import com.google.ads.instream.api.AdsRequest;
	import com.google.ads.instream.api.AdsRequestType;
	import com.google.ads.instream.api.FlashAdCustomEvent;
	import com.google.ads.instream.api.FlashAdsManager;
	import com.google.ads.instream.api.VastVideoAd;
	import com.google.ads.instream.api.VideoAd;
	import com.google.ads.instream.api.VideoAdsManager;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	public class IMAManager
	{
		
		
		private var adsState:String;
		public var adsLoader:AdsLoader;
        private var adsManager:AdsManager;
		private var adsTimer:Timer = new Timer(ADS_TIMEOUT, 1);
		private static const ADS_TIMEOUT:int = 30000;
		private var umiwiMediaPlayback:UmiwiMediaPlayback;
        
        private var video:Video;
        private var clickMovieClip:MovieClip;
		
		public function IMAManager(playback:Sprite)
		{
			umiwiMediaPlayback = playback as UmiwiMediaPlayback;
			
			adsTimer = new Timer(ADS_TIMEOUT, 1);
			adsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAdsLoadTimeout);
		}
		
		
		public function loadAd(target:MovieClip = null):void { 
			
            Security.allowDomain("googleads.g.doubleclick.net");
            Security.allowDomain("*.googlesyndication.com"); 
            
			if (!adsLoader) {
				adsLoader = new AdsLoader();
				umiwiMediaPlayback.addAdsContainer(adsLoader as DisplayObject); 
				adsLoader.addEventListener(AdsLoadedEvent.ADS_LOADED, onAdsLoaded);
				adsLoader.addEventListener(AdErrorEvent.AD_ERROR, onAdError);
			}
			adsLoader.requestAds(createAdsRequest());
			adsTimer.start();
			adsState == null;
            UConfigurationLoader.updateMsg("Ad requested");
			
		} 
		
		
		/**
		 * This method is used to create the AdsRequest object which is used by the
		 * AdsLoader to request ads.
		 */
		private function createAdsRequest():AdsRequest {
			var request:AdsRequest = new AdsRequest();
			request.adSlotWidth = umiwiMediaPlayback.mediaContainer.width;
			request.adSlotHeight = umiwiMediaPlayback.mediaContainer.height - 20;
			//request.adType = AdsRequestType.VIDEO;
            //request.adType = getAdsTypeRandomly();
            request.adTimePosition = 0;
           // request.adType = "video_fullscreen"
			request.adType = AdsRequestType.GRAPHICAL_FULL_SLOT;
			request.channels = ["angela"];
			request.contentId = "123";
			request.publisherId = "ca-video-googletest1";
            //request.publisherId = "ca-video-afvtest"; 
            //request.publisherId = "ca-video-pub-8477572604480528"; 
            //request.maxTotalAdDuration = 30;
			// Checks the companion type from flashVars to decides whether to use GUT
			// or getCompanionAds() to load companions.
			request.disableCompanionAds = true;
			return request;
		}
        
        private function getAdsTypeRandomly():String
        {
            var i:Number = Math.random();
            var type:String
            if(i < 0.5)
            {
                type = AdsRequestType.VIDEO;
            }
            else
            {
                type = AdsRequestType.GRAPHICAL_FULL_SLOT;
            }
            return type;
        }
        
        
        
        /**
         * This method is invoked when the adsLoader has completed loading an ad
         * using the adsRequest object provided.
         */
        private function onAdsLoaded(adsLoadedEvent:AdsLoadedEvent):void {
            UConfigurationLoader.updateMsg("Ads Loaded");
            adsManager = adsLoadedEvent.adsManager;
            adsManager.addEventListener(AdErrorEvent.AD_ERROR, onAdError);
            adsManager.addEventListener(AdEvent.CONTENT_PAUSE_REQUESTED,
                onContentPauseRequested);
            adsManager.addEventListener(AdEvent.CONTENT_RESUME_REQUESTED,
                onContentResumeRequested);
            adsManager.addEventListener(AdLoadedEvent.LOADED, onAdLoaded);
            adsManager.addEventListener(AdEvent.STARTED, onAdStarted);
            adsManager.addEventListener(AdEvent.CLICK, onAdClicked);
            //jason
            adsManager.addEventListener(AdEvent.USER_CLOSE, onAdClosed);
            
            //resetPlayerState();
            //displayAdsInformation(adsManager);
            
            if (adsManager.type == AdsManagerTypes.FLASH) {
                var flashAdsManager:FlashAdsManager = adsManager as FlashAdsManager;
                //jason		
                //flashAdsManager.decoratedAd = false;
                flashAdsManager.y = 20;
                flashAdsManager.addEventListener(AdSizeChangedEvent.SIZE_CHANGED,
                    onFlashAdSizeChanged);
                flashAdsManager.addEventListener(FlashAdCustomEvent.CUSTOM_EVENT,
                    onFlashAdCustomEvent);
                
/*                // For some reason calling video.localToGlobal(point) produced an
                // incorrect location.
                var point:Point = new Point(video.x, video.y);
                log("Setting x, y co-ordinates for the Flash ad slot to (" + point.x +
                    ", " + point.y + ").");
                flashAdsManager.x = point.x;
                flashAdsManager.y = point.y;
                
                log("Calling load, then play");*/
                flashAdsManager.load();
                flashAdsManager.play();
            } else if (adsManager.type == AdsManagerTypes.VIDEO) {
                var videoAdsManager:VideoAdsManager = adsManager as VideoAdsManager;
/*                videoAdsManager.addEventListener(AdEvent.STOPPED,
                    onVideoAdStopped);
                videoAdsManager.addEventListener(AdEvent.PAUSED,
                    onVideoAdPaused);*/
                videoAdsManager.addEventListener(AdEvent.COMPLETE,
                    onVideoAdComplete);
                videoAdsManager.addEventListener(AdEvent.MIDPOINT,
                    onVideoAdMidpoint);
                videoAdsManager.addEventListener(AdEvent.FIRST_QUARTILE,
                    onVideoAdFirstQuartile);
                videoAdsManager.addEventListener(AdEvent.THIRD_QUARTILE,
                    onVideoAdThirdQuartile);
                videoAdsManager.addEventListener(AdEvent.RESTARTED,
                    onVideoAdRestarted);
                videoAdsManager.addEventListener(AdEvent.VOLUME_MUTED,
                    onVideoAdVolumeMuted);
                
/*                if(umiwiMediaPlayback.media.hasTrait(MediaTraitType.DISPLAY_OBJECT))
                {
                    var dot:DisplayObjectTrait = umiwiMediaPlayback.media.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                    var video:Video = dot.displayObject as Video;
                    if(video)
                    {
                        videoAdsManager.load(video);
                        videoAdsManager.play(video);
                    }
                }*/ 
                
                video = new Video(umiwiMediaPlayback.mediaContainer.width, umiwiMediaPlayback.mediaContainer.height);
                umiwiMediaPlayback.addChild(video);

                
                //clickMovieClip = new MovieClip();
                //clickMovieClip.mouseEnabled = true;
                umiwiMediaPlayback.clickMovieClip.width = umiwiMediaPlayback.mediaContainer.width;
                umiwiMediaPlayback.clickMovieClip.height = umiwiMediaPlayback.mediaContainer.height;
                (umiwiMediaPlayback.clickMovieClip as MovieClip).mouseEnabled = true;
                //umiwiMediaPlayback.addChild(clickMovieClip);
                videoAdsManager.clickTrackingElement = umiwiMediaPlayback.clickMovieClip;
                
                videoAdsManager.load(video);
                videoAdsManager.play(video);

            } 
        }
        
        private var labelTimer:Timer = new Timer(1000);
        private var timeLabel:Sprite = new Sprite();
        private var timeLeft:int = 15;
        private var timeLabelAdded:Boolean = false;
        private function addTimeLabel():void
        {
            if(timeLabelAdded)
            {
                umiwiMediaPlayback.setChildIndex(timeLabel, umiwiMediaPlayback.numChildren - 1);
            }
            else
            {
                MyDrawUtil.drawTimeLeftLabel(timeLabel);
                timeLabel.x = (umiwiMediaPlayback.mediaContainer.width - timeLabel.width) * 0.5;
                timeLabel.y = 0;
                umiwiMediaPlayback.addChild(timeLabel);
                labelTimer.start();
                labelTimer.addEventListener(TimerEvent.TIMER, updateTime);
                
                timeLabelAdded = true;
            }

        }
        
        private function updateTime(event:TimerEvent):void
        {
            var ads:Array = adsManager.ads;
            var time:int;
            if (ads) {
                for each (var ad:Ad in ads) {
                    try {
                        if (ad.type == AdTypes.VAST) {
                            var vastAd:VastVideoAd = ad as VastVideoAd;
                            time = vastAd.duration - vastAd.currentTime;
                        } 
                        else if (ad.type == AdTypes.VIDEO)
                        {
                            var videoAd:VideoAd = ad as VideoAd;
                            time = videoAd.duration - videoAd.currentTime;
                        }
                        else
                        {
                            timeLeft --;
                            time = timeLeft;
                            
                            this.addTimeLabel();
                            
                            if(time == 0)
                            {
                                this.unloadAd();
                            }
                        }
                    }
                    catch(e:Error)
                    {
                        
                    }
                }
            }
            if(time == 10)
            {
                UConfigurationLoader.traceChildren(umiwiMediaPlayback);
            }
            MyDrawUtil.setTime(timeLabel,time);
        }
        
        private function removeTimeLabel():void
        {
            labelTimer.stop();
            labelTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, updateTime);
            umiwiMediaPlayback.removeChild(timeLabel);
        }

        /**
         * This method is invoked when an interactive flash ad raises the
         * contentPauseRequested event.
         *
         * We recommend that publishers pause their video content when this method
         * is invoked. This is usually because the ad will play within the video
         * player itself or cover the video player so that the publisher content
         * would not be easily visible.
         */
        private function onContentPauseRequested(event:AdEvent):void {
            initAdsBuffer = true;
            umiwiMediaPlayback.startPlayerQuietly();
            
            addTimeLabel();
        }
        
        /**
         * This method is invoked when an interactive flash ad raises the
         * contentResumeRequested event.
         *
         * We recommend that publishers resume their video content when this method
         * is invoked. This is because the ad has completed playing and the
         * publisher content should be resumed from the time it was paused.
         */
        private function onContentResumeRequested(event:AdEvent):void {
            resumeStream()
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
        
        
        
        
        private function onAdStarted(event:AdEvent):void {
            logEvent(event.type);

        }
        
        private function onAdClicked(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onAdClosed(event:AdEvent):void {
            logEvent(event.type);
            resumeStream();
            adsTimer.reset();
            unloadAd();
        }
        
        private function onAdLoaded(event:AdLoadedEvent):void{
            logEvent(event.type);
            if (event.netStream) {
                //currentNetStream = event.netStream;
            }
        }
        
        private function onFlashAdSizeChanged(event:AdSizeChangedEvent):void {
            logEvent(event.type);
        }
        
        private function onFlashAdCustomEvent(event:FlashAdCustomEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdStopped(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdPaused(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdMidpoint(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdFirstQuartile(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdThirdQuartile(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdClicked(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdRestarted(event:AdEvent):void {
            logEvent(event.type);
        }
        
        private function onVideoAdVolumeMuted(event:AdEvent):void {
            logEvent(event.type);
        }
        
        /**
         * This method is invoked when the video ad loaded using the Google
         * In-Stream SDK has completed playing.
         */
        private function onVideoAdComplete(event:AdEvent):void {
            logEvent(event.type);
            removeListeners();
            
            
            if(video)
            {
                umiwiMediaPlayback.removeChild(video);
                video = null;
            }
            
            if(umiwiMediaPlayback.clickMovieClip)
            {
                umiwiMediaPlayback.removeChild(umiwiMediaPlayback.clickMovieClip);
            }
            
            // Remove clickTrackingElement before playing content or a different ad.
            if (adsManager.type == AdsManagerTypes.VIDEO) {
                (adsManager as VideoAdsManager).clickTrackingElement = null;
            }
            adsTimer.reset();
            this.unloadAd();
        }
        
        function metaDataHandler(infoObject:Object):void {
            //log("content metadata");
        }
        
        private function onAdError(adErrorEvent:AdErrorEvent):void {
            UConfigurationLoader.updateMsg("Ad error: " + adErrorEvent.error.errorMessage);
        }
        
        
        private function removeListeners():void {
            adsManager.removeEventListener(AdLoadedEvent.LOADED, onAdLoaded);
            adsManager.removeEventListener(AdEvent.STARTED, onAdStarted);
            
            if (adsManager.type == AdsManagerTypes.VIDEO) {
                var videoAdsManager:VideoAdsManager = adsManager as VideoAdsManager;
                videoAdsManager.removeEventListener(AdEvent.STOPPED,
                    onVideoAdStopped);
                videoAdsManager.removeEventListener(AdEvent.PAUSED,
                    onVideoAdPaused);
                videoAdsManager.removeEventListener(AdEvent.COMPLETE,
                    onVideoAdComplete);
                videoAdsManager.removeEventListener(AdEvent.MIDPOINT,
                    onVideoAdMidpoint);
                videoAdsManager.removeEventListener(AdEvent.FIRST_QUARTILE,
                    onVideoAdFirstQuartile);
                videoAdsManager.removeEventListener(AdEvent.THIRD_QUARTILE,
                    onVideoAdThirdQuartile);
                videoAdsManager.removeEventListener(AdEvent.RESTARTED,
                    onVideoAdRestarted);
                videoAdsManager.removeEventListener(AdEvent.VOLUME_MUTED,
                    onVideoAdVolumeMuted);
            } else if (adsManager.type == AdsManagerTypes.FLASH) {
                var flashAdsManager:FlashAdsManager = adsManager as FlashAdsManager;
                flashAdsManager.removeEventListener(
                    AdSizeChangedEvent.SIZE_CHANGED, onFlashAdSizeChanged);
                flashAdsManager.removeEventListener(
                    FlashAdCustomEvent.CUSTOM_EVENT, onFlashAdCustomEvent);
            }
        }
        
        private function removeAdsManagerListeners():void {
            adsManager.removeEventListener(AdErrorEvent.AD_ERROR, onAdError);
            adsManager.removeEventListener(AdEvent.CONTENT_PAUSE_REQUESTED,
                onContentPauseRequested);
            adsManager.removeEventListener(AdEvent.CONTENT_RESUME_REQUESTED,
                onContentResumeRequested);
            adsManager.removeEventListener(AdEvent.CLICK, onAdClicked);
            adsManager.removeEventListener(AdEvent.USER_CLOSE, onAdClosed);
        }
        
        private function unloadAd():void {
            removeTimeLabel();
            try {
                if (adsManager) {
                    removeListeners();
                    removeAdsManagerListeners();
                    adsManager.unload();
                    adsManager = null;
                }

            } catch (e:Error) {
                UConfigurationLoader.updateMsg("Error occured during unload : " + e.message);
            }
            this.resumeStream();
        }

        
		
        private function logEvent(str:String):void
        {
            
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