package com.umiwi.control
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Toolbar extends MovieClip
	{
		private var visibilityTimer:Timer;
		
		private static const VISIBILITY_DELAY:int = 3000;
		
		public function Toolbar()
		{
			super();
			mouseEnabled = true;
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			visible = true;
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			this.visible = true;
			if (visibilityTimer.running)
			{
				visibilityTimer.stop();
			}
			visibilityTimer.reset();
			visibilityTimer.start();
		}
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			visible = false;		
		}
	}
}