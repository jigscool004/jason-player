package com.umiwi.control
{
	import com.umiwi.util.Constants;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class VolumeButton extends TraitControl
	{
		private static const MUTE_BUTTON_WIDTH:uint = 24;
		
		public function VolumeButton()
		{
			super();
            buttonMode = true;
			traitType = MediaTraitType.AUDIO; 
			
			toolTipMC.tip.text = "静音设置";
			toolTipMC.visible = false;
			volumeBtn.addEventListener(MouseEvent.MOUSE_OVER,showTooltip);
			volumeBtn.addEventListener(MouseEvent.MOUSE_OUT,hideTooltip);
            volumeBtn.addEventListener(MouseEvent.CLICK, onMute);
            volumeBar.addEventListener(Constants.SLIDER_CHANGE, onVolumeChanged);
            
            volumeBar.min = 0;
            volumeBar.max = 1;
		}
		
		private function showTooltip(event:MouseEvent):void{
			toolTipMC.visible = true;
		}
		
		private function hideTooltip(event:MouseEvent):void{
			toolTipMC.visible = false;
		}		
        
        private function onVolumeChanged(event:Event):void
        {
            var audioTrait:AudioTrait = traitInstance as AudioTrait;
            audioTrait.muted = false;
            (volumeBtn as MovieClip).gotoAndStop(1);
            audioTrait.volume = volumeBar.value;
        }
		
        protected function onMute(event:MouseEvent):void
        {
            var audioTrait:AudioTrait = traitInstance as AudioTrait;
            if(audioTrait.muted){
                audioTrait.muted = false;
                volumeBar.value = audioTrait.volume;
                (volumeBtn as MovieClip).gotoAndStop(1);
            }else
            {
                audioTrait.muted = true;
                volumeBar.value = 0;
                (volumeBtn as MovieClip).gotoAndStop(2);
            }
        }
		
		override protected function addElement():void{
			this.visible = true;
			var audioTrait:AudioTrait = traitInstance as AudioTrait;
			volumeBar.value = 0.5;
			audioTrait.volume = 0.5;
		}
		
		override protected function removeElement():void{
			this.visible = false;
			if(traitInstance == null)
			{
				return;
			}
		}
	}
}