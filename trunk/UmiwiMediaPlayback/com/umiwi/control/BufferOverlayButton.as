package com.umiwi.control
{
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.BufferEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	public class BufferOverlayButton extends TraitControl
	{
		public function BufferOverlayButton()
		{
			super();
			mouseEnabled = false;
			traitType = MediaTraitType.BUFFER;
			
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
		}
		
		override protected function addElement():void{
			var bufferTrait:BufferTrait = traitInstance as BufferTrait;
			bufferTrait.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, updateState);
			bufferTrait.addEventListener(BufferEvent.BUFFERING_CHANGE, updateState);
		}
		
		private function updateState(event:Event = null):void
		{
			var isPlaying:Boolean = false;
			if(media.hasTrait(MediaTraitType.PLAY))
			{
				var playTrait:PlayTrait = (media.getTrait(MediaTraitType.PLAY) as PlayTrait);
				if(playTrait.playState == PlayState.PLAYING)
				{
					isPlaying = true;
					startedOnce = true;
				}
			}
			if(!startedOnce)
			{
				visible = true;
			}
			else
			{
				// Show the overlay only if both the bufferable and playtrait are present,
				// and buffering is taking place while playing back.
				visible
				= (traitInstance == null) 
					? 	false
					: 	(( traitInstance as BufferTrait ).buffering && isPlaying);	
			}

			
/*			UConfigurationLoader.updateMsg("* visible:" + visible + " bufferTrait:" + (traitInstance == null));
			UConfigurationLoader.updateMsg("* isPlaying:" + isPlaying);
			if(traitInstance)
			{
				UConfigurationLoader.updateMsg("* bufferTrait is buffering:" + ( traitInstance as BufferTrait ).buffering);
			}*/
		}
		
		override protected function removeElement():void
		{
			var bufferTrait:BufferTrait = traitInstance as BufferTrait;
			if(bufferTrait == null)
			{
				visible = false;
				return;
			}
			bufferTrait.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, updateState);
			bufferTrait.removeEventListener(BufferEvent.BUFFERING_CHANGE, updateState);
		}
		
		override public function set visible(value:Boolean):void
		{
		    var date:Date = new Date();
			//UConfigurationLoader.updateMsg(date.toLocaleTimeString() + " ** set visible:" + value);

			if (value != _visible)
			{
				_visible = value;
				
				if (value == true)
				{
					visibilityTimer.stop();
					super.visible = true;
				}
				else
				{
					if (visibilityTimer.running)
					{
						visibilityTimer.stop();
					}
					visibilityTimer.reset();
					visibilityTimer.start();
				}
			}
		}
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			super.visible = false;		
		}
		
		private var startedOnce:Boolean = false;
		
		private var _visible:Boolean;
		private var visibilityTimer:Timer;
		
		private static const VISIBILITY_DELAY:int = 500;
	}
}