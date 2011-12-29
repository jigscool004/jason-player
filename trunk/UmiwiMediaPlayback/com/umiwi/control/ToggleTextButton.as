package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    import com.umiwi.util.Constants;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    
    public class ToggleTextButton extends MovieClip
    {
        public var buttonIndex:uint;
        private var selected_:Boolean = false;
        private var myFilters:Array = [];
        
        public function set selected(b:Boolean):void
        {
            selected_ = b;
            changeStatus(b);
        }
        
        public function get selected():Boolean
        {
            return selected_;
        }
        
        public function ToggleTextButton()
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
            //filters = myFilters;
        }
        
        protected function onRollOut(event:MouseEvent):void
        {   
            //filters = [];
        }
        
        private function changeStatus(b:Boolean):void
        {
            if(b)
            {
                gotoAndStop(2);
            }
            else
            {
                gotoAndStop(1);
            }
        }
        
        protected function onMouseClick(event:MouseEvent):void
        {
            var bEvent:ButtonEvent = new ButtonEvent(ButtonEvent.TOGGLE_BUTTON, true);
            bEvent.index = buttonIndex;
            dispatchEvent(bEvent);
            
            selected = true;
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