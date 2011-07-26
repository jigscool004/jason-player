package com.umiwi.control
{
	import com.umiwi.util.UConfigurationLoader;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class FullScreenButton extends MovieClip
	{
		public function FullScreenButton()
		{
			super();
			mouseEnabled = true;
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			
			toolTipMC.visible = false;
			setTipText1();
			addEventListener(MouseEvent.MOUSE_OVER,showTooltip);
			addEventListener(MouseEvent.MOUSE_OUT,hideTooltip);
		}
		
		private function showTooltip(event:MouseEvent):void{
			toolTipMC.visible = true;
		}
		
		private function hideTooltip(event:MouseEvent):void{
			toolTipMC.visible = false;
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			toolTipMC.visible = false;
			/*如果是外站，那么弹到umiwi视频页面*/
/*			if (UConfigurationLoader.isOut)
			{
				var d = new Date();
				var m = d.getMonth()+1;
				var year = d.getFullYear();
				var day = d.getDate();
				if ( m < 10) m = '0'+m;
				if ( day < 10) day = '0'+day;
				year = year%100;
				navigateToURL(new URLRequest('http://www.umiwi.com/video/detail'+flvID+'?utm_source=umv&utm_medium=videoshare&utm_content='+flvID+'&utm_campaign='+year+m+day));
				myNS.pause();
				toolBar.playBtn.gotoAndStop(1);	
				bigPlayBtn.visible=true;
				playState="pause";
				return;
			}*/
			
			
			switch (stage.displayState) {
				case "normal" :
					stage.displayState="fullScreen";
					gotoAndStop(2);
					setTipText2();
					break;
				case "fullScreen" :
					stage.displayState="normal";
					gotoAndStop(1);
					setTipText1();
					break;
				default :
					stage.displayState="normal";
					gotoAndStop(1);
					setTipText1();
			}
		}
		
		private function setTipText1():void{
			toolTipMC.tip.text = "全屏";
			toolTipMC.width = toolTipMC.width/2;
		}
		
		private function setTipText2():void{
			toolTipMC.tip.text = "退出全屏";
			toolTipMC.width = toolTipMC.width*2;
		}
	}
}