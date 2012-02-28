package com.umiwi.control
{
	import com.umiwi.util.Constants;
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class RecommendVideo extends TraitControl
	{
        private static const TIME_COUNT:int = 10;
        private var timer:Timer = new Timer(1000, TIME_COUNT);
        private var count:uint = TIME_COUNT;
        
		public function RecommendVideo()
		{
			super();
			traitType = MediaTraitType.PLAY;
			visible = false;
            addEventListener(Constants.OPEN_COMMENT_PANEL, openCommentPanel);
            replayButton.addEventListener(MouseEvent.CLICK, resetTimer);
            shareButton.addEventListener(MouseEvent.CLICK, resetTimer);
            commentButton.addEventListener(MouseEvent.CLICK, resetTimer);
            addEventListener(Constants.START_TIMER, startTimer);
            timer.addEventListener(TimerEvent.TIMER, updateLabel);
		}
        
        private function updateLabel(event:TimerEvent):void
        {
            --count;
            timeLabel.text = count.toString();
            if(count == 0)
            {
                navigateToURL(new URLRequest(loader0.link), "_top");
            }
        }
        
        private function startTimer(event:Event):void
        {
            timer.start();
        }
        
        private function resetTimer(event:Event=null):void
        {
            timer.reset();
            count = TIME_COUNT;
            timeLabel.text = count.toString();
        }
        
        private function openCommentPanel(event:Event=null):void
        {
            resetTimer();
            commentPanel.visible = true;
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
                if(ControlUtil.configuration.isMember)
                {
                    openCommentPanel();
                }
                else
                {
                    commentPanel.visible = false;
                    timer.start();
                }
			}
			else{
				visible = false;
			}
		}
	}
}