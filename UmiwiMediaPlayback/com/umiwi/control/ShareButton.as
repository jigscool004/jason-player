package com.umiwi.control
{
    import com.umiwi.util.Constatns;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class ShareButton extends BaseIconButton
    {
        
        public function ShareButton()
        {
            super();
        }
        
        override protected function onMouseClick(event:MouseEvent):void
        {
            var shareEvent:Event = new Event(Constatns.OPEN_SHARE_PANEL, true);
            dispatchEvent(shareEvent);
        }
    }
}