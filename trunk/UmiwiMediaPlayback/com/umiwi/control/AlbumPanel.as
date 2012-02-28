package com.umiwi.control
{
    import com.umiwi.control.component.MultiLineCell;
    import com.umiwi.util.Constants;
    import com.umiwi.util.ControlUtil;
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.controls.List;
    import fl.data.DataProvider;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    
    import org.osmf.events.PlayEvent;
    import org.osmf.traits.MediaTraitType;
    import org.osmf.traits.PlayState;
    import org.osmf.traits.PlayTrait;

    public class AlbumPanel extends TraitControl
    {
        public function AlbumPanel()
        {
            super();
            traitType = MediaTraitType.PLAY;
            this.visible = false;
            mouseEnabled = true;
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            dispatchEvent(new Event(Constants.CLOSE_ALBUM_PANEL, true));
        }
        
        public function loadConfiguration():void
        {
            var tl:List = tileList as List;
            tl.setStyle("cellRenderer", MultiLineCell);
            tl.opaqueBackground = 0x000000;
            tl.dataProvider = ControlUtil.configuration.albumDataProvider;
            for(var i:int = 0; i < tl.dataProvider.length; i++)
            {
                var item:Object = tl.dataProvider.getItemAt(i);
                if(item && item["videoid"] == ControlUtil.configuration.flvID)
                {
                    tl.selectedIndex = i;
                }
            }
            tl.addEventListener(Event.CHANGE, onChange);
        }
        
        private function onChange(event:Event):void
        {
            var tl:List = tileList as List;
            var item:Object = tl.selectedItem;
            if(item && item["link"])
            {
                var request:URLRequest = new URLRequest(item["link"]);
                navigateToURL(request, "_top");
            }
                
        }
        
        override protected function addElement():void{
            var playTrait:PlayTrait = traitInstance as PlayTrait;
            playTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        }
        
        override protected function removeElement():void{
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
            if(playTrait.playState == PlayState.STOPPED)
            {
                if(ControlUtil.configuration.albumDataProvider.length > 0)
                {
                    playNext();
                }
            }
        }
        
        private function playNext():void
        {
            var nextIndex:int = tileList.selectedIndex + 1;
            if(nextIndex > 0 && nextIndex < tileList.dataProvider.length)
            {
                var item:Object = (tileList.dataProvider as DataProvider).getItemAt(nextIndex);
/*                var request:URLRequest = new URLRequest(item["link"]);
                navigateToURL(request, "_top");
                UConfigurationLoader.updateMsg("Play next video " + item["title"]);*/
                
                if (ExternalInterface.available && !ControlUtil.configuration.out)
                {
                    try{
                        ExternalInterface.call("jumpToURL", item["link"]);
                        UConfigurationLoader.updateMsg("Play next video " + item["title"]);
                    }
                    catch(_:Error)
                    {
                        trace(_.toString());
                    }
                }
            }
        }
    }
}