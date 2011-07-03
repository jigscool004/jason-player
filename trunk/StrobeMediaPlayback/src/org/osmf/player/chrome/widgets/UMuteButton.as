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

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.events.AudioEvent;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class UMuteButton extends ButtonWidget
	{
		private var volumeChange:ASSET_VolumeChange
		
		public function UMuteButton()
		{
			super();
			
			upFace = AssetIDs.VOLUME_BACKDROP;
			downFace = AssetIDs.VOLUME_BACKDROP;
			overFace = AssetIDs.VOLUME_BACKDROP;
		}

		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			
			super.configure(xml, assetManager);
			
			
			
			var slider:DisplayObject = assetManager.getDisplayObject(AssetIDs.VOLUME_CHANGE);
			slider.x = 22;
			slider.y = 2;
			this.addChild(slider);
			volumeChange = slider as ASSET_VolumeChange;
			registerSlider();
		}
		
		private function registerSlider():void{
			volumeChange.addEventListener(MouseEvent.CLICK, onVolumeClick);
		}
		
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			if (event.localX < 22) 
			{
				audible.muted = !audible.muted;
			}
		}
		
		protected function onVolumeClick(event:MouseEvent):void
		{
			event.stopPropagation();
			volumeChange.maskMC.width = event.localX;
			onSliderUpdate();
		}
		
		private function onSliderUpdate(event:ScrubberEvent = null):void
		{		
			if (audible)
			{				
				var newVolume:Number = volumeChange.maskMC.width/volumeChange.width;		
				audible.volume = newVolume;
				audible.muted = newVolume <= 0.0;
			}
			
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			visible = true;
			audible = media ? media.getTrait(MediaTraitType.AUDIO) as AudioTrait : null;
			if (audible == null)
			{
				visible = false;
				return;
			}
			audible.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
			audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			
			onMutedChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			visible = false;	
		}
		
		private function onMutedChange(event:AudioEvent = null):void
		{
			updateSliderPosition(audible.muted ? 0.0 : audible.volume);
		}		
		
		private function onVolumeChange(event:AudioEvent = null):void
		{
			updateSliderPosition(event.volume);
		}	
		
		
		private function updateSliderPosition(volume:Number):void
		{
			if (volume <= 0)
			{
				volumeChange.maskMC.width = 0;
			}
			else
			{
				volumeChange.maskMC.width = (volumeChange.width) * volume;
			}	
			
		}
		
		protected var audible:AudioTrait;
	}
}