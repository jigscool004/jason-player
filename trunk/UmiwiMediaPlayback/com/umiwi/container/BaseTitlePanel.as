package com.umiwi.container
{
    import com.umiwi.util.Constants;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    public class BaseTitlePanel extends MovieClip
    { 
        private var timer:Timer = new Timer(3000, 1);
        protected var titleText:String = "Title";
        
        public function BaseTitlePanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, hideAlert);
        }
        
        private function onAdded2Stage(event:Event):void
        { 
            title.text = titleText;
            removeEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            okButton.addEventListener(MouseEvent.CLICK, submitComment);
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            alert.visible = false;
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            hideMe();
        }
        
        protected function submitComment(event:Event):void
        {
            var text:String = ta.text;
            if(text && text.length > 0)
            {
                //send post request.
                hideMe();
            }
            else
            {
                alert.visible = true;
                timer.reset();
                timer.start();
            }
        }
        
        private function hideMe():void
        {
            visible = false;
            ta.text = "";
        }
        
        private function hideAlert(event:TimerEvent):void
        {
            alert.visible = false;
        }
    }
}