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

package com.umiwi.util
{
	import fl.data.DataProvider;

	/**
	 * Player configuration data model
	 */ 		
	public class PlayerConfiguration
	{
		/** The location of the mediafile. */
		public var src:String = "";
		
		public var descriptionUrl:String = "";
		
		/** Contains the asset metadata */
		public var assetMetadata:Object = new Object();
		
		/** The background color of the player */ 
		public var backgroundColor:uint = 0;
		
		/** Tint color */ 
		public var tintColor:uint = 0;
		
		/** Tels wether the player should auto hide controls */ 
		public var controlBarAutoHide:Boolean = true;	
		
		/** Tels whether the media should be played in a loop */ 
		public var loop:Boolean = false;
		
		/** Tels whether the media should autostart */ 
		public var autoPlay:Boolean = true;
		
		public var umiwiAutoPlay:Boolean = true;
		
		
		/** Defines the file that holds the player's skin */
		public var skin:String = "";
		
		/** Defines if messages will show verbose or not */ 
		public var verbose:Boolean = false;
		
		/** Defines the path to the image to show before the main content shows */
		public var poster:String = "";
	
		/** Defines if the play button overlay appears */
		public var playButtonOverlay:Boolean = true;
		
		/** Defines if the buffering overlay appears */
		public var bufferingOverlay:Boolean = true;
		
		/** Defines the high quality threshold */
		public var highQualityThreshold:uint = 480;
		
		/** Defines the auto switch quality */
		public var autoSwitchQuality:Boolean = true;
		
		/** Defines the optimizeInitialIndex flag */ 
		public var optimizeInitialIndex:Boolean = true
			
		/** Defines the optimized buffering flag */
		public var optimizeBuffering:Boolean = true;
			
		
		/** Indicates, for RTMP streaming URLs, whether the URL includes the FMS application instance or not. */
		public var urlIncludesFMSApplicationInstance : Boolean = false;
			
		/** Defines the initial buffer time for video content */
		//public var initialBufferTime:Number = 0.1;		
		public var initialBufferTime:Number = 5;	
		
		/** Defines the expanded buffer time for video content */
		public var expandedBufferTime:Number = 10;	
		
		/** Defines the buffer time for dynamic streams */
		public var dynamicStreamBufferTime:Number = 0;
		
		/** Defines the minimal continuous playback time */
		public var minContinuousPlaybackTime:Number = 30;
		
		public var bufferWindow:Number = 300;
		
		public var bufferThreshold:Number = 180;
		
		public var backBufferTime:Number = 1200;
		
		public var colorFilter:String = "normal";
		
		public var out:Boolean = false;
		
		public var flvID:String = "5759";
        
        public var showRecommend:Boolean = true;
        
        public var showAds:Boolean = true;
        
        public var logo:Object = {src:"http://images.umiwi.com/u/public/images/footer-2.gif", x:10, y:10, alpha:0.7, link:"http://www.umiwi.com"};
        
        public var domains:Array = ["*.umiwi.com"];
        
        public var flashURL:String = "http://vod2.umiwi.com/vod/2010/05/21/a1fcf3594be0b2aca4809bcaf6687098.ssm/a1fcf3594be0b2aca4809bcaf6687098.f4m";
        
        public var htmlURL:String = "http://vod2.umiwi.com/vod/2010/05/21/a1fcf3594be0b2aca4809bcaf6687098.ssm/a1fcf3594be0b2aca4809bcaf6687098.f4m";
        
        public var videoURL:String = "";
        
        public var isMember:Boolean = false;
        
        public var autoPlayNext:Boolean = false;
        
        public var title:String = "优米网";
        
        public var intro:String = "";
        
        public var albumDataProvider:DataProvider = new DataProvider();
        
        public var albumIndex:int = -1;
        
        public var hostName:String;
        
        public var fileName:String;
        
        public var token:String;
        
        public var hasMBR:Boolean = false;
        
        public var commentDefault:Boolean = true;
	}
}