package com.umiwi.util
{
    import com.umiwi.control.TraitControl;
    
    import fl.events.SliderEvent;
    import fl.motion.AdjustColor;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Rectangle;
    
    import org.osmf.traits.DisplayObjectTrait;
    import org.osmf.traits.MediaTraitType;
    
    public class DisplayUtil extends TraitControl
    {
        
        private var brightness:Number = 0;
        private var contrast:Number = 0;
        public function DisplayUtil()
        {
            super();
            traitType = MediaTraitType.DISPLAY_OBJECT;
        }
        
        public function setDisplay(data:Object):void {
            brightness = data["b"];
            contrast = data["c"];
            setColor();    
        }
        
        private function setColor() {
            var color:AdjustColor = new AdjustColor();
            color.brightness = brightness/20 * 255;
            color.contrast = contrast/20 * 100;
            color.hue = 0;
            color.saturation = 0;
            var colorArray:Array = color.CalculateFinalFlatArray();
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            if(displayTrait)
            {
                displayTrait.displayObject.filters = [new ColorMatrixFilter(colorArray)];
            }
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