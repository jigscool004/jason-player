package com.umiwi.util
{
	import fl.controls.TextArea;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.player.configuration.PlayerConfiguration;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class ControlUtil extends Object
	{
		protected var traitType:String = MediaTraitType.PLAY;
		protected var traitInstance:MediaTraitBase;
		
		protected var _media:MediaElement;
		
		protected var playback:UmiwiMediaPlayback;
		
		public static var configuration:PlayerConfiguration;
		public static var playStatus:String;
        
        public static var playTime:Number;
        public static var totalTime:Number;
		
		public function ControlUtil(pb:UmiwiMediaPlayback)
		{
			super();
			playback = pb;
			playback.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
            if(event.target is TextField)
            {
                return;
            }
			if(event.keyCode == Keyboard.SPACE && traitInstance)
			{
				var playTrait = traitInstance as PlayTrait;
				if(playTrait.playState == PlayState.STOPPED || playTrait.playState == PlayState.PAUSED)
				{
					playTrait.play();
				}
				else{
					playTrait.pause();
				}
			}
		}
		
		public function setElement(element:MediaElement):void{
			_media = element
			if(element.hasTrait(traitType))
			{
				traitInstance = element.getTrait(traitType);
				addElement();
			}
			else
			{
				removeElement();
				traitInstance = null;
			}
		}
		
		protected function addElement():void{
			(traitInstance as PlayTrait).addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
		}
		
		protected function removeElement():void{
			if (traitInstance == null)
			{
				return;
			}
			(traitInstance as PlayTrait).removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			playStatus = (traitInstance as PlayTrait).playState;
            
            var timeOffset:Number =  ControlUtil.totalTime - ControlUtil.playTime;
            if(playStatus == PlayState.STOPPED)
            {
                UConfigurationLoader.updateMsg("Video " + timeOffset + " seconds left.");
                //if(timeOffset < 5)
                //{   
                    if(ControlUtil.configuration.albumDataProvider.length > 0)
                    {
                        playNext();
                    }
                //}
            }
		}
		
		public function get media():MediaElement
		{
			return _media;
		}
        
        public static function captureURL(currentTime:Number):URLRequest
        {
            var captureRequest:URLRequest=new URLRequest(UConfigurationLoader.CAPTURE_URL);
            captureRequest.method=URLRequestMethod.GET;
            var parameter:URLVariables=new URLVariables;
            parameter.vhost = ControlUtil.configuration.hostName;
            if(ControlUtil.configuration.isRTMP)
            {
                parameter.videoid = ControlUtil.configuration.flvID;
            }
            else
            {
                parameter.fileName = ControlUtil.configuration.fileName;
            }
            
            parameter.startTime = currentTime;
            parameter.picWidth = 200;
            parameter.picHeight = 150;
            
            captureRequest.data = parameter;
            return captureRequest;
        }
        
        public static function formatTA(ta:TextArea):TextArea
        {
            ta.textField.opaqueBackground = 0xCCCCCC;
            var myFormat:TextFormat = new TextFormat();
            myFormat.size = 14;
            ta.setStyle("textFormat",myFormat);
            return ta;
        }
        
        
        private function playNext():void
        {
            var nextIndex:int = configuration.albumIndex + 1;
            if(nextIndex > 0 && nextIndex < configuration.albumDataProvider.length)
            {
                var item:Object = configuration.albumDataProvider.getItemAt(nextIndex);
                /*                var request:URLRequest = new URLRequest(item["link"]);
                navigateToURL(request, "_top");
                UConfigurationLoader.updateMsg("Play next video " + item["title"]);*/
                
                if (ExternalInterface.available && !ControlUtil.configuration.out)
                {
                    try{
                        ExternalInterface.call("jumpToURL", item["link"]);
                        UConfigurationLoader.updateMsg("Play next video " + item["label"]);
                    }
                    catch(_:Error)
                    {
                        trace(_.toString());
                    }
                    return;
                }
            }
            UConfigurationLoader.updateMsg("Album finished.");
            stopPlay();
        }
        
        public static function stopPlay():void {
            
            if(configuration.autoPlayNext)
            {
                UConfigurationLoader.callExternal("video_play_next");
            }
            else
            {
                UConfigurationLoader.callExternal("video_play_over");
            }
        }
	}
}