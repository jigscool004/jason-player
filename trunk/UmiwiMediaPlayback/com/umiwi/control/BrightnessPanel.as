package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    import com.umiwi.util.Constants;
    
    import fl.events.SliderEvent;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class BrightnessPanel extends MovieClip
    {
        private var brightness:Number = 0;
        private var contrast:Number = 0;
        public function BrightnessPanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            okButton.addEventListener(MouseEvent.CLICK, closePanel);
            restoreButton.addEventListener(MouseEvent.CLICK, restoreDisplay);
            brightnessSlider.addEventListener(SliderEvent.CHANGE, brightnessChanged);
            contrastSlider.addEventListener(SliderEvent.CHANGE, contrastChanged);
        }
        
        protected function closePanel(event:MouseEvent):void
        {
            parent.visible = false;
        }
        
        private function restoreDisplay(event:MouseEvent):void
        {
            brightnessSlider.value = 0;
            contrastSlider.value = 0;
            brightness = 0;
            contrast = 0;
            throwEvent();
        }
        
        private function brightnessChanged(e:SliderEvent):void {
            brightness = e.target.value;
            throwEvent();
        }
        
        private function contrastChanged(e:SliderEvent):void {
            contrast = e.target.value
            throwEvent();
        }
        
        private function throwEvent():void
        {
            var event:ButtonEvent = new ButtonEvent(ButtonEvent.SET_DISPLAY, true);
            event.data = {b: brightness, c: contrast};
            dispatchEvent(event);
        }
    }
}