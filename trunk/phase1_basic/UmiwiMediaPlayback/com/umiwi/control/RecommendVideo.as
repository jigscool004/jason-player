package com.umiwi.control
{
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class RecommendVideo extends TraitControl
	{
		public function RecommendVideo()
		{
			super();
			traitType = MediaTraitType.PLAY;
			visible = false;
		}
		
		override protected function addElement():void{
			this.visible = false;
			var playTrait:PlayTrait = traitInstance as PlayTrait;
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
			if(playTrait.playState == PlayState.STOPPED)
			{
                if(ControlUtil.configuration.showRecommend)
                {
                    visible = true;
                }
				
				UConfigurationLoader.callExternal("video_play_over");
				UConfigurationLoader.updateMsg("Video stop");
			}
			else{
				visible = false;
			}
		}
	}
}