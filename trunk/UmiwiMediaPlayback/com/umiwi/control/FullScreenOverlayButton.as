package com.umiwi.control
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class FullScreenOverlayButton extends TraitControl
	{
		public function FullScreenOverlayButton()
		{
			super();
			mouseEnabled = true;
			traitType = MediaTraitType.DISPLAY_OBJECT;
			this.doubleClickEnabled = true;
			addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			if(media.hasTrait(MediaTraitType.PLAY)){
				var playTrait:PlayTrait = (media.getTrait(MediaTraitType.PLAY)) as PlayTrait;
				
				if(playTrait.playState == PlayState.STOPPED || playTrait.playState == PlayState.PAUSED)
				{
					playTrait.play();
				} else
				{
					playTrait.pause();
				}
			}
		}
		
		protected function onDoubleClick(event:MouseEvent):void
		{
			switch (stage.displayState) {
				case "normal" :
					stage.displayState="fullScreen";
					gotoAndStop(2);
					break;
				case "fullScreen" :
					stage.displayState="normal";
					gotoAndStop(1);
					break;
				default :
					stage.displayState="normal";
					gotoAndStop(1);
			}
		}
	}
}