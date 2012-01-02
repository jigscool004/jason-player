package com.umiwi.control
{
    import com.umiwi.util.Constants;
    
    import fl.transitions.Tween;
    import fl.transitions.easing.Regular;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.FullScreenEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class TopBar extends MovieClip
    {
        
        private var timer:Timer = new Timer(5000,1);
        private var isDrawOut:Boolean = false;
        
        public function TopBar()
        {
            super();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
            stage.addEventListener(MouseEvent.ROLL_OUT, onRollOut1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);
            
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent, false, 0, true);
            
            zoom50.addEventListener(MouseEvent.CLICK, onClick50);
            zoom75.addEventListener(MouseEvent.CLICK, onClick75);
            zoom100.addEventListener(MouseEvent.CLICK, onClick100);
            y = 0 - height;
            visible = false;
        }
        
        private function onMouseMove1(event:MouseEvent):void
        {
            drawOut();
        }
        
        private function onRollOut1(event:MouseEvent):void
        {
            drawIn();
        }
        
        private function onTimerCompleted(event:TimerEvent):void
        {
            drawIn();
        }
        
        private function onFullScreenEvent(event:FullScreenEvent):void
        {
            if(event.fullScreen) {
                visible = true;
            }
            else
            {
                visible = false;
            }
        }
        
        private function drawOut():void
        {
            if(!isDrawOut)
            {
                var myTween:Tween = new Tween(this, "y", Regular.easeIn, 0 - height, 0, .6, true);
                isDrawOut = true;
            }
            timer.reset();
            timer.start();
        }
        
        private function drawIn():void
        {
            timer.stop();
            if(isDrawOut)
            {
                var myTween:Tween = new Tween(this, "y", Regular.easeIn, 0, 0 - height, .6, true);
                isDrawOut = false;
            }
        }
        
        protected function onClick50(event:MouseEvent):void
        {
            var shareEvent:Event = new Event(Constants.ZOOM50, true);
            dispatchEvent(shareEvent);
            
            zoom75.selected = false;
            zoom100.selected = false;
        }
        
        protected function onClick75(event:MouseEvent):void
        {
            var shareEvent:Event = new Event(Constants.ZOOM75, true);
            dispatchEvent(shareEvent);
            
            zoom50.selected = false;
            zoom100.selected = false;
        }
        protected function onClick100(event:MouseEvent):void
        {
            var shareEvent:Event = new Event(Constants.ZOOM100, true);
            dispatchEvent(shareEvent);
            
            zoom50.selected = false;
            zoom75.selected = false;
        }
    }
}