package com.umiwi.control
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class ToggleIconButtonOnColor extends BaseIconButton
    {
        private var selected_:Boolean = false;
        public var toggle:Boolean = false;
        
        public function set selected(b:Boolean):void
        {
            selected_ = b;
            if(selected_)
            {
                icon.transform.colorTransform = slectedColor;
            }
            else
            {
                icon.transform.colorTransform = normalColor;
            }
        }
        
        public function get selected():Boolean{
            return selected_;
        }
        
        public function ToggleIconButtonOnColor()
        {
            super();
        }
        
        override protected function onRollOut1(event:MouseEvent):void
        {   
            var icon:MovieClip = getChildByName("icon") as MovieClip;
            if(selected)
            {
                icon.transform.colorTransform = slectedColor;
            }
            else
            {
                icon.transform.colorTransform = normalColor;
            }
        }
        
        override protected function onMouseClick(event:MouseEvent):void
        {
            super.onMouseClick(event);
            if(toggle)
            {
                selected = !selected;
            }
            else
            {
                selected = true;
            }
        }
    }
}