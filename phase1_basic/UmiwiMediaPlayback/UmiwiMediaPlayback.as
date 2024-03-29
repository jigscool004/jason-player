﻿package
{
	import com.umiwi.control.TraitControl;
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.player.configuration.ConfigurationLoader;
	import org.osmf.player.configuration.PlayerConfiguration;
	import org.osmf.player.configuration.XMLFileLoader;
	import org.osmf.player.errors.ErrorTranslator;
	import org.osmf.player.media.StrobeMediaFactory;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.plugins.PluginLoader;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="25", width="610", height="523")]
	public class UmiwiMediaPlayback extends Sprite
	{
		public function UmiwiMediaPlayback()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//initialize(loaderInfo.parameters, stage, loaderInfo, null);
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
			
			Security.allowDomain("*.csbew.com");
			Security.allowDomain("*.acs86.com");
			Security.allowDomain("*.umiwi.com");
			Security.loadPolicyFile("http://upload.umiwi.com/crossdomain.xml");
			
			
			uc.getFlvInfo(parameters, loadConfigurationFromParameters);
			function loadConfigurationFromParameters(params:Object):void{
				videoInfoLoaded = true;
				if(params.autoPlay == "0")
				{
					configuration.autoPlay = false;
				}
				else
				{
					configuration.autoPlay = true;
				}
				if(configuration.src != params.src)
				{
					configuration.src = params.src;
					configuration.poster = params.poster;
					loadMedia();
				}
				uc.getRecommendFlv(params, loadRecommendFlv);
				function loadRecommendFlv(params:XML):void
				{
					for (var i:int=0; i <params.Item.length(); i++) 
					{
						var xmlItem:XML = params.Item[i];
						loadPic(xmlItem.@thumburl,miniatureMC["loader"+(i%4)].childLoader);
						miniatureMC["loader"+(i%3)].title.text=xmlItem.@title.toString();
						miniatureMC["loader"+(i%3)].visible=true;
						var timeDuration:String = FormatUtils.convertTime(xmlItem.@duration.toString());
						miniatureMC["loader"+(i%3)].otherMsg.text="时长:"+ timeDuration +"   播放:"+ xmlItem.@playcount.toString();
						miniatureMC["loader"+(i%3)].link = xmlItem.@link.toString();
						miniatureMC["loader"+(i%3)].wrapper.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent)
						{
							navigateToURL(new URLRequest(e.currentTarget.parent.link));
						});
					}
					if(params.Item.length() == 0)
					{
						miniatureMC.visible = false;
					}
					else if(params.Item.length() == 1)
					{
						miniatureMC.gotoAndStop(3);
					}
					else if(params.Item.length() == 2)
					{
						miniatureMC.gotoAndStop(2);
					}
					else
					{
						miniatureMC.gotoAndStop(1);
					}
				}
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
			ControlUtil.configuration = this.configuration;
			
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, onStageResize);
			
			mainContainer = new MediaContainer();
			mainContainer.backgroundColor = configuration.backgroundColor;
			mainContainer.backgroundAlpha = 0;
			
		    addChildAt(mainContainer, 0);
			
			mediaContainer.clipChildren = true;
			mediaContainer.layoutMetadata.percentWidth = 100;
			mediaContainer.layoutMetadata.height = _stage.height - toolBar.toolBarBack.height;
			mediaContainer.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			mainContainer.layoutRenderer.addTarget(mediaContainer);
			mainContainer.measure();
			initAssets();
			// Simulate the stage resizing, to update the dimensions of the container:
			onStageResize();
		}
		
		private function initAssets():void
		{
			ad.visible = false;
			var myMenu:ContextMenu= new ContextMenu();
			myMenu.hideBuiltInItems();
			this.contextMenu=myMenu;
			var swfURL = this.loaderInfo.url;
			isUmiwi = (swfURL.indexOf('www.umiwi.com') != -1);
			
			//trace(swfURL);
			
			iisPath="http://www.umiwi.com/player/";
			
			
			UConfigurationLoader.updateMsg('iisPath='+iisPath);
			
			//初始化大播放按钮不可见
			bigPlayBtn.visible=false;
			//场景底部预留给工具条的高度
			bottomHeight=toolBar.toolBarBack.height;
			//loading flvID
			bufferingMC.visible = true;
			
			
/*			swfStage=localVideoMC.stage;
			swfStage.scaleMode=StageScaleMode.NO_SCALE;
			swfStage.align=StageAlign.TOP_LEFT;
			swfStage.addEventListener(Event.RESIZE,function()
			{
				centerBufferingMC();
				resizeDisplay();
			});*/
			toolBar.brightNessBtn.adjustBar.visible=false;
			//初始化推荐视频不可见
			miniatureMC.visible=false;
			toolBar.scrubBar.visible = false;
					
			toolBar.umiwilink.visible = true;//isOut = (this.loaderInfo.parameters.out == '1');
			toolBar.umiwilink.buttonMode = true;
			toolBar.umiwilink.addEventListener(MouseEvent.CLICK,function()
			{
				var d = new Date();
				var m = d.getMonth()+1;
				var year = d.getFullYear();
				var day = d.getDate();
				if ( m < 10) m = '0'+m;
				if ( day < 10) day = '0'+day;
				year = year%100;
				navigateToURL(new URLRequest('http://www.umiwi.com/?utm_source=umv&utm_medium=videoshare&utm_content='+_loaderInfo.parameters.flvID+'&utm_campaign='+year+m+day));
			});
            
            if(configuration.colorFilter == "reverse")
            {
                var filterObj:ColorMatrixFilter = new ColorMatrixFilter();    
                filterObj.matrix = new Array(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0);  
                
                
                
                for(var i:int=0; i<toolBar.numChildren; i++)
                {
                    toolBar.getChildAt(i).filters = [filterObj];
                }
                //toolBar.filters = [filterObj]; 
                
                //bufferingMC.filters = [filterObj]; 
                
                
                var matrix:Array = new Array();
                matrix = matrix.concat([1, 0, 0, 0, 0]); // red
                matrix = matrix.concat([0, 1, 0, 0, 0]); // green
                matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
                matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
                var rawFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
                toolBar.umiwilink.filters = [rawFilter];
                toolBar.umiwilink.gotoAndStop(3);
            }
			
			controlUtil = new ControlUtil(this);
			
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
			onMouseMove();
			
		}
		
		private function onStageResize(event:Event = null):void
		{

			mainContainer.width = _stage.stageWidth;
			mainContainer.height = _stage.stageHeight;
			
			
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrameCallback);
		}		
		
		private function onEnterFrameCallback(event:Event):void{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameCallback);
			
			swfWidth=_stage.stageWidth;
			swfHeight=_stage.stageHeight;
			
			mediaContainer.width = _stage.stageWidth;
			bufferingMC.width = _stage.stageWidth;
			miniatureMC.x=(swfWidth-miniatureMC.width)/2;
			if(_stage.displayState == "fullScreen")
			{
				mediaContainer.height = _stage.stageHeight;
				bufferingMC.height = _stage.stageHeight;
				miniatureMC.y=(swfHeight-miniatureMC.height)/2;
			}else
			{
				mediaContainer.height = _stage.stageHeight - toolBar.toolBarBack.height;
				bufferingMC.height = _stage.stageHeight - toolBar.toolBarBack.height;
				miniatureMC.y=(swfHeight-toolBar.toolBarBack.height-miniatureMC.height)/2;
			}
			
			
			fullScrBtn.width = _stage.stageWidth;
			fullScrBtn.height = _stage.stageHeight;
			
			toolBar.y=swfHeight-toolBar.height-PADDING;			
			toolBar.toolBarBack.width=swfWidth;
			toolBar.fullScrBtn.x=toolBar.toolBarBack.width-37;
			toolBar.volumeButton.x=toolBar.fullScrBtn.x - toolBar.volumeButton.width -10;
			toolBar.brightNessBtn.x=toolBar.volumeButton.x-36.15;
			toolBar.umiwilink.x = toolBar.brightNessBtn.x - 128;			
			
			//toolBar.totalTime.x=toolBar.toolBarBack.width-71.4;
			
            if(swfWidth < 480)
            {
                if(swfWidth > 430)
                {
                    if(configuration.colorFilter == "reverse")
                    {
                        toolBar.umiwilink.gotoAndStop(4);
                    }
                    else
                    {
                        toolBar.umiwilink.gotoAndStop(2);
                    }
                }
                else
                {
                    toolBar.umiwilink.visible = false;
                }
                
            }	
			
			//缩放时进度条不可见
			//toolBar.scrubBar.scrubber.visible=toolBar.scrubBar.visible=toolBar.scrubBar.scrubBarPlayedTrack.visible=toolBar.scrubBar.scrubBarLoadedTrack.visible=false;
			//toolBar.scrubBar.width=toolBar.scrubBar.scrubBarTrack.width=toolBar.scrubBar.scrubBarPlayedTrack.width=toolBar.scrubBar.scrubBarLoadedTrack.width=mainContainer.width-20;
			toolBar.scrubBar.setWidth(swfWidth-20);
			
			bigPlayBtn.x=(swfWidth-bigPlayBtn.width) - 50;
			bigPlayBtn.y=(swfHeight-bigPlayBtn.height) - 37 - toolBar.toolBarBack.height;
			
		    localVideoMC.width = _stage.stageWidth;
			localVideoMC.height = _stage.stageHeight;
			
			this.setChildIndex(mainContainer, 0);
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
				
				unRegisterMedia(_media);
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
					
					registerMedia(_media);
					
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
		
		private function unRegisterMedia(media:MediaElement):void{
			if(media == null)
			{
				return;
			}
			_media.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
			_media.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
		}
		
		private function registerMedia(media:MediaElement):void{
			if(media == null)
			{
				return;
			}
			_media.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
			_media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
			onMediaElementTraitsChange(null);
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent = null):void
		{
			var element:MediaElement;
			if (event && event.target is MediaElement)
			{
				element = event.target as MediaElement
			} 
			else if(_media != null)
			{
				element = _media;
			}else
			{
				return;
			}
			//localVideoMC.backOfVideo.visible = false;
			
			var i:int;
			for(i=0; i<this.numChildren; i++)
			{
				if(this.getChildAt(i) is TraitControl)
				{
					(getChildAt(i) as TraitControl).setElement(element);
				}
			}
			
			for(i=0; i<toolBar.numChildren; i++)
			{
				if(toolBar.getChildAt(i) is TraitControl)
				{
					(toolBar.getChildAt(i) as TraitControl).setElement(element);
				}
			}
		
			controlUtil.setElement(element);
			
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
                    
                    (bufferingMC as TraitControl).setElement(posterImage);

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
		
		private function centerBufferingMC()
		{
			bufferingMC.x=Math.round((mainContainer.width-bufferingMC.width)/2);
			bufferingMC.y=Math.round((mainContainer.height-bufferingMC.height)/1.5);
		}
		
		private function showBuffering()
		{
			fadeIn(bufferingMC,300);
		}
		
		
		private function fadeIn(o:DisplayObject,time:uint,firstTime:Boolean = true)
		{
			o.visible = true;
/*			if (firstTime)
			{
				o.visible = true;
				if (o.fading)
				{
					try{clearTimeout(o.fadeTimer);} catch(e:Error){ }
				}
			}
			o.fading = true;
			var _step:Number = 40/time;
			o.alpha+=_step;
			if (o.alpha >= 1)
			{
				o.fading = false;
				o.alpha = 1;
				return;
			}
			else
			{
				o.fadeTimer = setTimeout(function()
				{
					fadeIn(o,time,false);
				},40);
			}*/
		}
		
		private var visibilityTimer:Timer;
		
		private static const VISIBILITY_DELAY:int = 3000;
		
		public function Toolbar()
		{

		}
		
		protected function onMouseMove(event:MouseEvent=null):void
		{
			toolBar.visible = true;
			if (visibilityTimer.running)
			{
				visibilityTimer.stop();
			}
			visibilityTimer.reset();
			if (stage.displayState == "fullScreen")
			{
				visibilityTimer.start();
			}
		}
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			if (stage.displayState == "fullScreen")
			{
				toolBar.visible = false;		
			}
		}
		
		private function onFullScreenEvent(event:FullScreenEvent):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				toolBar.visible = true;
			}
		}
		
		private function loadPic(url:String,mc:MovieClip):void
		{
			if (mc.getChildAt(0)!=null)
			{
				mc.removeChildAt(0);
			}
			var loader:Loader=new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(evt:Event)
			{
				if (isUmiwi)
				{
					var img:Bitmap = new Bitmap(evt.target.content.bitmapData);
					img.smoothing = true;
					img.width = 104;
					img.height = 78;
					mc.addChild(img);
				}
				else
				{
					loader.width = 104;
					loader.height = 78;
				}
			});
            
            try {
                loader.load(new URLRequest(url), new LoaderContext(true));
            } catch (error:Error) {
                UConfigurationLoader.updateMsg("Failed to get recommended thumbnail. " + error.message);
            }
			
			if (!isUmiwi) mc.addChild(loader);
		}
		
		public function stopPlay():void {
			
			UConfigurationLoader.updateMsg("Video stop");
			UConfigurationLoader.callExternal("video_play_over");
			
            if(configuration.showRecommend)
            {
                //显示推荐视频
                miniatureMC.visible=true;
            }

			
		}
		
		public function hideRecommend():void{
			miniatureMC.visible=false;
		}
		
		private var uc:UConfigurationLoader = new UConfigurationLoader();
		
		public var factory:StrobeMediaFactory;		
		public var configuration:PlayerConfiguration;
		public var player:StrobeMediaPlayer;
		
		private var pluginHostWhitelist:Vector.<String>;
		private var mainContainer:MediaContainer;
		private var mediaContainer:MediaContainer = new MediaContainer();	
		private var controlUtil:ControlUtil;
		private var posterImage:ImageElement;
		private var _media:MediaElement;
		private var _stage:Stage;
		private var _loaderInfo:LoaderInfo;
		private var videoInfoLoaded:Boolean = false;
		private var swfWidth:int
		private var swfHeight:int
		
		private var isUmiwi:Boolean = true;
		private var iisPath:String;
		private var bottomHeight:Number;
		private var resized:Boolean = false;
		
		private static const PADDING:uint = 3;
		private static const POSTER_INDEX:int = 2;
		private static const MEDIA_PLAYER:String = "org.osmf.media.MediaPlayer";
		private static const STREAMING_SOURCE:String = "http://vod2.umiwi.com/vod/2011/05/30/26f57ef0c2e1b2d88f04c9c192b9dc6d.ssm/26f57ef0c2e1b2d88f04c9c192b9dc6d.f4m";
		private static const SLICE_SOURCE:String = "http://112.90.217.88/vod2.umiwi.com/h.ssm/h.f4m";
		
		private static const EXTERNAL_INTERFACE_ERROR_CALL:String
		= "function(playerId, code, message, detail)"
			+ "{"
			+ "	if (onMediaPlaybackError != null)"
			+ "		onMediaPlaybackError(playerId, code, message, detail);"
			+ "}";		
	}
}