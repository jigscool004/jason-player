package com.umiwi.control
{
	import com.umiwi.util.Constants;
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.StageDisplayState;
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
            replayButton.addEventListener(MouseEvent.CLICK, replay);
            shareButton.addEventListener(MouseEvent.CLICK, onShareClick);
            commentButton.addEventListener(MouseEvent.CLICK, openCommentPanel);
            addEventListener(Constants.START_TIMER, startTimer);
            timer.addEventListener(TimerEvent.TIMER, updateLabel);
		}
        
        private function replay(event:MouseEvent):void
        {
            var e:Event = new Event(Constants.REPLAY_VIDEO, true);
            dispatchEvent(e);
            resetTimer();
        }
        
        private function onShareClick(event:MouseEvent):void
        {
            var e:Event = new Event(Constants.OPEN_SHARE_PANEL, true);
            dispatchEvent(e);
            resetTimer();
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
            if(!commentPanel.showing)
            {
                //Can not input in full screen mode.
                restorScreen();
                
                commentPanel.show();
            }
            else
            {
                commentPanel.hide();
                timer.start();
            }
        }
        
        
        private function restorScreen():void
        {
            if(stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                stage.displayState=StageDisplayState.NORMAL;
            }
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
            var timeOffset:Number =  ControlUtil.totalTime - ControlUtil.playTime;
			//if(playTrait.playState == PlayState.STOPPED && (timeOffset < 5) &&
              //  ControlUtil.configuration.albumDataProvider.length <= 0)
                
            if(playTrait.playState == PlayState.STOPPED &&
                    ControlUtil.configuration.albumDataProvider.length <= 0)
			{
                UConfigurationLoader.updateMsg("Video " + timeOffset + " seconds left.");
                UConfigurationLoader.updateMsg("Video stop");
                ControlUtil.stopPlay();
                
                if(ControlUtil.configuration.showRecommend)
                {
                    visible = true;
                }
                if(ControlUtil.configuration.commentDefault)
                {
                    openCommentPanel();
                }
                else
                {
                    commentButton.visible = false;
                    timer.start();
                }
			}
			else{
				visible = false;
			}
		}
	}
}