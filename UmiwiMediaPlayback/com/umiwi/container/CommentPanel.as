package com.umiwi.container
{
    import com.umiwi.control.component.BasePanel;
    import com.umiwi.util.Constants;
    import com.umiwi.util.ControlUtil;
    import com.umiwi.util.UConfigurationLoader;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;
    
    public class CommentPanel extends BasePanel
    {
        var timer:Timer = new Timer(3000, 1);
        public function CommentPanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, hideAlert);
        }
        
        private function onAdded2Stage(event:Event):void
        { 
            removeEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            okButton.addEventListener(MouseEvent.CLICK, submitComment);
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            alert.visible = false;
            visible = false;
            ControlUtil.formatTA(ta);
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            hideMe();
        }
        
        private function submitComment(event:Event):void
        {
            var text:String = ta.text;
            if(text && text.length > 0)
            {
                //send post request.
                if (ExternalInterface.available && !ControlUtil.configuration.out)
                {
                    try{
                        ExternalInterface.call("submitComment", text);
                        UConfigurationLoader.updateMsg(text);
                    }
                    catch(_:Error)
                    {
                        trace(_.toString());
                    }
                }
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
            hide();
            ta.text = "";
            dispatchEvent(new Event(Constants.START_TIMER, true));
        }
        
        private function hideAlert(event:TimerEvent):void
        {
            alert.visible = false;
        }
    }
}