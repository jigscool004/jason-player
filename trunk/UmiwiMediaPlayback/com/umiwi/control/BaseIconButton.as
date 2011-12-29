package com.umiwi.control
{
    import com.umiwi.util.Constants;
    
    import fl.motion.Color;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.utils.getQualifiedClassName;
    
    public class BaseIconButton extends MovieClip
    {
        
        private var myFilters:Array = [];
        
        public function BaseIconButton()
        {
            super();
            mouseEnabled = true;
            buttonMode = true;
            addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            addEventListener(MouseEvent.ROLL_OUT, onRollOut);
            addEventListener(MouseEvent.CLICK, onMouseClick);
            
            var filter:BitmapFilter = getBitmapFilter();
            myFilters.push(filter);
        }
        
        protected function onRollOver(event:MouseEvent):void
        {
            var ct:ColorTransform = new ColorTransform(); 
            ct.color = Constants.TINT_COLOR; 
            icon.transform.colorTransform = ct;
            
            filters = myFilters;
        }
        
        protected function onRollOut(event:MouseEvent):void
        {
            var ct:ColorTransform = new ColorTransform();
            icon.transform.colorTransform = ct;
            
            filters = [];
        }
        
        protected function onMouseClick(event:MouseEvent):void
        {
            var eventName:String = getQualifiedClassName(this);
            var shareEvent:Event = new Event(eventName, true);
            dispatchEvent(shareEvent);
        }
        
        private function getBitmapFilter():BitmapFilter {
            var color:Number = Constants.GLOW_COLOR;
            var alpha:Number = 0.8;
            var blurX:Number = 2;
            var blurY:Number = 2;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;
            
            return new GlowFilter(color,
                alpha,
                blurX,
                blurY,
                strength,
                quality,
                inner,
                knockout);
        }
    }
}