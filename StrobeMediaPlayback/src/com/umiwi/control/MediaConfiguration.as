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
		
		public static function changeView(obj:DisplayObject):DisplayObject
		{
			if(!obj)
			{
				return null;
			}
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
			
			var filterArray:Array=[1, 0, 0, 0, -255,
									0, 1, 0, 0, -255,
									0, 0, 1, 0, -255,
									0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			obj.filters = [colorMatrix];
			return obj;
			
		}
		
		public static function setBrightness(obj:DisplayObject, value:Number):DisplayObject
		{
			if(!obj)
			{
				return null;
			}
			var filterArray:Array=[1, 0, 0, 0, value,
									0, 1, 0, 0, value,
									0, 0, 1, 0, value,
									0, 0, 0, 1, 0];
			var colorMatrix:ColorMatrixFilter=new ColorMatrixFilter(filterArray);
			obj.filters = [colorMatrix];
			return obj;
		}
	}
}