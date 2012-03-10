package com.umiwi.control
{
    import com.umiwi.util.Constants;
    
    import fl.motion.Color;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.text.TextField;
    import flash.utils.getQualifiedClassName;
    
    public class BaseTextButton extends MovieClip
    {   
        
        public function BaseTextButton()
        {
            super();
            mouseChildren = false;
            buttonMode = true;
            addEventListener(MouseEvent.ROLL_OVER, onRollOver);
            addEventListener(MouseEvent.ROLL_OUT, onRollOut);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {
            var tf:TextField = getChildByName("textField") as TextField;
            tf.mouseEnabled = true;
        }
        
        protected function onRollOver(event:MouseEvent):void
        {
            gotoAndStop(2);
            var tf:TextField = textField as TextField;
            tf.textColor = Constants.TINT_COLOR;

        }
        
        protected function onRollOut(event:MouseEvent):void
        {
            this.gotoAndStop(1);
            var tf:TextField = textField as TextField;
            tf.textColor = 0xCCCCCC;
        }
        
        protected function onMouseDown(event:MouseEvent):void
        {
            gotoAndStop(3);
        }
    }
}