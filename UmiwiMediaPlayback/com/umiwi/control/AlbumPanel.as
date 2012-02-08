package com.umiwi.control
{
    import com.umiwi.control.component.MultiLineCell;
    import com.umiwi.util.Constants;
    import com.umiwi.util.ControlUtil;
    
    import fl.controls.TileList;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    public class AlbumPanel extends MovieClip
    {
        public function AlbumPanel()
        {
            super();
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
            var tl:TileList = tileList as TileList;
            tl.setStyle("cellRenderer", MultiLineCell);
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
            var tl:TileList = tileList as TileList;
            var item:Object = tl.selectedItem;
            if(item && item["link"])
            {
                var request:URLRequest = new URLRequest(item["link"]);
                navigateToURL(request, "_top");
            }
                
        }
    }
}