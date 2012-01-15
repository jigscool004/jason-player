package com.umiwi.control
{
    import com.umiwi.util.ControlUtil;
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.controls.CheckBox;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class PlaymodePanel extends BasePanel
    {
        private static const PLAY_NEXT_KEY:String = "playNext";
        public function PlaymodePanel()
        {
            super();
        }
        
        override protected function onAddedToStage(event:Event):void{
            super.onAddedToStage(event);
            playCheck.label.text = "自动连播";
            playCheck.toggle = true;
            playCheck.addEventListener(MouseEvent.CLICK, onCheck);
            
            var pObj:Object = UConfigurationLoader.loadConfig(PLAY_NEXT_KEY);
            
            var playNext:Boolean = false;
            if(pObj != null && pObj == true)
            {
                playNext = true;
            }
            playCheck.selected = playNext;
            ControlUtil.configuration.autoPlayNext = playNext;
        }
        
        private function onCheck(event:MouseEvent):void
        {
            if(playCheck.selected){
                ControlUtil.configuration.autoPlayNext = true;
                UConfigurationLoader.saveConfig(PLAY_NEXT_KEY, true);
            }
            else
            {
                ControlUtil.configuration.autoPlayNext = false;
                UConfigurationLoader.saveConfig(PLAY_NEXT_KEY, false);
            }
        }
    }
}