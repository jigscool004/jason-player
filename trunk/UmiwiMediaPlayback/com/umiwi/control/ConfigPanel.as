package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    import com.umiwi.util.Constants;
    
    import fl.controls.RadioButton;
    import fl.core.UIComponent;
    
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import org.osmf.media.MediaElement;
    import org.osmf.traits.MediaTraitType;
    
    public class ConfigPanel extends MovieClip
    {   
        private var isBrightSet:Boolean = false;
        private var selectedIndex_:int;
        
        public function set selectedIndex(i:int):void
        {
            if(i != selectedIndex_)
            {
                selectedIndex_ = i;
                changeSelectedIndex(selectedIndex_);
            }
            
        }
        
        public function get selectedIndex():int
        {
            return selectedIndex_;
        }
        
        public function ConfigPanel()
        {
            super();
            
            this.visible = false;
            mouseEnabled = true;
            addEventListener(Constants.CLOSE_ME, closeMe);
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            
            addEventListener(ButtonEvent.TOGGLE_BUTTON, onToggleButton);
            
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {   
            definitionTab.textField.text = "清晰度";
            lightTab.textField.text = "亮度调节";
            playTab.textField.text = "播放";
            
            definitionTab.buttonIndex = 1;
            lightTab.buttonIndex = 2;
            playTab.buttonIndex = 3;
        }
        
        private function changeColor(rb:UIComponent):void
        {
            var myFormat:TextFormat = new TextFormat();
            myFormat.font = "Arial";
            myFormat.size = 14;
            myFormat.bold = true;
            myFormat.color = 0xFFFFFF;
            rb.setStyle("textFormat", myFormat); 
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            visible = false;
        }
        
        private function onToggleButton(event:ButtonEvent):void
        {
            changeSelectedIndex(event.index);
        }
        
        private function changeSelectedIndex(index:uint):void
        {
            gotoAndStop(index);
            
            definitionTab.selected = false;
            lightTab.selected = false;
            playTab.selected = false;
            
            if(index == 1)
            {
                definitionTab.selected = true;
            }
            if(index == 2)
            {
                lightTab.selected = true;
            }
            if(index == 3)
            {
                playTab.selected = true;
            }
            
        }
    }
}