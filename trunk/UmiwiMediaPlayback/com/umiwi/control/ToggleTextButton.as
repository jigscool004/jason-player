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
    }
}