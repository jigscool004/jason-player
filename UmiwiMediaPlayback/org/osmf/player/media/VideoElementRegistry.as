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

package org.osmf.player.media
{
	import flash.errors.IllegalOperationError;
	import flash.filters.DisplacementMapFilter;
	import flash.net.NetStream;
	import flash.utils.Dictionary;
	
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.*;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * @private
	 */
	public class VideoElementRegistry
	{
		// Public Interface
		//
		
		/* static */
		public static function getInstance():VideoElementRegistry
		{
			instance ||= new VideoElementRegistry(ConstructorLock);
			return instance;
		}
		
		public function VideoElementRegistry(lock:Class = null):void
		{
			if (lock != ConstructorLock)
			{
				throw new IllegalOperationError("VideoElementRegistry is a singleton: use getInstance to obtain a reference."); 
			}

			// Use weak references - we not interested in GC instances.
			_videoElements = new Dictionary(true);
		}
		
		public function register(videoElement:VideoElement):void
		{
			_videoElements[videoElement] = true;
		}
		
		public function retriveMediaElementByNetStream(netStream:NetStream):VideoElement
		{
			var result:VideoElement;
			for (var key:Object in _videoElements) 
			{
				var videoElement:VideoElement = key as VideoElement;
				var loadTrait:NetStreamLoadTrait = videoElement.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				if (loadTrait.netStream == netStream)
				{
					return videoElement;
				}
			}
			return result;
		}
		
		// Internals
		//
		private static var instance:VideoElementRegistry;
		
		private var _videoElements:Dictionary;		
	}
}

class ConstructorLock {};