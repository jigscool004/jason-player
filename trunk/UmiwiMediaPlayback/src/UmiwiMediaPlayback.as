package
{
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.configuration.ConfigurationLoader;
	import org.osmf.player.configuration.PlayerConfiguration;
	import org.osmf.player.configuration.XMLFileLoader;
	import org.osmf.player.errors.ErrorTranslator;
	import org.osmf.player.media.StrobeMediaFactory;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.plugins.PluginLoader;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;

	[SWF(frameRate="25", backgroundColor="#FFFFFF")]
	public class UmiwiMediaPlayback extends Sprite
	{
		public function UmiwiMediaPlayback()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		
			initialize(loaderInfo.parameters, stage, loaderInfo, null);
		}
		
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
			
			var uc:UConfigurationLoader = new UConfigurationLoader();
			uc.getFlvInfo(parameters, loadConfigurationFromParameters);
			function loadConfigurationFromParameters(params:Object):void{
				videoInfoLoaded = true;
				configuration.src = params.src;
				configuration.poster = params.poster;
				loadMedia();
			}
			
			configuration = new PlayerConfiguration();
			
			var configurationXMLLoader:XMLFileLoader = new XMLFileLoader();
			var configurationLoader:ConfigurationLoader = new ConfigurationLoader(configurationXMLLoader);			
			configurationLoader.addEventListener(Event.COMPLETE, onConfigurationReady);			
			configurationLoader.load(parameters, configuration);
			
			function onConfigurationReady(event:Event):void
			{	
				CONFIG::LOGGING
				{
					logger.trackObject("PlayerConfiguration", configuration);	
					var p:uint = 0;
					for each(var pluginResource:MediaResourceBase in configuration.pluginConfigurations)
					{
						logger.trackObject("PluginResource"+(p++), pluginResource);
					}
				}
				
				initializeControl();			
				initializeView();	
				
				// After initialization, either load the assigned media, or
				// load requested plug-ins first, and then load the assigned
				// media:
				var pluginLoader:PluginLoader = new PluginLoader(configuration.pluginConfigurations, factory);
				pluginLoader.addEventListener(Event.COMPLETE, loadMedia);
				pluginLoader.loadPlugins();
			}	
		}
		
		private function initializeControl():void
		{
			// Construct a media factory and add support for playlists:
			factory = new StrobeMediaFactory(configuration);
			
			// Construct a media controller, and configure it:
			
			player = new StrobeMediaPlayer();
			CONFIG::LOGGING
			{
				player = new DebugStrobeMediaPlayer();
			}
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			player.autoPlay 			= configuration.autoPlay;
			player.loop 				= configuration.loop;
			player.autoSwitchQuality 	= configuration.autoSwitchQuality;	
			player.videoRenderingMode	= configuration.videoRenderingMode;
			player.highQualityThreshold	= configuration.highQualityThreshold;	
		}	
		
		private function initializeView():void
		{			
			// Set the SWF scale mode, and listen to the stage change
			// dimensions:
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, onStageResize);
			
			mainContainer = new MediaContainer();
			mainContainer.backgroundColor = configuration.backgroundColor;
			mainContainer.backgroundAlpha = 0;
			
			addChild(mainContainer);
			
			mediaContainer.clipChildren = true;
			mediaContainer.layoutMetadata.percentWidth = 100;
			mediaContainer.layoutMetadata.percentHeight = 100;
			
			mainContainer.layoutRenderer.addTarget(mediaContainer);
			
			var controlBar:Asset_toolBar = new Asset_toolBar();
			addChild(controlBar);
			// Simulate the stage resizing, to update the dimensions of the container:
			onStageResize();
		}		
		
		private function onStageResize(event:Event = null):void
		{
			// Propagate dimensions to the main container:
			mainContainer.width = _stage.stageWidth;
			mainContainer.height = _stage.stageHeight;
			
			// Propagate dimensions to the control bar:
/*			if (controlBar != null)
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
			}*/
		}		
		
		public function loadMedia(..._):void
		{	
			
			//Show buffering overlay.
			if(configuration.src == null || configuration.src == "")
			{
				return;
			}
			var resource:StreamingURLResource = new StreamingURLResource(configuration.src);
			resource.streamType = configuration.streamType;
			resource.urlIncludesFMSApplicationInstance = configuration.urlIncludesFMSApplicationInstance;
			
			// Add the configuration metadata to the resource.
			// Transform the Object to Metadata instance.
			for (var namespace:String in configuration.assetMetadata)
			{
				resource.addMetadataValue(namespace, configuration.assetMetadata[namespace]);
			}
			CONFIG::LOGGING
			{
				logger.trackResource("AssetResource", resource);		
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
				
				processPoster();
			}	
			
			return processedMedia;
		}
		
		private function set media(value:MediaElement):void
		{
			
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
					
/*					// Forward a reference to controlBar:
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
					}*/
					
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
/*					if (playOverlay != null)
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
					}*/
				}
			}			
		}
		
		private function onFullScreen(event:FullScreenEvent):void
		{				
			var scaleFactor:Number;
			
			if (_stage.displayState == StageDisplayState.NORMAL) 
			{		
/*				if (controlBar)
				{										
					// Set the autoHide property to the value set by the user.
					// If the autoHide property changed we need to adjust the layout settings
					if (controlBar.autoHide!=configuration.controlBarAutoHide)
					{
						controlBar.autoHide = configuration.controlBarAutoHide;	
						layout();
					}
				}*/
				Mouse.show();	
			}
			else if (_stage.displayState == StageDisplayState.FULL_SCREEN)
			{	
/*				if (controlBar)
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
				}*/
				addChild(mainContainer);	
				mainContainer.validateNow();			
			}
		}		
		
		private function onFullScreenRequest(event:Event=null):void
		{
			if (_stage.displayState == StageDisplayState.NORMAL) 
			{				
				removeChild(mainContainer);
				_stage.fullScreenSourceRect = player.getFullScreenSourceRect(_stage.fullScreenWidth, _stage.fullScreenHeight);
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
					addChildAt(mainContainer, 0);	
					mainContainer.validateNow();
				}
			}
			else				
			{
				_stage.displayState = StageDisplayState.NORMAL;
			}			
		}
		
		private function processPoster():void
		{
			// Show a poster if there's one set, and the content is not yet playing back:
			if 	(	configuration
				&&	configuration.poster != null
				&&	configuration.poster != ""
				&&	configuration.autoPlay == false
				&&	player.playing == false
			)
			{
				try
				{
					posterImage = new ImageElement(new URLResource(configuration.poster));
					
					// Setup the poster image:
					posterImage.smoothing = true;
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
							
							// Remove the poster image:
							mediaContainer.removeMediaElement(posterImage);
							LoadTrait(posterImage.getTrait(MediaTraitType.LOAD)).unload();
							posterImage = null;
						}
					}
				}
				catch (error:Error)
				{
					// Fail poster loading silently:
					trace("WARNING: poster image failed to load at", configuration.poster);
				}
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
			
			
			trace("Error:", message); 
			
			
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
				}
				catch(_:Error)
				{
					trace(_.toString());
				}
			}
		}	
		public var factory:StrobeMediaFactory;		
		public var configuration:PlayerConfiguration;
		public var player:StrobeMediaPlayer;
		
		private var pluginHostWhitelist:Vector.<String>;
		private var mainContainer:MediaContainer;
		private var mediaContainer:MediaContainer = new MediaContainer();	
		private var posterImage:ImageElement;
		private var _media:MediaElement;
		private var _stage:Stage;
		private var _loaderInfo:LoaderInfo;
		private var videoInfoLoaded:Boolean = false;
		
		private static const POSTER_INDEX:int = 2;
		private static const MEDIA_PLAYER:String = "org.osmf.media.MediaPlayer";
		
		private static const EXTERNAL_INTERFACE_ERROR_CALL:String
		= "function(playerId, code, message, detail)"
			+ "{"
			+ "	if (onMediaPlaybackError != null)"
			+ "		onMediaPlaybackError(playerId, code, message, detail);"
			+ "}";		
	}
}