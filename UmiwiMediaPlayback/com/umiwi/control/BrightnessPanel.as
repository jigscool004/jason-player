package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    import com.umiwi.util.Constants;
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.events.SliderEvent;
    
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class BrightnessPanel extends MovieClip
    {
        private static const BRIGHTNESS_KEY:String = "brightness";
        private static const CONTRAST_KEY:String = "contrast";
        
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
            restoreButton.textField.text = "恢复默认";
            brightnessSlider.addEventListener(Constants.SLIDER_CHANGE, brightnessChanged);
            contrastSlider.addEventListener(Constants.SLIDER_CHANGE, contrastChanged);
            
            var bObj:Object = UConfigurationLoader.loadConfig(BRIGHTNESS_KEY);
            if(bObj)
            {
                brightness = bObj as Number;
                brightnessSlider.value = brightness;
            }
            
            var cObj:Object = UConfigurationLoader.loadConfig(CONTRAST_KEY);
            if(cObj)
            {
                contrast = cObj as Number;
                contrastSlider.value = contrast;
            }
            
            throwEvent();
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
            
            UConfigurationLoader.saveConfig(BRIGHTNESS_KEY, 0);
            UConfigurationLoader.saveConfig(CONTRAST_KEY, 0);
        }
        
        private function brightnessChanged(e:Event):void {
            brightness = e.target.value;
            throwEvent();
            UConfigurationLoader.saveConfig(BRIGHTNESS_KEY, brightness);
        }
        
        private function contrastChanged(e:Event):void {
            contrast = e.target.value
            throwEvent();
            UConfigurationLoader.saveConfig(CONTRAST_KEY, contrast);
        }
        
        private function throwEvent():void
        {
            var event:ButtonEvent = new ButtonEvent(ButtonEvent.SET_DISPLAY, true);
            event.data = {b: brightness, c: contrast};
            dispatchEvent(event);
        }
    }
}