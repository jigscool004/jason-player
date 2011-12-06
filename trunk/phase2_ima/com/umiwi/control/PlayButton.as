package com.umiwi.control
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class PlayButton extends TraitControl
	{
		public function PlayButton()
		{
			super();
			traitType = MediaTraitType.PLAY;
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			if(playTrait.playState == PlayState.STOPPED || playTrait.playState == PlayState.PAUSED)
			{
				playTrait.play();
				gotoAndStop(2);
			}
			else{
				playTrait.pause();
				gotoAndStop(1);
			}
		}
		
		override protected function addElement():void{
			this.visible = true;
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			if(playTrait.playState == PlayState.PLAYING)
			{
				gotoAndStop(2);
			}
			else{
				gotoAndStop(1);
			}
			playTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
		}
		
		override protected function removeElement():void{
			this.visible = false;
			if(traitInstance == null)
			{
				return;
			}
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			playTrait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
			playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
		}
		
		protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			if(playTrait.playState == PlayState.STOPPED || playTrait.playState == PlayState.PAUSED)
			{
				gotoAndStop(1);
			}
			else{
				gotoAndStop(2);
			}
		}
	}
}