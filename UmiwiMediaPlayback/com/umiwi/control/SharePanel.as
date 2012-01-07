package com.umiwi.control
{
    import com.umiwi.util.Constants;
    import com.umiwi.util.ControlUtil;
    
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    public class SharePanel extends MovieClip
    {   
        public function SharePanel()
        {
            super();
            this.visible = false;
            mouseEnabled = true;
            addEventListener(Event.ADDED_TO_STAGE, onAdded2Stage);
        }
        
        private function onAdded2Stage(event:Event):void
        {
            okButton.addEventListener(MouseEvent.CLICK, closeMe);
            closeButton.addEventListener(MouseEvent.CLICK, closeMe);
            
            copyFlash.addEventListener(MouseEvent.CLICK, copy2Flash);
            copyHtml.addEventListener(MouseEvent.CLICK, copy2Html);
            copyVideo.addEventListener(MouseEvent.CLICK, copy2Video);
            
            okButton.textField.text = "返回播放";
            copyFlash.textField.text = "复制";
            copyHtml.textField.text = "复制";
            copyVideo.textField.text = "复制";
        }
        
        public function loadConfiguration():void
        {
            var request:URLRequest = new URLRequest(ControlUtil.configuration.poster);
            poster.scaleContent = true;            
            poster.load(request);
            
            var a:Array = [qzone, tsina, tqq, tsohu, kaixin001, renren, t163];
            for (var i:int=0; i<a.length; i++)
            {
                a[i].alpha = 0.8
                a[i].addEventListener(MouseEvent.CLICK, onClick);
                function onClick(event:MouseEvent):void {
                    navigateToURL(new URLRequest("http://www.jiathis.com/send/?url=" + ControlUtil.configuration.htmlURL +
                        "&title=" + "优米网" + 
                        "&webid=" + String(event.target.name) +
                        "&uid="+ 123));
                }
                a[i].addEventListener(MouseEvent.ROLL_OVER,btnMouseOver);
                function btnMouseOver(event:MouseEvent):void {
                    event.target.alpha = 1;
                }
                a[i].addEventListener(MouseEvent.ROLL_OUT,btnMouseOut);
                function btnMouseOut(event:MouseEvent):void {
                    event.target.alpha = 0.8;
                }
            }
            
            flashText.text = ControlUtil.configuration.flashURL;
            htmlText.text = ControlUtil.configuration.htmlURL;
            
            if(!ControlUtil.configuration.isMember)
            {
                videoLabel.visible = false;
                videoText.visible = false;
                copyVideo.visible = false;
            }
            else
            {
                videoText.text = ControlUtil.configuration.videoURL;
            }
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            dispatchEvent(new Event(Constants.CLOSE_SHARE_PANEL, true));
        }
        
        private function copy2Flash(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ControlUtil.configuration.flashURL);
        }
        
        private function copy2Html(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ControlUtil.configuration.htmlURL);
        }
        
        private function copy2Video(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ControlUtil.configuration.videoURL);
        }
    }
}