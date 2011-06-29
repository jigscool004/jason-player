/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	
	public class LogoLinkButton extends ButtonWidget
	{

		public function LogoLinkButton()
		{
			super();
			
			upFace = AssetIDs.LOGO_LINK_BUTTON;
			downFace = AssetIDs.LOGO_LINK_BUTTON;
			overFace = AssetIDs.LOGO_LINK_BUTTON;
		}
		// Overrides
		//

		
		override protected function onMouseClick(event:MouseEvent):void
		{
			navigateToURL(new URLRequest('http://www.umiwi.com/'));
		}
	}
}