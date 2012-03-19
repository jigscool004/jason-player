package com.umiwi.control
{
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class Toolbar extends MovieClip
	{
        
        
        private var timer:Timer = new Timer(5000,1);
        private var isDrawOut:Boolean = false;
        
        public function Toolbar()
        {
            super();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
            stage.addEventListener(Event.MOUSE_LEAVE, onRollOut1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);
            
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent, false, 0, true);
            
            fullScrBtn.addEventListener(MouseEvent.CLICK, onClickFullScreen);
            fullScrBtn.buttonMode = true;
            y = stage.stageHeight - toolBarBack.height;
        }
        
        private function onMouseMove1(event:MouseEvent):void
        {
            if (stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                drawOut();
            }
            else
            {
                visible = true;
            }
        }
        
        private function onRollOut1(event:Event):void
        {
            if (stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                drawIn();
            }
        }
        
        private function onTimerCompleted(event:TimerEvent):void
        {
            if (stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                drawIn();
            }
        }
        
        private function onFullScreenEvent(event:FullScreenEvent):void
        {
            if(event.fullScreen) {
                timer.reset();
                timer.start();
                
                setFullScreenButton2();
            }
            else
            {
                y = stage.stageHeight - height;
                
                setFullScreenButton1();
            }
        }
        
        private function drawOut():void
        {
            if(!isDrawOut)
            {
                var myTween:Tween = new Tween(this, "y", Regular.easeIn, stage.stageHeight, stage.stageHeight - height, .6, true);
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
                var myTween:Tween = new Tween(this, "y", Regular.easeIn, stage.stageHeight - height, stage.stageHeight, .6, true);
                isDrawOut = false;
            }
        }
        
        protected function onClickFullScreen(event:MouseEvent):void
        {
            switch (stage.displayState) {
                case StageDisplayState.NORMAL:
                    stage.displayState=StageDisplayState.FULL_SCREEN;
                    setFullScreenButton2();
                    break;
                case StageDisplayState.FULL_SCREEN:
                    stage.displayState=StageDisplayState.NORMAL;
                    setFullScreenButton1();
                    break;
                default :
                    stage.displayState=StageDisplayState.NORMAL;
                    setFullScreenButton1();
            }
        }
        
        private function setFullScreenButton1():void
        {
            var tf:TextField = fullScrBtn.textField as TextField;
            tf.text = "全屏";
        }
        
        private function setFullScreenButton2():void
        {
            var tf:TextField = fullScrBtn.textField as TextField;
            tf.text = "退出全屏";
        }
	}
}