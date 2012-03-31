﻿package
{
	import com.umiwi.control.ShareButton;
	import com.umiwi.control.TraitControl;
	import com.umiwi.control.component.BasePanel;
	import com.umiwi.event.ButtonEvent;
	import com.umiwi.util.Constants;
	import com.umiwi.util.ControlUtil;
	import com.umiwi.util.DisplayUtil;
	import com.umiwi.util.IMAManager;
	import com.umiwi.util.UConfigurationLoader;
	
	import fl.containers.UILoader;
	import fl.transitions.TransitionManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
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
	import flash.net.NetStream;
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
	import org.osmf.elements.SerialElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamLoadTrait;
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
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;
	
	[SWF(backgroundColor="0x000000", frameRate="25", width="610", height="510")]
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
            
            //For rtmp capture image, server side: Application.xml
            //<VideoSampleAccess enabled="true">low_quality;high_quality</VideoSampleAccess>
			Security.loadPolicyFile("http://upload.umiwi.com/crossdomain.xml");
            Security.loadPolicyFile("http://vod2.umiwi.com/crossdomain.xml");
            Security.loadPolicyFile("http://i1.umivi.net/crossdomain.xml");
            //Security.loadPolicyFile("http://i1.v.umiwi.com/crossdomain.xml");
            //Security.loadPolicyFile("http://r1.vod.umiwi.com/crossdomain.xml");
            
            Security.loadPolicyFile("http://screenshots1.v.umiwi.com/crossdomain.xml");
			
            Security.allowDomain(".umiwi.com");
            Security.allowDomain(".umiwi.net");
            
			adsManager = new IMAManager(this)
			
			uc.getFlvInfo(parameters, loadConfigurationFromParameters);

			function loadConfigurationFromParameters(params:Object):void{
				videoInfoLoaded = true;

                for each(var domainString:String in configuration.domains)
                {
                    Security.allowDomain(domainString);
                }


				configuration.src = params.src;
				configuration.poster = params.poster;
				loadMedia();

				
				uc.getRecommendFlv(params, loadRecommendFlv);
				function loadRecommendFlv(params:XML):void
				{
					for (var i:int=0; i <params.Item.length(); i++) 
					{
						var xmlItem:XML = params.Item[i];
						loadPic(xmlItem.@thumburl,recommendPanel["loader"+(i%4)].poster);
						recommendPanel["loader"+(i%4)].title.text=xmlItem.@title.toString();
						recommendPanel["loader"+(i%4)].visible=true;
						//var timeDuration:String = FormatUtils.convertTime(xmlItem.@duration.toString());
						//recommendPanel["loader"+(i%4)].otherMsg.text="时长:"+ timeDuration +"   播放:"+ xmlItem.@playcount.toString();
						recommendPanel["loader"+(i%4)].link = xmlItem.@link.toString();
						recommendPanel["loader"+(i%4)].wrapper.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent)
						{
                            UConfigurationLoader.updateMsg(e.currentTarget.parent.link);
							navigateToURL(new URLRequest(e.currentTarget.parent.link), "_top");
						});
					}
/*					if(params.Item.length() == 0)
					{
						recommendPanel.gotoAndStop(4);
					}
					else if(params.Item.length() == 1)
					{
						recommendPanel.gotoAndStop(3);
					}
					else if(params.Item.length() == 2)
					{
						recommendPanel.gotoAndStop(2);
					}
					else
					{
						recommendPanel.gotoAndStop(1);
					}*/
				}
                
                var logo:Object = configuration.logo;
                logoLoader.x = logo.x;
                logoLoader.y = logo.y;
                logoLoader.alpha = logo.alpha;
                var request:URLRequest = new URLRequest(logo.src);
                logoLoader.scaleContent = false;            
                logoLoader.load(request);
                logoLoader.buttonMode = true;
                logoLoader.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent)
                {
                    navigateToURL(new URLRequest(configuration.logo.link));
                });
                
                sharePanel.loadConfiguration();
                albumPanel.loadConfiguration();
                onEnterFrameCallback();
			}
			
			configuration = new PlayerConfiguration();
            ControlUtil.configuration = this.configuration;
			var configurationXMLLoader:XMLFileLoader = new XMLFileLoader();
			var configurationLoader:ConfigurationLoader = new ConfigurationLoader(configurationXMLLoader);			
			configurationLoader.addEventListener(Event.COMPLETE, onConfigurationReady);			
			configurationLoader.load(parameters, configuration);
			
			function onConfigurationReady(event:Event=null):void
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
			
			if(configuration.autoPlay && configuration.showAds)
			{
				//Waiting for ads completed.
				disablePlayControl();
			}
			
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
            
            if(configuration.autoPlay)
            {
                mediaContainer.visible = false;
            }
            
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
            
			//初始化推荐视频不可见
			recommendPanel.visible=false;
			toolBar.scrubBar.visible = false;
			
			controlUtil = new ControlUtil(this);
            
            if(!configuration.showAds)
            {
                removeChild(clickMovieClip);
            }
            
            if(!configuration.hasMBR)
            {
                configPanel.definitionTab.visible = false;
            }
            
            addEventListener(Constants.OPEN_SHARE_PANEL, openSharePanel);
            addEventListener(Constants.CLOSE_SHARE_PANEL, closeSharePanel);
            addEventListener(Constants.CLOSE_LIGHT, closeLight);
            addEventListener(Constants.OPEN_DISPLAY_PANEL, openDisplayPanel);
            addEventListener(Constants.OPEN_BITRATE_PANEL, openBitratePanel);
            
            addEventListener(Constants.OPEN_ALBUM_PANEL, openAlbumPanel);
            addEventListener(Constants.CLOSE_ALBUM_PANEL, closeAlbumPanel);
            
            addEventListener(Constants.OPEN_NOTE_PANEL, openNotePanel);
            addEventListener(Constants.CLOSE_NOTE_PANEL, closeNotePanel);
            
            addEventListener(Constants.ZOOM50, zoomVideo);
            addEventListener(Constants.ZOOM75, zoomVideo);
            addEventListener(Constants.ZOOM100, zoomVideo);
            addEventListener(Constants.ZOOM_FULL, zoomVideo);
            
            addEventListener(ButtonEvent.SET_DISPLAY, setDisplay);
            
            addEventListener(Constants.REPLAY_VIDEO, playVideo);
            
            if (ExternalInterface.available && !ControlUtil.configuration.out)
            {
                try{
                    ExternalInterface.addCallback("playVideo", playVideo);
                }
                catch(_:Error)
                {
                    trace(_.toString());
                }
            }
		}
        
        private function openSharePanel(event:Event):void
        {
            player.pause();
            if(!sharePanel.showing)
            {
                hidePanels();
                sharePanel.show();
            }
            else
            {
                sharePanel.hide();
            }
            
        }
        
        private function closeSharePanel(event:Event):void
        {
            if(recommendPanel.visible == false)
            {
                player.play();
            }
            sharePanel.hide();
        }
        
        private function openAlbumPanel(event:Event):void
        {
            
            if(albumPanel.showing)
            {
                player.play();
                albumPanel.hide();
            }
            else
            {
                hidePanels();
                albumPanel.show();
                player.pause();
            }
        }
        
        private function openNotePanel(event:Event):void
        {
            if(notePanel.showing)
            {
                player.play();
                notePanel.hide();
            }
            else
            {
                //Can not input in full screen mode.
                restorScreen();
                
                hidePanels();
                player.pause();
                notePanel.currentTime = player.currentTime;
                notePanel.show();
            }
        }
        
        private function restorScreen():void
        {
            if(stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                stage.displayState=StageDisplayState.NORMAL;
            }
        }
        
        private function closeNotePanel(event:Event):void
        {
            player.play();
            notePanel.hide();
        }
        
        private function hidePanels():void
        {
            layoutPanels();
            for(var i:int = 0; i < numChildren; i++)
            {
                if(getChildAt(i) is BasePanel)
                {
                    var panel:BasePanel = getChildAt(i) as BasePanel;
                    if(panel.showing)
                    {
                        panel.hide();
                    }
                }
            }
            
        }
        
        private function closeAlbumPanel(event:Event):void
        {
            albumPanel.hide();
            player.play();
        }
        
        private function closeLight(event:Event):void
        {
            UConfigurationLoader.callExternal("switchLight");
        }
        
        private function openBitratePanel(event:Event):void
        {
            if(configPanel.showing) {
                if(configPanel.selectedIndex == 1) 
                {
                    hidePanels();
                    configPanel.hide();
                }
                else
                {
                    configPanel.selectedIndex = 1;
                }
            }
            else
            {
                configPanel.selectedIndex = 1;
                openConfigPanel();
            }
            
        }
        
        private function openDisplayPanel(event:Event):void
        {
            if(configPanel.showing) {
                if(configPanel.selectedIndex == 2) 
                {
                    hidePanels();
                    configPanel.hide();
                }
                else
                {
                    configPanel.selectedIndex = 2;
                }
            }
            else
            {
                configPanel.selectedIndex = 2;
                openConfigPanel();
            }
        }
        
        private function openConfigPanel():void
        {
            hidePanels();
            configPanel.show();
        }
        
        private function zoomVideo(event:Event):void
        {
            var zoomFactor:Number;
            LayoutMetadata(player.media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE))
                .scaleMode = configuration.scaleMode;
            switch(event.type)
            {
                case Constants.ZOOM50:
                    zoomFactor = 0.5;
                    break;
                case Constants.ZOOM75:
                    zoomFactor = 0.75;
                    break;
                case Constants.ZOOM100:
                    zoomFactor = 1;
                    break;
                case Constants.ZOOM_FULL:
                    zoomFactor = 1;
                    
                    LayoutMetadata(player.media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE))
                        .scaleMode = ScaleMode.STRETCH;
                    break;
                default:
                    zoomFactor = 1;
            }
            mediaContainer.width = stage.stageWidth * zoomFactor;
            mediaContainer.height = stage.stageHeight * zoomFactor;
            
            var positionFactor:Number = (1 - zoomFactor) * 0.5
            mainContainer.x = stage.stageWidth * positionFactor;
            mainContainer.y = stage.stageHeight * positionFactor;
            
            mediaContainer.layout(stage.stageWidth * zoomFactor, stage.stageHeight * zoomFactor);
        }
        
        private function setDisplay(event:ButtonEvent):void
        {
            displayUtil.setDisplay(event.data);
        }

		
		private function enableToolBar(en:Boolean):void
		{
			for(var i:int=0; i<toolBar.numChildren; i++)
			{
				if(toolBar.getChildAt(i) is TraitControl)
				{
					(toolBar.getChildAt(i) as TraitControl).enabled = en;
				}
			}
		}
		

		
		private function onStageResize(event:Event = null):void
		{

			mainContainer.width = _stage.stageWidth;
			mainContainer.height = _stage.stageHeight;
			
			
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrameCallback);
		}		
		
		private function onEnterFrameCallback(event:Event=null):void{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameCallback);

			swfWidth=_stage.stageWidth;
			swfHeight=_stage.stageHeight;
			
            toolBar.y=swfHeight-toolBar.height-PADDING;			
            toolBar.toolBarBack.width=swfWidth;
            //hide albume button

			mediaContainer.width = _stage.stageWidth;
            
            centerBufferingMC();
            
			if(_stage.displayState == "fullScreen")
			{
				mediaContainer.height = _stage.stageHeight;
                
                var padding:Number = 20;
                var buttonWidth:Number = 65;
                topBar.topBarBG.width = swfWidth;
                topBar.zoom50.x = swfWidth/2 - buttonWidth*2 - padding*1.5;
                topBar.zoom75.x = swfWidth/2 - buttonWidth - padding*0.5;
                topBar.zoom100.x = swfWidth/2 + padding*0.5;
                topBar.zoomFull.x = swfWidth/2 + buttonWidth + padding*1.5;
                topBar.y = 0;
                
                toolBar.fullScrBtn.x=toolBar.toolBarBack.width - 80;
			}else
			{
				mediaContainer.height = _stage.stageHeight - toolBar.toolBarBack.height;
                
                toolBar.fullScrBtn.x=toolBar.toolBarBack.width - 40;
			}
            
            toolBar.volumeButton.x=toolBar.fullScrBtn.x - toolBar.volumeButton.width - 5;
            toolBar.configButton.x=toolBar.volumeButton.x - toolBar.configButton.icon.width - 30;
            
            if(configuration.albumDataProvider.length <= 0)
            {
                toolBar.albumButton.visible = false;
            }
            else
            {
                toolBar.albumButton.visible = true;
                toolBar.albumButton.x = toolBar.configButton.x - 40;
                albumPanel.x = toolBar.albumButton.x;
                albumPanel.y = swfHeight-toolBar.toolBarBack.height;
            }
			
			if(adsManager.adsLoader)
			{
				adsManager.adsLoader.width = swfWidth;
				if(_stage.displayState == "fullScreen")
				{
					adsManager.adsLoader.height = _stage.stageHeight;
				}else
				{
					adsManager.adsLoader.height = _stage.stageHeight - toolBar.toolBarBack.height;
				}
			}
			
			
			fullScrBtn.width = _stage.stageWidth;
			fullScrBtn.height = _stage.stageHeight;

			
            toolBar.scrubBar.setWidth(swfWidth-20);
			
			bigPlayBtn.x= 50;
			bigPlayBtn.y=(swfHeight-bigPlayBtn.height) - 37 - toolBar.toolBarBack.height;
			
		    localVideoMC.width = _stage.stageWidth;
			localVideoMC.height = _stage.stageHeight;
            
            var xPosition:Number;
            var drawerStatus:Boolean;
            if(_stage.displayState == "fullScreen")
            {
                xPosition = swfWidth - rightSideDrawer.width;
                drawerStatus = true;
            }
            else
            {
                xPosition = swfWidth;
                drawerStatus = false;
            }
            var yPosition:Number = (swfHeight - toolBar.toolBarBack.height - rightSideDrawer.height) * .5;
            rightSideDrawer.stopTween(drawerStatus, xPosition, yPosition);
            
            layoutPanels();
			
			var toolbarIndex = this.getChildIndex(toolBar);
			this.setChildIndex(mainContainer, 0);
		}
        
        private function layoutPanels():void
        {
            putInCenterAbsolutely(configPanel);
            putInCenterAbsolutely(sharePanel);
            putInCenterAbsolutely(notePanel);
            
            if(configuration.albumDataProvider.length > 0)
            {
                albumPanel.x = toolBar.albumButton.x;
                albumPanel.y = swfHeight-toolBar.toolBarBack.height;
            }
            
            if(_stage.displayState == "fullScreen")
            {
                putInCenter(recommendPanel);
            }else
            {
                recommendPanel.x = 0;
                recommendPanel.y = 0;
            }
            
            resizePanel(configPanel);
            resizePanel(sharePanel);
            resizePanel(notePanel);
            resizePanel(recommendPanel);
        }
        
        private function resizePanel(movieClip:MovieClip):void
        {
            var aWidth:Number = movieClip.width - 20;
            var aHeight:Number = movieClip.height - 20;
            if(aWidth > _stage.stageWidth || aHeight > _stage.stageHeight)
            {
                if(aHeight == 0 || _stage.stageHeight == 0)
                {
                    return;
                }
                var aRatio:Number = aWidth/aHeight;
                var stageRatio:Number = _stage.stageWidth/_stage.stageHeight;
                var scaleFactor:Number;
                if(aRatio > stageRatio)
                {
                    scaleFactor = _stage.stageWidth/movieClip.width;
                    movieClip.width = _stage.stageWidth;
                    movieClip.height = movieClip.height * scaleFactor;
                }
                else
                {
                    scaleFactor = _stage.height/movieClip.height;
                    movieClip.width = movieClip.width * scaleFactor;
                    movieClip.height = _stage.stageHeight;
                }
            }
        }
        
        private function putInCenter(movieClip:MovieClip):void
        {
            if(!movieClip)
            {
                return;
            }
            movieClip.x = (_stage.stageWidth - movieClip.width) * 0.5;
            movieClip.y = (_stage.stageHeight - movieClip.height) * 0.5;
        }
        
        private function putInCenterAbsolutely(movieClip:MovieClip):void
        {
            if(!movieClip)
            {
                return;
            }
            movieClip.x = _stage.stageWidth * 0.5;
            movieClip.y = _stage.stageHeight * 0.5;
        }
		
		private var preResource:String = "http://pagead2.googlesyndication.com/" +  
			"pagead/scache/googlevideoadslibraryas3.swf";
		
		public function loadMedia(..._):void
		{	
			
			//Show buffering overlay.
			if(configuration.src == null || configuration.src == "" || !videoInfoLoaded)
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
		
		public function set media(value:MediaElement):void
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
					
					registerMedia(_media);
					
					_stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
					mainContainer.addEventListener(MouseEvent.DOUBLE_CLICK, onFullScreenRequest);
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
        
        public function get media():MediaElement
        {
            return _media;
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
                var dObject:DisplayObject = getChildAt(i);
				if(dObject is TraitControl)
				{
					(dObject as TraitControl).setElement(element);
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
            displayUtil.setElement(element);
			
            if(configuration.showAds)
            {
                setElement(element);
            }
            else
            {
                mediaContainer.visible = true;
            }
			
		}
		
		protected var traitType:String = MediaTraitType.PLAY;
		protected var traitInstance:MediaTraitBase;
		public var initBuffer:Boolean = false;
		
		public function setElement(element:MediaElement):void{
			if(element.hasTrait(traitType))
			{
				traitInstance = element.getTrait(traitType);
				addElement();
			}
			else
			{
				if(traitInstance != null)
				{
					removeElement();
					traitInstance = null;
				}
			}
			
			if(element.hasTrait(MediaTraitType.DISPLAY_OBJECT) && !configuration.autoPlay)
			{
				bufferingMC.visible = false;
			}
		}
		
		protected function addElement():void{
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			playTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
			visibilityDeterminingEventHandler();
		}
		
		protected function removeElement():void{
			if(traitInstance == null)
			{
				return;
			}
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			playTrait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
			playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
		}
		
		protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			var playTrait:PlayTrait = traitInstance as PlayTrait;
			if(playTrait.playState == PlayState.PLAYING && !initBuffer)
			{
				this.disablePlayControl();
				adsManager.loadAd();
				initBuffer = true;
				playTrait.pause();
				startPlayerQuietly()
			}
		}
		
		private var quietPlayerTimer:Timer = new Timer(1000);
		private var netStream:NetStream;
		
		public function startPlayerQuietly():void{
/*			if(initBuffer && initAdsBuffer)
			{
				
				quietPlayerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetPlayerQuietly);
				quietPlayerTimer.start();
			}*/
			if(initBuffer && adsManager.initAdsBuffer)
			{
				mediaContainer.visible = false;
				toolBar.scrubBar.visible = false;
				player.muted = true;
				player.play();
				var loadTrait:LoadTrait = _media ? _media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
				if(loadTrait is NetStreamLoadTrait)
				{
					netStream = (loadTrait as NetStreamLoadTrait).netStream;
					netStream.bufferTime = configuration.initialBufferTime;
					quietPlayerTimer.addEventListener(TimerEvent.TIMER, enlargeBuffer);
					quietPlayerTimer.start();
					UConfigurationLoader.updateMsg("Enlarge buffer while ads is displaying");
				}
			}
		}
		
		public function stopPlayerQuietly():void
		{
            mediaContainer.visible = true;
			quietPlayerTimer.stop();
			var loadTrait:LoadTrait = _media ? _media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
			if(loadTrait is NetStreamLoadTrait)
			{
				var netStream:NetStream = (loadTrait as NetStreamLoadTrait).netStream;
				netStream.bufferTime = configuration.initialBufferTime;
				UConfigurationLoader.updateMsg("Reset buffer after ads is closed");
			}
			netStream = null;
		}
		
		private function enlargeBuffer(event:TimerEvent):void
		{
			if(player.playing)
			{
				mediaContainer.visible = true;
				player.muted = false;
				player.seek(0);
				player.pause();
				bufferingMC.visible = false;
				toolBar.scrubBar.visible = true;
				bufferingMC.visible = false;
			}
			if(netStream && netStream.bufferTime<=netStream.bufferLength && 
				netStream.bufferTime< ControlUtil.configuration.bufferWindow)
			{
				netStream.bufferTime = Math.min(netStream.bufferTime + configuration.expandedBufferTime, ControlUtil.configuration.bufferWindow);
				UConfigurationLoader.updateMsg("Enlarge buffer size to " + netStream.bufferTime.toString());
			}
		}
		
		public function resetPlayerQuietly(event:TimerEvent):void
		{
/*			mediaContainer.visible = true;
			quietPlayerTimer.stop();
			player.muted = false;
			player.seek(0);
			player.pause();
			bufferingMC.visible = false;
			toolBar.scrubBar.visible = true;
			
			bufferingMC.visible = false;*/
		}
		
		private function onFullScreen(event:FullScreenEvent):void
		{				
			var scaleFactor:Number;
			
			if (_stage.displayState == StageDisplayState.NORMAL) 
			{		
                mainContainer.x = 0;
                mainContainer.y = 0;
				Mouse.show();	
			}
			else if (_stage.displayState == StageDisplayState.FULL_SCREEN)
			{	
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
                    
                    //(bufferingMC as TraitControl).setElement(posterImage);
                    bufferingMC.visible = false;

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
            bufferingMC.bufferBG.x = 0;
            bufferingMC.bufferBG.y = 0;
            bufferingMC.bufferBG.width = _stage.stageWidth;
            bufferingMC.bufferBG.height = _stage.stageHeight;
            bufferingMC.bufferSymbol.x = _stage.stageWidth * 0.5;
            
            if(_stage.displayState == "fullScreen")
            {
                bufferingMC.bufferSymbol.y = _stage.stageHeight * 0.5;
            }
            else
            {
                bufferingMC.bufferSymbol.y = (_stage.stageHeight - toolBar.toolBarBack.height) * 0.5;
            }
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
		
		public function disablePlayControl():void
		{
			toolBar.mouseChildren = false;
			bigPlayBtn.mouseEnabled = false;
            var toolbarIndex = this.getChildIndex(toolBar);
            this.setChildIndex(bigPlayBtn, toolbarIndex + 1);
			fullScrBtn.mouseEnabled = false;
            
            rightSideDrawer.visible = false;
		}
		
		public function enablePlayControl():void
		{
			toolBar.mouseChildren = true;
			bigPlayBtn.mouseEnabled = true;
			fullScrBtn.mouseEnabled = true;
            removeChild(clickMovieClip);
            
            rightSideDrawer.visible = true;
		}
		
		private function loadPic(url:String,mc:UILoader):void
		{	
            try {
                var request:URLRequest = new URLRequest(url);
                mc.load(request);
            } catch (error:Error) {
                UConfigurationLoader.updateMsg("Failed to get recommended thumbnail. " + error.message);
            }
		}
		

		
		public function hideRecommend():void{
			recommendPanel.visible=false;
		}
		
		//Add ads behind tool bar.
		public function addAdsContainer(loader:DisplayObject):void
		{
			var toolIndex:int = getChildIndex(toolBar);
			addChildAt(loader, toolIndex); 
		}
        
        private function playVideo(event:Event = null):void {
            if(player)
            {
                player.play();
            }
        }
		
		private var uc:UConfigurationLoader = new UConfigurationLoader();
        private var displayUtil:DisplayUtil = DisplayUtil.getInstance();
		
		public var factory:StrobeMediaFactory;		
		public var configuration:PlayerConfiguration;
		public var player:StrobeMediaPlayer;
		
		private var pluginHostWhitelist:Vector.<String>;
		private var mainContainer:MediaContainer;
		public var mediaContainer:MediaContainer = new MediaContainer();	
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
		
		private var adsManager:IMAManager;

		
		private static const PADDING:uint = 6;
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