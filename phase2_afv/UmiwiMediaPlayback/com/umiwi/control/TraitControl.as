package com.umiwi.control
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	
	public class TraitControl extends MovieClip
	{
		protected var traitType:String;
		protected var traitInstance:MediaTraitBase;
		
		protected var _media:MediaElement;
		
		public function TraitControl()
		{
			super();
			mouseEnabled = true;
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		protected function onMouseClick(event:MouseEvent):void
		{
		}
		
		public function setElement(element:MediaElement):void{
			_media = element
			if(element.hasTrait(traitType))
			{
				traitInstance = element.getTrait(traitType);
				addElement();
			}
			else
			{
				if(traitInstance != null)
				{
					removeElement();
					traitInstance = null;
				}
			}
		}
		
		protected function addElement():void{
			
		}
		
		protected function removeElement():void{
			
		}
		
		public function get media():MediaElement
		{
			return _media;
		}
	}
}