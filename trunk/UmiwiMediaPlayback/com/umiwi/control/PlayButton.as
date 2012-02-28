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
            buttonMode = true;
			traitType = MediaTraitType.PLAY;
            
            toolTipMC.tip.text = "点击播放";
            toolTipMC.visible = false;
            addEventListener(MouseEvent.ROLL_OVER,showTooltip);
            addEventListener(MouseEvent.ROLL_OUT,hideTooltip);
        }
        
        private function showTooltip(event:MouseEvent):void{
            toolTipMC.visible = true;
        }
        
        private function hideTooltip(event:MouseEvent):void{
            toolTipMC.visible = false;
        }
            
		
		override protected function onMouseClick(event:MouseEvent):void
		{
            if ( traitInstance == null) {
                return;
            }
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			if(playTrait.playState == PlayState.STOPPED || playTrait.playState == PlayState.PAUSED)
			{
				playTrait.play();
				gotoAndStop(2);
                toolTipMC.tip.text = "点击暂停";
			}
			else{
				playTrait.pause();
				gotoAndStop(1);
                toolTipMC.tip.text = "点击播放";
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