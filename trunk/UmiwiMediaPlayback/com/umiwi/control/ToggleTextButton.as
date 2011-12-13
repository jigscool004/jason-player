package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    
    public class ToggleTextButton extends MovieClip
    {
        public var buttonIndex:uint;
        private var selected_:Boolean = false;
        
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
            //addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            //addEventListener(MouseEvent.ROLL_OUT, onRollOut);
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }
        
        
/*        protected function onRollOver(event:MouseEvent):void
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
        }*/
        
        private function changeStatus(b:Boolean):void
        {
            if(b)
            {
                var filterObj:ColorMatrixFilter = new ColorMatrixFilter();    
                filterObj.matrix = new Array(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0); 
                filters = [filterObj];
            }
            else
            {
                filters = [];
            }
        }
        
        protected function onMouseClick(event:MouseEvent):void
        {
            var bEvent:ButtonEvent = new ButtonEvent(ButtonEvent.TOGGLE_BUTTON, true);
            bEvent.index = buttonIndex;
            dispatchEvent(bEvent);
            
            selected = true;
        }
    }
}