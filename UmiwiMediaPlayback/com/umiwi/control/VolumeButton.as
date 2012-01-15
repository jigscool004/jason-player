package com.umiwi.control
{
	import com.umiwi.util.Constants;
	import com.umiwi.util.UConfigurationLoader;
	
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
        private static const MUTE_KEY:String = "muted";
        private static const VOLUME_KEY:String = "volume";
		
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
            
            UConfigurationLoader.saveConfig(VOLUME_KEY, volumeBar.value);
        }
		
        protected function onMute(event:MouseEvent):void
        {
            var audioTrait:AudioTrait = traitInstance as AudioTrait;
            if(audioTrait.muted){
                unMute(audioTrait);
                UConfigurationLoader.saveConfig(MUTE_KEY, false);
            }
            else
            {
                mute(audioTrait);
                UConfigurationLoader.saveConfig(MUTE_KEY, true);
            }
        }
		
		override protected function addElement():void{
			this.visible = true;
			var audioTrait:AudioTrait = traitInstance as AudioTrait;
            
            var vObj:Object = UConfigurationLoader.loadConfig(VOLUME_KEY);
            var volumeValue:Number;
            
            if(vObj)
            {
                volumeValue = vObj as Number;
            }
            else
            {
                volumeValue = 0.5;
            }
			volumeBar.value = volumeValue;
			audioTrait.volume = volumeValue;
            
            var muted:Boolean = UConfigurationLoader.loadConfig(MUTE_KEY);
            if(muted)
            {
                mute(audioTrait);
            }
		}
        
        private function unMute(audioTrait:AudioTrait):void
        {
            audioTrait.muted = false;
            volumeBar.value = audioTrait.volume;
            (volumeBtn as MovieClip).gotoAndStop(1);
        }
        
        private function mute(audioTrait:AudioTrait):void
        {
            audioTrait.muted = true;
            volumeBar.value = 0;
            (volumeBtn as MovieClip).gotoAndStop(2);
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