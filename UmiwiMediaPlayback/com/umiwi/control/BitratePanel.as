package com.umiwi.control
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class BitratePanel extends MovieClip
    {
        public function BitratePanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            okButton.addEventListener(MouseEvent.CLICK, closePanel);
        }
        
        protected function closePanel(event:MouseEvent):void
        {
            parent.visible = false;
        }
    }
}