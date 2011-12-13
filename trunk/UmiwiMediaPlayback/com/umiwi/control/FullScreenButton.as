package com.umiwi.control
{
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	public class FullScreenButton extends MovieClip
	{
		public function FullScreenButton()
		{
			super();
			mouseEnabled = true;
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent, false, 0, true);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{	
            updateState();

		}
        
        private function onFullScreenEvent(event:FullScreenEvent):void
        {
            if(event.fullScreen) {
                gotoAndStop(2);
            }
            else
            {
                gotoAndStop(1);
            }
        }
        
        private function updateState():void
        {
            switch (stage.displayState) {
                case StageDisplayState.NORMAL:
                    stage.displayState=StageDisplayState.FULL_SCREEN;
                    break;
                case StageDisplayState.FULL_SCREEN:
                    stage.displayState=StageDisplayState.NORMAL;
                    break;
                default :
                    stage.displayState=StageDisplayState.NORMAL;
            }
        }
	}
}