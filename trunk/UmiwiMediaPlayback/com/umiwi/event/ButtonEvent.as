package com.umiwi.event
{
    import flash.events.Event;
    
    public class ButtonEvent extends Event
    {
        public static const TOGGLE_BUTTON:String = "toggleButton";
        
        public var index:int;
        
        public function ButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}