package com.umiwi.control
{
    import fl.events.SliderEvent;
    import fl.motion.AdjustColor;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Rectangle;
    
    import org.osmf.traits.DisplayObjectTrait;
    import org.osmf.traits.MediaTraitType;
    
    public class BrightnessPanel extends TraitControl
    {
        private var brightness:Number = 0;
        private var contrast:Number = 0;
        public function BrightnessPanel()
        {
            super();
            traitType = MediaTraitType.DISPLAY_OBJECT;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            brightnessSlider.addEventListener(SliderEvent.CHANGE, brightnessChanged);
            contrastSlider.addEventListener(SliderEvent.CHANGE, contrastChanged);
        }
        
        private function brightnessChanged(e:SliderEvent):void {
            brightness = e.target.value
            setColor();    
        }
        
        private function contrastChanged(e:SliderEvent):void {
            contrast = e.target.value
            setColor();    
        }
        
        private function setColor() {
/*            var brightness:Number = tmpValue/20 * 255;
            var filterArray:Array=[1, 0, 0, 0, brightness,
                0, 1, 0, 0, brightness,
                0, 0, 1, 0,brightness,
                0, 0, 0, 1, 0];
            var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            displayTrait.displayObject.filters=[colorMatrix];*/
            
            var color:AdjustColor = new AdjustColor();
            color.brightness = brightness/20 * 255;
            color.contrast = contrast/20 * 100;
            color.hue = 0;
            color.saturation = 0;
            var colorArray:Array = color.CalculateFinalFlatArray();
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            displayTrait.displayObject.filters = [new ColorMatrixFilter(colorArray)];
        }
        
        override protected function addElement():void{
            this.visible = true;
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
        }
        
        override protected function removeElement():void{
            visible = false;
        }
    }
}