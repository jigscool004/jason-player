package com.umiwi.control
{
    import fl.motion.Color;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.utils.getQualifiedClassName;
    
    public class BaseTextButton extends MovieClip
    {
        //protected var icon:MovieClip;
        //private var highlightColor:Color;
        //protected var colorValue:Number = 
        
        public function BaseTextButton()
        {
            super();
            mouseEnabled = true;
            addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            addEventListener(MouseEvent.ROLL_OUT, onRollOut);
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }
        
        protected function onRollOver(event:MouseEvent):void
        {
            var filterObj:ColorMatrixFilter = new ColorMatrixFilter();    
            filterObj.matrix = new Array(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0);  
            
            var matrix:Array = new Array();
            matrix = matrix.concat([0, 0, 0, 0, 0]); // red
            matrix = matrix.concat([0, 1, 0, 0, 0]); // green
            matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            var rawFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
            filters = [filterObj];
            
            //highlightColor   =   new   Color(icon);
            //highlightColor.setTint(0x993366); 
        }
        
        protected function onRollOut(event:MouseEvent):void
        {
            filters = [];
        }
        
        protected function onMouseClick(event:MouseEvent):void
        {
            var eventName:String = getQualifiedClassName(this);
            var shareEvent:Event = new Event(eventName, true);
            dispatchEvent(shareEvent);
        }
    }
}