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
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IDegrafaObject;
	import flash.events.EventDispatcher
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import com.degrafa.utilities.external.LoadingLocation;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	


	
	/**
	* The ExternalDataAsset class defines the properties for an external data source used at runtime by Degrafa. 
	* You can use an ExternalDataAsset object in actionscript - it may be useful to 
	* set up preloading, for example, but in mxml use of an ExternalDataAsset is already encapsulated into 
	* the Degrafa class that uses the content (when it is ready) by virtue of its source property assignment.
	* The data content provided by an ExternalDataAsset will only be available once the asset from the external url has 
	* loaded.
	*/
	public class ExternalDataAsset extends DegrafaObject implements IDegrafaObject{
		protected var _url:String; 
		//type as identified by mime type
		private var _mimeType:String ;
		//status before and during loading
		private var _status:String ;
		//either a URLLoader or a Loader intance
		private var _loader:Object;
		//external bytesize, if known before loading (provided for actionscript use/preloading support only). 
		private var _externalSize:Boolean = false;
		private var _bytesTotalExternal:Number=NaN; //assigned a value at instantiation if available. Possible use via actionscript for preloading activity.
		
		protected var dataType:Class;
		protected var _data:Object;
		//optional LoadingLocation for external security file/policy file requests
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
		public static const STATUS_DATA_ERROR:String = 		'itemDataError';
		
		//static type constants for identified mime type of loaded content
		public static const TYPE_UNKNOWN:String = 		'unknown';
		public static const TYPE_SWF:String = 			'application/x-shockwave-flash';
		public static const TYPE_IMAGE_JPEG:String = 	'image/jpeg';
		public static const TYPE_IMAGE_PNG:String = 	'image/png';
		public static const TYPE_IMAGE_GIF:String = 	'image/gif';
		
		//for loading from external domains using a Loader,always assume bitmapData is wanted see note in load method
		public static var requestBitmapDataAccess:LoaderContext = new LoaderContext(true);

		//store a dictionary of references to instances by class, based on urls. This is ignored by the constructor
		//and is only for use by the static getUniqueInstance class function, to faciliatate url assignments to source properties for Degrafa mxml
		private static var _uniqueInstances:Dictionary=new Dictionary(true);
		
		/**
		 * static method to prevent multiple instances referring to the same external asset
		 * this avoids creation of multiple instances of the same loaded data (multiple instances remain possible if required, by simply by using the constructor)
		 * @param	url the url to the external asset (must be relative if a LoadingLocation is used)
		 * @param	loc an optional LoadingLocation
		 */
		protected static function getUniqueInstance(url:String = null, loc:LoadingLocation = null,clazz:Class=null):ExternalDataAsset
		{

			if (!_uniqueInstances[clazz]) _uniqueInstances[clazz] = new Dictionary();
			if (url && _uniqueInstances[clazz][url] && _uniqueInstances[clazz][url].loadingLocation === loc)
			{
			//	trace('found existing instance:'+url)
				return _uniqueInstances[clazz][url]
			} else {
			//		trace('creating new instance:'+url)
				_uniqueInstances[clazz][url] = new clazz(url);
				 if (loc) _uniqueInstances[clazz][url].loadingLocation = loc;
				 return _uniqueInstances[clazz][url];
			}

		}
		
		
		/**
		 * Constructor
		 * 
		 * <p>The ExternalDataAsset constructor has one optional argument for url(s) and a second optional argument
		 * to specifiy filesize for an external bitmap (useful when considered as part of a collection to preload if the data is available). 
		 * The url argument can be either a string for a single url or an array of url strings for backup.</p>
		 * 
		 * @param	url			a single url as a string. If a loadingGroup association is made in the loadingGroup property the url should be relative to the LoadingGroup basePath : use a LoadingGroup for fallback urls to provide redundancy under error conditions
		 * @param	totalBytes	an [optional] specification for the total bytes to be loaded for this item, only available through the constructor (actionscript use)
		 */
		public function ExternalDataAsset(url:String = null, totalBytes:Number = NaN,loader:Class=null) {
			if (url != null)
			{
				_url = url;
			}
			//if (!_loader) _loader = Loader;
			_loader  = new loader();
			_mimeType = ExternalDataAsset.TYPE_UNKNOWN;
			_status = ExternalDataAsset.STATUS_WAITING;
			if (!isNaN(totalBytes)) {
				_bytesTotalExternal = Math.floor(totalBytes);
				_externalSize = true;
			}
		}
		

		/**
		 * load this item, using LoadingGroup settings if this ExternalDataAsset is associated with a LoadingGroup instance
		 */
		public function load():void {
			if (_url.length){
			addListeners();

			var loadFrom:String;
			if (_loadingLocation)
			{
				if (!_loadingLocation.requestedPolicyFile) _loadingLocation.requestPolicyFile();
				loadFrom = _loadingLocation.basePath + _url;
			} else {
				loadFrom = _url;
			}
				
			//for loading from external domains, set default loading behaviour to check policy file permissions and attempt loading of default policyfile location/name if not yet granted.
			if (_loader is Loader) (_loader as Loader).load(new URLRequest(loadFrom),requestBitmapDataAccess );
		    else
		    {
				(_loader as URLLoader).load(new URLRequest(loadFrom));
			//	trace('requested')
			}
			_status = ExternalDataAsset.STATUS_REQUESTED;
			dispatchEvent(new Event(ExternalDataAsset.STATUS_REQUESTED));
			} 
		}
		
		/**
		 * add internal listeners for loading support
		 */
		private function addListeners():void
		{
			var target:Object
			if (_loader is URLLoader)
			{
				target = _loader as URLLoader;
			} else if (_loader is Loader)
			{
				target = (_loader as Loader).contentLoaderInfo;
			}
			if (!target.hasEventListener(Event.OPEN)) {
			with (target) {
				
					addEventListener(Event.OPEN, onLoadStart);	
					addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					addEventListener(Event.COMPLETE, onLoadComplete);
					addEventListener(Event.INIT, onLoadInit);
					addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					
				}
			 if (target is URLLoader) (target as URLLoader).addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
		
		/**
		 * remove internal listeners for loading support
		 */
		private function removeListeners():void {
			var target:Object
			if (_loader is URLLoader)
			{
				target = _loader as URLLoader;
			} else if (_loader is Loader)
			{
				target = (_loader as Loader).contentLoaderInfo;
			}
			if (hasEventListener(Event.OPEN)) {
			with (target) {
					removeEventListener(Event.OPEN, onLoadStart);	
					removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					removeEventListener(Event.COMPLETE, onLoadComplete);
					removeEventListener(Event.INIT, onLoadInit);
					removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				}
				if (target is URLLoader) (target as URLLoader).removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
		
		/**
		 * Check mime type of loaded content. Incorporated in loading event processing, but not yet used. May be used to restrict loading to data assets only
		 * to prevent swf loading. E.g. The ExternalBitmapData subclass is intended for bitmap loading only.
		 */
		private function checkContentType():void {
			if (_loader is URLLoader) return;
			if (_mimeType == ExternalDataAsset.TYPE_UNKNOWN && _loader.contentLoaderInfo.contentType != null) {
				_mimeType = _loader.contentLoaderInfo.contentType;
				//this contentType property did not seem to be available until after the last progress event in testing
				dispatchEvent(new Event(ExternalDataAsset.STATUS_IDENTIFIED));
			}
			
		}
		
		/**
		 * event handler for explicit SecurityError from a URLLoader based load
		 * @param	evt event received from eventDispatcher
		 */
		private function onSecurityError(evt:Event):void {
			_status = ExternalDataAsset.STATUS_SECURITY_ERROR;
			removeListeners();
			dispatchEvent(new Event(ExternalDataAsset.STATUS_SECURITY_ERROR));
			//this ExternalDataAsset does nothing now...as it cannot.
		}
		
		
		/**
		 * event handler for start of loading 
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadStart(evt:Event):void {
			_status = ExternalDataAsset.STATUS_STARTED;
			checkContentType();
			dispatchEvent(new Event(ExternalDataAsset.STATUS_STARTED));
		}
		
		//overridden in subclasses, processes the loaded content,
		//returns the status as one of the ExternalDataAsset.STATUS constants.
		protected function processLoad(_loader:Object):String
		{
			return ExternalDataAsset.STATUS_READY;
		}
		//overridden in subclasses
		protected function cleanUp():void
		{
			
		}
		/**
		 * event handler for completion of loading
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadComplete(evt:Event):void {
			checkContentType();

			//let the sub-class process the loader's content and return the status
			_status = processLoad(_loader);
			
			switch (_status)
			{
				case ExternalDataAsset.STATUS_READY:
					dispatchEvent(new Event(ExternalDataAsset.STATUS_READY));
					cleanUp();
					removeListeners();
				break;
				case ExternalDataAsset.STATUS_SECURITY_ERROR:
				//the data is inaccessible after load (e.g. bitmapdata loaded with a Loader)
					removeListeners();
					dispatchEvent(new Event(ExternalDataAsset.STATUS_SECURITY_ERROR));
				break;
			}
		}
		
		/**
		 * event handler for progress of loading
		 * @param	evt ProgressEvent event received from eventDispatcher
		 */
		private function onLoadProgress(evt:ProgressEvent):void {
			checkContentType();
			_status = ExternalDataAsset.STATUS_PROGRESS;
			dispatchEvent(new ProgressEvent(ExternalDataAsset.STATUS_PROGRESS, false, false, evt.bytesLoaded, evt.bytesTotal));
		}
		
		/**
		 * event handler for initialization of loaded content
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadInit(evt:Event):void {
			checkContentType();
			_status = ExternalDataAsset.STATUS_INITIALIZING;
			checkContentType();
			dispatchEvent(new Event(ExternalDataAsset.STATUS_INITIALIZING));
		}
		
		/**
		 * event handler for error in loading
		 * @param	evt IOErrorEvent event received from eventDispatcher
		 */
		private function onLoadError(evt:IOErrorEvent):void {
		//	trace('LOAD ERROR:error '+evt)
			_status = ExternalDataAsset.STATUS_LOAD_ERROR;
			dispatchEvent(new Event(ExternalDataAsset.STATUS_LOAD_ERROR));
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
			if (_status == ExternalDataAsset.STATUS_READY) return (_data as dataType);
			else {
				//initiate load if it has not already commenced and return false (could also be null if preferred).
				if (_status == ExternalDataAsset.STATUS_WAITING) load();
				return false;
			}
		}
		
		/**
		 * the current bytes loaded for this ExternalDataAsset
		 */
		public function get bytesLoaded():Number {
			if (!(_status == ExternalDataAsset.STATUS_WAITING || _status == ExternalDataAsset.STATUS_REQUESTED))  return _loader.contentLoaderInfo.bytesLoaded;
			else return 0; //this is always accurate!
		}
		
		/**
		 * the bytesTotal for this ExternalDataAsset if known (i.e. verified during an actual load, or the value provided if pre-assigned through the constructor when instantiated)
		 * the value returned is NaN for unassigned, unverified (from actual file data) values
		 */
		public function get bytesTotal():Number {
			if (!(_status == ExternalDataAsset.STATUS_WAITING || _status == ExternalDataAsset.STATUS_REQUESTED)) return _loader.contentLoaderInfo.bytesTotal;
			else return _bytesTotalExternal; //returns NaN if unassigned a value from the constructor at this point
		}
		
		/**
		 * resets the status to waiting prior to load, stopping any current load in progress.
		 * @return Boolean value of true if status was anything other than waiting when called, otherwise false
		 */
		protected function reset():Boolean {
			if (!(_status == ExternalDataAsset.STATUS_WAITING || _status == ExternalDataAsset.STATUS_READY)) {
				//cancel any load in progress:
				removeListeners();
				_loader.close();
			}
			var reload:Boolean = (_status!=ExternalDataAsset.STATUS_WAITING)
			_status = ExternalDataAsset.STATUS_WAITING;
			_bytesTotalExternal = NaN;
			_mimeType = ExternalDataAsset.TYPE_UNKNOWN;
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
		 *if a loadingLocation is specified the url property in the ExternalDataAsset must be relative to the basepath specified in the LoadingLocation
		 *if an ExternalDataAsset's domain has a non-default policy file, a LoadingLocation must be used to specify the explicit location and
		 *name of the cross-domain file that grants access. An ExternalDataAsset without a LoadingLocation will only check for permission 
		 *in the default location and name (web document root, crossdomain.xml) for permission to access the remote file's BitmapData.
		*/
		public function get loadingLocation():LoadingLocation { return _loadingLocation; }
		
		public function set loadingLocation(value:LoadingLocation):void 
		{
			if (value) 	_loadingLocation = value;
		} 
		
	}
}
	
