package com.umiwi.control
{
    import fl.transitions.Tween;
    import fl.transitions.easing.Regular;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    public class RightSideDrawer extends MovieClip
    {
        private var timer:Timer = new Timer(5000,1);
        private var isDrawOut:Boolean = false;
        
        public function RightSideDrawer()
        {
            super();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
            stage.addEventListener(MouseEvent.ROLL_OUT, onRollOut1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);
            x = stage.stageWidth - width;
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
        
        private function drawOut():void
        {
            if(!isDrawOut)
            {
                isDrawOut = true;
                var myTween:Tween = new Tween(this, "x", Regular.easeIn, stage.stageWidth, stage.stageWidth - width, .6, true);
            }
            timer.reset();
            timer.start();
        }
        
        private function drawIn():void
        {
            timer.stop();
            if(isDrawOut)
            {
                isDrawOut = false;
                var myTween:Tween = new Tween(this, "x", Regular.easeIn, stage.width - width, stage.width, .6, true);
            }
        }
    }
}