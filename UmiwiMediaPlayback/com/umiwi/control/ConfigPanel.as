package com.umiwi.control
{
    import com.umiwi.event.ButtonEvent;
    import com.umiwi.util.Constatns;
    
    import fl.controls.RadioButton;
    import fl.core.UIComponent;
    
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import org.osmf.media.MediaElement;
    import org.osmf.traits.MediaTraitType;
    
    public class ConfigPanel extends TraitControl
    {   
        private var isBrightSet:Boolean = false;
        private var selectedIndex_:int;
        
        public function set selectedIndex(i:int):void
        {
            selectedIndex_ = i;
        }
        
        public function get selectedIndex():int
        {
            return selectedIndex_;
        }
        
        public function ConfigPanel()
        {
            super();
            traitType = MediaTraitType.DISPLAY_OBJECT;
            
            this.visible = false;
            mouseEnabled = true;
            addEventListener(Constatns.CLOSE_ME, closeMe);
            addEventListener(Constatns.SIMPLE_CONFIRM, closeMe);
            addEventListener(ButtonEvent.TOGGLE_BUTTON, changeSelectedIndex);
            
            initButton();
        }
        
        private function initButton():void
        {
            definitionTab.label.text = "清晰度";
            lightTab.label.text = "亮度调节";
            playTab.label.text = "播放";
            
            definitionTab.buttonIndex = 1;
            lightTab.buttonIndex = 2;
            playTab.buttonIndex = 3;
            
            changeColor(nomalRadio);
            changeColor(highRadio);
            changeColor(autoRadio);
            changeColor(okButton);
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
        
        public function changeSelectedIndex(event:ButtonEvent):void
        {
            gotoAndStop(event.index);
            
            if(!isBrightSet)
            {
                (brightnessPanel as BrightnessPanel).setElement(_media);
                isBrightSet = true;
            }
            
            
            if(event.target != definitionTab)
            {
                definitionTab.selected = false;
            }
            if(event.target != lightTab)
            {
                lightTab.selected = false;
            }
            if(event.target != playTab)
            {
                playTab.selected = false;
            }
            
        }
    }
}