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
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	
	public class FullScreenLeaveButton extends ButtonWidget
	{
		public function FullScreenLeaveButton()
		{	
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			upFace = AssetIDs.FULL_SCREEN_LEAVE_NORMAL;
			downFace = AssetIDs.FULL_SCREEN_LEAVE_NORMAL;
			overFace = AssetIDs.FULL_SCREEN_LEAVE_NORMAL;
		}
		
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			visible = false;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			visible
				=	element != null
				&&	stage != null
				&&	stage.displayState != StageDisplayState.NORMAL;
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			stage.displayState = StageDisplayState.NORMAL;
		}
		
		// Internals
		//
		
		private function onAddedToStage(event:Event):void
		{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
			processRequiredTraitsAvailable(media);
		}
		
		private function onFullScreenEvent(event:FullScreenEvent):void
		{
			processRequiredTraitsAvailable(media);
		}
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DISPLAY_OBJECT;
	}
}