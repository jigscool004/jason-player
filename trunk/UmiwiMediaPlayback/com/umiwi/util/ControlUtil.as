package com.umiwi.util
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
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
		
		public function ControlUtil(pb:UmiwiMediaPlayback)
		{
			super();
			playback = pb;
			playback.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
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
/*			if((traitInstance as PlayTrait).playState == PlayState.STOPPED)
			{
				//playback.stopPlay();
			}else
			{
				//playback.hideRecommend();
			}*/
			playStatus = (traitInstance as PlayTrait).playState;
		}
		
		public function get media():MediaElement
		{
			return _media;
		}
	}
}