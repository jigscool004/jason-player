package com.umiwi.control
{
    import com.umiwi.util.ControlUtil;
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.controls.CheckBox;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class PlaymodePanel extends BasePanel
    {
        public function PlaymodePanel()
        {
            super();
        }
        
        override protected function onAddedToStage(event:Event):void{
            super.onAddedToStage(event);
            (playCheck as CheckBox).addEventListener(MouseEvent.CLICK, onCheck);
        }
        
        private function onCheck(event:MouseEvent):void
        {
            var cb:CheckBox = playCheck as CheckBox;
            if(cb.selected){
                ControlUtil.configuration.autoPlayNext = true;
            }
            else
            {
                ControlUtil.configuration.autoPlayNext = false;
            }
        }
    }
}