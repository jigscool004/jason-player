package com.umiwi.control
{
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	
	/**
	 * ScrubBar widget is responsible for setting up the scrub bar UI and behaviour.
	 */ 
	public class ScrubBar extends TraitControl
	{
		
		public function ScrubBar()
		{			
			
			traitType = MediaTraitType.SEEK;
			
			scrubBarClickArea = new Sprite();
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_UP, onTrackMouseUp);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_OVER, onTrackMouseOver);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
			
			addChild(scrubBarClickArea);
			
			currentPositionTimer = new Timer(CURRENT_POSITION_UPDATE_INTERVAL);
			currentPositionTimer.addEventListener(TimerEvent.TIMER, updateScrubberPosition);
			
			super();
			
			scrubBarClickArea.x = scrubBarTrack.x;
			scrubBarClickArea.y = scrubBarTrack.y;
			scrubBarClickArea.graphics.clear();
			scrubBarClickArea.graphics.beginFill(0xFFFFFF, 0.0);
			scrubBarClickArea.graphics.drawRect(0.0, 0.0, scrubBarTrack.width, Math.max(scrubBarTrack.height, scrubber.height));
			scrubBarClickArea.graphics.endFill();
			
			updateScrubberPosition();
			updateState();
			
			scrubTimer = new Timer(UPDATE_INTERVAL);
			scrubTimer.addEventListener(TimerEvent.TIMER, onScrubberUpdate);
			seekTimeDisMC.visible = false;
			configure();
		}
		
		public function configure():void
		{
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, onScrubberMouseDown);;
			scrubber.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubber.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
				
			scrubber.enabled = false;
			scrubber.addEventListener(ScrubberEvent.SCRUB_START, onScrubberStart);
			scrubber.addEventListener(ScrubberEvent.SCRUB_UPDATE, onScrubberUpdate);
			scrubber.addEventListener(ScrubberEvent.SCRUB_END, onScrubberEnd);
			_rangeY = 0.0;
			_rangeX = scrubBarTrack.width;
			
			this.scrubberEnd = scrubBarTrack.x + scrubBarTrack.width - scrubber.width/2;
			updateState();
			
		}
		
		override protected function addElement():void
		{
			this.visible = true;
			if (media.hasTrait(MediaTraitType.PLAY))
			{
				// Prepare for getting the player to the Live content directly (UX rule)
				var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait.playState != PlayState.PLAYING)
				{
					started = false;
					playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onFirstPlayStateChange);
				}
				else
				{
					started = true;
				}
				playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
				
			}	
			
			updateState();
			
		}
		 
		override protected function removeElement():void
		{
			updateState();
		}
		
		private function onFirstPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING)
			{
				started = true;
				updateState();
				var playTrait:PlayTrait = _media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait)
				{
					playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onFirstPlayStateChange);	
				}
			}
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			updateTimerState();
		}
		
		private function updateState():void
		{
			visible = _media != null;
			enabled = _media ? _media.hasTrait(MediaTraitType.SEEK) : false;
								
			scrubBarLoadedTrack.visible = _media ? _media.hasTrait(MediaTraitType.LOAD) : false;
			scrubBarPlayedTrack.visible = _media ? _media.hasTrait(MediaTraitType.PLAY) : false;
			if (scrubber)
			{
				scrubber.enabled = _media ? _media.hasTrait(MediaTraitType.SEEK) : false;
				scrubber.visible = true;
			}
			updateTimerState();
		}
		
		private function updateTimerState():void
		{
			var timeTrait:TimeTrait = _media ? _media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			if (timeTrait == null)
			{
				currentPositionTimer.stop();
				
				resetUI();
			}
			else
			{ 
				var playTrait:PlayTrait = _media ? _media.getTrait(MediaTraitType.PLAY) as PlayTrait : null;
				if (playTrait && !currentPositionTimer.running)
				{
					currentPositionTimer.start();
				}
			}
		}		
		
		private function updateScrubberPosition(event:Event = null):void
		{
			if(_sliding)
			{
				return;
			}
			var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;			
			if (timeTrait != null && timeTrait.duration)
			{
				var loadTrait:LoadTrait = media ? media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
				var seekTrait:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
				var duration:Number = timeTrait.duration;
			
				var position:Number = isNaN(seekToTime) ? timeTrait.currentTime : seekToTime;
				var scrubberX:Number
					= 	0
						+ 	(	scrubberEnd
							* position
						)
						/ duration
						||	0; // Default value if calc. returns NaN.
				
				scrubber.x = Math.min(scrubberEnd, Math.max(0, scrubberX));
				if (loadTrait)
				{
/*					scrubBarLoadedTrack.width 
						=  scrubberEnd
						* ((loadTrait.bytesTotal && loadTrait.bytesLoaded) 
							? (Math.min(1.0, loadTrait.bytesLoaded / loadTrait.bytesTotal)) 
							: seekTrait ? 1.0 : 0.0);*/
					if(loadTrait.bytesTotal && loadTrait.bytesLoaded)
					{
						scrubBarLoadedTrack.width 
							=  scrubberEnd * (Math.min(1.0, loadTrait.bytesLoaded / loadTrait.bytesTotal)); 
					}
					else if(loadTrait is NetStreamLoadTrait)
					{
						if(ControlUtil.playStatus != PlayState.STOPPED)
						{
							var netStream:NetStream = (loadTrait as NetStreamLoadTrait).netStream;
							scrubBarLoadedTrack.width 
								= 	0
								+ 	(	scrubberEnd
									* (position + netStream.bufferLength)
								)
								/ duration
								||	0;
							enlargeBuffer(netStream);
							applyUmiwiPolicy(netStream);
						}
						else
						{
							scrubBarLoadedTrack.width = 0;
						}

					}
				}
				
				scrubBarPlayedTrack.width = Math.max(0, scrubber.x);
			}
			else
			{
				resetUI();
			}
		}
		
		private function enlargeBuffer(netStream:NetStream):void
		{
			if(netStream.bufferTime<=netStream.bufferLength && netStream.bufferTime>= ControlUtil.configuration.expandedBufferTime)
			{
				netStream.bufferTime = Math.min(netStream.bufferTime* 2, ControlUtil.configuration.bufferWindow);
				UConfigurationLoader.updateMsg("Enlarge buffer size to " + netStream.bufferTime.toString());
			}
		}
		
		private var dealedTag:int = 0;
		
		private function applyUmiwiPolicy(netStream:NetStream):void
		{
			var bufferTail:Number = netStream.time + netStream.bufferLength;
			if(bufferTail >= (ControlUtil.configuration.bufferWindow -10))
			{
				var bufferWindowOffset:Number = bufferTail % ControlUtil.configuration.bufferWindow;
				var tag:int = bufferTail / ControlUtil.configuration.bufferWindow;
				if (bufferWindowOffset <= 5 && tag != dealedTag)
				{
					if (netStream.bufferLength > ControlUtil.configuration.bufferThreshold && netStream.bufferTime > 0.1)
					{
						netStream.bufferTime = 0;
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");
						UConfigurationLoader.updateMsg("Loaded content reach buffer window, pause buffer.");
						UConfigurationLoader.updateMsg("Loaded buffer time: " + int(bufferTail) + ". Play time: " + int(netStream.time));
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");
					}else if(netStream.bufferLength <= ControlUtil.configuration.bufferThreshold && netStream.bufferTime < ControlUtil.configuration.bufferWindow)
					{
						dealedTag = tag;
						netStream.bufferTime = ControlUtil.configuration.expandedBufferTime;
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");
						UConfigurationLoader.updateMsg("Play progress reach threshold, resume buffer.");
						UConfigurationLoader.updateMsg("Loaded buffer time: " + int(bufferTail) + ". Play time: " + int(netStream.time));	
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");
					}/*else
					{
						dealedTag = tag;
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");
						UConfigurationLoader.updateMsg("Loaded content reach buffer window, nothing is triggered");
						UConfigurationLoader.updateMsg("Loaded buffer time: " + int(bufferTail) + ". Play time: " + int(netStream.time));
						UConfigurationLoader.updateMsg("-----------------------------------------------------------------");						
					}*/
				}
			}
		}
		
		public function setWidth(newWidth:Number):void{
			scrubBarTrack.width = newWidth;
			updateScrubberPosition();
		}

		private function seekToX(relativePositition:Number):void
		{
			if (!started)
			{
				return;
			}
			var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			var seekTrait:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
			var playTrait:PlayTrait = media ? media.getTrait(MediaTraitType.PLAY) as PlayTrait : null;
			if (timeTrait && seekTrait)
			{
				
				if (relativePositition == -4.0)
				{
					// Set the time to 0 for this position. Fix for ST-176: For long movies, one cannot rewind to the beginning of the movie by scrubbing the cursor
					time = 0.0;
				}
				else
				{
					var time:Number = timeTrait.duration * (relativePositition / scrubberEnd);
				}
				
				if (seekTrait.canSeekTo(time)) 
				{
					if (playTrait && playTrait.playState == PlayState.STOPPED)
					{
						// If the stream is stopped when playing it will always start from 0, regardless of this seek,
						// so we make sure the stream is not stopped. We need to check if the element at hand can pause,
						// though:
						if (playTrait.canPause)
						{
							playTrait.play();
							playTrait.pause();
						}
					}
					seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
					seekToTime = time;
					seekTrait.seek(time);
					trace(FormatUtils.convertTime(time));
					trace("seek to x " + relativePositition);
					scrubber.x = Math.max(0, relativePositition);
					scrubBarPlayedTrack.width = scrubber.x;
				}
			}
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			if (event.seeking == false)
			{
				var seekTrait:SeekTrait = event.target as SeekTrait;
				var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;	
				updateScrubberPosition();
				
				seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
					
				trace("current time " + FormatUtils.convertTime(timeTrait.currentTime));
				trace("seek time " + FormatUtils.convertTime(seekToTime));
				seekToTime = NaN;			
			}
		}
		
		private function onScrubberUpdate(event:Event = null):void
		{
			showTimeHint();
			seekToX(scrubber.x);
		}
		
		private function onScrubberStart():void
		{
			var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playTrait)
			{
				preScrubPlayState = playTrait.playState;
				if (playTrait.canPause && playTrait.playState != PlayState.PAUSED)
				{
					playTrait.pause();
				}
			}
		}
		
		private function onScrubberEnd():void
		{
			seekToX(scrubber.x);
			if (preScrubPlayState)
			{
				var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playable)
				{
					if (playable.playState != preScrubPlayState)
					{
						switch (preScrubPlayState)
						{
							case PlayState.STOPPED:
								playable.stop();
								break;
							case PlayState.PLAYING:
								playable.play();
								break;
						}
					}
				}
			}
		}
		
		private function onTrackMouseDown(event:MouseEvent):void
		{
			seekToX(mouseX - scrubber.width / 2.0);			
			showTimeHint();			
		}
		
		private function onTrackMouseUp(event:MouseEvent):void
		{
			stopScrubber();		
		}
		
		private function onTrackMouseOver(event:MouseEvent):void
		{
			showTimeHint();
			var loadTrait:LoadTrait = media ? media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
			if(loadTrait is NetStreamLoadTrait)
			{
				var netStream:NetStream = (loadTrait as NetStreamLoadTrait).netStream;
				var bufferTail:Number = netStream.time + netStream.bufferLength;
				UConfigurationLoader.updateMsg("Loaded buffer time: " + int(bufferTail) + ". Play time: " + int(netStream.time));
			}
		}
		
		private function onTrackMouseMove(event:MouseEvent):void
		{
			showTimeHint();
			if (event.buttonDown && !_sliding)
			{
				startScrubber();			
			}
		}
		
		private function onTrackMouseOut(event:MouseEvent):void
		{
			try
			{
				if (event.relatedObject != scrubber && (event.relatedObject is DisplayObject) && !contains(event.relatedObject) || event.relatedObject == this)
				{			
				}
			}
			catch (e:Error)
			{		
			}
			seekTimeDisMC.visible = false;
		}
		
		private function onScrubberMouseDown(event:MouseEvent):void
		{
			startScrubber(false);
		}
		
		
		private function showTimeHint():void
		{
			if (scrubBarClickArea.mouseX >= 0.0 && scrubBarClickArea.mouseX <= scrubBarClickArea.width)
			{
				seekTimeDisMC.visible = true;
				var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
				if (timeTrait)
				{
					var time:Number = timeTrait.duration * ((mouseX - scrubber.width / 2.0) / scrubBarTrack.width);
					
					var currentTimeString:String = FormatUtils.formatTimeStatus(time, timeTrait.duration)[0];
					seekTimeDisMC.seekTimeTxt.text = currentTimeString;
					seekTimeDisMC.x = this.mouseX + seekTimeDisMC.width * 0.3;
				}
			}
		}
		
		private function resetUI():void
		{
			if (scrubber)
			{
				scrubber.x = 0;
			}
			scrubBarPlayedTrack.width = 0.0;
		}
		
		private function getBufferTime():Number
		{
			var result:Number = 0.0;			
			var loadTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
			if (loadTrait && loadTrait.netStream)
			{
				result = loadTrait.netStream.bufferTime;
			}
			return result;
		}
		
		public function startScrubber(lockCenter:Boolean = true):void
		{
			if (_enabled && _sliding == false)
			{
				_sliding = true;
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
				scrubTimer.start();
				this.onScrubberStart();
				var dragArea:Rectangle=new Rectangle(0,scrubber.y,this.scrubberEnd,0);
				scrubber.startDrag
				( false
					,dragArea
				);
			}
		}
		
		public function stopScrubber():void
		{
			if (_enabled && _sliding)
			{
				scrubTimer.stop();
				scrubber.stopDrag();
				_sliding = false;
				
				try
				{
					stage.removeEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
				}
				catch (e:Error)
				{
					// swallow this, it means that we already removed
					// the event listened in a previous stop() call
				}
				this.onScrubberEnd()
				
			}
		}
		
		private function onStageExitDrag(event:MouseEvent):void
		{
			stopScrubber();
		}
		
		private var _enabled:Boolean = true;
		private var _sliding:Boolean;
		private var scrubTimer:Timer;
		private var _origin:Number = 0.0;
		private var _rangeX:Number = 100.0;
		private var _rangeY:Number = 100.0;

				
		private var _live:Boolean = false;
		private var scrubBarClickArea:Sprite;
		
		//private var scrubBarHint:TimeHintWidget;
		
		private var scrubberStart:Number;
		private var scrubberEnd:Number;
		
		private var scrubBarWidth:Number;
		private var scrubberWidth:Number;
		
		private var currentPositionTimer:Timer;
		
		private var preScrubPlayState:String;
		
		private var lastWidth:Number;
		private var lastHeight:Number;
		
		private var seekToTime:Number;
		private var started:Boolean;
		
		
		/* static */
		
		private static const TIME_LIVE:String = "Live";
		private const UPDATE_INTERVAL:int = 40;
		
		private static const CURRENT_POSITION_UPDATE_INTERVAL:int = 100;
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
		_requiredTraits[1] = MediaTraitType.DVR;
		
	}
}
