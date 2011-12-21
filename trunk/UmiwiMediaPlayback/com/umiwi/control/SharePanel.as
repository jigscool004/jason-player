package com.umiwi.control
{
    import com.umiwi.util.Constatns;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class SharePanel extends MovieClip
    {
        public function SharePanel()
        {
            super();
            this.visible = false;
            mouseEnabled = true;
            okButton.addEventListener(MouseEvent.CLICK, closeMe);
            addEventListener(Constatns.SIMPLE_CONFIRM, closeMe);
            
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            visible = false;
        }
    }
}