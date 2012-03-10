package com.umiwi.control.component
{
    import fl.transitions.*;
    import fl.transitions.easing.*;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    
    public class BasePanel extends MovieClip
    {
        private var enlargeObj:Object = {type:Zoom, direction: Transition.IN, duration: .5, easing: Strong.easeOut};
        private var shrinkObj:Object = {type:Zoom, direction: Transition.OUT, duration: .5, easing: Strong.easeIn};
        
        public var showing:Boolean = false;
        
        public function show():void
        {
            showing = true;
            TransitionManager.start(this, enlargeObj);
        }
        
        public function hide():void
        {
            showing = false;
            TransitionManager.start(this, shrinkObj);
        }
    }
}