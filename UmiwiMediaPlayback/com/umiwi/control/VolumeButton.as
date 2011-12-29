package com.umiwi.control
{
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
		}
		
		private function showTooltip(event:MouseEvent):void{
			toolTipMC.visible = true;
		}
		
		private function hideTooltip(event:MouseEvent):void{
			toolTipMC.visible = false;
		}		
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var audioTrait:AudioTrait = traitInstance as AudioTrait;
			if (event.target.name == "volumeBar")
			{
				audioTrait.muted = false;
				audioTrait.volume = event.localX / volumeBar.width;
				volumeBar.maskMC.width = event.localX * 1.1;
				
			}
			else if(event.localX < MUTE_BUTTON_WIDTH)
			{
				if(audioTrait.muted){
					audioTrait.muted = false;
					volumeBar.maskMC.width = audioTrait.volume * volumeBar.width;
				}else
				{
					audioTrait.muted = true;
					volumeBar.maskMC.width = 0;
				}
			}

		}
		
		override protected function addElement():void{
			this.visible = true;
			var audioTrait:AudioTrait = traitInstance as AudioTrait;
			volumeBar.maskMC.width = volumeBar.width * 0.5;
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