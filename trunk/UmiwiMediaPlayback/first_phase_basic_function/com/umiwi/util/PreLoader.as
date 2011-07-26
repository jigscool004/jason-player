/*****************************************************
 *  
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/

package com.umiwi.util
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	public class Preloader extends MovieClip
	{
		private static const SIGNED_DIGEST:String = "b63185fca5d2bdbb568593f2bf232e87e5a20a7ea2ce2e26671d159838d598ed";
		
		public function Preloader()
		{
			trace("init preloader");
			stop();
			super();
			
			// Set the SWF scale mode, and listen to the stage change
			// dimensions:
			stage.align = StageAlign.TOP_LEFT;
			
			var myURLLoader:URLLoader = new URLLoader();
			var myURLReq:URLRequest = new URLRequest();
			myURLReq.url = "osmf_1.0.0.16316.swz";
			myURLReq.digest = SIGNED_DIGEST;
			myURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			myURLLoader.addEventListener(Event.COMPLETE, getLibComplete);
			myURLLoader.load(myURLReq);
			/*			addEventListener(Event.ENTER_FRAME, progressDrawingEventHandler);
			stage.addEventListener(Event.RESIZE, progressDrawingEventHandler);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressDrawingEventHandler);
			loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			
			
			
			
			progressDrawingEventHandler();*/
			
			
		}
		
		private function getLibComplete(e:Event):void
		{
			var someLoader:Loader = new Loader();
			addChild(someLoader);
			someLoader.loadBytes((ByteArray)(e.target.data), new LoaderContext(false, ApplicationDomain.currentDomain)); 
			someLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLibLoaded);
			
			//logger.info("获取外部库成功!");
		}
		
		private function onLibLoaded(e:Event):void
		{
			//var class1:Class = getDefinitionByName("org.osmf.media.MediaElement") as Class;
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAppLoaded);
			loader.load(new URLRequest("UmiwiMediaPlayback.swf"), new LoaderContext(false, ApplicationDomain.currentDomain));
			Security.allowDomain("UmiwiMediaPlayback.swf")
		}
		
		
		
		private static const WIDTH:Number = 150;
		private static const HEIGHT:Number = 12;
		
		/*private function progressDrawingEventHandler(event:Event = null):void
		{
		graphics.clear();
		graphics.lineStyle(1, 0x000000, 0.5);
		var x:Number = stage.stageWidth / 2 - WIDTH / 2;
		var y:Number = stage.stageHeight / 2 - HEIGHT / 2
		var p:Number = loaderInfo.bytesLoaded / loaderInfo.bytesTotal;
		graphics.drawRect(x, y, WIDTH, HEIGHT);
		graphics.lineStyle(1, 0xFFFFFF, 1);
		graphics.drawRect(x + 1, y + 1, WIDTH - 2, HEIGHT - 2);
		graphics.beginFill(0xFFFFFF, 1);
		graphics.drawRect(x + 1, y + 1, (WIDTH - 2) * p, HEIGHT - 2);
		graphics.endFill();
		}
		
		private function onLoaderComplete(event:Event):void
		{
		removeEventListener(Event.ENTER_FRAME, progressDrawingEventHandler);
		stage.removeEventListener(Event.RESIZE, progressDrawingEventHandler);
		loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressDrawingEventHandler);
		loaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
		
		var configurationFileURL:String = loaderInfo.parameters.configuration;
		if (configurationFileURL != null)
		{
		configuration.loadFromFile(configurationFileURL, true);
		}
		else
		{
		trace("WARNING: configuration file not specified in SWF parameters");
		onConfigurationComplete(null);
		}
		}*/
		
		private function onAppLoaded(event:Event):void
		{
			graphics.clear();
			nextFrame();
			//addChild(event.target.content);
			var player:Class = getDefinitionByName("UmiwiMediaPlayback") as Class;
			addChild(new player());
			
		}
	}
}