package com.umiwi.control
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    public class SliderControl extends MovieClip
    {
        public var min:Number = -10;
        public var max:Number = 10;
        
        private var _enabled:Boolean = true;
        private var _sliding:Boolean;
        private var _sliderClickArea:Sprite;
        private var scrubberStart:Number;
        private var scrubberEnd:Number;
        
        private var _value:Number = 0;
        
        public function set value(v:Number):void
        {
            _value = v;
            var position:Number = width * (v - min) / (max - min);
            position = position - sliderButton.width * 0.5
            sliderButton.x = Math.max(0, position);
            valueBar.width = sliderButton.x;
        }
        
        public function get value():Number
        {
            return _value;
        }
        
        public function SliderControl()
        {
            super();
            buttonMode = true;
            _sliderClickArea = new Sprite();
            _sliderClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
            _sliderClickArea.addEventListener(MouseEvent.MOUSE_UP, onTrackMouseUp);
            _sliderClickArea.addEventListener(MouseEvent.MOUSE_OVER, onTrackMouseOver);
            _sliderClickArea.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
            _sliderClickArea.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
            
            addChild(_sliderClickArea);
            _sliderClickArea.x = sliderBack.x;
            _sliderClickArea.y = sliderBack.y;
            setClickArea();
            
            sliderButton.addEventListener(MouseEvent.MOUSE_DOWN, onSliderButtonMouseDown);;
            sliderButton.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
            sliderButton.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
            
            scrubberEnd = sliderBack.x + sliderBack.width - sliderButton.width/2;
        }
        
        private function setClickArea():void
        {
            _sliderClickArea.graphics.clear();
            _sliderClickArea.graphics.beginFill(0xFFFFFF, 0.0);
            _sliderClickArea.graphics.drawRect(0.0, 0.0, sliderBack.width, sliderBack.height);
            _sliderClickArea.graphics.endFill();
        }
        
        private function onTrackMouseDown(event:MouseEvent):void
        {
            seekToX(mouseX - sliderButton.width / 2.0);			
            //showHint();			
        }
        
        private function onTrackMouseUp(event:MouseEvent):void
        {
            stopScrubber();		
        }
        
        private function onTrackMouseOver(event:MouseEvent):void
        {
            //showHint();
        }
        
        private function onTrackMouseMove(event:MouseEvent):void
        {
            //showHint();
            if (event.buttonDown && !_sliding)
            {
                startScrubber();			
            }
            valueBar.width = sliderButton.x;
        }
        
        private function onTrackMouseOut(event:MouseEvent):void
        {
            //hideHint();
        }
        
        private function onSliderButtonMouseDown(event:MouseEvent):void
        {
            startScrubber(false);
        }
        
        public function startScrubber(lockCenter:Boolean = true):void
        {
            if (_enabled && _sliding == false)
            {
                _sliding = true;
                stage.addEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
                var dragArea:Rectangle=new Rectangle(0,sliderButton.y,this.scrubberEnd,0);
                (sliderButton as Sprite).startDrag(false, dragArea);
            }
        }
        
        public function stopScrubber():void
        {
            if (_enabled && _sliding)
            {
                sliderButton.stopDrag();
                _sliding = false;
                
                try
                {
                    stage.removeEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
                }
                catch (e:Error)
                {
                    // swallow this, it means that we already removed
                    // the event listened in a previous stop() call
                }
                this.onScrubberEnd()
                
            }
        }
        
        private function onStageExitDrag(event:MouseEvent):void
        {
            stopScrubber();
        }
        
        private function onScrubberEnd():void
        {
            seekToX(sliderButton.x);
        }
        
        private function seekToX(relativePositition:Number):void
        {
            sliderButton.x = Math.max(0, relativePositition);
            valueBar.width = sliderButton.x;
            
            _value = min + (max - min) * relativePositition / width;
            
            dispatchEvent(new Event("sliderChange"));
        }
    }
}