package com.umiwi.control
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	public class BrightnessButton extends TraitControl
	{
		public function BrightnessButton()
		{
			super();
			traitType = MediaTraitType.DISPLAY_OBJECT;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			toolTipMC.tip.text = "亮度调节";
			toolTipMC.visible = false;
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			disAdjustBarBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
			disAdjustBarBtn.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			adjustBar.dragBar.addEventListener(MouseEvent.MOUSE_DOWN,brightNessAdjust);
			adjustBar.dragBar.addEventListener(MouseEvent.MOUSE_MOVE,setBrightNess);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,stopBrightNessAdjust);
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			adjustBar.visible = false;
			toolTipMC.visible = false;
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			adjustBar.visible = !adjustBar.visible;
			toolTipMC.visible = false;
		}
		
		protected function onButtonOver(event:MouseEvent):void
		{
			if(!adjustBar.visible)
			{
				toolTipMC.visible = true;
			}
		}
		
		
		private function brightNessAdjust(e:Event) {
			var dragArea:Rectangle=new Rectangle(5.5,-7,0,-40);
			adjustBar.dragBar.startDrag(false,dragArea);
		}
		
		private function setBrightNess(e:Event) {
			//updateMsg(toolBar.brightNessBtn.adjustBar.dragBar.y);
			var tmpValue:Number=adjustBar.dragBar.y+6;
			var brightness:Number = -(tmpValue/48)* 255;
			var filterArray:Array=[1, 0, 0, 0, brightness,
				0, 1, 0, 0, brightness,
				0, 0, 1, 0,brightness,
				0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
			displayTrait.displayObject.filters=[colorMatrix];
			
		}
		
		private function stopBrightNessAdjust(e:Event) {
			if (adjustBar.visible == false)
			{
				return;
			}
			adjustBar.dragBar.stopDrag();
			var tmpValue:Number=adjustBar.dragBar.y+6;
			var brightness:Number = -(tmpValue/48)* 255;
			var filterArray:Array=[1, 0, 0, 0, brightness,
				0, 1, 0, 0, brightness,
				0, 0, 1, 0,brightness,
				0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
			displayTrait.displayObject.filters=[colorMatrix];
			
		}
		
		override protected function addElement():void{
			this.visible = true;
			var displayTrait:DisplayObjectTrait = traitInstance as DisplayObjectTrait;
		}
		
		override protected function removeElement():void{
			visible = false;
		}
	}
}