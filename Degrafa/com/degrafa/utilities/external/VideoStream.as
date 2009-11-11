////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 The Degrafa Team : http://www.Degrafa.com/team
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
////////////////////////////////////////////////////////////////////////////////
// Original author of this code: Greg Dove  	            http://greg-dove.com
// Contributed to Degrafa for beta 3.2, November 2009
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.utilities.external
{
	import com.degrafa.core.DegrafaObject;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	

	/**
	 * ...
	 * @author Greg Dove
	 * 
	 * TODO:
	 * A) Implement snap-to-keyframe seek targeting: use keyframe metadata where it is available for seek targeting the timestamp of closest keyframe.
	 * B) more streaming testing. 
	 *  - check specs: It appears that video content encoding is important. Poorly encoded content fails on streaming seek in both wowza and FMS. This happens in other players as well.
	 *  - testing has been done with wowza1.7.2 and FMS3.5. Need to test with Red 5, Weborb streaming servers (others?)
	 * C) Add automatic streaming connection attempts for rtmp connections through firewalls dropping down to http (similar to other players like FLVPlayback etc) until successful connection attempt where 
	 * rmtp connections fail on first attempt.
	 * D) Add Camera/Webcam support and support for live streams in/out.
	 * E) Add binding support for metaData, embedded cuepoints, images, text etc
	 */
	public class VideoStream extends DegrafaObject
	{
		//ExternalData static status constants/events
		public static const STATUS_WAITING:String='itemWaiting';
		public static const STATUS_REQUESTED:String='itemRequested';
		public static const STATUS_STARTED:String='itemLoadStarted';
		public static const STATUS_PROGRESS:String='itemLoadProgress';
		public static const STATUS_INITIALIZING:String='itemInitializing';
		public static const STATUS_READY:String='itemReady';
		public static const STATUS_IDENTIFIED:String='itemIdentified';
		public static const STATUS_LOAD_ERROR:String='itemLoadError';
		public static const STATUS_SECURITY_ERROR:String='itemSecurityError';
		public static const STATUS_DATA_ERROR:String='itemDataError';
		
		//Error statuses
		public static const ERROR_STATUS_NONE:String="errorNone";
		public static const ERROR_STATUS_DATA_ACCESS:String="errorDataAccess";
		public static const ERROR_STATUS_CONTENT_ACCESS:String="errorDataAccess";
		public static const ERROR_STATUS_CONNECTION_ACCESS:String="errorConnectionAccess";

		public static const ERROR_STATUS_UPDATE:String="errorUpdate";
		
		//Reference/Lookup Objects
		//DEV NOTE: some work in progress going on here. 
		protected static const _fileTypePrefixes:Object={type_mp3: "mp3", type_mp4: "mp4", type_m4v: "mp4", type_f4v: "mp4", type_3gpp: "mp4", type_mov: "mp4"};
		protected static const _streamingProtocols:Array=["rtmp", "rtmpt", "rtmps", "rtmpe", "rtmpte"];
		protected static var instances:Dictionary=new Dictionary(true);
		protected static var __connections:Object={};
		
		//VideoStream statuses
		protected static const STREAM_STATUS_NORMAL:int=0;
		protected static const STREAM_STATUS_LOOPING:int=1;
		protected static const STREAM_STATUS_REWINDING:int=2;

		
		//Audio status
		public static const AUDIO_STATUS_UPDATE:String="audioStatusUpdate"; //muted or unmuted changes
		
		//Buffer statuses
		public static const BUFFER_EMPTY:String="bufferEmpty";
		public static const BUFFER_FULL:String="bufferFull";
		public static const BUFFER_DIMINISHED:String="bufferDiminished";
		public static const BUFFER_BUFFERING:String="bufferBuffering";
		public static const BUFFER_FLUSHING:String="bufferFlushing";
		
		public static const BUFFER_STATUS_UPDATE:String="bufferStatusUpdate";
		public static const BUFFER_STATUS_CHANGE:String="bufferStatusChange";
		public static const BUFFER_TIME_CHANGED:String="bufferTimeChanged";
		
		//http loading statuses
		public static const LOAD_START:String="loadStart";
		public static const LOAD_PROGRESS:String="loadProgress";
		public static const LOAD_COMPLETE:String="loadComplete";
		public static const LOAD_UDPATE:String="loadUpdate";
		
		//Seek intent statuses		
		public static const SEEK_NONE:String="seekNone";
		public static const SEEK_SEEKING:String="seekSeeking";
		//Seek result statuses	
		public static const SEEK_STATUS_END:String="seekStatusEnd";
		
		//Play activity intent statuses			
		public static const PLAY_STOPPED:String="playStopped"; //stopped at start of stream
		public static const PLAY_PAUSED:String="playPaused"; //paused somewhere in stream
		public static const PLAY_PLAYING:String="playPlaying"; //playing intent or actual
		//Play activity statuses/events
		public static const PLAY_STATUS_RESET:String="playStatusReset";
		public static const PLAY_STATUS_WAITING:String="playStatusWaiting";
		public static const PLAY_STATUS_COMPLETE:String="playStatusComplete"; //end of stream
		public static const PLAY_STATUS_UPDATE:String="playStatusUpdate"; //update pulse during play
		public static const PLAY_STATUS_CHANGED:String="playStatusChanged"; //change event for playStatus
		public static const PLAY_STATUS_FPS_UPDATE:String="playStatusFPSupdate"; //change in frames per second
		
		//Connection statuses
		public static const CONNECT_FAILED:String="NetConnection.Connect.Failed";
		public static const CONNECT_SUCCESS:String="NetConnection.Connect.Success";
		public static const CONNECT_REJECTED:String="NetConnection.Connect.Rejected";
		public static const CONNECT_APPSHUTDOWN:String="NetConnection.Connect.AppShutDown";
		public static const CONNECT_CLOSED:String="NetConnection.Connect.Closed";
		
		
	   //letterbox detection
		public static const LETTERBOX_UPDATE:String="letterBoxUpdate";
		
		//content related constants
		
		public static const HIGH:String="high";
		public static const MEDIUM:String="medium";
		public static const LOW:String="low";
		public static const NON_STREAMING:String="non-streaming";
		public static const STREAMING:String="streaming";
		public static const NONE:String="none";

		
		//fundamental video support
		protected var _ns:NetStream;
		protected var _nc:NetConnection;
		protected var _st:SoundTransform;
		protected var _vid:Video=new Video(1920, 1080);
		
		//bitmapData related
		protected var _pixelMargin:uint=1;
		protected var _bitmapData:BitmapData;
		protected var _latestImage:BitmapData;
		private static var _testBitmapData:BitmapData=new BitmapData(1,1,false,0);
		
		//video source related
		//local working url
		protected var _workingUrl:String;
		//original setter value
		protected var _setUrl:String;
		//other
		protected var _metaData:Object;
		protected var _textData:String;
		protected var _protocol:String;
		protected var _port:String;
		protected var _basePath:String;
		protected var _relativeURL:Boolean;
		protected var _loadingLocation:LoadingLocation;
		protected var _implicitLocation:LoadingLocation;
		
		//video characteristics
		protected var _width:uint;
		protected var _height:uint;
		protected var _position:Number=0;
		protected var _bufferTime:Number=2;
		protected var _bufferLength:Number=0;
		protected var _duration:Number;
		protected var _audioDelay:Number=0;
		protected var _currentFPS:Number=0;
		
		//http loading
		protected var _bytesTotal:Number; //stored as Number type to handle extremely large files
		protected var _bytesLoaded:Number; //stored as Number type to handle extremely large files
		protected var _httpCached:Boolean; //have we determined that this is a cached video?
		

		
		//initial buffer state
		protected var _bufferStatus:String=BUFFER_EMPTY; //buffer status: either empty, buffering, full or flushing
		
		//initial seek and play intents
		protected var _seekStatus:String=SEEK_NONE; // seek intent: either seeking, end of seeking, or none
		protected var _playStatus:String=PLAY_STOPPED; // play intent: either playing, paused or stopped (at start of stream)
		
		//quick check flags - actual stream state
		protected var _rtmp:Boolean; //is this an rtmp stream (or http)
		protected var _isPlaying:Boolean; //is the stream currently in a playing state
		protected var _isPaused:Boolean=true; //is the stream paused;
		protected var _isSeeking:Boolean; //is the stream currently in a seeking state
		//general flags - stream state
		protected var _isConnected:Boolean; //netconnection status is good
		protected var _isReady:Boolean; //has the stream started (once)
		protected var _wasBitmapAccessible:Boolean; //stream level flag for whether this rtmp stream has had a valid bitmapdata access history
		protected var _wasStreamingSeek:Boolean; //flag to check if the last seek was in a rtmp stream
		protected var _requiresMetaData:Boolean;// rtmp stream permissions appear to arrive after a seek via metadata.
		protected var _rtmpSeekCycle:Boolean;//flag for seeking during stream
		
		protected var _bitmapAccessible:Boolean; //the bitmapData is currently accessible
		protected var _bitmapAccessTested:Boolean; //the test for rtmp access to bitmapData has been performed.
		protected var _rtmpWait:Boolean; //if an bitmap write fails after having been successful, keep waiting until metaData
		protected var _rtmpMonitor:Boolean; //for an rtmp stream, monitor access after Play.Stop
		protected var _updateSeekPos:Boolean; //misc flags
		protected var _reset:Boolean; //reset flag to capture initial frame for rtmp content paused at start;
		protected var _bufferTimeChange:Boolean; //misc flags
		protected var _waitOneFrame:Boolean; //misc flags
		
		protected var _seekQueue:Array=[]; //queue of seek requests within this stream		
		protected var _maxCurrentSeekablePosition:Number=0; //for http: maximum observed seekable keyframe if not full loaded or explicit metadata for fully loaded content
		
		
		//VideoStream characteristics
		protected var _forceUpdates:Boolean;  //misc flags
		protected var _playheadUpdateInterval:uint=250; //how often to dispatch playheadUpdates
		protected var _seekUpdateTimeFrame:uint=30; //combine all seek operations that occur within this many milliseconds timeframe into a single seek operation
		protected var _updateTimer:Timer=new Timer(_playheadUpdateInterval, 0); //timers related to the above settings
		protected var _seekTimer:Timer=new Timer(_seekUpdateTimeFrame,1);//timers related to the above settings
		protected var _seekTarget:Number; //last requested seek value during the seek update timeframe
		
		//audio
		protected var _volume:Number=0.5;
		
		//content related
		protected var _invalidated:Boolean;
		protected var _copyTargets:Dictionary;
		protected var _copyTargetCount:uint;
		protected static const copyPoint:Point=new Point();
		protected static const DISPOSAL_DEFERRAL:uint=35;
		
		/**
		 * @private
		 * TODO... not yet complete. Intended for use in String url assignments to the source property in a VideoFill as a shortcut approach to referencing content
		 * similar to BitmapFill
		 */
		public function getUniqueInstance(url:String, loc:LoadingLocation=null):VideoStream
		{
			//if the url is absolute, then ignore any loading location parameter (should this be an error instead?)
			if (LoadingLocation.isAbsoluteURL(url))
			{
				if (loc) trace('WARNING: had a request for ' + url + ' with a loading location specified. Ignoring the loading location because the url is an absolute url')
				var decoded:Object=LoadingLocation.extractLocation(url);
			}
			if (!loc)
			{
				loc=new LoadingLocation();
				if (LoadingLocation.isAbsoluteURL(url))
				{
					decoded=LoadingLocation.extractLocation(url);
				}
			}
			return new VideoStream();
		}
		
		/**
		 * Constructor
		 * VideoStream encapsulates the functionality required to support provision of video content in BitmapData format.
		 * It provides support for both http progressive video and rtmp streamed video, subject to access permissions to the underlying bitmapdata. 
		 * */	
		public function VideoStream()
		{
			_updateTimer.addEventListener(TimerEvent.TIMER, onUpdate,false,0,true);
			_seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSeekReady,false,0,true);
			_vid.smoothing=true;
		}
		
		/**
		 * @private
		 * onSeekReady is used to handle timer based consolidation of seek requests
		 * to prevent excessive seeking via binding to a thumb/track type control with liveDragging
		 * */
		protected function onSeekReady(e:TimerEvent):void{
			if(_ns){
				_seekQueue.push(_seekTarget);
				_seekTimer.reset();
				if (!_isSeeking) {
					performSeek(_seekTarget);
					_isSeeking=true;
					_seekTarget=NaN;
				} else _seekTimer.start();
			}
		}
		/**
		 * @private
		 * destroyStream
		 * */
		protected function destroyStream():void
		{
			ConnectionItem.decommissionNetStream(_ns);
			_ns.removeEventListener(NetStatusEvent.NET_STATUS, statusMonitor);
			_ns.removeEventListener(IOErrorEvent.IO_ERROR, ioErrhandler);
			_ns.close();
			_ns=null;
		}
		
		/**
		 * @private
		 * onBWDone callback
		 * */		
		protected function onBWDone(...args):void{
			//TODO
			trace('onBWDone');
			if (args.length && args[0]) {
				trace('received bandwidth data:'+args.length+" element(s):")
				trace(args.join(" :: "))
			}
		}
		
		/**
		 * @private
		 * onFCUnsubscribe callback
		 * */		
		protected function onFCUnsubscribe(info:Object):void{
			//TODO
			trace('onFCUnsubscribe');
		}
		
		/**
		 * @private
		 * onFCSubscribe callback
		 * */			
		protected function onFCSubscribe(info:Object):void{
			//TODO
			trace('onFCSubscribe');
		}
		
		/**
		 * @private
		 * connection status listener
		 * */
		protected function onConnectionStatus(e:NetStatusEvent):void
		{
	        var oldErr:String=_errorDetail;
			switch (e.info.code)
			{
				case CONNECT_SUCCESS:
					ConnectionItem(__connections[_nc.uri]).status=ConnectionItem.IN_USE;  //=new ConnectionItem(_nc);
					if (_ns)
					{
						_vid.attachNetStream(null);
						_ns.close();
					}
					_ns=new NetStream(_nc);
					_ns.bufferTime=_bufferTime;

					_ns.client= clientObj; //using client object to access private methods inside this VideoStream instance
					_ns.addEventListener(NetStatusEvent.NET_STATUS, statusMonitor, false, 0, true);
					_ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrhandler, false, 0, true);
					_ns.soundTransform=_st;
					_isConnected=true;
					

					updateErrorStatus(ERROR_STATUS_NONE,ERROR_STATUS_NONE,_errorStatus!=ERROR_STATUS_NONE);
					play();
					break;
				case CONNECT_FAILED:
					ConnectionItem(__connections[_nc.uri]).status=ConnectionItem.ERROR;
					updateErrorStatus(ERROR_STATUS_CONNECTION_ACCESS,"The attempt to connect to the server at\n" + loadingLocation.basePath + "\nhas failed");
					if (_debug)	showDebug(_errorDetail, 400, 400);
					_isConnected=false;
					break;
				case CONNECT_CLOSED:
					
					if (__connections[_nc.uri]){
						updateErrorStatus(ERROR_STATUS_CONNECTION_ACCESS,"The connection to the server at\n" + loadingLocation.basePath + "\nhas been closed");
						ConnectionItem(__connections[_nc.uri]).status=ConnectionItem.ERROR;
						if (_debug)	showDebug(_errorDetail, 400, 400);
					} 
					_isConnected=false;
					break;
				case CONNECT_APPSHUTDOWN:
					_errorDetail="The server at\n" + loadingLocation.basePath + "\nhas shut down the application on the server";
					_errorStatus=ERROR_STATUS_CONNECTION_ACCESS;
					ConnectionItem(__connections[_nc.uri]).status=ConnectionItem.ERROR;
					if (_debug ) showDebug(_errorDetail, 400, 400);
					_isConnected=false;
					break;
				case CONNECT_REJECTED:
					_errorDetail="The server at\n" + loadingLocation.basePath + "\nhas rejected the connection attempt";
					_errorStatus=ERROR_STATUS_CONNECTION_ACCESS;
					ConnectionItem(__connections[_nc.uri]).status=ConnectionItem.ERROR;
					if (_debug ) showDebug(_errorDetail, 400, 400);
					_isConnected=false;				
					break;
				default:
					trace('unhandled netconnection status')
					break;
			}
			if (oldErr!=_errorDetail) dispatchUpdateEvent(ERROR_STATUS_UPDATE);
		}
		
		
		/**
		 * @private
		 * set up a http progressive video connection
		 * */
		protected function prepHttpCon():void
		{
			//connect only once
			if (!_httpConnected)
			{
				//'null' connection
				_httpNC.connect(null);
				//static connection flag for http
				_httpConnected=true;
			}
			//this instance is connected:
			_isConnected=true;
			//use the single connection for all http netstreams
			_ns=new NetStream(_httpNC);

			//catchall in addition to any LoadingLocation:
			_ns.checkPolicyFile=true;
			_ns.bufferTime=_bufferTime;
			_httpCached=false; //cacheing needs to be rechecked
			_maxCurrentSeekablePosition=0; //tracking for http max seek positions
			
			_ns.client=clientObj;
			_ns.addEventListener(NetStatusEvent.NET_STATUS, statusMonitor, false, 0, true);
			_ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrhandler,false,0,true);
			_ns.bufferTime=_bufferTime;
			_ns.soundTransform=_st;
			
		}
		
		protected static var _httpNC:NetConnection=new NetConnection();
		protected static var _httpConnected:Boolean;
		//clientObj is required for netstream access to private methods inside this instance
		protected var clientObj:Object={onBWDone:onBWDone,onFCSubscribe:onFCSubscribe, onCuePoint: onCuePoint, onMetaData: onMetaData, onTextData: onTextData, onImageData: onImageData, onPlayStatus: onPlayStatus, onXMPData: onXMPData}; 	
		
		
		
		protected function resetInternalState():void{

			_wasBitmapAccessible=false;
			_bitmapAccessible=false;
			_bitmapAccessTested=false;
			//reset any letterbox detections
			_letterBoxContent=null;
			_letterBoxDetected=false;
			_letterBoxChecked=false;
			//mark the content as changed by zeroing the _width and _height
			_width=_height=0;
			_currentFPS=0;
			//clear the display if we have switched urls
			if (_bitmapData) _bitmapData.fillRect(_bitmapData.rect,0);
			if(_copyTargetCount) {
				var copyRect:Rectangle = _bitmapData.rect
				for  (var copyBitmapData:Object in _copyTargets){
					var copyData:BitmapData = BitmapData(copyBitmapData);
					//make a copy
					copyData.copyPixels(_bitmapData,copyRect,copyPoint);
					//transform it
					var ctrans:ColorTransform = _copyTargets[copyBitmapData] as ColorTransform;
					if (ctrans) {
						copyData.colorTransform(copyRect,ctrans);
					}
				}
			}
			if (_position){
				_position=0;
				dispatchStatusEvent(PLAY_STATUS_UPDATE);
			}
			
			if (_bytesLoaded||_bytesTotal ) {
				_bytesLoaded=0;
				_bytesTotal=0;
				dispatchUpdateEvent(LOAD_UDPATE)
			}
			_metaData=null;
			_bufferLength=0;
		}
		
		
		/**
		 * @private
		 * instantiate supporting classes for video connection and reset all flags and status variables
		 * */		
		protected function initVideoSupport(streamingApplicationURL:String=null):void
		{
			if (!_st) {
				_st=new SoundTransform();
			}
			_st.volume=_volume;
			resetInternalState();
			
			if (!streamingApplicationURL)
			{
				prepHttpCon();
			
			}
			else
			{
				if (_rtmp)
				{
					
						if (__connections[streamingApplicationURL])
						{
							var connItem:ConnectionItem = ConnectionItem(__connections[streamingApplicationURL]);
							if (connItem.status != ConnectionItem.CLOSED) {
								//re-use the existing connection
								_nc=ConnectionItem(__connections[streamingApplicationURL]).increment(onConnectionStatus,ioErrhandler);
								//call connect handler:
								var info:Object={code:CONNECT_SUCCESS}
								_nc.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,info))
							} else {
								//reconnect
								_nc=ConnectionItem(__connections[streamingApplicationURL]).increment(onConnectionStatus,ioErrhandler);
							}
					}
					else
					{
						_nc=new NetConnection();
						__connections[streamingApplicationURL]=new ConnectionItem(_nc,clientObj,onConnectionStatus,ioErrhandler,streamingApplicationURL,true);
						
					}
				}
				else
				{
					prepHttpCon();
				}
			}
			dispatchStatusEvent(STATUS_INITIALIZING);
		}
		

		
		/**
		 * @private
		 * */			
		private static var _testRect:Rectangle=new Rectangle(0,0,1,1);
		/**
		 * @private
		 * data access check
		 * */	
		private function hasAccess():Boolean{
			try {
				_testBitmapData.draw(_vid,null,null,null,_testRect);
				return true;
			} catch (e:Error){	}
			return false;
		}
		
		
		
		/**
		 * @private
		 * */			
		protected var _streamStatus:uint;
		
		/**
		 * @private
		 * stream status event listener/monitor
		 * */	
		protected function statusMonitor(e:NetStatusEvent):void
		{
			var info:Object=e.info;
			switch (info.level)
			{
				case "error":
				
					switch (info.code)
					{
						case "NetStream.Play.StreamNotFound":
							_errorStatus=ERROR_STATUS_CONTENT_ACCESS;
							_errorDetail="No video stream was found \n" + loadingLocation.basePath + "\n" + _workingUrl;
	
							if (_debug)
								showDebug(_errorDetail,400,400);
							
							break;
						case "NetStream.Play.FileStructureInvalid":
							_errorStatus=ERROR_STATUS_CONTENT_ACCESS;
							_errorDetail="The following video stream was invalid \n" + loadingLocation.basePath + "\n" + _workingUrl;
							
							if (_debug)
								showDebug(_errorDetail,400,400);
							
							break;
						case "NetStream.Play.Failed":
							_errorStatus=ERROR_STATUS_CONTENT_ACCESS;
							_errorDetail="The following video stream was unable to play \n" + loadingLocation.basePath + "\n" + _workingUrl + "\n" + info.description;
							
							if (_debug)
								showDebug(_errorDetail,400,400);

							
							break;
						case "NetStream.Seek.Failed":
							
							if (!_rtmp)
							{
								//seek to the maximum possible
								
								_isSeeking=false;
								_seekQueue.length=0;
								//let's assume that this is not a cached copy otherwise the seek should have worked
								_httpCached=false;
								//force an update for position listeners
								dispatchStatusEvent(PLAY_STATUS_UPDATE);
							}
							else
							{
								var tmp:Number=Number(_seekQueue.shift());
								_isSeeking=Boolean(_seekQueue.length);

								dispatchStatusEvent(PLAY_STATUS_UPDATE);
							}
							
							break;
						case "NetStream.Seek.InvalidTime":

							
							if (!_rtmp)
							{

								_isSeeking=false;
								_seekQueue.length=0;
								//we can be sure that this is not a cached copy otherwise the seek should have worked
								_httpCached=false;
								//force an update for position listeners
								dispatchStatusEvent(PLAY_STATUS_UPDATE);
							}
							else
							{
								tmp=Number(_seekQueue.shift());
								_isSeeking=Boolean(_seekQueue.length);

								dispatchStatusEvent(PLAY_STATUS_UPDATE);
							}
							
							break;
						
						default:
							
							break;
						
					}
					break;
				case "status":

					switch (info.code)
					{
						case "NetStream.Play.Start":
							if (!_isReady)
							{
								_isReady=true;
								if (_autoPlay){
									//playing intent
									playStatus=PLAY_PLAYING;
							}
								else
								{
									//stopped intent
									if (!_rtmp) _ns.pause();
									else {
										_requiresMetaData=true;
										_reset=true;
									}
									playStatus=PLAY_STOPPED;
								}

								return;
							}

							if (_rtmp ) {
								//reset for updated permissions
								
								if (!hasAccess()){
									_wasStreamingSeek=true;
									if (_bitmapAccessible) _wasBitmapAccessible=true;
									_bitmapAccessible=false;
									_bitmapAccessTested=false;
									if (_isPaused) {
										_requiresMetaData=true;
									}
									if (playStatus==PLAY_PAUSED && !_isPaused) {
										_ns.pause();
									}
								}
								
							}
							
							break;
						
						case "NetStream.Play.Reset":

							playStatus=PLAY_STATUS_RESET

							break;
						case "NetStream.Play.Stop":

							if (_ns.time >= _duration || (Math.abs(_ns.time - _duration) < 0.1))
							{
								if (_autoLoop && (_streamStatus != STREAM_STATUS_LOOPING))
								{
									_streamStatus=STREAM_STATUS_LOOPING;
									_seekQueue.length=0;
									_seekQueue.push(0);
									_isSeeking=true;
									_isPlaying=false;
									performSeek(0);
								}
							} else {
								if (_rtmp){
									_rtmpMonitor=true;
								} else _isPlaying=false; 
							}
							
							break;
						case "NetStream.Play.Complete":
							//only happens for rtmp streams, not progressive
							if (_duration){ 
								if (_ns.time >= _duration || (Math.abs(_ns.time - _duration) < 0.1)){
									_isPlaying=false;
									if (_autoLoop && (_streamStatus != STREAM_STATUS_LOOPING))
									{
										_streamStatus=STREAM_STATUS_LOOPING;
										_seekQueue.length=0;
										_seekQueue.push(0);
										_isSeeking=true;
										performSeek(0);
									}
								}
								playStatus=PLAY_STATUS_COMPLETE

							}
							
							break;
						case "NetStream.Buffer.Full":

							if (!_isReady)
							{
								//first time playing
								if (_autoPlay)
								{
									playStatus=PLAY_PLAYING;
									_isPlaying=true;
									_isPaused=false;
									if (!_rtmp && !_vid.hasEventListener(Event.ENTER_FRAME))
										_vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate, false, 0, true);
								}
								else
								{
									playStatus=PLAY_STOPPED;
									_isPlaying=false;
									_isPaused=true;
									_ns.pause()
								}
								if (!_rtmp) {
									_isReady=true;
								}
							}
							
					
							if (_bufferStatus!=BUFFER_FULL){
								_bufferLength=_ns.bufferLength;
								_bufferStatus=BUFFER_FULL;
								dispatchStatusEvent(BUFFER_STATUS_CHANGE);
							}
							break;
						case "NetStream.Buffer.Flush":
							
					
							if (_bufferStatus!=BUFFER_FLUSHING){
								_bufferLength=_ns.bufferLength;
								_bufferStatus=BUFFER_FLUSHING;
								dispatchStatusEvent(BUFFER_STATUS_CHANGE);
							}
							break;
						
						case "NetStream.Buffer.Empty":

							_bufferTime=_ns.bufferTime
							if (_ns.time >= _duration || (Math.abs(_ns.time - _duration) < 0.1))
							{
								if (_autoLoop && (_streamStatus != STREAM_STATUS_LOOPING))
								{
									_streamStatus=STREAM_STATUS_LOOPING;
									_seekQueue.length=0;
									_seekQueue.push(0);
									_isSeeking=true;
									performSeek(0);
								}
							}
							_bufferStatus=BUFFER_EMPTY

							break;
						case "NetStream.Seek.Notify":
						
							if (_reset){
								playStatus=PLAY_STOPPED;
								_ns.pause();
								_isSeeking=false;
								_isPlaying=false;
								_reset=false;
								break;
							}
							if (_seekQueue.length) _position=Number(_seekQueue.shift()); //approximate
							_wasStreamingSeek=_rtmp ;
							_isSeeking=Boolean(_seekQueue.length);
							//is this an autoLoop or a rewind?
							if (playStatus == PLAY_STOPPED && !_isSeeking && _position != 0)
							{
								//we have seeked from the stopped state at the start...so switch to PAUSE intent
								playStatus=PLAY_PAUSED;
							}
							
							//if we have seeked back to the start as an autoLoop setting, then reset the looping state
							if (_streamStatus == STREAM_STATUS_LOOPING && _position == 0)
							{
								_streamStatus=STREAM_STATUS_NORMAL;
								//autoset the play intent: looping happens when the playhead hits the end of the video
								playStatus=PLAY_PLAYING;
							}
							//if we have seeked back to the start as an rewind action , then reset the rewinding state
							if (_streamStatus == STREAM_STATUS_REWINDING && _position == 0)
							{
								_streamStatus=STREAM_STATUS_NORMAL;
								//autoset the play intent: a rewind action results in a 'stopped at start' behaviour
								playStatus=PLAY_STOPPED;
							}						
							
							if (_wasStreamingSeek)
							{
								if (_bitmapAccessible) _wasBitmapAccessible=true;
								_bitmapAccessible=false;
								_bitmapAccessTested=false;
							}
							else {
								while (_seekQueue.length)
								{
									_position=Number(_seekQueue.shift());
									_isSeeking=false;
									_updateSeekPos=true;
									
								}
								if (!_vid.hasEventListener(Event.ENTER_FRAME)) _vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate,false,0,true);	
							}
							
							if (!_isSeeking)
							{
								_seekStatus=SEEK_STATUS_END
								dispatchStatusEvent(_seekStatus);
								_seekStatus=SEEK_NONE;
								//if there was a pause request during seeking:
								if (!_isPaused && (playStatus == PLAY_PAUSED || playStatus == PLAY_STOPPED))
								{
									if (!_rtmp)	_isPaused=true;
									_ns.pause();
								}
								
								//http seek ?
								if (!_rtmp)
								{
									dispatchStatusEvent(PLAY_STATUS_UPDATE);
								}
							}
							else{
								_seekStatus=SEEK_SEEKING;
								performSeek(Number(_seekQueue.shift()))
								dispatchStatusEvent(_seekStatus);
							}
							break;
						case "NetStream.Unpause.Notify":
							if (_requiresMetaData && playStatus==PLAY_PAUSED){
								
								break;
								
							}
							_isPaused=false;
							_isPlaying=true;
							
							if (!_vid.hasEventListener(Event.ENTER_FRAME)) _vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate, false, 0, true);
							playStatus=PLAY_PLAYING;
							dispatchStatusEvent(PLAY_STATUS_UPDATE);
							break;
						case "NetStream.Pause.Notify":
							_isPaused=true;
							_isPlaying=false;
							//autoPlay is set to false? then handle the pause at the start
							if (!_isReady && !_autoPlay)
							{
								_isReady=true;
								dispatchStatusEvent(PLAY_STATUS_UPDATE);
							}
							
							_vid.removeEventListener(Event.ENTER_FRAME, videoFrameUpdate);
							if (_streamStatus == STREAM_STATUS_REWINDING)
							{
								_seekQueue.length=0;
								_seekQueue.push(0);
								_isSeeking=true;
								performSeek(0);
							}
							break;
						default:
							trace("UNHANDLED STATUS EVENT:" + info.code);
							break;
					}
					break;
			}
		}
		
		/**
		 * @private
		 * */		
		protected function onCuePoint(infoObject:Object):void
		{
			//TODO make this available via binding
			trace("onCuePoint");
		}
		
		/**
		 * @private
		 * */		
		protected function onXMPData(infoObject:Object):void
		{
			//TODO make this available via binding
			trace('received XMP data:' );
		/*	for (var thing:String in infoObject){
				trace(thing+":"+XML(infoObject[thing]).toXMLString());
			}*/
		}
		
		
		/**
		 * @private
		 * Important handler:  required information is included in metadata and it signals bitmapdata access for rtmp streams.
		 * rtmp streams must be configured to sendDuplicateMetaData (e.g. FMS options)
		 * */		
		
		protected function onMetaData(infoObject:Object):void
		{		
			_requiresMetaData=false;
			
			_metaData=infoObject;
			if (_metaData.duration != _duration)
			{
				initChange("duration", _duration, _duration=_metaData.duration, this);
			}
			//earliest point that we have valid width and height data for the video itself
			if (_metaData.width && (_metaData.width != _width || _metaData.height != _height))
			{
				
				_width=_metaData.width;
				_height=_metaData.height
				if (_vid)
				{
					_vid.attachNetStream(null)
					
					_vid.clear();
					_vid.width=_width;
					_vid.height=_height;
					_offset.a=_vid.scaleX;
					_offset.d=_vid.scaleY;
				}
				
				if (!_rtmp)
				{
					if (_ns.bytesTotal && (_ns.bytesLoaded == _ns.bytesTotal))
					{
						//assume cached
						_httpCached=true;
					}
				}
				
				if (_wasStreamingSeek)
				{	
					if (!_seekQueue.length)
					{
						_wasStreamingSeek=false;
						_seekStatus=SEEK_NONE;
						_waitOneFrame=true;
					}
					return;
				}
				
				if (_streamStatus == STREAM_STATUS_LOOPING || _streamStatus == STREAM_STATUS_REWINDING)
				{
					return;
				}
				if (_bitmapData)
				{
					var oldBD:BitmapData=_bitmapData;
					
				}
				if (_width && _height)
				{
					_bitmapData=new BitmapData(_width + _pixelMargin * 2, _height + _pixelMargin * 2, false, 0);
					
					if (oldBD){
						//get rid of the old bitmapdata and dispatch a change
						initChange("content", null, _bitmapData, this);
						oldBD.dispose();
					}
				}
				else
					trace('need to deal with situation with width and height are not yet known')
				
				_vid.attachNetStream(_ns);
				
				if (!_vid.hasEventListener(Event.ENTER_FRAME)) _vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate, false, 0, true);

				dispatchStatusEvent(STATUS_READY);
				
			}
			else
			{
				if (_wasStreamingSeek)
				{	
					if (!_seekQueue.length)
					{
						_wasStreamingSeek=false;
						_seekStatus=SEEK_NONE;
						_waitOneFrame=true;
					}
				}
				if (_wasBitmapAccessible ){
					//assume it is again
					_bitmapAccessible=_bitmapAccessTested=true;
					if (!_vid.hasEventListener(Event.ENTER_FRAME)) _vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate,false,0,true);
					_waitOneFrame=true;
					if (!_isSeeking) _seekStatus=SEEK_NONE;
					return;
				}
				
			}
			
		}
		
		
		/**
		 * @private
		 * */
		private function onTextData(textData:Object):void
		{
			trace("client onTextData");
			trace("--- textData properties ----");
			var key:String;
			
			for (key in textData)
			{
				trace(key + ": " + textData[key]);
			}
		}
		
		/**
		 * @private
		 * */
		private function onImageData(imageData:Object):void
		{
			trace("client onImageData");
			//TODO: make this accessible via binding 
			var imageloader:Loader=new Loader();
			imageloader.loadBytes(imageData.data); 
			_latestImage=(imageloader.content as Bitmap).bitmapData.clone();
		}
		
		/**
		 * @private
		 * */
		private function onPlayStatus(infoObject:Object):void
		{
			//fire it through the statusMonitor handler for consistency
			_ns.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, infoObject))
		}
		
		/**
		 * @private
		 * */
		private function ioErrhandler(e:IOErrorEvent):void
		{
			//TODO: finalise error handling
			var target:Object=e.target;
			if (target == _ns)
			{
				_errorStatus=ERROR_STATUS_DATA_ACCESS;
				_errorDetail="A stream error has occured for "+_setUrl;
			}
			else if (target == _nc)
			{
				_errorStatus=ERROR_STATUS_CONNECTION_ACCESS;
				_errorDetail="A connection error has occured for "+_nc.uri;
			}
			dispatchUpdateEvent(ERROR_STATUS_UPDATE);
		}
		
		/**
		 * @private
		 * utility support to show a visual cue when debugging via the bitmapData content. 
		 * This is usually triggered by a lack of bitmapData access permission, but could be for other reasons.
		 * 
		 * */
		private function showDebug(msg:String, width:uint=0, height:uint=0):void
		{
			var force:Boolean;
			var widthtarg:uint=(width ? width : _bitmapData ? _bitmapData.width : 400);
			var t:TextField=new TextField();
			t.width=widthtarg;
			t.wordWrap=true;
			t.autoSize=TextFieldAutoSize.LEFT;
			t.defaultTextFormat=new TextFormat("_sans", 12, 0x000000, false, false, false, null, null, "center");
			t.text=msg;
			if (width && height)
			{
				if (!_bitmapData || (_bitmapData && (_bitmapData.width != width || _bitmapData.height != height)))
				{
					_bitmapData=new BitmapData(width, height, false, 0xffffff);
					force=true;
				}
			}
			if (!_bitmapData)
			{
				_bitmapData=new BitmapData(t.width, t.height, false, 0xffffff);
				force=true;
			}
			_bitmapData.fillRect(_bitmapData.rect, 0xffffff)
			_bitmapData.draw(t, new Matrix(1, 0, 0, 1, 0, (_bitmapData.height - t.height) / 2), null, null, null, true);
			if (force)
				dispatchStatusEvent(STATUS_READY);
			
		}
		
		/**
		 * @private
		 * */		
		private var _lastDecFrame:uint;
		/**
		 * @private
		 * */
		private var _lastcheckFrame:uint;
		/**
		 * @private
		 * */
		private var _offset:Matrix=new Matrix(1, 0, 0, 1, _pixelMargin, _pixelMargin);
		
		
		/**
		 * @private
		 * */
		private function videoFrameUpdate(e:Event,forceRedraw:Boolean=false):void
		{
			var triggerChange:Boolean=_forceUpdates;
			//detect new frame
			if (_isSeeking)
			{
				
				return;
			}
			if (_requiresMetaData ) {
				
				if (_reset) _st.volume=0;
				if (!hasAccess()) {
					if (_wasStreamingSeek){
						
					}
					return;
				}
				else {
					_requiresMetaData=false;
					_bitmapAccessible=true;
					_bitmapAccessTested=true;
					_wasStreamingSeek=false;
				}
			}
			
			if (!_bitmapAccessible && _bitmapAccessTested)
			{
				_vid.removeEventListener(Event.ENTER_FRAME, videoFrameUpdate);
				return;
			}
			if (_wasStreamingSeek)
			{
				//retest
				_bitmapAccessible=false;
				_bitmapAccessTested=false;
				return;
			}
			
			if (_waitOneFrame) {
				_waitOneFrame=false;
				return;
			}
			
			_lastcheckFrame=_ns.decodedFrames;
			if (_lastcheckFrame != _lastDecFrame || forceRedraw)
			{
				_lastDecFrame=_lastcheckFrame;
				
				if (!_rtmp && (_maxCurrentSeekablePosition < _ns.time))
				{
					if (_updateSeekPos)
						_updateSeekPos=false;
					//haven't figured out a way to detect keyframes yet during play
					_maxCurrentSeekablePosition=_ns.time;
				}
				
				var copyBitmapData:Object;
				var cbd:BitmapData;
				var copyRect:Rectangle = _bitmapData.rect
				var ctrans:ColorTransform;
				if (_bitmapAccessible)
				{
					if (_rtmpMonitor ){
						if ( !hasAccess()) {
						return;
						} else _rtmpMonitor=false;
					} 
					_bitmapData.draw(_vid, _offset, null, null, null,_quality==HIGH); 
					
					
					if(_copyTargetCount) {
						for  (copyBitmapData in _copyTargets){
							cbd = BitmapData(copyBitmapData);
							//	copyData.lock();
							ctrans = _copyTargets[copyBitmapData] as ColorTransform;
							
							if (ctrans && ctrans.alphaMultiplier>0) {
								//make a copy
								cbd.copyPixels(_bitmapData,copyRect,copyPoint);
								
								//colortransform it
								cbd.colorTransform(copyRect,ctrans);
		
							} else {
								cbd.fillRect(copyRect,0);
							}

						}
					}
					
					
					//check for letterboxing within the first 100 frames
					//TODO: make this smarter
					if (_detectLetterBox && !_letterBoxChecked){
						
						if ( _checkLBLimit) {
							var checkRect:Rectangle 
							
							if (!_letterBoxContent) {
								_checkLetterBoxData=new BitmapData(_width,_height,false,0xffffff);
								_letterBoxHelper=new Rectangle(_pixelMargin,_pixelMargin,_width,_height);
								_checkLetterBoxData.threshold(_bitmapData,_letterBoxHelper,copyPoint,">=",0x080808,0xffffff,0xffffff,false);
								checkRect=_checkLetterBoxData.getColorBoundsRect(0x0,0x0,false);
								if(!checkRect.equals(_checkLetterBoxData.rect)&&!checkRect.isEmpty()){
									_letterBoxContent=checkRect;
									_letterBoxDetected=true;
									dispatchUpdateEvent(LETTERBOX_UPDATE);
									triggerChange=true
								}
							} else {
								
								_checkLetterBoxData.threshold(_bitmapData,_letterBoxHelper,copyPoint,">=",0x080808,0xffffff,0xffffff,false);
								checkRect=_checkLetterBoxData.getColorBoundsRect(0x0,0x0,false);
								if (!checkRect.equals(_checkLetterBoxData.rect) && !_letterBoxContent.equals(checkRect)&&!checkRect.isEmpty()){
									_letterBoxContent=checkRect;
									_letterBoxDetected=true;
									
									dispatchUpdateEvent(LETTERBOX_UPDATE);
									triggerChange=true
								}
							}
							_checkLBLimit--;
							
						} else {
							//cleanup
							if (_checkLetterBoxData) {
								deregisterCopyTarget(_checkLetterBoxData,true);
								_checkLetterBoxData=null;
							}
							_checkLBLimit=100;
							_letterBoxChecked=true;
							
						}
					}
					
					if (triggerChange)
						initChange("content", _bitmapData, _bitmapData, this);
				}
				else
				{
					
					try
					{
						_bitmapAccessTested=true;
						_bitmapData.draw(_vid, _offset, null, null, null, true); 
						
						if(_copyTargetCount) {
							
							for  ( copyBitmapData in _copyTargets){
								
								cbd = BitmapData(copyBitmapData);
								ctrans = _copyTargets[copyBitmapData] as ColorTransform;
								
								if (ctrans && ctrans.alphaMultiplier>0) {
									//make a copy
									cbd.copyPixels(_bitmapData,copyRect,copyPoint);
									//colortransform it
									cbd.colorTransform(copyRect,ctrans);
									
								} else { //zero alpha optimization
									cbd.fillRect(copyRect,0);
								}
							}
						}	
						
						if (triggerChange)
							initChange("content", _bitmapData, _bitmapData, this);
						_bitmapAccessible=true
						
						if (_reset){
							playStatus=PLAY_STOPPED;
							performSeek(0);
						}
					}
					catch (err:Error)
					{
						_bitmapAccessible=false;
						_errorStatus=ERROR_STATUS_DATA_ACCESS;
						_errorDetail="There is a problem with " + (_rtmp ? " streaming VideoSampleAccess " : " crossdomain ") + " permissions to permit access\nto VideoStream " + this.id + "'s bitmapdata";
						
						
						if (_debug)
							showDebug(_errorDetail,400,400);
					}
				}
			} else {
				if (!_rtmp && isPaused){
					if (_vid.hasEventListener(Event.ENTER_FRAME)) _vid.removeEventListener(Event.ENTER_FRAME, videoFrameUpdate);
	
				}

			}
		}
		
			/**
			 * @private
			 * */
			private var _autoPlay:Boolean=true;
			
			public function set autoPlay(value:Boolean):void
			{
				if (value != _autoPlay)
				{
					_autoPlay=value;
					initChange("autoPlay", !_autoPlay, _autoPlay, this);
				}
			}
			
			public function get autoPlay():Boolean
			{
				return _autoPlay;
			}
			
			/**
			 *An optional loadingLocation reference. Using a LoadingLocation simplifies management of groups of video assets from other domains
			 *by permitting different locations (alternate domains used for loading) to be specified once in code.<br/>
			 *If a loadingLocation is specified the url property in the VideoStream must be relative to the basePath specified in the LoadingLocation.
			 *For http progressive download video, permission rules are subject to flash standard crossdomain permissions.
			 *If an VideoStream's domain has a non-default policy file, a LoadingLocation must be used to specify the explicit location and
			 *name of the cross-domain file that grants access. An ExternalDataAsset without a LoadingLocation will only check for permission 
			 *in the default location and name (web document root, crossdomain.xml) for permission to access the remote file's BitmapData.
			 * For rtmp streamed video content, a loadingLocation basePath provides an easily maintained reference to a video application, and the possibility
			 * to specifiy the video assets as being relative to that location.
			 */
			public function set loadingLocation(value:LoadingLocation):void
			{
				if (value != _loadingLocation)
					_invalidated=true;
				_loadingLocation=value;
			}
			
			public function get loadingLocation():LoadingLocation
			{
				if (_implicitLocation) return _implicitLocation;
				if (!_loadingLocation)
					_loadingLocation=new LoadingLocation();
				return _loadingLocation;
			}
			
			/**
			 * the url of the external asset
			 * assignable as either a string representing a url relative to an associated LoadingLocation basePath or as a regular url
			 * For alternate domain loading use an associated LoadingLocation
			 * assigned via the loadingLocation property and make this url relative to the basePath defined in the LoadingLocation
			 */
			public function get url():String
			{
				return _setUrl;
				
			}
			private var _delayedSetter:Boolean;
			
			private function delayedURLsetter():void
			{
				_delayedSetter=true;
				var toSet:String=_setUrl;
				_setUrl="";
				url=toSet;
			}
			
			public function set url(value:String):void
			{
				if (_setUrl != value)
				{
					playStatus=PLAY_STATUS_WAITING;
					
					if (_vid.hasEventListener(Event.ENTER_FRAME)) _vid.removeEventListener(Event.ENTER_FRAME,videoFrameUpdate);
					_isReady=false;
					_updateTimer.stop();
					if (_ns) destroyStream();
					
					_setUrl=value;

					
					if (_nc && _nc.uri.length){
						//remove listeners and request autoclose for the old connection
						ConnectionItem(__connections[_nc.uri]).decrementAndAutoClose(onConnectionStatus,ioErrhandler);
						_nc=null;
						//update position if its not zero
						if (_position) {
							_position=0;
							dispatchStatusEvent(PLAY_STATUS_UPDATE);	
						}
					}
					//was it null or empty String?
					if (!value || value=="") {
						_contentType=NONE;
						if (_bitmapData){
							//erase to black
							_bitmapData.fillRect(_bitmapData.rect,0);
						}
						resetInternalState();

						return;
					}


					
					//if the url is relative, then assume it is http unless a LoadingLocation is set
					if (!_loadingLocation && _setUrl.indexOf("//") == -1)
					{
						if (!_delayedSetter)
						{
							//wait in case the loadingLocation has been set via mxml and is not yet instantiated
							//don't much like this, can't think of anything better atm for mxml assignment/instantiation delay
							setTimeout(delayedURLsetter, 1)
							return;
						}
						_relativeURL=true;
						_workingUrl=_setUrl;
						//if there's no loadinging location and its relative, then assume its always http
						_rtmp=false;
						_protocol="http";

					}
					else
					{
						//the url is either full or it is relative and there is a loadingLocation to which it is relative
						if (_setUrl.indexOf("//") != -1)
						{
							//it's not relative
							_relativeURL=false;
							var decoded:Object=LoadingLocation.extractLocation(_setUrl);
							var rawProtocol:String=decoded.protocol.split(":")[0];
							_protocol=rawProtocol;
							if (_streamingProtocols.indexOf(rawProtocol) != -1)
							{
								_rtmp=true;
								_workingUrl=_setUrl.split(decoded.basepath)[1];
								
								//wowza permits this, it seems FMS 3.5 does not, so make take it down to common ground
								if (_workingUrl.indexOf("flv:")!=-1) _workingUrl=_workingUrl.split("flv:").join("");
								//ditto for flv extension
								if (_workingUrl.lastIndexOf(".flv")==(_workingUrl.length-4))_workingUrl=_workingUrl.substring(0,_workingUrl.length-4);
								
							}
							else
							{
								_rtmp=false;
								_workingUrl=_setUrl;
	
							}
							//if we already had a loadingLocation in the past and have just decoded a full url with a different basePath, then create a new LoadingLocation instance
							
						    //this is an implicit loadingLocation
							if (!_implicitLocation) _implicitLocation=new LoadingLocation();
							_implicitLocation.basePath=decoded.protocol + decoded.domain + decoded.basepath;

							_implicitLocation.requestPolicyFile();
						}
						else
						{
							//it's relative (to an explicit LoadingLocation)
							_implicitLocation=null;
							decoded=LoadingLocation.extractLocation(_loadingLocation.basePath)
							rawProtocol=decoded.protocol.split(":")[0];
							_protocol=rawProtocol;
							if (_streamingProtocols.indexOf(rawProtocol) != -1)
							{
								_rtmp=true;
								_relativeURL=false;
								_workingUrl=_setUrl;
	
								//no point trying to request a policy file here as its a streaming video
								
								//wowza permits this, it seems FMS 3.5 does not, so make take it down to common ground
								if (_workingUrl.indexOf("flv:")!=-1) _workingUrl=_workingUrl.split("flv:").join("");
								//ditto
								if (_workingUrl.lastIndexOf(".flv")==(_workingUrl.length-4))_workingUrl=_workingUrl.substring(0,_workingUrl.length-4);

							}
							else
							{
								_rtmp=false;
							
								//is it really relative to the application or just to a loading location?
								//check to see if its relative to the application's location (true relative), otherwise prepend the LoadingLocation's basepath
								var appObject:Object = LoadingLocation.extractLocation();
								if (_loadingLocation.basePath.indexOf(appObject.protocol+appObject.domain+appObject.basepath)!=0) {
									_relativeURL=false;
									_workingUrl=_loadingLocation.basePath+_setUrl;
								} else {
									_workingUrl=_setUrl;
									_relativeURL=true;
								}
								
								_loadingLocation.requestPolicyFile();
							}
						}
					}

					_invalidated=true;
					if (_rtmp) 	_contentType=STREAMING;
					else _contentType=NON_STREAMING;
					
					
					initVideoSupport(loadingLocation.basePath);
					
					if (!_rtmp)
						play();
				} // else ignore the assigned value because it hasn't changed

			}
			
			/**
			 * The <code>content</code> property provides access to the BitmapData that this VideoStream generates.<br/>
			 * This should not usually be further manipulated directly but used as it is supplied. If this value is null, then the BitmapData is not
			 * currently available from the VideoStream. This property is intended to be used in situations where BitmapData is used as an input to
			 * drawing API functions.
			 * @see flash.display.BitmapData
			 * */				
			public function get content():BitmapData
			{
				return _bitmapData;
			}
			
////--------------------AUDIO RELATED------------------------			

			/**
			 * The <code>volume</code> property lets you set or access the sound volume of the audio component of a VideoStream.<br/>
			 * The range of values is 0.0 (no sound) through to 1.0 (full volume).<br/>
			 * Defaults to 0.5 .<br/>
			 * If the <code>muted</code> property is true then adjusting this value will not automatically unmute the sound, unless the <code>autoUnMute</code> property is set to true.
			 * @see autoUnMute
			 * @see muted
			 * */			
			public function get volume():Number
			{
				return _volume;
			}
			
			public function set volume(value:Number):void
			{
				_volume=value;
				if (!_muted || (_muted && _autoUnMute)){
					if (_st ) { 
						_st.volume=value;
						if (_ns &&_st) _ns.soundTransform=_st;
					}
					if (_muted && _volume){
						//its autoUnMuted:
						_muted=false;
						dispatchUpdateEvent(AUDIO_STATUS_UPDATE)
					}
				}
			}
			
			private var _autoUnMute:Boolean;
			/**
			 * The <code>autoUnMute</code> property lets you determine whether unMuting will occur automatically if an adjustmet to the volume property is made.<br/>
			 * Defaults to false.
			 * When set to true, if the <code>volume</code> property is changed to a value other than zero while <code>muted</code> is true, then <code>muted</code> will be set to false.
			 * This permits easy configuration for the situation where manipulating the volume setting via a component is intended to switch off the 
			 * <code>muted</code> state of the VideoStream.
			 * @see volume
			 * @see muted
			 * */
			public function get autoUnMute():Boolean{
				return _autoUnMute;
			}
			
			public function set autoUnMute(val:Boolean):void{
				_autoUnMute=val;
			}			
			
			
			
			/**
			 * @private
			 * */		
			private var _muted:Boolean;
			[Bindable(event="audioStatusUpdate")]
			/**
			 * The <code>muted</code> property lets you set or access the muted state of the audio component of a VideoStream.<br/>
			 * Defaults to false.
			 * A muted VideoStream has no audible sound, adjusting the volume.
			 * @see volume
			 * @see autoUnMute
			 * */
			public function get muted():Boolean{
				return _muted;
			}
			
			public function set muted(val:Boolean):void{
				if (_muted!=val){
					_muted=val;
					if (!_muted){
						if (_st) _st.volume=_volume;
					} else {
						if (_st) _st.volume=0;
					}
					if (_ns &&_st) _ns.soundTransform=_st;
					dispatchUpdateEvent(AUDIO_STATUS_UPDATE)
					
				}
			}
			
///--------------------END AUDIO RELATED------------------------			
			
			
			private var _autoLoop:Boolean=true;
			
			/**
			 * Determines whether this video stream automatically loops back to the start at position zero. Defaults to true.
			 */
			public function get autoLoop():Boolean
			{
				return _autoLoop;
			}
			
			public function set autoLoop(value:Boolean):void
			{
				_autoLoop=value;
			}
			
			//proxy getters for metadata:
			[Bindable(event="propertyChange")]
			public function get duration():Number
			{
				return _duration;
			}
			

			
			public function get audioCodec():String
			{
				if (_metaData && _metaData.audiocodecid)
				{
					return String(_metaData.audiocodecid);
				}
				else
					return "unknown";
			}
			
			/**
			 * Specifies an optional pixel padding around the bitmap that this VideoSource generates. This is useful to prevent color bleeding under some circumstances when the repeat
			 * setting on the VideoFill is not set to repeat and the fill is rotated or scaled.
			 */
			public function get pixelMargin():uint
			{
				return _pixelMargin;
			}
			
			public function set pixelMargin(val:uint):void
			{
				if (_pixelMargin!=val) {
					var oldVal:int=_pixelMargin;
					_pixelMargin=val;
					_offset.tx=_offset.ty=_pixelMargin;
				    if (_bitmapData) {
					if (_width && _height) {
						var oldBmp:BitmapData=_bitmapData;
						_bitmapData=new BitmapData(_width+_pixelMargin*2,_height+_pixelMargin*2,false,0);
						var tempRec:Rectangle= oldBmp.rect;
						tempRec.inflate(-oldVal,-oldVal);
						_bitmapData.copyPixels(oldBmp,tempRec,new Point(_pixelMargin,_pixelMargin))
						if (oldBmp) deregisterCopyTarget(oldBmp,true);

						initChange("pixelMargin",oldVal,_pixelMargin,this);
					}
					}
				}
			}
			/**
			 * The <code>reverseOffset</code> property provides access to a read-only correction Matrix for the content BitmapData
			 * generated by this VideoStream.
			 * This matrix is the offset to the actual video content within the BitmapData. 
			 */
			public function get reverseOffset():Matrix
			{
				return new Matrix(1, 0, 0, 1, -_pixelMargin, -pixelMargin);
			}
			
			/**
			 * @private
			 */
			protected function dispatchStatusEvent(status:String):void
			{
				
				dispatchEvent(new Event(status));
				
			}
			
			/**
			 * @private
			 */
			protected function dispatchUpdateEvent(update:String):void
			{

				dispatchEvent(new Event(update));
			}
			
			/**
			 * The <code>playheadUpdateInterval</code> property specifies whether to dispatch propertyChange events for every frame update of the video content.</br>
			 * Defaults to false.<br>
			 * Setting this to true can be useful in some situations with VideoFill, but it is usually best (i.e. less cpu intensive) to structure the Degrafa composition
			 * in such a way that it is not necessary to have this set to true.<br/>
			 * Situations to avoid are having filters or masking on the geometry that is being filled with video or in any of its parent hierarchy, including target displayobjects.
			 */
			protected function get forceUpdates():Boolean
			{
				return _forceUpdates;
			}
			
			public function set forceUpdates(val:Boolean):void
			{
				_forceUpdates=val;
			}
			
			/**
			 * The <code>playheadUpdateInterval</code> property specifies the precision of the update events for playheadTime in milliseconds.<br/> 
			 * Defaults to 250 ms.<br/>
			 * Setting this to a lower value will dispatch playheadTime updates more frequently (and therefore with more precision)
			 * but is more CPU intensive. This property has a minimum value of 5, values lower than 5 will be set to 5.
			 * @default 250
			 */
			public function set playheadUpdateInterval(val:uint):void
			{
				if (val < 5)
					val=5; //minimum of 5 ms for this value
				_playheadUpdateInterval=val;
				_updateTimer.delay=_playheadUpdateInterval;
			}
			
			public function get playheadUpdateInterval():uint
			{
				return _playheadUpdateInterval;
			}
			
			/**
			 * @private
			 */
			protected var _lastUpdate:Number=0;
			
			/**
			 * @private
			 * listener to handle dispatching events for updated metrics related to the stream
			 * */
			protected function onUpdate(e:TimerEvent):void
			{

				_position=_ns.time;
				var curLen:Number=_ns.bufferLength;
				var _updateBuffer:Boolean;
				var _updatePlayhead:Boolean;
				if (_bufferLength != curLen || _bufferTimeChange)
				{
					//logic: if bufferStatus was full or empty and it is now observed to not be full, then we are in a diminished buffer state
					if (_bufferStatus == BUFFER_FULL && _bufferTime > curLen)
					{
						_bufferStatus=BUFFER_DIMINISHED;
						dispatchStatusEvent(BUFFER_STATUS_CHANGE);
					} else if (_bufferStatus == BUFFER_EMPTY && curLen > 0)
					{
						_bufferStatus=BUFFER_BUFFERING;
						dispatchStatusEvent(BUFFER_STATUS_CHANGE);
					} else if (_bufferStatus == BUFFER_DIMINISHED && _bufferTime <= curLen)
					{
						_bufferStatus=BUFFER_FULL;
						dispatchStatusEvent(BUFFER_STATUS_CHANGE);
					} 
					//this seemed to happen in rtmp (Wowza) - to verify
					if (_bufferStatus==BUFFER_FLUSHING && curLen>_bufferTime) _bufferStatus=BUFFER_FULL;
					
					_updateBuffer=true; //flag to dispatch event
					if (_bufferTimeChange) _bufferTimeChange=false; // transient flag has been dealt with
					
				}
				
				if (!_rtmp)
				{
					//dispatch loading and buffer update events
					//observed: sometimes bytesTotal is -1 int value (or 4294967295), if it is ignore
					if (!_bytesTotal && (_ns.bytesTotal>0 && _ns.bytesTotal!=4294967295))
					{
						
						_bytesTotal=_ns.bytesTotal;
						dispatchUpdateEvent(LOAD_START)
					}
					if (_bytesLoaded != (_bytesLoaded=_ns.bytesLoaded))
						dispatchUpdateEvent(LOAD_PROGRESS)
					//if we detect that the full video has downloaded:
					if ( !_httpCached && _bytesTotal) {
						if (_bytesLoaded==_bytesTotal) {
							_httpCached=true;
							dispatchUpdateEvent(LOAD_COMPLETE)
						}
					}

				}
				
				if (!_isSeeking)
				{
					if (_lastUpdate != _position)
					{
						
						_lastUpdate=_position;
						
						_updatePlayhead=true;
					}
				}
				
				if (_updateBuffer)
					dispatchUpdateEvent(BUFFER_STATUS_UPDATE);
				if (_updatePlayhead)
					dispatchUpdateEvent(PLAY_STATUS_UPDATE);
				//frames per second support
				var fps:Number=_ns.currentFPS;
				if (fps!=_currentFPS){
					_currentFPS=fps;
					if (!_isPaused) dispatchUpdateEvent(PLAY_STATUS_FPS_UPDATE);
				}
				
				if (!_isConnected) _updateTimer.stop();
			}
			
			
			[Bindable(event="loadUpdate")]
			[Bindable(event="loadStart")]
			/**
			 * The <code>bytesTotal</code> property lets you access the total amount of bytes to be loaded if this VideoStream
			 * is playing a progressive download (http) video file.
			 */		
			public function get bytesTotal():uint
			{
				return _bytesTotal;
			}
			[Bindable(event="loadUpdate")]
			[Bindable(event="loadProgress")]
			/**
			 * The <code>bytesLoaded</code> property lets you access the total amount of bytes already loaded if this VideoStream
			 * is playing a progressive download (http) video file.
			 */		
			public function get bytesLoaded():uint
			{
				return _bytesLoaded;
			}
			
			/**
			 * @private
			 */
			protected var _debug:Boolean;
			/**
			 * The <code>debugMode</code> property provides a visual cue to some errors during development with VideoStream
			 * by making the errors visible in the bitmapData that this VideoStream creates.
			 */	
			public function set debugMode(val:Boolean):void
			{
				_debug=val;
			}
			
			public function get debugMode():Boolean
			{
				return _debug;
			}
			
			//CONTROL
			[Bindable(event="playStatusUpdate")]
			/**
			 * The <code>playheadTime</code> property represents the current time code in seconds for the playhead in this VideoStream
			 */	
			public function get playheadTime():Number
			{
				if (_ns)
				{
					var tmp:Number=_position - (_audioDelay ? _audioDelay : 0)
					if (tmp*0!=0) //isNaN
					{
						tmp=0;
					}
					if (tmp) tmp = uint(tmp*100)*0.01;
					
					return (tmp < 0 ? 0 : tmp);
				}
				else
				{
					return 0;
				}
			}
			
			public function set playheadTime(val:Number):void
			{
				if (val*0!=0 || val < 0) //isNan or negative
				{
					val=0;
				}
				if (_ns)
				{
					var limit:Number=seekableTo;
					if (limit<val) val=limit; //faster than Math.min
					if (val != _ns.time)
					{
						_position=_ns.time; 
						
						_seekStatus=SEEK_SEEKING;
						
						_seekTarget=val;
						if (!_seekTimer.running) _seekTimer.start();
					}
					else
					{
						//force the position back (for sliders etc bound to this)
						dispatchUpdateEvent(PLAY_STATUS_UPDATE);
					}
				}
			}
			/**
			 *@private
			 * a protected method for performing the actual seek on the netstream. This is deferred after seek requests to 
			 * allow for consolidation of multiple seek requests within a short timeframe.
			 * */	
			protected function performSeek(to:Number):Boolean{
				if (_ns){
					if (_rtmp) {
						if (to!=0) _rtmpSeekCycle=true;
						_requiresMetaData=true;
					}
					_isSeeking=true;
					_ns.seek(to);
					return true;
				}
				return false;
			}
			
			
			/**
			 * Plays or resumes play of a paused video.
			 * */		
			public function play():Boolean
			{
				
				if (_setUrl=="" || _setUrl==null) return false;
				
				if (_isReady && (_playStatus == PLAY_PAUSED || _playStatus == PLAY_STOPPED))
				{
					
					
					if (!_rtmp)
					{
						//assume immediate response
						_isPlaying=true;
						_isPaused=false;
						if (!_vid.hasEventListener(Event.ENTER_FRAME))
							_vid.addEventListener(Event.ENTER_FRAME, videoFrameUpdate, false, 0, true);
					}
					_ns.resume();
					//	restart the position update event dispatching
					_updateTimer.start();
					
					playStatus=PLAY_PLAYING
					//respond with success indication
					return true;
				}
				if (_playStatus == PLAY_PLAYING)
				{
					//respond with success indication
					return true;
				}
				if (_workingUrl && _isConnected )
				{

					dispatchStatusEvent(STATUS_REQUESTED);
					if (_relativeURL)
					{
						if (!_rtmp)
						{
			
							if (_loadingLocation) _loadingLocation.requestPolicyFile();

							_ns.play(_workingUrl);
							_vid.attachNetStream(_ns);
						}
						else
						{
							_ns.play(_workingUrl)
							_vid.attachNetStream(_ns);
						}
					}
					else
					{
						if (!_rtmp)
						{
							_loadingLocation.requestPolicyFile();
							if (!_ns)
							{
								_ns=new NetStream(_httpNC);
								_ns.bufferTime=_bufferTime;
							}
						} 
						_ns.play(_workingUrl);
						_vid.attachNetStream(_ns);
					}
					dispatchStatusEvent(STATUS_WAITING);
				}
				else {
					//this is a false start!
					return false;
				}
				//otherwise all is good so start the update event dispatching
				_updateTimer.start();
				return true;
			}
			
			/**
			 * Pauses the video at the current playheadTime.
			 * */
			public function pause():void
			{
				if (_setUrl=="" || _setUrl==null) return;
				
				if (!_ns || playStatus == PLAY_STOPPED || playStatus == PLAY_PAUSED)
				{
					//can't really pause
					return;
				}
				playStatus=PLAY_PAUSED;
				
				//if the status is currently seeking, need to pause post-seek
				//for now do this:
				if (_seekStatus == SEEK_SEEKING)
				{
					return;
				}
				_seekStatus=SEEK_NONE;

				if (!_rtmp)
				{
					_isPaused=true;
					_isPlaying=false;
				}
				_ns.pause();
			}
			
			
			/**
			 * Rewinds and stops the video at the start.
			 * */
			public function rewind():void
			{
				if (!_ns || playStatus == PLAY_STOPPED || _streamStatus == STREAM_STATUS_REWINDING)
				{
					//can't really rewind
					return;
				}
				//seek intent is seeking
				_seekStatus=SEEK_SEEKING;
				//VideoStream status is rewinding
				_streamStatus=STREAM_STATUS_REWINDING;

				if (_isPlaying)
				{
					playStatus=PLAY_STOPPED;
					//pause first then rewind
					_ns.pause(); //handle it from there for rtmp via events
					if (!_rtmp)
					{
						//seek immediately for http as pause seems to be immediate
						_seekQueue.length=0;
						_seekQueue.push(0);
						_isSeeking=true;
						performSeek(0);
					}
				}
				else
				{
					playStatus=PLAY_STOPPED;
					_seekQueue.length=0;
					_seekQueue.push(0);
					_isSeeking=true;
					performSeek(0);
				}
			}
			
			/**
			 * The <code>seekableTo</code> property represents the calculated (known) or estimated current maximum seekable point within the stream.
			 * This differs between http progressive videos and streaming videos.
			 * for streaming video it covers the duration of the video, for progressive download video
			 * it includes the full video if the video has completely downloaded otherwise it is within 
			 * the proportion of the video that has downloaded thus far (which may be an estimate in terms
			 * of the actual playing time this represents)
			 * 
			 * */
			public function get seekableTo():Number
			{
				if (!_isReady)
				{
					return _maxCurrentSeekablePosition=0;
				}
				//if its a stream return the _duration value extracted from metadata
				if (_rtmp)
				{
					if (_metaData) return _maxCurrentSeekablePosition=_duration;
					//what to do here?
					return _ns.time;
				}
				//for http progressive download its 'less certain'
				if (!_rtmp)
				{
					if (_httpCached)
					{
						//if we believe its fully loaded/cached, then its easy, so long as we have information about the duration
						if (_metaData.lastkeyframetimestamp)
							return _maxCurrentSeekablePosition=_metaData.lastkeyframetimestamp;
						//a couple of common metadata encodings of seek points:
						if (_metaData.keyframes && _metaData.keyframes.times)
						{
							if (_metaData.keyframes.times is Array)
							{
								var keyframeTimes:Array=_metaData.keyframes.times as Array;
								return _maxCurrentSeekablePosition=Number(keyframeTimes[keyframeTimes.length - 1]);
							}
						}
						if (_metaData.seekpoints && _metaData.seekpoints is Array)
						{
							_maxCurrentSeekablePosition=Number(_metaData.seekpoints[ _metaData.seekpoints.length-1].time);
							
							if (_maxCurrentSeekablePosition*0==0)
							{
								return _maxCurrentSeekablePosition;
							} //otherwise its NaN
						}
						if (_metaData.canSeekToEnd && _duration)
							return _maxCurrentSeekablePosition=_duration;
						
						
						if (_duration) return _maxCurrentSeekablePosition=_duration;
						//what if there was no helpful metadata?
						//catchall: seek no further that current playhead as we don't know the duration
						_maxCurrentSeekablePosition=_ns.time;
						
						//TODO: check if/how often this occurs.
					}
					else
					{
						var temp:Number=_maxCurrentSeekablePosition;
						if (_bufferStatus == BUFFER_FULL || _bufferStatus == BUFFER_FLUSHING)
						{
							//allow for current position plus buffer or below as a certainty
							temp= _maxCurrentSeekablePosition + Math.min(_ns.bufferLength, _ns.bufferTime);
							//isNaN ?
							if (temp*0!=0) temp= _maxCurrentSeekablePosition;
						} 
						
						//allow for a proportion of the preloaded content as well : guesstimates
						if (_bytesTotal>0){
							var approxPos:Number;
							//if we have the metadata, use it to help the calculation
							if (_metaData.framerate && _metaData.audiodatarate && _metaData.videodatarate && _bytesLoaded>0){
								var rate:Number=(Number(_metaData.audiodatarate)+Number(_metaData.videodatarate))*Number(_metaData.framerate);
								//drop back bytesLoaded to cover an arbitrary or informed allocation for the size of metadata
								var nonmedia:Number = (_metaData.audiosize && _metaData.datasize && _metaData.videosize)? Number(_metaData.datasize-(_metaData.audiosize+_metaData.videosize)):10000;
								
								approxPos = (_bytesLoaded-nonmedia)/rate;
								//drop back by half a sec to be a little more conservative (the encoding data rate can be variable so this approx could be out by quite a bit)
								approxPos-=0.5;
								if (temp<approxPos) temp=approxPos;
							} else {
								//drop back bytesLoaded to cover an arbitrary allocation for the size of metadata
								var loaded:Number=(_bytesLoaded-10000)/_bytesTotal;
								if (loaded<0) loaded=0;
								if (_duration) {
									//drop back by half a sec to be a little more conservative (the encoding data rate can be variable so this approx could be out by quite a bit)
									approxPos =loaded*_duration-.5;
									if (temp<approxPos) temp=approxPos;
								}
							}
						}
						//TODO: add in support for keyframe metadata, where it exists, to return the exact seekpoint close to temp value
						return temp;
					}
				}
				//TODO: consider options here....rtmp with no metadata does it exist?
				return 0;
			}
			
			
			/**
			 * @private
			 * */
			protected function set playStatus(val:String):void
			{
				if (val != _playStatus)
				{
					_playStatus=val;
					dispatchStatusEvent(PLAY_STATUS_CHANGED);
					dispatchStatusEvent(_playStatus);
				}
			}
			/**
			 * @private
			 * the current play intent of the player
			 * */
			protected function get playStatus():String
			{
				return _playStatus;
			}
			
			[Bindable(event="playStatusChanged")]
			/**
			 * The <code>isPlaying</code> property returns a Boolean true if the VideoStream is currently playing. 
			 *  */
			public function get isPlaying():Boolean
			{
				//based on intent
				return (_playStatus == PLAY_PLAYING || _playStatus == PLAY_STATUS_COMPLETE); 
			}
			
			[Bindable(event="playStatusChanged")]
			/**
			 * The <code>isPaused</code> property returns a Boolean true if the VideoStream is currently paused or stopped. 
			 *  */
			public function get isPaused():Boolean
			{
				//based on intent
				return (_playStatus == PLAY_PAUSED || _playStatus == PLAY_STOPPED);
			}
			
			[Bindable(event="bufferStatusChange")]
			/**
			 * The <code>bufferStatus</code> property returns a string value indicating the current buffer status in the VideoStream.
			 * possible values are bufferBuffering,bufferFull,bufferDiminished,bufferEmpty, and bufferFlushing
			 *  */
			public function get bufferStatus():String
			{
				return _bufferStatus;
			}
			
			
			[Bindable(event="bufferStatusUpdate")]
			public function get bufferIndicator():String
			{
				//asume green
				var ret:String="green";
				var ratio:Number;
				switch (_bufferStatus)
				{
					case BUFFER_FULL:
					case BUFFER_FLUSHING:
						//ret= "green" already
						break;
					case BUFFER_EMPTY:
						ret="red";
						break;
					case BUFFER_BUFFERING:
						ratio=_bufferLength / _bufferTime;
						//the buffer is not 'healthy' until its full
						if (ratio < 1)
							ret="orange";
						if (ratio < .2)
							ret="red";
						break;
					case BUFFER_DIMINISHED:
						//buffering or falling
						if (!_bufferTime)
						{
							if (_bufferLength)
								return 'green';
							return 'red';
						}
						ret="green";
						ratio=_bufferLength / _bufferTime;
						//'health' is considered higher if we have already had a full buffer
						if (ratio < .75)
							ret="orange";
						if (ratio < .2)
							ret="red";
						break;
					default:
						trace('err: unhandled buffer state')
						break;
				}
				return ret;
				
			}
			
			
			
			[Bindable(event="bufferTimeChanged")]
			public function get bufferTime():Number
			{
				return Number(_bufferTime.toFixed(2));
			}
			
			
			public function set bufferTime(val:Number):void
			{
				if (val >= 0 && _bufferTime != val)
				{
					_bufferTime=val;
					if (_ns)
					{
						_ns.bufferTime=val;
						_bufferTimeChange=true;
					}
					//TODO: (check) consider maybe should only dispatch this if the ns exists?
					dispatchUpdateEvent(BUFFER_TIME_CHANGED);
				}
			}
			
			[Bindable(event="bufferStatusUpdate")]
			public function get bufferLength():Number
			{
				if(!_ns) return 0;
				_bufferLength=_ns.bufferLength
				return _bufferLength;
			}
			
			[Bindable(event="bufferStatusUpdate")]
			public function get bufferRatio():Number{
				if (!_bufferTime) return 1;
				return _bufferLength/_bufferTime;
			}
			
			// ************ ALPHA SUPPORT FROM EXTERNAL REQUESTERS*********************
			
			protected static function processDisposalQueue(e:TimerEvent):void{
				if (_disposalQueue && _disposalQueue.length){
					BitmapData(_disposalQueue.shift()).dispose();
				} else {
					_disposalTimer.stop();
					_disposalTimer.removeEventListener(TimerEvent.TIMER,processDisposalQueue);
					_disposalTimer=null;
				}
			}
			
			protected static var _disposalQueue:Array;
			protected static var _disposalTimer:Timer;
			
			/**
			 * utility support functions for updating additional bitmapdata copies. Intended for use with alpha target copies.
			 * This VideoStream generates bitmapData without alpha channel by default for performance reasons 
			 * so on2vp6 alpha channel video is currently not supported - will review this based on demand and/or provide a subclass for on2vp6 content with alpha.
			 * The original bitmapData can be used as a source for multiple alpha versions, but the bitmapdata frameupdating will become very cpu intensive for 
			 * multiple simultaneous alpha versions of higher resolution video content or multiple VideoStreams with alpha requests etc. Use with a modicum of common sense.
			 * */
			public function registerCopyTarget(target:BitmapData,colorTransform:ColorTransform=null):void{
				if (!_copyTargets) _copyTargets=new Dictionary(true);
				if (_bitmapData && target.rect.equals(_bitmapData.rect)){
					_copyTargets[target]=colorTransform;
					_copyTargetCount++
				} //otherwise do nothing, consider throwing an error here
			}
			
			protected function clearAllCopyTargets():void{
				if (!_copyTargets) return;
				for (var target:Object in _copyTargets){
					deregisterCopyTarget(BitmapData(target),true);
				}
			}
			
			public function deregisterCopyTarget(target:BitmapData,destroyTarget:Boolean=false):void{
				
				if (_copyTargets && _copyTargets[target]!==undefined){
					if (_copyTargets[target] is ColorTransform) {
						if (!_disposalQueue) _disposalQueue=[];	
						if (destroyTarget) _disposalQueue.push(target)
					} else {
						if (destroyTarget){
							if (!_disposalQueue) _disposalQueue=[];	
							_disposalQueue.push(target);
						}
					}
					
					_copyTargetCount--;
					_copyTargets[target]=null;
					delete _copyTargets[target];
				} else{//destroy target if requested, simple utility only
					if (destroyTarget){
						if (!_disposalQueue) _disposalQueue=[];	
						_disposalQueue.push(target);
					}
				}
				if (!_disposalTimer && _disposalQueue.length)  {
					_disposalTimer =new Timer(DISPOSAL_DEFERRAL,0);
					_disposalTimer.addEventListener(TimerEvent.TIMER,processDisposalQueue,false,0,true);
					_disposalTimer.start();
				} 
			}
			/**
			 * The <code>letterBoxContent</code> property, if not null, provides a Rectangle instance that defines the VideoStream's letterboxed content.
			 * This property is <code>read-only</code>.
			 * 
			 * @see flash.geom.Rectangle
			 */			
			public function requestPausedBitmapdataUpdate():void{
				if (_isPaused && _bitmapAccessible){	
					videoFrameUpdate(new Event("explicitRequest",false,false),true);
				}
			}
			
//LETTERBOX DETECTION SUPPORT		
			protected var _letterBoxContent:Rectangle;
			protected var _letterBoxHelper:Rectangle;
			protected var _letterBoxDetected:Boolean;
			protected var _letterBoxChecked:Boolean;
			protected var _checkLetterBoxData:BitmapData;
			protected var _checkLBLimit:uint =100;
			
			//letterbox detection
			[Bindable(event="letterBoxUpdate")]
			/**
			 * The <code>letterBoxContent</code> property, if not null, provides a Rectangle instance that defines the VideoStream's letterboxed content.
			 * This property is <code>read-only</code>.
			 * 
			 * @see flash.geom.Rectangle
			 */
			public function get letterBoxContent():Rectangle
			{
				return _letterBoxContent;
			}
			/**
			 * @private
			 * */			
			protected var _detectLetterBox:Boolean;
			/**
			 * The <code>detectLetterBox</code> property lets you specify whether this VideoStream has letterbox detection enabled.<br/>
			 * Defaults to false.</br>
			 * This is an experimental feature that is still under development.<br/>
			 * When set to true, in the current (beta) implementation, the stream will perform a very simple analysis during the first 
			 * 100 rendered frames after it has been enabled. The detection algorithm is likely to change in the future and is likely to include sporadic
			 * monitoring throughout the stream rather than just a simple test during the first 100 frames after being enabled.</br>
			 * The current (beta) algorithm only looks for black letterboxing of content within a small tolerance range. 
			 * Results may be inaccurate or undesirable for some content.
			 */	
			public function get detectLetterBox():Boolean{
				return _detectLetterBox;
			}
			
			
			[Inspectable(category="General", enumeration="true,false", defaultValue="false")]		
			public function set detectLetterBox(val:Boolean):void{
				var notify:Boolean;
				if (val!=_detectLetterBox){
					if (_letterBoxDetected) notify=true;
					_letterBoxDetected=false;
					_letterBoxContent=null;
					_letterBoxHelper=null;
					_letterBoxChecked=false;
					_checkLBLimit=100;
					if (_detectLetterBox)  {
						//setting to false
						if (_checkLetterBoxData) deregisterCopyTarget(_checkLetterBoxData,true);
					}
					_checkLetterBoxData=null;
					_detectLetterBox=val;
					if (notify) {
						dispatchUpdateEvent(LETTERBOX_UPDATE);
						initChange('content',_bitmapData,_bitmapData,this);
					}
				}
			}
			

			
			[Bindable(event="letterBoxUpdate")]
			/**
			 * The <code>isLetterBoxed</code> property lets you access the current frames per second decoding from this VideoStream.
			 * This property is <code>read-only</code>.
			 */	
			public function get isLetterBoxed():Boolean{
				return _letterBoxDetected;
			}
			
			[Bindable(event="playStatusFPSupdate")]
			/**
			 * The <code>currentFPS</code> property lets you access the current frames per second decoding from this VideoStream.
			 * This is independent of the swf frame rate.
			 */	
			public function get currentFPS():Number{
				return _currentFPS;
			}
			
			/**
			 * @private
			 * */
			private var _quality:String="high";

			/**
			 * The <code>quality</code> property lets you alter the rendering quality for this VideoStream at the basic content level.<br/>
			 * Defaults to high.<br/>
			 * This affects the quality of the rendered bitmapData, and may be reduced to lower 
			 * CPU load slightly if rendering quality is not the highest priority.
			 * @default high
			 * */
			public function get quality():String{
				return _quality;
			}
			[Inspectable(category="General", enumeration="high,med,low", defaultValue="high")]
			public function set quality(val:String):void{
				val=val.toLowerCase();
				if (_quality!=val){
					if (val=="low" || val=="high"||val=="med"){
						_quality=val;
						_vid.smoothing=(val!="low");
					}
				}
			}

			/**
			 * @private
			 * */		
			private var _contentType:String;
			[Bindable(event="itemInitializing")]
			/**
			 * The <code>contentType</code> property lets you access a string value that represents the type of the content.
			 * Valid values are none,non-streaming,streaming (VideoFill.NONE,VideoFill.STREAMING,VideoFill.NON_STREAMING)
			 * This property is <code>read-only</code>.
			 * */
			public function get contentType():String{
				if (!_contentType || !_contentType.length) return VideoStream.NONE;
				return _contentType;
			}
			
			//-----ERROR SUPPORT
			private var _errorStatus:String=ERROR_STATUS_NONE;
			private var _errorDetail:String;
			[Bindable(event="errorUpdate")]
			/**
			 * The <code>errorStatus</code> property lets you access a string value that represents the general type of error that has occured, if one exists.
			 * Valid values are errorNone,errorConnectionAccess,errorDataAccess,errorConnectionAccess (VideoFill.ERROR_STATUS_NONE,VideoFill.ERROR_STATUS_DATA_ACCESS,VideoFill.ERROR_STATUS_CONNECTION_ACCESS)
			 * This property is <code>read-only</code>.
			 * */			
			public function get errorStatus():String{
				return _errorStatus;
			}
			[Bindable(event="errorUpdate")]
			/**
			 * The <code>errorStatus</code> property lets you access a string value that represents a more descriptive explanation of an error that has occured, if one exists.
			 * If no error has occurred, the value remains as "none".
			 * This property is <code>read-only</code>.
			 * */			
			public function get errorDetail():String{
				return _errorDetail;
			}
			
			
			protected function updateErrorStatus(status:String,detail:String,sendEvent:Boolean=true):void{
				_errorStatus=status;
				_errorDetail=detail;
				if (sendEvent) dispatchStatusEvent(ERROR_STATUS_UPDATE);
			}
			
	}
}


////////////////////////////////////////////////////////////////////////////////////////////
//Local helper class for NetConnection management

import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;
import flash.utils.getTimer;
import com.degrafa.utilities.external.LoadingLocation;

final class ConnectionItem{

	private static var closureQueue:Array=[];
	private static const idleClosureDelay:int=30000; //30 secs
	private static const closeTimer:Timer = new Timer(idleClosureDelay+1,0)
	private static function nullFunc(...args):*{}			
	private static const nullClient:Object={onBWDone:nullFunc,onFCSubscribe:nullFunc, onCuePoint: nullFunc, onMetaData: nullFunc, onTextData: nullFunc, onImageData: nullFunc, onPlayStatus: nullFunc, onXMPData: nullFunc}; 
    
	public static const CONNECTING:String="connecting";
	public static const IN_USE:String="in use";
	public static const NEW_ITEM:String="new item";
	public static const REDUNDANT:String="redundant";
	public static const CLOSED:String="closed";
	public static const ERROR:String="error";
	
	private var _connectionCount:int=1;
	private var _nc:NetConnection;
	private var _connStatus:String = NEW_ITEM;
	
	private var deathTime:int;
	
	//local copies of LoadingLocation props
	
	private var uri:String;
	private var policyFile:String;
	private var loadingLocation:LoadingLocation;
	
	/**
	 * @private
	 * utility method to ignore any client callbacks on a NetStream object
	 */
	public static function decommissionNetStream(ns:NetStream):void{
		ns.client=nullClient;
	}
	
	
	/**
	 * @private
	 * Utility method for closing NetConnections for un-used ConnectionItems after a defined period. 
	 * */	
	private static function processQueue(e:TimerEvent):void{
		var t:int=getTimer();
		for each(var connItem:ConnectionItem in closureQueue){
			if (connItem.deathTime<t){
				var conn:NetConnection =connItem.nc;
				conn.client=nullClient;
				conn.close();
				connItem.status=CLOSED;
				closureQueue.shift();
			} else break;
		}
		if (!closureQueue.length) closeTimer.reset();
	}

	/**
	 * Constructor
	 * ConnectionItem is a utility class to support re-use and removal of NetConnection Objects in relation to streaming VideoStreams
	 * */		
	public function ConnectionItem(nc:NetConnection,client:Object=null,statusHandler:Function=null,errorHandler:Function=null,uri:String=null,autoConnect:Boolean=false){
		_nc=nc;
		if (client) _nc.client=client;
		if (statusHandler!=null || errorHandler!=null) addListeners(statusHandler,errorHandler);
		if (uri) this.uri=uri;
		if (!closeTimer.hasEventListener(TimerEvent.TIMER))closeTimer.addEventListener(TimerEvent.TIMER,processQueue,false,0,true);
		if (autoConnect) connect();
	}
	/**
	 * @private
	 * removes listeners to the NetConnection object for status and error handling
	 *
	 * */		
	public function removeListeners(statusHandler:Function=null,errorHandler:Function=null):void{
		if (statusHandler !=null) {
			_nc.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
		}
		if (errorHandler !=null) {
			_nc.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
	}
	/**
	 * @private
	 * adds listeners to the NetConnection object for status and error handling
     *
	 * */		
	private function addListeners(statusHandler:Function=null,errorHandler:Function=null):void{
		if (statusHandler !=null) {
			 _nc.addEventListener(NetStatusEvent.NET_STATUS, statusHandler, false, 0, true);
		}
		if (errorHandler !=null){
			_nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
		}
	}
	/**
	 * @private
	 * connect to the uri of this ConnectionItem via its associated NetConnection
	 * 
	 * @param uri an alternate uri to use from the one set at instantiation
	 * @return a Boolean value representing whether the connection attempt was made or not.
	 * */		
	
	public function connect(uri:String=null):Boolean{
		if (uri)  {
			this.uri=uri;
		}
		if (!_nc.connected){
			_nc.connect(this.uri)
			_connStatus=CONNECTING
		    return true;
		}
		return false;
	}
	/**
	 * @private
	 * retrieve the NetConnection for this ConnectionItem,
	 * adding listeners as required
	 * 
	 * @param statusHandler the listener function for NetStatus events
	 * @param errorHandler the listener function for IOError events
	 * @return the NetConnection object associated with this ConnectionItem
	 * */	
	public function increment(statusHandler:Function=null,errorHandler:Function=null):NetConnection{
		if (!_connectionCount) {
			//rescue it from the closureQueue
			var found:Boolean;
			var l:int=closureQueue.length;
			var i:int;
			for (i=0;i<l;i++){
				if (ConnectionItem(closureQueue[i])==this){
					//found me, rescue me
					closureQueue.splice(i,1);
				}
			}
		}
		//remove first before adding, to ensure we never get in the situation where we add twice
		if (statusHandler!=null || errorHandler!=null){
			removeListeners(statusHandler,errorHandler);
			addListeners(statusHandler,errorHandler);
		}
		if (!_nc.connected) {
			//reconnect
			_connStatus=CONNECTING;
			connect();
			
		} else {
			_connStatus=IN_USE;
		}

		_connectionCount++
		return _nc;
	}
	/**
	 * @private
	 * reduce the connection count for items using this connection
	 * 
	 * @param content the relative content to map to this connection
	 * */	
	public function decrementAndAutoClose(statusHandler:Function=null,errorHandler:Function=null):Boolean{
		_connectionCount--;
		if (!_connectionCount) {
			if ( _nc.connected){
				deathTime=getTimer()+idleClosureDelay;
				closureQueue.push(this );
			} 
			removeListeners(statusHandler,errorHandler);
			if (closureQueue.length && !closeTimer.running) closeTimer.start();
			_connStatus=REDUNDANT;
			return true;
		
		}
		return false;
	}

	
	private function get nc():NetConnection{
		return _nc;
	}

	/**
	 * @private
	 * the current status of this ConnectionItem
	 * */
	public function get status():String{
		return _connStatus;
	}
	public function set status(val:String):void{
		_connStatus=val;
	}
}

