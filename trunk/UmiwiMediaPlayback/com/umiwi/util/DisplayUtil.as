package com.umiwi.util
{
    import com.umiwi.control.TraitControl;
    
    import fl.events.SliderEvent;
    import fl.motion.AdjustColor;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    import org.osmf.traits.DisplayObjectTrait;
    import org.osmf.traits.MediaTraitType;
    
    public class DisplayUtil extends TraitControl
    {
        
        private var brightness:Number = 0;
        private var contrast:Number = 0;
        
        private static var instance:DisplayUtil;
        
        public static function getInstance():DisplayUtil
        {
            if(!instance)
            {
                instance = new DisplayUtil();
            }
            return instance;
        }
        
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
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            if(!displayTrait)
            {
                return;
            }
            var color:AdjustColor = new AdjustColor();
            color.brightness = brightness/20 * 255;
            color.contrast = contrast/20 * 100;
            color.hue = 0;
            color.saturation = 0;
            var colorArray:Array = color.CalculateFinalFlatArray();
            
            displayTrait.displayObject.filters = [new ColorMatrixFilter(colorArray)];
        }
        
        public function capture():Bitmap
        {
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            if(!displayTrait)
            {
                return null;
            }
            var videoObject:DisplayObject = displayTrait.displayObject;
            var bitmapData:BitmapData = new BitmapData(videoObject.width, videoObject.height, true, 0x000000);
            var matrix:Matrix = videoObject.transform.matrix.clone();
            matrix.scale(videoObject.width / videoObject.width, videoObject.height / videoObject.height);
            matrix.tx = 0;
            matrix.ty = 0;
            bitmapData.draw(videoObject, matrix);
            return new Bitmap(bitmapData);
        }
        
        override protected function addElement():void{
            this.visible = true;
            var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
            
            var bObj:Object = UConfigurationLoader.loadConfig(Constants.BRIGHTNESS_KEY);
            if(bObj)
            {
                brightness = bObj as Number;
            }
            var cObj:Object = UConfigurationLoader.loadConfig(Constants.CONTRAST_KEY);
            if(cObj)
            {
                contrast = cObj as Number;
            }
            setColor();
        }
        
        override protected function removeElement():void{
            visible = false;
        }
    }
}