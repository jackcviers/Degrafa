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
	import com.degrafa.utilities.IGraphicsExternalBitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import com.degrafa.core.DegrafaObject;
	

	
	/**
	* The ExternalBitmap class defines the properties for an external BitmapData source as either 
	* a jpg, png or gif image file. You can define an ExternalBitmap object in MXML, but you must attach 
	* that ExternalBitmap to a BitmapFill for it to appear in your application. It will only appear once 
	* it has loaded, which (currently) will be at some point in time after your BitmapFill has been requested
	* to render.
	*/
	
	/*
	TODO: 
	-implement back up loading in error handler: # retries and/or alternate urls if provided
	-remove additional events that are unnecessary/unused by degrafa.
	-remove traces/tidy up
	
	ideas: may need to permit specifying a custom x-domain file location for pre-loading for alternate urls
	
	questions: 
	-should any url be relative to a domain/basepath specified in the collection/manager class?
	(i.e. the url in here is relative to that domain/basepath only?)
	That way alternate loading locations for assets could just be specified in terms of domain/basepath 'locations'
	as properties at the collection level (and crossdomain permissions could be handled via the collection for other domains).
	It would be a constraint for usage to do it that way. But it would enhance the maintainability of an application.
	Different 'locations' as domains could be specified in the collection and assets could be associated with a specific 'location'. 
	Each of those could have their own crossdomain file location (if its not the default location/name) and 
	related error handling strategy (retry vs. alternate domain etc)
	*/
	public class ExternalBitmap extends DegrafaObject implements IGraphicsExternalBitmap {
		private var _url:Array=[]; //as an array to allow the possibility of alternate backup urls for use under error conditions
		private var _priority:uint = 0; //lowest priority, for pre-loading queue use, not yet implemented
		private var _type:String ;
		private var _status:String ;
		private var _loader:Loader;
		private var _externalSize:Boolean = false;
		private var _bitmapData:BitmapData;
		private var _bytesTotalExternal:Number=NaN; //assigned a value at instantiation if available.
		
		//static status constants/events
		public static const STATUS_WAITING:String = 	'itemWaiting';
		public static const STATUS_REQUESTED:String = 	'itemRequested';
		public static const STATUS_STARTED:String = 	'itemLoadStarted';
		public static const STATUS_PROGRESS:String = 	'itemLoadProgress';
		public static const STATUS_INITIALIZING:String ='itemInitializing';
		public static const STATUS_READY:String = 		'itemReady';
		public static const STATUS_IDENTIFIED:String =	'itemIdentified';
		public static const STATUS_ERROR:String = 		'itemLoadError';
		//static type constants for identified mime type of loaded content
		public static const TYPE_UNKNOWN:String = 		'unknown';
		public static const TYPE_SWF:String = 			'application/x-shockwave-flash';
		public static const TYPE_IMAGE_JPEG:String = 	'image/jpeg';
		public static const TYPE_IMAGE_PNG:String = 	'image/png';
		public static const TYPE_IMAGE_GIF:String = 	'image/gif';
		//static priority constants
		public static const PRIORITY_MINIMUM:uint = 0;
		public static const PRIORITY_MEDIUM:uint = 4;
		public static const PRIORITY_MAXIMUM:uint = 9;

		/**
		 * Constructor
		 * 
		 * <p>The ExternalBitmap constructor has one optional argument for url(s) and a second optional argument
		 * to specifiy filesize for an external bitmap (useful when considered as part of a collection to preload if the data is available). 
		 * The url argument can be either a string for a single url or an array of url strings for backup.</p>
		 * 
		 * @param	url			a single url as a string or an array of fallback urls to provide redundancy under error conditions
		 * @param	totalBytes	an [optional] specification for the total bytes to be loaded for this item. 
		 */
		function ExternalBitmap(url:Object=null,totalBytes:Number=NaN) {
			if (url){
			if (url is String) url = [url];
			if (!url is Array) throw new ArgumentError('malformed url argument in ExternalBitmap constructor, must be a url string or an array of url strings');

			_url = url as Array;
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
		 * load this item
		 */
		public function load():void {
		//	trace('load requested');
			if (_url.length){
			with (_loader.contentLoaderInfo) {
				trace('listeners added');
				if (!hasEventListener(Event.OPEN)) {
					addEventListener(Event.OPEN, onLoadStart);	
					addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					addEventListener(Event.COMPLETE, onLoadComplete);
					addEventListener(Event.INIT, onLoadInit);
					addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				}
			}
			//TODO: implement fallbackback loading in error handler: retries and/or alternate urls if provided
			
			_loader.load(new URLRequest(_url[0]));
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
		 * Check mime type of loaded content. Incorporated in loading, but not yet used. May be used to restrict loading to image assets only
		 * to prevent swf loading. This class is intended for bitmap loading only.
		 */
		private function checkContentType():void {
			if (_type == ExternalBitmap.TYPE_UNKNOWN && _loader.contentLoaderInfo.contentType != null) {
				_type = _loader.contentLoaderInfo.contentType;
				trace(ExternalBitmap.STATUS_IDENTIFIED + ":" + _type);
				//this contentType property did not seem to be available until after the last progress event in testing
				dispatchEvent(new Event(ExternalBitmap.STATUS_IDENTIFIED));
			}
		}
		
		/**
		 * event handler for start of loading 
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadStart(evt:Event):void {
			trace(ExternalBitmap.STATUS_STARTED)
			_status = ExternalBitmap.STATUS_STARTED;
			checkContentType()
			dispatchEvent(new Event(ExternalBitmap.STATUS_STARTED));
		}
		
		/**
		 * event handler for completion of loading
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadComplete(evt:Event):void {
			trace(ExternalBitmap.STATUS_READY)

			checkContentType()
			_status = ExternalBitmap.STATUS_READY;
			var tempBitmapdata:BitmapData = _bitmapData;
			_bitmapData = new BitmapData(_loader.content.width, _loader.content.height, true, 0x00000000);
			_bitmapData.draw(_loader.content);
			//release the displayobject
			_loader.unload();
			//release the old bitmapdata (if it existed)
			if (tempBitmapdata) tempBitmapdata.dispose(); 
			dispatchEvent(new Event(ExternalBitmap.STATUS_READY));
			removeListeners();
		}
		
		/**
		 * event handler for progress of loading
		 * @param	evt ProgressEvent event received from eventDispatcher
		 */
		private function onLoadProgress(evt:ProgressEvent):void {
			trace(ExternalBitmap.STATUS_PROGRESS); 
			checkContentType()
			_status = ExternalBitmap.STATUS_PROGRESS;
			dispatchEvent(new ProgressEvent(ExternalBitmap.STATUS_PROGRESS, false, false, evt.bytesLoaded, evt.bytesTotal));
		}
		
		/**
		 * event handler for initialization of loaded content
		 * @param	evt event received from eventDispatcher
		 */
		private function onLoadInit(evt:Event):void {
			checkContentType()
			trace(ExternalBitmap.STATUS_INITIALIZING)
			_status = ExternalBitmap.STATUS_INITIALIZING;
			checkContentType();
			dispatchEvent(new Event(ExternalBitmap.STATUS_INITIALIZING));
		}
		
		/**
		 * event handler for error in loading
		 * @param	evt IOErrorEvent event received from eventDispatcher
		 */
		private function onLoadError(evt:IOErrorEvent):void {
			//TODO: implement back up loading in error handler: retries and/or alternate urls
			trace('error '+evt)

			_status = ExternalBitmap.STATUS_ERROR;
			dispatchEvent(new IOErrorEvent(ExternalBitmap.STATUS_ERROR,evt.bubbles,evt.cancelable,evt.text));
			removeListeners();
			//handle the error or from the collection via the above event
		}
		
		/**
		 * The loaded content (a BitmapData instance) if it is available
		 * or false (Boolean) if not available.
		 */
		public function get content():Object {
			trace('content requested');
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
		 * Not used yet. Intended for use at a collection level to manage a loading queue.
		 * Current implementation is load on demand. A loading queue could preload based on priority,
		 * perhaps even leaving low priority items to load only on demand.
		 */
		public function get priority():uint { return _priority; }
		
		public function set priority(value:uint):void {
			value = Math.max(value, ExternalBitmap.PRIORITY_MINIMUM);
			value = Math.min(value, ExternalBitmap.PRIORITY_MAXIMUM);
			_priority = value;
		}
		
		/**
		 * resets the status to waiting prior to load, stopping any current load in progress.
		 * @return Boolean value of true if status was anything other than waiting when called, otherwise false
		 */
		private function reset():Boolean {
			if (!(_status == ExternalBitmap.STATUS_WAITING || _status == ExternalBitmap.STATUS_READY)) {
				//cancel load in progress:
				removeListeners();
				_loader.close();
			}
			var reload:Boolean = (_status!=ExternalBitmap.STATUS_WAITING)
			_status = ExternalBitmap.STATUS_WAITING;
			_bytesTotalExternal = NaN;
			_type = ExternalBitmap.TYPE_UNKNOWN
			return reload;
		}
		
		/**
		 * the url(s) of the external asset
		 * assignable as either a string (one url) or an array of urls for backup loading locations
		 * always accessible as an array of urls.
		 * currently same-domain only loading implemented. 
		 * TODO: implement alternate domain loading (but is here the right place? see notes at top of class file)
		 */
		public function get url():Array { return _url; }
		
		public function set url(value:*):void {
			if (value is String) value = [value];
			if (value is Array) {
				var update:Boolean = true;
				var len:uint = (value as Array).length;
				if (len == _url.length) {
					update = false;
					for (var i:uint = 0; i < len; i++) {
						if ((value as Array)[i] != _url[i]) {
							update = true;
							break;
						}
					}
				}
				if (update) {
					_url = value;
					//reset and reload automatically if this instance has already been requested and the url has been changed
					if (reset()) load();
				}
			} // else ignore the assigned value.
		}
	}
	
}