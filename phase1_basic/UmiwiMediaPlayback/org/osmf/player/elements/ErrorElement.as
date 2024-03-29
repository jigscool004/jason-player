﻿/*****************************************************
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

package org.osmf.player.elements
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	/**
	 * Defines a media element that displays an error. The element is used
	 * with play lists: if an element runs into trouble, the original element
	 * is removed, and this error element is inserted in its place.
	 * 
	 * An error element has a time trait: it plays for 5 seconds.  
	 */	
	public class ErrorElement extends MediaElement
	{
		// Public Interface
		//
		
		public function ErrorElement(errorMessage:String)
		{
			this.errorMessage = errorMessage;
			
			super();
		}
		
		// Overrides
		//
		
		override protected function setupTraits():void
		{
			super.setupTraits();
			
			
		}
		
		// Internals
		//
		
		private var errorMessage:String;
	}
}