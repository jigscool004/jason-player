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
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.ConfigButton;
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
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;

	/**
	 * ControlBar contains all the control widgets and is responsible for their layout.
	 */ 
	public class ControlBar extends AutoHideWidget
	{
		// Overrides
		//
	
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			id = WidgetIDs.CONTROL_BAR;
			face = AssetIDs.CONTROL_BAR_BACKDROP;
			fadeSteps = 6;			
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.layoutMode = LayoutMode.VERTICAL;
			layoutMetadata.height = 66;
			layoutMetadata.percentWidth = 100;
			super.configure(xml, assetManager);
			
			var topControls:Widget = new Widget();
			topControls.layoutMetadata.percentWidth = 100;
			topControls.layoutMetadata.height = 30;
			topControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			topControls.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			topControls.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
			
/*			// Left margin
			var leftTopMargin:Widget = new Widget();
			leftTopMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_LEFT;
			leftTopMargin.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			topControls.addChildWidget(leftTopMargin);*/
			
			var beforeScrubSpacer:Widget = new Widget();
			beforeScrubSpacer.width = 10;		
			topControls.addChildWidget(beforeScrubSpacer);
			
			// Scrub bar
			var scrubBar:ScrubBar = new ScrubBar();		
			scrubBar.id = WidgetIDs.SCRUB_BAR;
			scrubBar.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			scrubBar.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
			scrubBar.layoutMetadata.percentWidth = 100;
			topControls.addChildWidget(scrubBar);
			
			var rightScrubSpacer:Widget = new Widget();
			rightScrubSpacer.width = 10;
			topControls.addChildWidget(rightScrubSpacer);
			
/*			var rightTopMargin:Widget = new Widget();
			rightTopMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_RIGHT;
			rightTopMargin.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			topControls.addChildWidget(rightTopMargin);*/
			
			addChildWidget(topControls);
			
			var bottomControls:Widget = new Widget();
			bottomControls.layoutMetadata.percentWidth = 100;
			bottomControls.layoutMetadata.height = 33;
			bottomControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			bottomControls.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			bottomControls.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			
			// Left margin
/*			var leftMargin:Widget = new Widget();
			leftMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_LEFT;
			leftMargin.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			
			bottomControls.addChildWidget(leftMargin);*/
			
			var leftControls:Widget = new Widget();
			leftControls.layoutMetadata.percentHeight = 100;
			leftControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			leftControls.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			// Spacer
			var beforePlaySpacer:Widget = new Widget();
			beforePlaySpacer.width = 6;			
			leftControls.addChildWidget(beforePlaySpacer);
			
			// Play/pause
			var playButton:PlayButton = new PlayButton();
			playButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			playButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(playButton);
			
			var pauseButton:PauseButton = new PauseButton();
			pauseButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			pauseButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(pauseButton);
			
			// Previous/Next
			var previousButton:PlaylistPreviousButton = new PlaylistPreviousButton();
			previousButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			previousButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(previousButton);
			
			var nextButton:PlaylistNextButton = new PlaylistNextButton();
			nextButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			nextButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(nextButton);
			
			// Spacer
			var afterNextSpacer:Widget = new Widget();
			afterNextSpacer.layoutMetadata.width = 5;
			afterNextSpacer.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			
			leftControls.addChildWidget(afterNextSpacer);
			
			// Time bakdrop
			var timeBackdrop:Widget = new Widget();
			timeBackdrop.face = AssetIDs.SCRUB_HINT_BACKDROP;
			timeBackdrop.height = 26;
			timeBackdrop.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			timeBackdrop.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			leftControls.addChildWidget(timeBackdrop);
			
			// Time view
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			timeViewWidget.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;	
			timeBackdrop.addChildWidget(timeViewWidget);
			
			bottomControls.addChildWidget(leftControls);		
			
			// Spacer
			var afterPlaySpacer:Widget = new Widget();
			afterPlaySpacer.layoutMetadata.percentWidth = 100;
			afterPlaySpacer.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			
			bottomControls.addChildWidget(afterPlaySpacer);
			
			// Right side
			var rightControls:Widget = new Widget();
			rightControls.layoutMetadata.percentHeight = 100;
			rightControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			rightControls.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;			
			
			// Spacer
			var afterScrubSpacer:Widget = new Widget();
			afterScrubSpacer.width = 5;
			rightControls.addChildWidget(afterScrubSpacer);
			
			// Logo link
			var linkButton:LogoLinkButton = new LogoLinkButton();
			linkButton.id = WidgetIDs.LOGO_LINK;
			linkButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			linkButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(linkButton);
			
			// Spacer
			var afterLogo:Widget = new Widget();
			afterLogo.width = 5;
			rightControls.addChildWidget(afterLogo);
			
			// HD indicator
			var hdIndicator:QualityIndicator = new QualityIndicator();
			hdIndicator.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			hdIndicator.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(hdIndicator);
			
			// Spacer
			var afterTimeSpacer:Widget = new Widget();
			afterTimeSpacer.width = 5;
			rightControls.addChildWidget(afterTimeSpacer);
			
			// open config panel
			var configButton:ConfigButton = new ConfigButton();
			configButton.id = WidgetIDs.CONFIG_BUTTON;
			configButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			configButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(configButton);
			
			// Spacer
			var afterConfigSpacer:Widget = new Widget();
			afterConfigSpacer.width = 5;
			rightControls.addChildWidget(afterConfigSpacer);
			
			// volume change
			var umuteButton:UMuteButton = new UMuteButton();
			umuteButton.id = WidgetIDs.UMUTE_BUTTON;
			umuteButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			umuteButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(umuteButton);
			
			// Spacer
			var afterVolumeSpacer:Widget = new Widget();
			afterVolumeSpacer.width = 5;
			rightControls.addChildWidget(afterVolumeSpacer);
			
			// FullScreen			
			var fullscreenLeaveButton:FullScreenLeaveButton = new FullScreenLeaveButton();
			fullscreenLeaveButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			fullscreenLeaveButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(fullscreenLeaveButton);
		
			fullscreenEnterButton.id = WidgetIDs.FULL_SCREEN_ENTER_BUTTON; 
			fullscreenEnterButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			fullscreenEnterButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(fullscreenEnterButton);
			
			bottomControls.addChildWidget(rightControls);
			
			// Spacer
			var afterFullscreenSpacer:Widget = new Widget();
			afterFullscreenSpacer.layoutMetadata.width = 13;
			bottomControls.addChildWidget(afterFullscreenSpacer);

			var filler:Widget = new Widget();

/*			var rightMargin:Widget = new Widget();
			rightMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_RIGHT;
			rightMargin.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			bottomControls.addChildWidget(rightMargin);			*/	

			addChildWidget(bottomControls);

			configureWidgets
				(	[ pauseButton, playButton, previousButton, nextButton, afterPlaySpacer
					, leftControls		
					, scrubBar, afterScrubSpacer
					, timeBackdrop, linkButton
					, timeViewWidget, afterTimeSpacer
					, hdIndicator, configButton, afterConfigSpacer, umuteButton, afterVolumeSpacer
					, fullscreenEnterButton, fullscreenLeaveButton, afterFullscreenSpacer
					, rightControls
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
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
	}
}