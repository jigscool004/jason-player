package com.umiwi.control
{
    import com.umiwi.util.Constatns;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class BaseWindow extends MovieClip
    {
        public function BaseWindow()
        {
            super();
            this.visible = false;
            mouseEnabled = true;
            addEventListener(Constatns.CLOSE_ME, closeMe);
            addEventListener(Constatns.SIMPLE_CONFIRM, closeMe);
            
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            visible = false;
        }
    }
}