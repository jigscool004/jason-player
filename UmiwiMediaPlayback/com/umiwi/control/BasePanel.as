package com.umiwi.control
{
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class BasePanel extends MovieClip
    {
        public function BasePanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        protected function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            var btButton:BaseTextButton = getChildByName("okButton") as BaseTextButton;
            btButton.addEventListener(MouseEvent.CLICK, closePanel);
            btButton.buttonText = "确定";
        }
        
        protected function closePanel(event:MouseEvent):void
        {
            parent.visible = false;
        }
    }
}