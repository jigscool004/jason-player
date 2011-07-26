/*****************************************************
 *  
 *  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *  
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *   
 *  
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/

package org.osmf.player.chrome.utils
{
	/**
	 * Formatting utilities. 
	 */
	public class FormatUtils
	{
		public function FormatUtils()
		{
		}
		
		/**
		 * Formats a string suitable for displaying the current position of the playhead and the total duration of a media.
		 * 
		 * There are special formating rules for the currentPosition that depends on the total duration, that's why we format both values at the same time.
		 */ 
		public static function formatTimeStatus(currentPosition:Number, totalDuration:Number, isLive:Boolean=false, LIVE:String="Live"):Vector.<String>
		{
			
			var h:int;
			var m:int;
			var s:int;
			function prettyPrintSeconds(seconds:Number, leadingMinutes:Boolean = false, leadingHours:Boolean = false):String
			{
				seconds = Math.floor(isNaN(seconds) ? 0 : Math.max(0, seconds));
				h = Math.floor(seconds / 3600);
				m = Math.floor(seconds % 3600 / 60);
				s = seconds % 60;
				return (((h>0||leadingMinutes) && h<10) ? "0" : "")
					+ h + ":" 
				+ (((h>0||leadingMinutes) && m<10) ? "0" : "")
					+ m + ":" 
					+ (s<10 ? "0" : "") 
					+ s;
			}	
						
			var totalDurationString:String =  isNaN(totalDuration) ? LIVE : prettyPrintSeconds(totalDuration, true, true);			
			var currentPositionString:String = isLive ? LIVE :  prettyPrintSeconds(currentPosition, true, true);
			
			while (currentPositionString.length < totalDurationString.length)
			{
				currentPositionString = ' ' + currentPositionString;
			}
			while (totalDurationString.length < currentPositionString.length)
			{
				totalDurationString = ' ' + totalDurationString;
			}
			
			var result:Vector.<String> = new Vector.<String>();
			result[0] = currentPositionString;
			result[1] = totalDurationString;
			return result;
		}
		
		public static function convertTime(tmpTime:Number):String {
			//显示播放时间
			var tmpTime:Number;
			var tmpHour:Number;
			var tmpMinute:Number;
			var tmpSecond:Number;
			var tmpTimeToString:String;
			var tmpHourToString:String;
			var tmpMinuteToString:String;
			var tmpSecondToString:String;
			tmpHour=int(tmpTime/3600);
			if (tmpHour<10) {
				tmpHourToString="0"+tmpHour;
			} else {
				tmpHourToString=tmpHour.toString();
			}
			tmpMinute=int(tmpTime/60)-tmpHour*60;
			if (tmpMinute<10) {
				tmpMinuteToString="0"+tmpMinute;
			} else {
				tmpMinuteToString=tmpMinute.toString();
			}
			tmpSecond=int(tmpTime%60);
			if (tmpSecond<10) {
				tmpSecondToString="0"+tmpSecond;
			} else {
				tmpSecondToString=tmpSecond.toString();
			}
			tmpTimeToString=tmpHourToString+":"+tmpMinuteToString+":"+tmpSecondToString;
			return tmpTimeToString;
		}
		
		
	}
}