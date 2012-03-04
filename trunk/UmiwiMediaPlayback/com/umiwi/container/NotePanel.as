package com.umiwi.container
{
    import com.adobe.images.JPGEncoder;
    import com.dynamicflash.util.Base64;
    import com.umiwi.control.TraitControl;
    import com.umiwi.control.component.BasePanel;
    import com.umiwi.util.Constants;
    import com.umiwi.util.ControlUtil;
    import com.umiwi.util.DisplayUtil;
    import com.umiwi.util.UConfigurationLoader;
    
    import fl.containers.UILoader;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Matrix;
    import flash.media.Video;
    import flash.net.URLRequest;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    public class NotePanel extends BasePanel
    {
        private var timer:Timer = new Timer(3000, 1);
        public var currentTime:Number = -1;
        
        public function NotePanel()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, hideAlert);
            visible = false;
        }
        
        private function onAdded2Stage(event:Event):void
        { 
            removeEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
            okButton.addEventListener(MouseEvent.CLICK, submitComment);
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            alert.visible = false;
            
            ControlUtil.formatTA(ta);
        }
        
        override public function set visible(v:Boolean):void
        {
            super.visible = v;
            if(v)
            {
                capture();
            }
        }
        
        public function capture():void
        {
            if(currentTime < 0)
            {
                return;
            }
            var url:URLRequest = ControlUtil.captureURL(currentTime);
            imgLoader.load(url);
        }
        
        private static const JPG_QUALITY_DEFAULT:uint = 80;
        private function img2string():String
        {
            var loader:UILoader = imgLoader as UILoader;
            var img:Bitmap = loader.content as Bitmap;
            
            var jpgEncoder:JPGEncoder = new JPGEncoder(JPG_QUALITY_DEFAULT); 
            var byteArray:ByteArray = jpgEncoder.encode(img.bitmapData);
            return Base64.encodeByteArray(byteArray);
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            hideMe();
        }
        
        private function submitComment(event:Event):void
        {
            var text:String = ta.text;
            var imageString:String = img2string();
            if(text && text.length > 0)
            {
                //send post request.
                if (ExternalInterface.available && !ControlUtil.configuration.out)
                {
                    try{
                        ExternalInterface.call("submitNote", imageString, text);
                        UConfigurationLoader.updateMsg(imageString);
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
            ta.text = "";
            this.dispatchEvent(new Event(Constants.CLOSE_NOTE_PANEL, true));
        }
        
        private function hideAlert(event:TimerEvent):void
        {
            alert.visible = false;
        }
    }
}