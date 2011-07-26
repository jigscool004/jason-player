/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package com.umiwi.control
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.PerspectiveProjection;
	import flash.media.Microphone;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamType;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * TimeViewWidget displays the current time and the total duration of the media.
	 * 
	 */ 
	public class TimeViewLabel extends TraitControl
	{
		
		public function TimeViewLabel()
		{
			super();
			traitType = MediaTraitType.TIME;
		}
		
		/**
		 * Returns the current textual represention of the time displayed by the TimeViewWidget.
		 */ 
		internal function get text():String
		{
			return 	currentTimeLabel.text 
				+ (timeSeparatorLabel.visible ? timeSeparatorLabel.text : "") 
				+ (totalTimeLabel.visible ? totalTimeLabel.text : "");
		}
		
		/**
		 * Updates the displayed text based on the existing traits.
		 */ 
		internal function updateNow():void
		{
			var timeTrait:TimeTrait;
			timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;			
			updateValues(timeTrait.currentTime, timeTrait.duration);
		}
		
		/**
		 * Updates the displayed text using the time values provided as arguments.
		 */ 
		internal function updateValues(currentTimePosition:Number, totalDuration:Number):void
		{	
			// WORKARROUND: ST-285 CLONE -Multicast live duration
			// Check is the value is over the int range, and turn it into a NaN
			if (totalDuration > int.MAX_VALUE)
			{
				totalDuration = NaN;
			}
			
			// Don't display the time labels if total duration is 0
			if (isNaN(totalDuration) || totalDuration == 0) 
			{	
				if (currentTimePosition > 0)
				{
					totalTimeLabel.visible = false;
					timeSeparatorLabel.visible = false;
				}
			}
			else
			{				
				totalTimeLabel.visible = true;
				timeSeparatorLabel.visible = true;				
				
				var newValues:Vector.<String> = FormatUtils.formatTimeStatus(currentTimePosition, totalDuration, false, LIVE);
				
				// WORKARROUND: adding additional spaces since I'm unable to position the text nicely
				var currentTimeString:String = " " + newValues[0] + " ";
				var totalTimeString:String = " " + newValues[1] + " ";
				
				totalTimeLabel.text = totalTimeString;
				// Fix for (ST-306) The current time is shown very close to the slash from the total time, almost overlapping

				currentTimeLabel.text = currentTimeString;				
			}
		}
		
		
		override protected function addElement():void
		{
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			timer.start();				
			visible = true;
			if (media.hasTrait(MediaTraitType.SEEK))
			{
				seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			}
		}
		
		override protected function removeElement():void
		{		
			timer.stop();
			visible = false;
			if (media && media.hasTrait(MediaTraitType.SEEK))
			{
				seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				seekTrait = null;				
			}	
		}

		// Internals
		//
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
		private static const LIVE:String = "Live";
		private static const TIME_ZERO:String = " 0:00 ";
				
		private var seekTrait:SeekTrait;
		private var timer:Timer = new Timer(1000);
		private var maxLength:uint = 0;
		private var maxWidth:Number = 100;
		
		private function onTimerEvent(event:Event):void
		{
			updateNow();
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			var timeTrait:TimeTrait;
			timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;			
			
			if (event.seeking)
			{
				updateValues(event.time, timeTrait.duration);
				timer.stop();				
			}
			else
			{
				updateValues(event.time, timeTrait.duration);
				timer.start();
			}
		}	
	}
}