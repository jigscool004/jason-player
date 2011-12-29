package com.umiwi.event
{
    import flash.events.Event;
    
    public class ButtonEvent extends Event
    {
        public static const TOGGLE_BUTTON:String = "toggleButton";
        
        public static const SET_DISPLAY:String = "setDisplay";
        
        public var index:int;
        public var data:Object;
        
        public function ButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}