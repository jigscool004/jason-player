package com.umiwi.control
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class TabPanel extends MovieClip
    {
        public function TabPanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        protected function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            var btButton:BaseTextButton = getChildByName("okButton") as BaseTextButton;
            btButton.addEventListener(MouseEvent.CLICK, closePanel);
            btButton.textField.text = "确定";
        }
        
        protected function closePanel(event:MouseEvent):void
        {
            parent.visible = false;
        }
    }
}