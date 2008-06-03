////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.utilities.external {
	import com.degrafa.utilities.external.IExternalData
	import com.degrafa.utilities.external.ExternalDataAsset
	import flash.display.Loader;
	import flash.display.BitmapData;
	

	/**
	* The ExternalDataAsset class defines the properties for an external data source used at runtime by Degrafa. 
	* You can use an ExternalDataAsset object in actionscript - it may be useful to 
	* set up preloading, for example, but in mxml use of an ExternalDataAsset is already encapsulated into 
	* the Degrafa class that uses the content (when it is ready) by virtue of its source property assignment.
	* The data content provided by an ExternalDataAsset will only be available once the asset from the external url has 
	* loaded.
	*/
	public class ExternalBitmapData extends ExternalDataAsset implements IExternalData  {
		
			
		private var tempBitmapdata:BitmapData;
		
		//local override for getUniqueInstance mxml helper
		public static  function getUniqueInstance(url:String = null, loc:LoadingLocation = null):ExternalBitmapData
		{
			return ExternalDataAsset.getUniqueInstance(url, loc, ExternalBitmapData) as ExternalBitmapData;
		}
		/**
		 * Constructor for ExternalBitmapData
		 * @param	url absolute or relative url to external asset (must be relative if a LoadingLocation is used)
		 * @param	totalBytes [optional] total bytes, if known before loading commences
		 * @param	loc a LoadingLocation for security handling
		 */
		public function ExternalBitmapData(url:String = null, totalBytes:Number = NaN,loc:LoadingLocation=null)
		{
			dataType = BitmapData;
			super(url, totalBytes,Loader);
		}
		
		override protected function processLoad(loader:Object):String
		{
			tempBitmapdata = _data as BitmapData;
			var err:Boolean = false;
			try {
				_data = new BitmapData((loader as Loader).content.width, (loader as Loader).content.height, true, 0x00000000);
				_data.draw((loader as Loader).content);
			} catch (e:Error)
			{
				//the image has loaded but a crossdomain permission was not granted
				//so the bitmapData cannot be accessed. 
				//Only recourse is to check for another location if we're using a LoadingGroup
				//consider dispatching a specific permission failure event here.
				err = true;
			}
				//release the loaded DisplayObject
				(loader as Loader).unload();
				if (!err) {
					return ExternalDataAsset.STATUS_READY;
				} else return ExternalDataAsset.STATUS_SECURITY_ERROR;
		}
		
		override protected function cleanUp():void
		{
			if (tempBitmapdata) tempBitmapdata.dispose();
			tempBitmapdata = null;
		}
	}
}
	
