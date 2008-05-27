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
package com.degrafa.utilities{
	import flash.events.EventDispatcher
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import com.degrafa.utilities.LoadingLocation;
	import flash.net.registerClassAlias;


	
	/**
	* The ExternalBitmap class defines the properties for an external BitmapData source as either 
	* a jpg, png or gif image file. You can use an ExternalBitmap object in actionscript - it may be useful to 
	* set up preloading, for example, but in mxml use of an ExternalBitmap is already encapsulated into 
	* the BitmapFill class and is by virtue of whether the source assignment to a BitmapFill is determined to be 
	* a url.
	* The bitmapData provided by an ExternalBitmap will only be available once the asset from the external url has 
	* loaded and its bitmap data has been extracted. This may mean that if it has not already loaded when needed,
	* the BitmapFill will redraw and it will appear at some point in time after other sibling geometry has already rendered.
	*/
	public class ExternalBitmap extends EventDispatcher {
		private var _url:String; 
		private var _type:String ;
		private var _status:String ;
		private var _loader:Loader;
		private var _externalSize:Boolean = false;
		private var _bitmapData:BitmapData;
		private var _bytesTotalExternal:Number=NaN; //assigned a value at instantiation if available. Possible use via actionscript for preloading activity.
		private var _loadingLocation:LoadingLocation;
		
		//static status constants/events
		public static const STATUS_WAITING:String = 		'itemWaiting';
		public static const STATUS_REQUESTED:String = 		'itemRequested';
		public static const STATUS_STARTED:String = 		'itemLoadStarted';
		public static const STATUS_PROGRESS:String = 		'itemLoadProgress';
		public static const STATUS_INITIALIZING:String =	'itemInitializing';
		public static const STATUS_READY:String = 			'itemReady';
		public static const STATUS_IDENTIFIED:String =		'itemIdentified';
		public static const STATUS_LOAD_ERROR:String = 		'itemLoadError';
		public static const STATUS_SECURITY_ERROR:String = 	'itemSecurityError';
		
		//static type constants for identified mime type of loaded content
		public static const TYPE_UNKNOWN:String = 		'unknown';
		public static const TYPE_SWF:String = 			'application/x-shockwave-flash';
		public static const TYPE_IMAGE_JPEG:String = 	'image/jpeg';
		public static const TYPE_IMAGE_PNG:String = 	'image/png';
		public static const TYPE_IMAGE_GIF:String = 	'image/gif';
		
		//for loading from external domains, see note in load method
		public static var canAccessBitmapData:LoaderContext = new LoaderContext(true);

		
		private static var _uniqueHash:Object=new Object();
		
		/**
		 * static method to prevent multiple instances referring to the same external asset
		 * this avoids creation of multiple instances of the same loaded BitmapData
		 * @param	url the url to the external asset (must be relative if a LoadingLocation is used)
		 * @param	loc an optional LoadingLocation
		 */
		public static function getUniqueInstance(url:String = null, loc:LoadingLocation = null):ExternalBitmap
		{
			if (url && ExternalBitmap._uniqueHash[url] && ExternalBitmap._uniqueHash[url].loadingLocation === loc)
			{
			//	trace('found existing instance:'+url)
				return ExternalBitmap._uniqueHash[url]
			} else {
			//		trace('creating new instance:'+url)
				 ExternalBitmap._uniqueHash[url] = new ExternalBitmap(url);
				 if (loc) ExternalBitmap._uniqueHash[url].loadingLocation = loc;
				 return ExternalBitmap._uniqueHash[url];
			}
		}
		
		
		/**
		 * Constructor
		 * 
		 * <p>The ExternalBitmap constructor has one optional argument for url(s) and a second optional argument
		 * to specifiy filesize for an external bitmap (useful when considered as part of a collection to preload if the data is available). 
		 * The url argument can be either a string for a single url or an array of url strings for backup.</p>
		 * 
		 * @param	url			a single url as a string. If a loadingGroup association is made in the loadingGroup property the url should be relative to the LoadingGroup basePath : use a LoadingGroup for fallback urls to provide redundancy under error conditions
		 * @param	totalBytes	an [optional] specification for the total bytes to be loaded for this item, only available through the constructor (actionscript use)
		 */
		public function ExternalBitmap(url:String = null, totalBytes:Number = NaN) {
			if (url != null)
			{
				_url = url;
			}
			_loader = new Loader();
			_type = ExternalBitmap.TYPE_UNKNOWN;
			_status = ExternalBitmap.STATUS_WAITING;
			if (!isNaN(totalBytes)) {
				_bytesTotalExternal = Math.floor(totalBytes);
				_externalSize = true;
			}
			
		}
		
				
		/**
		 * load this item, using LoadingGroup settings if this ExternalBitmap is associated with a LoadingGroup instance
		 */
		public function load():void {
			if (_url.length){
			with (_loader.contentLoaderInfo) {
				if (!hasEventListener(Event.OPEN)) {
					addEventListener(Event.OPEN, onLoadStart);	
					addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					addEventListener(Event.COMPLETE, onLoadComplete);
					addEventListener(Event.INIT, onLoadInit);
					addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				}
			}

			var loadFrom:String;
			if (_loadingLocation)
			{
				if (!_loadingLocation.requestedPolicyFile) _loadingLocation.requestPolicyFile();
				
				loadFrom = _loadingLocation.basePath + _url;

			} else {
				loadFrom = _url;
			
			}
				
			//for loading from external domains, set default loading behaviour to check policy file permissions and attempt loading of default policyfile location/name if not yet granted.
			_loader.load(new URLRequest(loadFrom),ExternalBitmap.canAccessBitmapData );
			_status = ExternalBitmap.STATUS_REQUESTED;
			dispatchEvent(new Event(ExternalBitmap.STATUS_REQUESTED));
			} 
		}
		
		/**
		 * remove internal listeners for loading support
		 */
		private function removeListeners():void {
			with (_loader.contentLoaderInfo) {
				removeEventListener(Event.OPEN, onLoadStart);	
				removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				removeEventListener(Event.COMPLETE, onLoadComplete);
				removeEventListener(Event.INIT, onLoadInit);
				removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		/**
		 * Check mime type of loaded content. Incorporated in loading event processing, but not yet used. May be used to restrict loading to image assets only
		 * to prevent swf loading. The ExternalBitmap class is intended for bitmap loading only.
		 */
		private function checkContentType():void {
			if (_type == ExternalBitmap.TYPE_UNKNOWN && _loader.contentLoaderInfo.contentType != null) {
				_type = _loader.contentLoaderInfo.contentType;
				//this contentType property did not seem to be available until after the last progress event in testing
				dispatchEvent(new Event(ExternalBitmap.STATUS_IDENTIFIED));
			}
		}
		
		/**
		 * event handler for start of loading 
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadStart(evt:Event):void {
			_status = ExternalBitmap.STATUS_STARTED;
			checkContentType();
			dispatchEvent(new Event(ExternalBitmap.STATUS_STARTED));
		}
		
		/**
		 * event handler for completion of loading
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadComplete(evt:Event):void {
			checkContentType();
		//	trace(ExternalBitmap.STATUS_READY + ":" + _url);
			var tempBitmapdata:BitmapData = _bitmapData;
			var err:Boolean = false;
			try {
				_bitmapData = new BitmapData(_loader.content.width, _loader.content.height, true, 0x00000000);
				_bitmapData.draw(_loader.content);
			} catch (e:Error)
			{
				//the image has loaded but a crossdomain permission was not granted
				//so the bitmapData cannot be accessed. 
				//Only recourse is to check for another location if we're using a LoadingGroup
				//consider dispatching a specific permission failure event here.
				err = true;
			}
				//release the loaded DisplayObject
				_loader.unload();

			if (!err) 
			{
				_status = ExternalBitmap.STATUS_READY;
				dispatchEvent(new Event(ExternalBitmap.STATUS_READY));
				//release the old bitmapdata (if it existed) to free up memory
				if (tempBitmapdata) tempBitmapdata.dispose(); 
				removeListeners();
			} else {
				//we cannot provide the bitmapdata for use in the BitmapFill
				//just dispatch a security error event, the BitmapFill will not be rendered
				_status = ExternalBitmap.STATUS_SECURITY_ERROR;
				removeListeners();
				dispatchEvent(new Event(ExternalBitmap.STATUS_SECURITY_ERROR));
			}
		}
		
		/**
		 * event handler for progress of loading
		 * @param	evt ProgressEvent event received from eventDispatcher
		 */
		private function onLoadProgress(evt:ProgressEvent):void {
			checkContentType();
			_status = ExternalBitmap.STATUS_PROGRESS;
			dispatchEvent(new ProgressEvent(ExternalBitmap.STATUS_PROGRESS, false, false, evt.bytesLoaded, evt.bytesTotal));
		}
		
		/**
		 * event handler for initialization of loaded content
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadInit(evt:Event):void {
			checkContentType();
			_status = ExternalBitmap.STATUS_INITIALIZING;
			checkContentType();
			dispatchEvent(new Event(ExternalBitmap.STATUS_INITIALIZING));
		}
		
		/**
		 * event handler for error in loading
		 * @param	evt IOErrorEvent event received from eventDispatcher
		 */
		private function onLoadError(evt:IOErrorEvent):void {
		//	trace('LOAD ERROR:error '+evt)
			_status = ExternalBitmap.STATUS_LOAD_ERROR;
			dispatchEvent(new Event(ExternalBitmap.STATUS_LOAD_ERROR));
			//we cannot provide the bitmapdata for use in the BitmapFill
			//just dispatch a STATUS_LOAD_ERROR event, the BitmapFill will not be rendered
			removeListeners();
			//Consider implementing an automatic retry on load error

		}
		
		/**
		 * The loaded content (a BitmapData instance) if it is available
		 * or false (Boolean) if not available (triggers a loading request if not already requested).
		 */
		public function get content():Object {
		//	trace(_status+',content requested for '+_url)
			if (_status == ExternalBitmap.STATUS_READY) return _bitmapData;
			else {
				//initiate load if it has not already commenced and return false (could also be null if preferred).
				if (_status == ExternalBitmap.STATUS_WAITING) load();
				return false;
			}
		}
		
		/**
		 * the current bytes loaded for this ExternalBitmap
		 */
		public function get bytesLoaded():Number {
			if (!(_status == ExternalBitmap.STATUS_WAITING || _status == ExternalBitmap.STATUS_REQUESTED))  return _loader.contentLoaderInfo.bytesLoaded;
			else return 0; //this is always accurate!
		}
		
		/**
		 * the bytesTotal for this ExternalBitmap if known (i.e. verified during an actual load, or the value provided if pre-assigned through the constructor when instantiated)
		 * the value returned is NaN for unassigned, unverified (from actual file data) values
		 */
		public function get bytesTotal():Number {
			if (!(_status == ExternalBitmap.STATUS_WAITING || _status == ExternalBitmap.STATUS_REQUESTED)) return _loader.contentLoaderInfo.bytesTotal;
			else return _bytesTotalExternal; //returns NaN if unassigned a value from the constructor at this point
		}
		
		/**
		 * resets the status to waiting prior to load, stopping any current load in progress.
		 * @return Boolean value of true if status was anything other than waiting when called, otherwise false
		 */
		private function reset():Boolean {
			if (!(_status == ExternalBitmap.STATUS_WAITING || _status == ExternalBitmap.STATUS_READY)) {
				//cancel any load in progress:
				removeListeners();
				_loader.close();
			}
			var reload:Boolean = (_status!=ExternalBitmap.STATUS_WAITING)
			_status = ExternalBitmap.STATUS_WAITING;
			_bytesTotalExternal = NaN;
			_type = ExternalBitmap.TYPE_UNKNOWN;
			return reload;
		}
		

		/**
		 * the url of the external asset
		 * assignable as either a string representing a url relative to an associated LoadingGroup basePath or as a regular url 
		 * For alternate domain loading or for redundancy support (multple locations) loading on error, use an associated LoadingGroup
		 * assigned via the loadingGroup property and make this url relative to the basePath defined in the LoadingGroup
		 */
		public function get url():String { return _url; }
		
		public function set url(value:String):void {
			if (_url != value) {
					_url = value;
					//reset and reload automatically if this instance has already been requested and the url has been changed
					if (reset()) load();
			}// else ignore the assigned value because it hasn't changed
		} 
		
		
		
		/**
		 *optional loadingLocation reference. Using a LoadingLocation simplifies management of groups of bitmap assets from other domains
		 *by permitting different locations (alternate domains used for loading) to be specified once in code
		 *if a loadingLocation is specified the url property must be relative to the basepath specified in the LoadingLocation
		 *if an ExternalBitmap's domain has a non-default policy file, a LoadingLocation must be used to specify the explicit location and
		 *name of the cross-domain file that grants access. An ExternalBitmap without a LoadingLocation will only check for permission 
		 *in the default location and name (web document root, crossdomain.xml) for permission to access the remote file's BitmapData.
		*/
		public function get loadingLocation():LoadingLocation { return _loadingLocation; }
		
		public function set loadingLocation(value:LoadingLocation):void 
		{
			if (value) 	_loadingLocation = value;
		} 
		
	}
}
	
