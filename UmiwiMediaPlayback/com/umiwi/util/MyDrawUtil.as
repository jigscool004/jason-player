package com.umiwi.util
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    public class MyDrawUtil
    {
        private static const TIME_LEFT_WIDTH:int = 610;  //100
        private static const TIME_LEFT_HEIGHT:int = 20;
        
        public function MyDrawUtil()
        {
        }
        
        public static function drawTimeLeftLabel(child:Sprite):Sprite
        {
            child.graphics.beginFill(0x333333, 0.8);
            child.graphics.lineStyle(1, 0x333333);
            child.graphics.drawRoundRect(0, 0, TIME_LEFT_WIDTH, TIME_LEFT_HEIGHT, 5);
            child.graphics.endFill();
            
            var label:TextField = new TextField();
            label.name = "timeLabel";
            label.text = "广告剩余00秒";
            label.autoSize = TextFieldAutoSize.LEFT;
            label.x = (TIME_LEFT_WIDTH - label.width) * 0.5
            label.y = 0;
            var format:TextFormat = new TextFormat();
            //format.font = "Verdana";
            format.color = 0xCCCCCC;
            format.size = 12;
            format.bold = true;
            label.defaultTextFormat = format;
            child.addChild(label);
            return child;
        }
        
        public static function setTime(sprite:Sprite, time:int):void
        {
            var label:TextField = sprite.getChildByName("timeLabel") as TextField;
            if(label)
            {
                label.text = "广告剩余" + time + "秒";
            }
        }
    }
}