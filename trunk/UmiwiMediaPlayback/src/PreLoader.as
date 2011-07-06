package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	public class PreLoader extends Sprite
	{
		private var libLoader:Loader = new Loader();
		private static const SIGNED_DIGEST:String = "b63185fca5d2bdbb568593f2bf232e87e5a20a7ea2ce2e26671d159838d598ed";
		private static const UNSIGNED_DIGEST:String = "4e0edc22159b81e315c20abb2f11e5b7003050224ee93eaf40430b1c420528d7";
		
		public function PreLoader()
		{
			super();
			
			var myURLReq:URLRequest = new URLRequest();
			myURLReq.url = "osmf_1.0.0.16316.swz";
			myURLReq.digest = SIGNED_DIGEST;
			var myURLLoader:URLLoader = new URLLoader();
			myURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			myURLLoader.addEventListener("complete", onC);
			
			myURLLoader.load(myURLReq);
			
			function onC(e:Event):void {
				libLoader.loadBytes ((ByteArray)(myURLLoader.data), new LoaderContext ( false ,ApplicationDomain.currentDomain ) ) ;
				libLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE ,loadUI) ;
			}
		}
		
		private function loadUI(event:Event):void{
			libLoader = new Loader();
			libLoader.load ( new URLRequest ( "UmiwiMediaPlayback.swf" ) ,new LoaderContext ( false ,ApplicationDomain.currentDomain ) ) ;
			libLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE ,initUI) ;
		}
		
		private function initUI(event:Event):void{
			var ds:Class = getDefinitionByName("UmiwiMediaPlayback") as Class;
			stage.addChild(new ds() as DisplayObject);
		}
		
	}
}