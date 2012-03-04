package com.umiwi.control
{
    import com.umiwi.util.Constants;
    import com.umiwi.util.UConfigurationLoader;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class BitratePanel extends TabPanel
    {
        private static const BITRATE_KEY:String = "bitrate";
        public function BitratePanel()
        {
            super();
        }
        
        override protected function onAddedToStage(event:Event):void
        {
            super.onAddedToStage(event);
            
            normalRadio.label.text = "流 畅";
            highRadio.label.text = "高 清";
            autoRadio.label.text = "智 能";
            
            normalRadio.addEventListener(MouseEvent.CLICK, onClick50);
            highRadio.addEventListener(MouseEvent.CLICK, onClick75);
            autoRadio.addEventListener(MouseEvent.CLICK, onClick100);
            
            var option:Object = UConfigurationLoader.loadConfig(BITRATE_KEY);
            if(option)
            {
                if(option.toString() == Constants.NORMAL_BITRATE)
                {
                    normalRadio.selected = true;
                    changeBitrate(Constants.NORMAL_BITRATE);
                }
                else if(option.toString() == Constants.HIGH_BITRATE)
                {
                    highRadio.selected = true;
                    changeBitrate(Constants.HIGH_BITRATE);
                }
                else
                {
                    autoRadio.selected = true;
                    changeBitrate(Constants.AUTO_BITRATE);
                }
            }
            else
            {
                autoRadio.selected = true;
                changeBitrate(Constants.AUTO_BITRATE);
            }
        }
        
        protected function onClick50(event:MouseEvent):void
        {
            highRadio.selected = false;
            autoRadio.selected = false;
            
            changeBitrate(Constants.NORMAL_BITRATE);
        }
        
        protected function onClick75(event:MouseEvent):void
        {
            normalRadio.selected = false;
            autoRadio.selected = false;
            
            changeBitrate(Constants.HIGH_BITRATE);
        }
        protected function onClick100(event:MouseEvent):void
        {
            normalRadio.selected = false;
            highRadio.selected = false;
            
            changeBitrate(Constants.AUTO_BITRATE);
        }
        
        private function changeBitrate(type:String):void
        {
            var bitrateEvent:Event = new Event(type, true);
            dispatchEvent(bitrateEvent);
            UConfigurationLoader.saveConfig(BITRATE_KEY, type);
        }
    }
}