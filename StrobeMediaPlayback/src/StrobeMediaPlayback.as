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

package
{	
	import com.umiwi.control.MediaConfiguration;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.SecurityDomain;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.*;
	import org.osmf.events.*;
	import org.osmf.layout.*;
	import org.osmf.media.*;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.chrome.ConfigPanel;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.chrome.events.WidgetEvent;
	import org.osmf.player.chrome.widgets.BufferingOverlay;
	import org.osmf.player.chrome.widgets.PlayButtonOverlay;
	import org.osmf.player.chrome.widgets.VideoInfoOverlay;
	import org.osmf.player.configuration.*;
	import org.osmf.player.containers.StrobeMediaContainer;
	import org.osmf.player.elements.*;
	import org.osmf.player.elements.playlistClasses.*;
	import org.osmf.player.errors.*;
	import org.osmf.player.media.*;
	import org.osmf.player.metadata.StrobeDynamicMetadata;
	import org.osmf.player.plugins.PluginLoader;
	import org.osmf.player.utils.StrobePlayerStrings;
	import org.osmf.player.utils.StrobeUtils;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.OSMFStrings;
	
	CONFIG::LOGGING
	{
		import org.osmf.player.debug.DebugStrobeMediaPlayer;
		import org.osmf.player.debug.LogHandler;
		import org.osmf.player.debug.StrobeLoggerFactory;
		import org.osmf.player.debug.StrobeLogger;
		import org.osmf.logging.Log;
		import org.osmf.elements.LightweightVideoElement;
	}
	/**
	 * StrobeMediaPlayback is responsible for initializing a StrobeMediaPlayer and
	 * setting up the control bar behaviour and layout.
	 */
	[SWF(frameRate="25", backgroundColor="#000000")]
	public class StrobeMediaPlayback extends Sprite
	{
		// These should be accessible from the preloader for the performance measurement to work.
		public var configuration:PlayerConfiguration;
		public var player:StrobeMediaPlayer;		
		public var factory:StrobeMediaFactory;		
		
		public function StrobeMediaPlayback()
		{			
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
			CONFIG::LOGGING
			{
				// Setup the custom logging factory 
				Log.loggerFactory = new StrobeLoggerFactory(new LogHandler(false));
				logger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
			}
		}
		
		/**
		 * Initializes the player with the parameters and it's context (stage).
		 * 
		 * We need the stage at this point because we need 
		 * to setup the fullscreen event handlers in the initialization phase.
		 */ 
		public function initialize(parameters:Object, stage:Stage, loaderInfo:LoaderInfo, pluginHostWhitelist:Array):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Keep a reference to the stage (when a preloader is used, the
			// local stage property is null at this time):
			if (stage != null)
			{				
				_stage = stage;
			}
			
			// Keep a reference to the stage (when a preloader is used, the
			// local stage property is null at this time):
			if (loaderInfo != null)
			{				
				_loaderInfo = loaderInfo;
			}
			
					
			this.pluginHostWhitelist = new Vector.<String>();
			if (pluginHostWhitelist)
			{				
				for each(var pluginHost:String in pluginHostWhitelist)
				{
					this.pluginHostWhitelist.push(pluginHost);
				}
				
				// Add the current domain only if the pluginHostWhitelist != null 
				// (since for null we want to disable the whitelist protection).
				var currentDomain:String = StrobeUtils.retrieveHostNameFromUrl(loaderInfo.loaderURL);
				this.pluginHostWhitelist.push(currentDomain);
			}
			
			CONFIG::FLASH_10_1
			{
    			//Register the global error handler.
				if (_loaderInfo != null && _loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
				{
					_loaderInfo["uncaughtErrorEvents"].addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
					
				}
			}
			
			var uc:UConfigurationLoader = new UConfigurationLoader();
			uc.getFlvInfo(parameters, loadConfigurationFromParameters);
			function loadConfigurationFromParameters(params:Object):void{
				videoInfoLoaded = true;
				configuration.src = params.src;
				configuration.poster = params.poster;
			    loadMedia();
			}

			//stage.removeChild(loadingDisplay);
			var assetManager:AssetsManager = new AssetsManager();
			
			injector = new InjectorModule();
			var configurationLoader:ConfigurationLoader = injector.getInstance(ConfigurationLoader);
			
			configurationLoader.addEventListener(Event.COMPLETE, onConfigurationReady);			
			
			configuration = injector.getInstance(PlayerConfiguration);
			
			player = injector.getInstance(MediaPlayer);
			
			player.addEventListener(TimeEvent.COMPLETE, onComplete);
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			
			configurationLoader.load(parameters, configuration);	
			
			function onConfigurationReady(event:Event):void
			{				
				OSMFSettings.enableStageVideo = configuration.enableStageVideo;
				
				CONFIG::LOGGING
				{
					logger.trackObject("PlayerConfiguration", configuration);
				}
				
				if (configuration.skin != null && configuration.skin != "")
				{
					var skinLoader:XMLFileLoader = new XMLFileLoader();
					skinLoader.addEventListener(IOErrorEvent.IO_ERROR, onSkinLoaderFailure);
					skinLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSkinLoaderFailure);
					skinLoader.addEventListener(Event.COMPLETE, onSkinLoaderComplete);
					skinLoader.load(configuration.skin);
				}
				else
				{
					onSkinLoaderComplete();
				}
			}
			
			function onSkinLoaderComplete(event:Event = null):void
			{
				if (event != null)
				{
					var skinLoader:XMLFileLoader = event.target as XMLFileLoader;
					var skinParser:SkinParser = new SkinParser();
					skinParser.parse(skinLoader.xml, assetManager);
				}
				
				var chromeProvider:ChromeProvider = ChromeProvider.getInstance();
				chromeProvider.addEventListener(Event.COMPLETE, onChromeProviderComplete);
				if (chromeProvider.loaded == false && chromeProvider.loading == false)
				{
					chromeProvider.load(assetManager);
				}
				else
				{
					onChromeProviderComplete();
				}
			}
			
			function onSkinLoaderFailure(event:Event):void
			{
				trace("WARNING: failed to load skin file at " + configuration.skin);
				onSkinLoaderComplete();
			}
			
			if (configuration.javascriptCallbackFunction != "" && ExternalInterface.available && mediaPlayerJSBridge == null)
			{
				mediaPlayerJSBridge = new JavaScriptBridge(this, player, StrobeMediaPlayer, configuration.javascriptCallbackFunction);			
			}			
		}
		
		// Internals
		//
		private function onChromeProviderComplete(event:Event = null):void
		{			
			initializeView();	
			
			// After initialization, either load the assigned media, or
			// load requested plug-ins first, and then load the assigned
			// media:
			var pluginConfigurations:Vector.<MediaResourceBase> = ConfigurationUtils.transformDynamicObjectToMediaResourceBases(configuration.plugins);
			
			CONFIG::LOGGING
			{	
				var p:uint = 0;
				for each(var pluginResource:MediaResourceBase in pluginConfigurations)
				{
					logger.trackObject("PluginResource"+(p++), pluginResource);
				}
			}
			
			// EXPERIMENTAL: Ad plugin integration
			for each(var pluginResource:MediaResourceBase in pluginConfigurations)
			{
				pluginResource.addMetadataValue("MediaContainer", mediaContainer);
				pluginResource.addMetadataValue("MediaPlayer", player);
			}
			
			var pluginLoader:PluginLoader;
			factory = injector.getInstance(MediaFactory);
			pluginLoader = new PluginLoader(pluginConfigurations, factory, pluginHostWhitelist);
			pluginLoader.haltOnError = configuration.haltOnError;
			
			pluginLoader.addEventListener(Event.COMPLETE, loadMedia);
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			pluginLoader.loadPlugins();
		}			
		
		private function initializeView():void
		{			
			// Set the SWF scale mode, and listen to the stage change
			// dimensions:
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, onStageResize);
			
			mainContainer = new StrobeMediaContainer();
			mainContainer.backgroundColor = configuration.backgroundColor;
			mainContainer.backgroundAlpha = 0;
			
			addChild(mainContainer);
			
			mediaContainer.clipChildren = true;
			mediaContainer.layoutMetadata.percentWidth = 100;
			mediaContainer.layoutMetadata.percentHeight = 100;
			
			controlBarContainer = new MediaContainer();
			controlBarContainer.layoutMetadata.percentWidth = 100;
			controlBarContainer.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			controlBarContainer.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			
			// Setup play button overlay:
			if (configuration.playButtonOverlay == true)
			{
				playOverlay = new PlayButtonOverlay();
				playOverlay.configure(<default/>, ChromeProvider.getInstance().assetManager);
				playOverlay.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
				playOverlay.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
				playOverlay.layoutMetadata.index = PLAY_OVERLAY_INDEX;
				playOverlay.fadeSteps = OVERLAY_FADE_STEPS;
				mediaContainer.layoutRenderer.addTarget(playOverlay);
			}
			
			// Setup buffer overlay:
			if (configuration.bufferingOverlay == true)
			{
				bufferingOverlay = new BufferingOverlay();
				bufferingOverlay.configure(<default/>, ChromeProvider.getInstance().assetManager);
				bufferingOverlay.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
				bufferingOverlay.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
				bufferingOverlay.layoutMetadata.index = BUFFERING_OVERLAY_INDEX;
				bufferingOverlay.fadeSteps = OVERLAY_FADE_STEPS;
				mediaContainer.layoutRenderer.addTarget(bufferingOverlay);
			}
				
			// Setup alert dialog:
			alert = new AlertDialogElement();
			alert.tintColor = configuration.tintColor;				
			
			// Setup authentication dialog:
/*			loginWindow = new AuthenticationDialogElement();
			loginWindow.tintColor = configuration.tintColor;
			
			loginWindowContainer = new MediaContainer();
			loginWindowContainer.layoutMetadata.index = ALWAYS_ON_TOP;
			loginWindowContainer.layoutMetadata.percentWidth = 100;
			loginWindowContainer.layoutMetadata.percentHeight = 100;
			loginWindowContainer.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			loginWindowContainer.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			
			loginWindowContainer.addMediaElement(loginWindow);*/
			
			if (configuration.controlBarMode == ControlBarMode.NONE)
			{
				mainContainer.layoutMetadata.layoutMode = LayoutMode.NONE;
			}
			else
			{
				// Setup control bar:
				controlBar = new ControlBarElement();
				controlBar.autoHide = configuration.controlBarAutoHide;
				controlBar.autoHideTimeout = configuration.controlBarAutoHideTimeout * 1000;
				controlBar.tintColor = configuration.tintColor;
				
				layout();
				
				controlBarContainer.layoutMetadata.height = controlBar.height;
				controlBarContainer.addMediaElement(controlBar);
				controlBarContainer.addEventListener(WidgetEvent.REQUEST_FULL_SCREEN, onFullScreenRequest);
				
				mainContainer.layoutRenderer.addTarget(controlBarContainer);
				//mediaContainer.layoutRenderer.addTarget(loginWindowContainer);
			}	
			
			mainContainer.layoutRenderer.addTarget(mediaContainer);
			CONFIG::FLASH_10_1
			{
				var qosOverlay:VideoInfoOverlay = new VideoInfoOverlay();			
				qosOverlay.register(controlBarContainer, mainContainer, player);
				if (configuration.showVideoInfoOverlayOnStartUp)
				{
					qosOverlay.showInfo();
				}
			}
			
			configPanel = new ConfigPanel();
			configPanel.configure(<default/>, ChromeProvider.getInstance().assetManager);
			configPanel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			configPanel.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			configPanel.layoutMetadata.index = CONFIG_OVERLAY_INDEX;
			configPanel.fadeSteps = OVERLAY_FADE_STEPS;
			mediaContainer.layoutRenderer.addTarget(configPanel);
			configPanel.register(controlBarContainer, mainContainer, player);
			configPanel.visible = false;
			
			
			// Simulate the stage resizing, to update the dimensions of the container:
			onStageResize();
		}
		
		/**
		 * Loads the media or displays an error message on fail.
		 */ 
		public function loadMedia(..._):void
		{	
			// Try to load the URL set on the configuration:
			var resource:MediaResourceBase  = injector.getInstance(MediaResourceBase);

			CONFIG::LOGGING
			{
				logger.trackObject("AssetResource", resource);		
			}
			
			media = factory.createMediaElement(resource);
			if (_media == null)
			{
				var mediaError:MediaError
					= new MediaError
						( MediaErrorCodes.MEDIA_LOAD_FAILED
						, OSMFStrings.CAPABILITY_NOT_SUPPORTED
						);
					
				player.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, mediaError
						)
					);
			}
		}
		
		private function processNewMedia(value:MediaElement):MediaElement
		{
			var processedMedia:MediaElement;			
			
			if (value != null)
			{
				processedMedia = value;
				var layoutMetadata:LayoutMetadata = processedMedia.metadata.getValue(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
				if (layoutMetadata == null)
				{
					layoutMetadata = new LayoutMetadata();
					processedMedia.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);	
				} 
				
				layoutMetadata.scaleMode = configuration.scaleMode;
				layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
				layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
				layoutMetadata.percentWidth = 100;
				layoutMetadata.percentHeight = 100;
				layoutMetadata.index = 1;  
				if 	(	configuration
					&&	configuration.poster != null
					&&	configuration.poster != ""
					&&	player.autoPlay == false
					&&	player.playing == false
				)
				{
					if (configuration.endOfVideoOverlay == "")
					{
						configuration.endOfVideoOverlay = configuration.poster;
					}
					processPoster(configuration.poster);
				}
				processedMedia.metadata.addValue(MEDIA_PLAYER, player);
			}	
			
			return processedMedia;
		}
		
		private function layout():void
		{	
			controlBarContainer.layoutMetadata.index = ON_TOP;

			if	(	controlBar.autoHide == false
				&&	configuration.controlBarMode == ControlBarMode.DOCKED
				)
			{
				// Use a vertical layout:
				mainContainer.layoutMetadata.layoutMode = LayoutMode.VERTICAL;
				mediaContainer.layoutMetadata.index = 1;
			}
			else
			{
				mainContainer.layoutMetadata.layoutMode = LayoutMode.NONE;
				switch(configuration.controlBarMode)
				{
					case ControlBarMode.FLOATING:
						controlBarContainer.layoutMetadata.bottom = POSITION_OVER_OFFSET;
						break;
					case ControlBarMode.DOCKED:
						controlBarContainer.layoutMetadata.bottom = 0;
						break;
				}
			}
		}
		
		private function set media(value:MediaElement):void
		{
			if (alert && mediaContainer.containsMediaElement(alert))
			{				
				mediaContainer.removeMediaElement(alert);
				initializeView();
			}
			
			if (value != _media)
			{
				// Remove the current media from the container:
				if (_media)
				{					
					mediaContainer.removeMediaElement(_media);
				}

				var processedNewValue:MediaElement = processNewMedia(value);
				if (processedNewValue)
				{
					value = processedNewValue;
				}
				
				// Set the new main media element:
				_media = player.media = value;
				
				if (_media)
				{										
					// Add the media to the media container:
					mediaContainer.addMediaElement(_media);
					
					// Forward a reference to controlBar:
					if (controlBar != null)
					{
						controlBar.target = _media;
					}
					
					// Forward a reference to the play overlay:
					if (playOverlay != null)
					{
						playOverlay.media = _media;
					}
					
					// Forward a reference to the buffering overlay:
					if (bufferingOverlay != null)
					{
						bufferingOverlay.media = _media;
						if (!videoInfoLoaded)
						{
							bufferingOverlay.visible = true;
						}
					}
					
					if (configPanel != null)
					{
						configPanel.media = _media;
					}
					
					// Forward a reference to login window:
/*					if (loginWindow != null)
					{
						loginWindow.target = _media;
					}*/
					
					_stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
					mainContainer.addEventListener(MouseEvent.DOUBLE_CLICK, onFullScreenRequest);
					mediaContainer.doubleClickEnabled = true;
					mainContainer.doubleClickEnabled = true;
				}
				else
				{
					if (playOverlay != null)
					{
						playOverlay.media = null;
					}
					
					if (bufferingOverlay != null)
					{
						bufferingOverlay.media = null;
					}
					
					if (configPanel != null)
					{
						configPanel.media = null;
					}
				}
			}			
		}
		
		private function processPoster(posterUrl:String):void
		{
			// Show a poster if there's one set, and the content is not yet playing back:	
			try
			{
				if (posterImage)
				{
					removePoster();
				}
				
				posterImage = new ImageElement(new URLResource(posterUrl), new ImageLoader(false));
				
				// Setup the poster image:
				//posterImage.smoothing = true;
				var layoutMetadata:LayoutMetadata = new LayoutMetadata();
				layoutMetadata.scaleMode = configuration.scaleMode;
				layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
				layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
				layoutMetadata.percentWidth = 100;
				layoutMetadata.percentHeight = 100;
				layoutMetadata.index = POSTER_INDEX;  
				posterImage.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
				LoadTrait(posterImage.getTrait(MediaTraitType.LOAD)).load();
				mediaContainer.addMediaElement(posterImage);
				
				// Listen for the main content player to reach a playing, or playback error
				// state. At that time, we remove the poster:
				player.addEventListener
					( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE
					, onMediaPlayerStateChange
					);
					
				function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
				{
					if	(	event.state == MediaPlayerState.PLAYING
						||	event.state == MediaPlayerState.PLAYBACK_ERROR
						)
					{
						// Make sure this event is processed only once:
						player.removeEventListener(event.type, arguments.callee);
						
						removePoster();
					}
				}
			}
			catch (error:Error)
			{
				// Fail poster loading silently:
				trace("WARNING: poster image failed to load at", configuration.poster);
			}			
		}
		
		public function removePoster():void
		{
			// Remove the poster image:
			if (posterImage != null)
			{
				mediaContainer.removeMediaElement(posterImage);
				LoadTrait(posterImage.getTrait(MediaTraitType.LOAD)).unload();
			}
			posterImage = null;
		}
		// Handlers
		//
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		
			initialize(loaderInfo.parameters, stage, loaderInfo, null);
		}
	
		/**
		 * Toggles full screen state.
		 */ 
		private function onFullScreenRequest(event:Event=null):void
		{
			if (_stage.displayState == StageDisplayState.NORMAL) 
			{
				
				// NOTE: Exploration code - exploring some issues arround full screen and stage video
				if (!(OSMFSettings.enableStageVideo && OSMFSettings.supportsStageVideo)
					|| configuration.removeContentFromStageOnFullScreenWithStageVideo)
				{
					removeChild(mainContainer);					
				}
				
				// NOTE: Exploration code - exploring some issues arround full screen and stage video
				if (!(OSMFSettings.enableStageVideo && OSMFSettings.supportsStageVideo)
					|| configuration.useFullScreenSourceRectOnFullScreenWithStageVideo)
				{
					_stage.fullScreenSourceRect = player.getFullScreenSourceRect(_stage.fullScreenWidth, _stage.fullScreenHeight);				
				}				
				
				CONFIG::LOGGING
				{	
					if (_stage.fullScreenSourceRect != null)
					{
						logger.info("Setting fullScreenSourceRect = {0}", _stage.fullScreenSourceRect.toString());
					}
					else
					{
						logger.info("fullScreenSourceRect not set.");
					}
					if (_stage.fullScreenSourceRect !=null)
					{
						logger.qos.rendering.fullScreenSourceRect = 
							_stage.fullScreenSourceRect.toString();
						logger.qos.rendering.fullScreenSourceRectAspectRatio = _stage.fullScreenSourceRect.width / _stage.fullScreenSourceRect.height;
					}
					else
					{
						logger.qos.rendering.fullScreenSourceRect =	"";
						logger.qos.rendering.fullScreenSourceRectAspectRatio = NaN;
					}
					logger.qos.rendering.screenWidth = _stage.fullScreenWidth;
					logger.qos.rendering.screenHeight = _stage.fullScreenHeight;
					logger.qos.rendering.screenAspectRatio = logger.qos.rendering.screenWidth  / logger.qos.rendering.screenHeight;
				}
				
				try
				{
					_stage.displayState = StageDisplayState.FULL_SCREEN;
				}
				catch (error:SecurityError)
				{
					CONFIG::LOGGING
					{	
						logger.info("Failed to go to FullScreen. Check if allowfullscreen is set to false in HTML page.");
					}
					// This exception is thrown when the allowfullscreen is set to false in HTML
					addChild(mainContainer);	
					mainContainer.validateNow();
				}
			}
			else				
			{
				_stage.displayState = StageDisplayState.NORMAL;
			}			
		}
		
		/**
		 * FullScreen state changed handler.
		 */ 
		private function onFullScreen(event:FullScreenEvent):void
		{				
			if (_stage.displayState == StageDisplayState.NORMAL) 
			{		
				if (controlBar)
				{										
					// Set the autoHide property to the value set by the user.
					// If the autoHide property changed we need to adjust the layout settings
					if (controlBar.autoHide!=configuration.controlBarAutoHide)
					{
						controlBar.autoHide = configuration.controlBarAutoHide;	
						layout();
					}
				}
				Mouse.show();	
			}
			else if (_stage.displayState == StageDisplayState.FULL_SCREEN)
			{	
				if (controlBar)
				{
					// We force the autohide of the controlBar in fullscreen
					controlBarWidth = controlBar.width;
					controlBarHeight = controlBar.height;
					
					controlBar.autoHide = true;		
					// If the autoHide property changed we need to adjust the layout settings					
					if (controlBar.autoHide!=configuration.controlBarAutoHide)
					{
						layout();
					}
				}
				
				// NOTE: Exploration code - exploring some issues arround full screen and stage video
				if (!(OSMFSettings.enableStageVideo && OSMFSettings.supportsStageVideo)
					|| configuration.removeContentFromStageOnFullScreenWithStageVideo)
				{
					addChild(mainContainer);				
				}
				
				mainContainer.validateNow();			
			}
			
		}
		
		private function onStageResize(event:Event = null):void
		{
			// Propagate dimensions to the main container:
			mainContainer.width = _stage.stageWidth;
			mainContainer.height = _stage.stageHeight;
			
			// Propagate dimensions to the control bar:
			if (controlBar != null)
			{
				if	(	configuration.controlBarMode != ControlBarMode.FLOATING
					||	controlBar.width > _stage.stageWidth
					||	_stage.stageWidth < MAX_OVER_WIDTH
					)
				{
					controlBar.width = _stage.stageWidth;
				}
				else if (configuration.controlBarMode == ControlBarMode.FLOATING)
				{
					controlBar.width = MAX_OVER_WIDTH;
				}				
			}
		}
		CONFIG::FLASH_10_1
		{
			private function onUncaughtError(event:UncaughtErrorEvent):void
			{
				event.preventDefault();
				var timer:Timer = new Timer(3000, 1);
				var mediaError:MediaError
					= new MediaError(StrobePlayerErrorCodes.UNKNOWN_ERROR
						, event.error.name + " - " + event.error.message);
				
				timer.addEventListener
					( 	TimerEvent.TIMER 
					,	function(event:Event):void
						{
							onMediaError
								( new MediaErrorEvent
									( MediaErrorEvent.MEDIA_ERROR
									, false
									, false
									, mediaError
									)
								);
						}
				);
				timer.start();
			}
		}
		
		private function onComplete(event:TimeEvent):void
		{
			if 	(	configuration
				&&	configuration.endOfVideoOverlay != null
				&&	configuration.endOfVideoOverlay != ""
				&&	player.loop == false
				&&	player.playing == false
			)
			{
				processPoster(configuration.endOfVideoOverlay);
			}	
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			// Make sure this event gets handled only once:
			player.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			
			// Reset the current media:
			player.media = null;
			media = null;		
			
			// Translate error message:
			var message:String;
			if (configuration.verbose)
			{
				message = event.error.message + "\n" + event.error.detail;
			}
			else
			{
				message = ErrorTranslator.translate(event.error).message;
			}
			
			CONFIG::FLASH_10_1
			{
				var tokens:Array = Capabilities.version.split(/[\s,]/);
				var flashPlayerMajorVersion:int = parseInt(tokens[1]);
				var flashPlayerMinorVersion:int = parseInt(tokens[2]);
				if (flashPlayerMajorVersion < 10 || (flashPlayerMajorVersion  == 10 && flashPlayerMinorVersion < 1))
				{
					if (configuration.verbose)
					{
						message += "\n\nThe content that you are trying to play requires the latest Flash Player version.\nPlease upgrade and try again.";	
					}
					else
					{
						message = "The content that you are trying to play requires the latest Flash Player version.\nPlease upgrade and try again.";
					}								
				}
			}
			
			// If an alert widget is available, use it. Otherwise, trace the message:
			if (alert)
			{
				if (_media != null && mediaContainer.containsMediaElement(_media))
				{
					mediaContainer.removeMediaElement(_media);
				}
				if (controlBar != null && controlBarContainer.containsMediaElement(controlBar))
				{
					controlBarContainer.removeMediaElement(controlBar);
				}
				if (posterImage && mediaContainer.containsMediaElement(posterImage))
				{
					mediaContainer.removeMediaElement(posterImage);
				}
				if (playOverlay != null && mediaContainer.layoutRenderer.hasTarget(playOverlay))
				{
					mediaContainer.layoutRenderer.removeTarget(playOverlay);
				}
				if (bufferingOverlay != null && mediaContainer.layoutRenderer.hasTarget(bufferingOverlay))
				{
					mediaContainer.layoutRenderer.removeTarget(bufferingOverlay);
				}
				
				mediaContainer.addMediaElement(alert);
				alert.alert("Error", message);
			}
			else
			{
				trace("Error:", message); 
			}
			
		
			
			
			// Forward the raw error message to JavaScript:
			if (ExternalInterface.available)
			{
				try
				{	
					ExternalInterface.call
						( EXTERNAL_INTERFACE_ERROR_CALL
							, ExternalInterface.objectID
							, event.error.errorID, event.error.message, event.error.detail
						);
					
					//JavaScriptBridge.call(["org.strobemediaplayback.triggerHandler", ExternalInterface.objectID, "error", {}]);	
					JavaScriptBridge.error(event);					
				}
				catch(_:Error)
				{
					trace(_.toString());
				}
			}
		}
		
		private var _stage:Stage;
		private var _loaderInfo:LoaderInfo;		
		
		private var injector:InjectorModule;
		private var pluginHostWhitelist:Vector.<String>;
		
		private var mediaPlayerJSBridge: JavaScriptBridge = null;
		private var mainContainer:StrobeMediaContainer;
		private var mediaContainer:MediaContainer = new MediaContainer();;
		private var controlBarContainer:MediaContainer;
		//private var loginWindowContainer:MediaContainer;
		private var _media:MediaElement;
		
		private var controlBar:ControlBarElement;
		private var configPanel:ConfigPanel
		private var alert:AlertDialogElement;
		//private var loginWindow:AuthenticationDialogElement;
		private var posterImage:ImageElement;
		private var playOverlay:PlayButtonOverlay;
		private var bufferingOverlay:BufferingOverlay;
		
		private var controlBarWidth:Number;
		private var controlBarHeight:Number;
		
		/* static */
		private static const ALWAYS_ON_TOP:int = 9999;
		private static const ON_TOP:int = 9998;
		private static const POSITION_OVER_OFFSET:int = 20;
		private static const MAX_OVER_WIDTH:int = 400;
		private static const POSTER_INDEX:int = 2;
		private static const PLAY_OVERLAY_INDEX:int = 3;
		private static const BUFFERING_OVERLAY_INDEX:int = 4;
		private static const CONFIG_OVERLAY_INDEX:int = 5;
		private static const OVERLAY_FADE_STEPS:int = 6;
		private static const MEDIA_PLAYER:String = "org.osmf.media.MediaPlayer";
		
		private var videoInfoLoaded:Boolean = false;
		
		private static const EXTERNAL_INTERFACE_ERROR_CALL:String
		 	= "function(playerId, code, message, detail)"
			+ "{"
			+ "	if (onMediaPlaybackError != null)"
			+ "		onMediaPlaybackError(playerId, code, message, detail);"
			+ "}";
		
		CONFIG::LOGGING
		{
			protected var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		}
	}
}                    
