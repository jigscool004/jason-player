package com.umiwi.control
{
    import com.umiwi.control.component.BasePanel;
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

    public class AlbumPanel extends BasePanel
    {
        public function AlbumPanel()
        {
            super();
            this.visible = false;
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            upButton.addEventListener(MouseEvent.CLICK, scrollUp);
            downButton.addEventListener(MouseEvent.CLICK, scrollDown);
            var tl:List = tileList as List;
            tl.rowHeight = 40;
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            dispatchEvent(new Event(Constants.CLOSE_ALBUM_PANEL, true));
        }
        
        protected function scrollUp(event:MouseEvent):void
        {
            var tl:List = tileList as List;

            if(tl.verticalScrollPosition > 0)
            {
                tl.verticalScrollPosition -= tl.rowHeight;
            }
            else
            {
                tl.verticalScrollPosition = 0;
            }
           
        }
        
        protected function scrollDown(event:MouseEvent):void
        {
            var tl:List = tileList as List;
            
            if(tl.verticalScrollPosition + tl.rowHeight < tl.maxVerticalScrollPosition)
            {
                tl.verticalScrollPosition += tl.rowHeight;
            }
            else
            {
                tl.verticalScrollPosition = tl.maxVerticalScrollPosition
            }
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
                    ControlUtil.configuration.albumIndex = i;
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