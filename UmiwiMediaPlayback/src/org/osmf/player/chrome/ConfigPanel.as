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

package org.osmf.player.chrome
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.CloseConfigButton;
	import org.osmf.player.chrome.widgets.DisplayConfigWidget;
	import org.osmf.player.chrome.widgets.FullScreenEnterButton;
	import org.osmf.player.chrome.widgets.FullScreenLeaveButton;
	import org.osmf.player.chrome.widgets.LogoLinkButton;
	import org.osmf.player.chrome.widgets.MuteButton;
	import org.osmf.player.chrome.widgets.PauseButton;
	import org.osmf.player.chrome.widgets.PlayButton;
	import org.osmf.player.chrome.widgets.PlaylistNextButton;
	import org.osmf.player.chrome.widgets.PlaylistPreviousButton;
	import org.osmf.player.chrome.widgets.QualityIndicator;
	import org.osmf.player.chrome.widgets.ScrubBar;
	import org.osmf.player.chrome.widgets.TimeViewWidget;
	import org.osmf.player.chrome.widgets.UMuteButton;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.widgets.WidgetIDs;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;

	/**
	 * ControlBar contains all the control widgets and is responsible for their layout.
	 */ 
	public class ConfigPanel extends AutoHideWidget
	{
		// Overrides
		//
		
		public function register(target:Sprite, container:Sprite, mediaPlayer:StrobeMediaPlayer):void
		{
			this.container = container;
			this.mediaPlayer = mediaPlayer;
			
			target.addEventListener("openConfigPanel", onOpening);
		}		
		
		private function onOpening(event:Event):void{
			this.visible = true;
			this.addEventListener(Event.COMPLETE, onEnterFrame);
			this.addEventListener(Event.ACTIVATE, onEnterFrame);
			this.addEventListener(Event.EXIT_FRAME, onEnterFrame);
			this.addEventListener(Event.OPEN, onEnterFrame);
			this.addEventListener("closeConfigPanel", onCloseButtonClick);
		}
		
		private function onEnterFrame(event:Event):void
		{	
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.media = media;
		}
		
		private function onCloseButtonClick(event:Event):void
		{	
			removeEventListener("closeConfigPanel", onCloseButtonClick);
			visible = false;
		}
	
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			id = WidgetIDs.CONFIG_PANEL;
			//face = AssetIDs.CONFIG_PANEL_BACKDROP;
			fadeSteps = 6;			
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.layoutMode = LayoutMode.VERTICAL;
			layoutMetadata.width = 100;
			layoutMetadata.height = 150;
			super.configure(xml, assetManager);
			
			var topControls:Widget = new Widget();
			topControls.layoutMetadata.percentWidth = 100;
			topControls.layoutMetadata.height = 20;
			topControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			topControls.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			topControls.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			
			var closeMe:CloseConfigButton = new CloseConfigButton();
			closeMe.id = WidgetIDs.CLOSE_CONFIG;
			closeMe.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			closeMe.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			topControls.addChildWidget(closeMe);
			addChild(topControls);
			
			var bottomControls:Widget = new Widget();
			bottomControls.layoutMetadata.height = 240;
			bottomControls.layoutMetadata.percentWidth = 100;
			bottomControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			bottomControls.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			bottomControls.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			var brightness:DisplayConfigWidget = new DisplayConfigWidget();
			brightness.id = WidgetIDs.BRIGHTNESS_SLIDER;
			brightness.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			brightness.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			bottomControls.addChildWidget(brightness);
			
			var spacer1:Widget = new Widget();
			spacer1.width = 5;
			bottomControls.addChildWidget(spacer1);			
			
			var contrast:DisplayConfigWidget = new DisplayConfigWidget();
			contrast.id = WidgetIDs.BRIGHTNESS_SLIDER;
			contrast.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			contrast.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			bottomControls.addChildWidget(contrast);
			
			var spacer2:Widget = new Widget();
			spacer2.width = 5;
			bottomControls.addChildWidget(spacer2);			
			
			var saturation:DisplayConfigWidget = new DisplayConfigWidget();
			saturation.id = WidgetIDs.BRIGHTNESS_SLIDER;
			saturation.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			saturation.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			bottomControls.addChildWidget(saturation);
			
			addChild(bottomControls);
			
			configureWidgets
			(	[ topControls, closeMe,
				, bottomControls, brightness, spacer1, contrast, spacer2, saturation
				]
			);
			
			
			measure();
		}

		// Internals
		//
	
		private function configureWidgets(widgets:Array):void
		{
			for each( var widget:Widget in widgets)
			{
				if (widget)
				{
					widget.configure(<default/>, assetManager);					
				}
			}
		}		
		
		private var fullscreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();
		
		private var playTrait:PlayTrait;
		
		private var scrubBarLiveTrack:DisplayObject;
		
		private var lastWidth:Number;
		private var lastHeight:Number;
		
		private var container:Sprite;
		private var mediaPlayer:StrobeMediaPlayer;
		
		private var closeButton:CloseButton;
		
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
	}
}