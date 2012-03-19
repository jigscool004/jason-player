package com.umiwi.control
{
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.transitions.Tween;
    import fl.transitions.easing.Regular;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    public class RightSideDrawer extends MovieClip
    {
        private var timer:Timer = new Timer(5000,1);
        private var drawOutTween:Tween;
        private var drawInTween:Tween;
        public var isDrawOut:Boolean = false;
        
        private static const PADDING:Number = 6;
        
        public function RightSideDrawer()
        {
            super();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
            stage.addEventListener(Event.MOUSE_LEAVE, onRollOut1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);
            
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {  
            x = stage.stageWidth;
            
            var lb:ToggleIconButton = lightButton as ToggleIconButton;
            lb.normalText = "关灯";
            lb.selectedText = "开灯";
            lb.addEventListener(MouseEvent.CLICK, onLightButtonClick);
        }
        
        private function onLightButtonClick(event:MouseEvent):void
        {
            var lb:ToggleIconButton = (lightButton as ToggleIconButton);
            if(lb.selected)
            {
                UConfigurationLoader.callExternal("light_off");
            }
            else
            {
                UConfigurationLoader.callExternal("light_on");
            }
        }
        
        private function onMouseMove1(event:MouseEvent):void
        {
            drawOut();
        }
        
        private function onRollOut1(event:Event):void
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
                drawOutTween = new Tween(this, "x", Regular.easeIn, stage.stageWidth, stage.stageWidth - width + PADDING, .6, true);
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
                drawInTween = new Tween(this, "x", Regular.easeIn, stage.stageWidth - width + PADDING, stage.stageWidth, .6, true);
            }
        }
        
        public function stopTween(status:Boolean, xPosition:Number, yPosition:Number):void
        {
            if(drawOutTween)
            {
                drawOutTween.stop();
            }
            if(drawInTween)
            {
                drawInTween.stop();
            }
            isDrawOut = status;
            timer.stop();
            x = xPosition;
            y = yPosition;
        }
    }
}