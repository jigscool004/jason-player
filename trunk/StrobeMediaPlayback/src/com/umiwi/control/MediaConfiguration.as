package com.umiwi.control
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;

	public class MediaConfiguration
	{
		private var brightnessProperty:Number;
		
		private var contrastProperty:Number;
		
		private var hueProperty:Number;
		
		private var saturationProperty:Number;
		
		public function MediaConfiguration()
		{
		}
		
		public static function changeView(obj:DisplayObject):Object
		{
/*			brightness:Number = 0,
				
				contrast:Number = 0,
					
					hue:Number = 0,
						
						saturation:Number = 0
			
			brightnessProperty = Math.max(-255, Math.min(brightness, 255));
			
			contrastProperty = Math.max(-100, Math.min(contrast, 100));
			
			hueProperty = Math.max(-180, Math.min(hue, 180));hue;
			
			saturationProperty = Math.max(-100, Math.min(saturation, 100));
			
			//Assign Adjustments From Class Properties
			
			var color:AdjustColor = new AdjustColor();
			
			color.brightness = brightnessProperty;
			
			color.contrast = contrastProperty;
			
			color.hue = hueProperty;
			
			color.saturation = saturationProperty;
			
			
			//Flatten Adjustment Numbers Within An Array
			
			var colorArray:Array = new Array();
			
			colorArray = color.CalculateFinalFlatArray();
			
			
			//Assign colorArray As The targetDisplayObject Filter
			
			targetDisplayObject.filters = [new ColorMatrixFilter(colorArray)];*/	
			
			var filterArray:Array=[1, 0, 0, 0, 2,
				0, 1, 0, 0, 2,
				0, 0, 1, 0, 2,
				0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			obj.filters = [colorMatrix];
			return obj;
			
		}
	}
}