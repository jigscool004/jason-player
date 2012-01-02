package com.umiwi.control
{
    import flash.events.MouseEvent;

    public class ToggleIconButton extends BaseIconButton
    {
        public var selected:Boolean = false;
        public var normalText:String;
        public var selectedText:String;
        
        public function ToggleIconButton()
        {
            super();
        }
        
        override protected function onMouseClick(event:MouseEvent):void
        {
            super.onMouseClick(event);
            selected = !selected;
            if(selected)
            {
                text.text = selectedText;
            }
            else
            {
                text.text = normalText;
            }
        }
    }
}