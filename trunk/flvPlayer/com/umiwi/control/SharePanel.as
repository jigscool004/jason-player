package com.umiwi.control
{
    import com.umiwi.control.component.BasePanel;
    import com.umiwi.util.Constants;
    import com.umiwi.util.UConfigurationLoader;
    
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    public class SharePanel extends BasePanel
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
            try{
                var request:URLRequest = new URLRequest(Constants.configuration.poster);
                poster.scaleContent = true;            
                poster.load(request);
            }
            catch(e:Error)
            {
                UConfigurationLoader.updateMsg("Failed to load poster. " + e.message);
            }

            
            var a:Array = [tsina, tqq, qzone, renren, kaixin001, tsohu, douban];
            for (var i:int=0; i<a.length; i++)
            {
                a[i].alpha = 0.8
                a[i].addEventListener(MouseEvent.CLICK, onClick);
                function onClick(event:MouseEvent):void {
                    navigateToURL(new URLRequest("http://www.jiathis.com/send/?url=" + Constants.configuration.htmlURL +
                        "&title=" + Constants.configuration.title + " " + Constants.configuration.intro + 
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
            
            flashText.text = Constants.configuration.flashURL;
            htmlText.text = Constants.configuration.htmlURL;
            
            if(!Constants.configuration.isMember)
            {
                videoLabel.visible = false;
                videoText.visible = false;
                copyVideo.visible = false;
            }
            else
            {
                videoText.text = Constants.configuration.videoURL;
            }
        }
        
        protected function closeMe(event:MouseEvent):void
        {
            dispatchEvent(new Event(Constants.CLOSE_SHARE_PANEL, true));
        }
        
        private function copy2Flash(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Constants.configuration.flashURL);
        }
        
        private function copy2Html(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Constants.configuration.htmlURL);
        }
        
        private function copy2Video(event:MouseEvent):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Constants.configuration.videoURL);
        }

    }
}