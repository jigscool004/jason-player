package com.umiwi.control
{
    import com.umiwi.util.Constants;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import org.osmf.events.PlayEvent;
    import org.osmf.media.MediaElement;
    import org.osmf.traits.AudioTrait;
    import org.osmf.traits.MediaTraitType;
    
    public class AlbumButton extends TraitControl
    {
        
        public function AlbumButton()
        {
            super();
            buttonMode = true;
            traitType = MediaTraitType.DISPLAY_OBJECT; 
            
            toolTipMC.tip.text = "播放列表";
            toolTipMC.visible = false;
            addEventListener(MouseEvent.ROLL_OVER,showTooltip);
            addEventListener(MouseEvent.ROLL_OUT,hideTooltip);
        }
        
        private function showTooltip(event:MouseEvent):void{
            toolTipMC.visible = true;
        }
        
        private function hideTooltip(event:MouseEvent):void{
            toolTipMC.visible = false;
        }		
        
        override protected function onMouseClick(event:MouseEvent):void
        {
            var shareEvent:Event = new Event(Constants.OPEN_ALBUM_PANEL, true);
            dispatchEvent(shareEvent);
            
        }
    }
}