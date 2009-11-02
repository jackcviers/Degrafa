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
package com.degrafa.paint{
	
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IBlend;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.ITransformablePaint;
	import com.degrafa.core.Measure;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.transform.ITransform;
	import com.degrafa.utilities.external.ExternalDataAsset;
	import com.degrafa.utilities.external.ExternalDataPropertyChangeEvent;
	import com.degrafa.utilities.external.LoadingLocation;
	import com.degrafa.utilities.external.VideoStream;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	[DefaultProperty("source")]
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("VideoFill.png")]
	
	/**
	 * VideoFill is an advanced paint class used to fill an area with playing Video content.
	 */
	public class VideoFill extends DegrafaObject implements IGraphicsFill, IBlend,ITransformablePaint{
		
		// static constants
		public static const NONE:String = "none";
		public static const REPEAT:String = "repeat";
		public static const STRETCH:String = "stretch";
		//targetSettings
		//scale to target bounds, without maintaining aspect ratio.
		public static const MATCH_BOUNDS:String = "matchTargetBounds";
		//scale the VectorFill to the target bounds, whilst maintaining aspect ratio. center horizontally and vertically
		public static const MATCH_BOUNDS_MAINTAIN_AR:String = "matchTargetBoundsMaintainAspectRatio";
		//draw without any scaling transforms to match the target bounds, but center on the fill bounds to the target's center of bounds
		public static const CENTER_TO_TARGET:String = "centerToTarget";
		private static var _targetSettings:Array = [NONE, MATCH_BOUNDS,MATCH_BOUNDS_MAINTAIN_AR,CENTER_TO_TARGET ];
		
		private var _alphaRequests:Dictionary;
		
		/**
		 * targetSetting options, avalailable as a convenience.
		 */
		public static function get targetSettingOptions():Array
		{
			return _targetSettings.concat();
		}


		private var bitmapData:BitmapData;
		private var _videoSource:VideoStream;
		private var _loadingLocation:LoadingLocation;

		private var instantiationTimer:uint=5;
		
		public function VideoFill(source:Object = null,loc:LoadingLocation=null){
			this._loadingLocation = loc;
			this.source = source;
			
		}
		
		//TODO: Consider not implementing IBlend 
		private var _blendMode:String="normal";
		[Inspectable(category="General", enumeration="normal,layer,multiply,screen,lighten,darken,difference,add,subtract,invert,alpha,erase,overlay,hardlight", defaultValue="normal")]
		[Bindable(event="propertyChange")]
		public function get blendMode():String { 
			return _blendMode; 
		}
		
		public function set blendMode(value:String):void {
			if(_blendMode != value){
				
				var oldValue:String=_blendMode;
				
				_blendMode = value;
				
				//call local helper to dispatch event	
				initChange("blendMode",oldValue,_blendMode,this);
				
			}
			
		}
		
		private var _x:Number;
		/**
		 * The x-axis coordinate of the upper left point of the gradient rectangle. If not specified 
		 * a default value of 0 is used.
		 **/
		public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		public function set x(value:Number):void{
			if(_x != value){
				
				var oldValue:Number=_x;
				
				_x = value;
				
				//call local helper to dispatch event	
				initChange("x",oldValue,_x,this);
				
			}
		}
		
		
		private var _y:Number;
		/**
		 * The y-axis coordinate of the upper left point of the gradient rectangle. If not specified 
		 * a default value of 0 is used.
		 **/
		public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				
				var oldValue:Number=_y;
				
				_y = value;
				
				//call local helper to dispatch event	
				initChange("y",oldValue,_y,this);
				
			}
		}
		
		
		private var _width:Number;
		/**
		 * The width to be used for scaling the video content rectangle (excluding pixelMargin).
		 **/
		public function get width():Number{
			if(_width*0!=0){
				if (_coordType == "ratio") return 1;
				if (bitmapData) {
					return bitmapData.width-(_correctionMatrix?_correctionMatrix.tx*2:0);
				} else return 0;
			}
			return _width;
		}
		public function set width(value:Number):void{
			if(_width != value){
				
				var oldValue:Number=_width;
				
				_width = value;
				
				//call local helper to dispatch event	
				initChange("width",oldValue,_width,this);
			}
		}
		
		
		private var _height:Number;
		/**
		 * The height to be used for scaling the video content rectangle (excluding pixelMargin).
		 **/
		public function get height():Number{
			if(_height*0!=0){
				if (_coordType == "ratio") return 1;
				if (bitmapData) {
					return bitmapData.height-(_correctionMatrix?_correctionMatrix.ty*2:0);
				} else return 0;
			}
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				if (value<0){
					if (!_height) return;
					value=0;
				}
				if (!value) value=NaN;
				var oldValue:Number=_height;
				_height = value;
				//call local helper to dispatch event	
				initChange("height",oldValue,_height,this);
			}
		}
		
		private var _repeatX:String = "none";
		[Inspectable(category="General", enumeration="none,repeat,stretch", defaultValue="none")]
		[Bindable(event="propertyChange")]
		/**
		* How the bitmap repeats horizontally.
		* Valid values are "none", "repeat", and "stretch".
		* Setting this value to "repeat" if repeatY is "none" will automatically set repeatY to "repeat" also.
		* If targetSetting is set to a value other than "none" then both repeatX and repeatY must be set to "repeat" to enable repeating
		* If targetSetting is set to a value other than "none" then values of "stretch" are ignored for repeatX or repeatY
		* @default "none"
		*/

		public function get repeatX():String{ 
			return _repeatX;
		}
		
		public function set repeatX(value:String):void {
			if(_repeatX != value){
				
				var oldValue:String=value;
				
				_repeatX = value;
				
				//call local helper to dispatch event	
				initChange("repeatX",oldValue,_repeatX,this);
				if (_repeatX=="repeat" && _repeatY=="none") repeatY="repeat";
				
			}
			
		}
		
		private var _repeatY:String = "none";
		[Inspectable(category = "General", enumeration = "none,repeat,stretch", defaultValue="none")]
		[Bindable(event="propertyChange")]
		/**
		* How the bitmap repeats vertically.
		* Valid values are "none", "repeat", and "stretch".
		* Setting this value to "repeat" if repeatX is "none" will automatically set repeatX to "repeat" also.
		* If targetSetting is set to a value other than "none" then both repeatX and repeatY must be set to "repeat" to enable repeating
		* If targetSetting is set to a value other than "none" then values of "stretch" are ignored for repeatX or repeatY
		* @default "none"
		*/

		public function get repeatY():String{ 
			return _repeatY; 
		}
		
		public function set repeatY(value:String):void {
			if(_repeatY != value){
				
				var oldValue:String=value;
				
				_repeatY = value;
				
				
				//call local helper to dispatch event	
				initChange("repeatY",oldValue,_repeatY,this);
				if (_repeatY=="repeat" && _repeatX=="none") repeatX="repeat";
				
			}
			
		}
		
		private var _rotation:Number = 0;
		[Bindable(event="propertyChange")]
		/**
		* The number of degrees to rotate the bitmap.
		* Valid values range from 0.0 to 360.0.
		* @default 0
		*/

		public function get rotation():Number {
			return _rotation;
		}
		
		public function set rotation(value:Number):void {
			
			if(_rotation != value){
				
				var oldValue:Number=value;
				
				_rotation = value;
				
				//call local helper to dispatch event	
				initChange("rotation",oldValue,_rotation,this);
				
			}
			
		}
		
		private var _scaleX:Number = 1;
		/**
		* The percent to horizontally scale the video when filling, from 0.0 to 1.0.
		* If 1.0, the video is filled at its natural size.
		* @default 1.0
		*/
	 	[Bindable(event="propertyChange")]
		public function get scaleX():Number {
			return _scaleX; 
		}
		
		public function set scaleX(value:Number):void {
			
			if(_scaleX != value){
				
				var oldValue:Number=value;
				
				_scaleX = value;
				
				//call local helper to dispatch event	
				initChange("scaleX",oldValue,_scaleX,this);
				
			}
			
		}
		
		private var _scaleY:Number = 1;
		[Bindable(event="propertyChange")]
		/**
		* The percent to vertically scale the video when filling, from 0.0 to 1.0.
		* If 1.0, the video is filled at its natural size.
		* @default 1.0
		*/

		public function get scaleY():Number { 
			return _scaleY; 
		}
		
		public function set scaleY(value:Number):void {
			
			if(_scaleY != value){
				
				var oldValue:Number=value;
				
				_scaleY = value;
				
				//call local helper to dispatch event	
				initChange("scaleY",oldValue,_scaleY,this);
				
			}
		
		}
		
		
		protected var _coordType:String = "relative";
		[Inspectable(category="General", enumeration="absolute,relative,ratio", defaultValue="absolute")]
		/**
		 * The <code>coordinateType</code> property specifies the coordinates to be used for fill bounds, either absolute, or relative to target bounds, or as a ratio to target bounds.
		 * For VideoFill this defaults to relative.
		 * For <code>targetSetting</code> set to a setting other than VideoFill.NONE, this setting does not apply as they ignore it.
		 * @seet targetSetting
		 **/

		public function set coordinateType(value:String):void
		{
			if (value!=_coordType) 
			{
				//call local helper to dispatch event	
				initChange("coordinateType",_coordType,_coordType = value,this);
			}
		}
		public function get coordinateType():String{
			return _coordType;
		}
		
		
		
		/**
		 * @private
		 * 
		 * */
		private var _smooth:Boolean = true; 
		[Inspectable(category = "General", enumeration = "true,false", defaultValue="true")]
		[Bindable(event="propertyChange")]
		/**
		* A flag indicating whether to smooth the video image when filling with it if scaling is applied.
		* @default true
		*/

		public function get smooth():Boolean{
			return _smooth; 
		}
		
		public function set smooth(value:Boolean):void {
			
			if(_smooth != value){
				
				var oldValue:Boolean=value;
				
				_smooth = value;
				
				//call local helper to dispatch event	
				initChange("smooth",oldValue,_smooth,this);
				
			}
			
		}
		
		/**
		 * @private
		 * 
		 * */		
		private var _targetSetting:uint = 0;
		[Inspectable(category = "General", enumeration = "none,matchTargetBounds,matchTargetBoundsMaintainAspectRatio,centerToTarget", defaultValue="none")]
		/**
		 * A 'smart'/quick setting for matching fill rendering between source and target. Using this setting overrides - or more precisely, ignores -
		 * most of the manual settings applied to the fill. Using 'none' enables all the regular manual settings
		 */
		public function get targetSetting():String{
			return _targetSettings[_targetSetting]; 
		}
		
		public function set targetSetting(value:String):void {
			var valIndex:int = _targetSettings.indexOf(value);
			if (valIndex == -1) {
				valIndex = 0;
			}
			if (_targetSetting != valIndex)
			{
				var oldValue:uint = _targetSetting;
				_targetSetting=valIndex;
				//_requiresPreRender = true;
				//call local helper to dispatch event	
				initChange("targetSetting",_targetSettings[oldValue],_targetSettings[_targetSetting],this);
			}
		}
		/**
		 * @private
		 * 
		 * */		
		private var _insetFromStroke:Boolean;	
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		/**
		 * whether the fillrendering bounds are determined by insetting from half the stroke width of the target or not.
		 * this setting only has effect when used to fill degrafa target geometry otherwise it is ignored.
		 */
		public function get insetFromStroke():Boolean
		{
			return _insetFromStroke? _insetFromStroke:false;
		}
		public function set insetFromStroke(value:Boolean):void
		{
			if (value != _insetFromStroke) {
				_insetFromStroke = value;
				initChange("insetFromStroke", !_insetFromStroke, _insetFromStroke, this);
			}
		}
		
		//EXTERNAL DATA SUPPORT
		/**
		 * @private
		 * 
		 * */
		private var _waiting:Boolean;
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		[Bindable("externalDataPropertyChange")] 
		/**
		* A support property for binding to in the event of an external loading wait.
		* permits a simple binding to indicate that the wait is over
		*/

		public function get waiting():Boolean
		{
			return (_waiting==true);
		}
		public function set waiting(val:Boolean):void
		{
		  if (val != _waiting  )
		  {
			_waiting = val; 
			//support binding, but don't use propertyChange to avoid Degrafa redraws for no good reason
			dispatchEvent(new ExternalDataPropertyChangeEvent(ExternalDataPropertyChangeEvent.EXTERNAL_DATA_PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE , "waiting", !_waiting, _waiting, this))
		  }
		}
		/**
		 * @private
		 * 
		 * */		
		private var _correctionMatrix:Matrix;
		/**
		 * @private
		 * 
		 * */
		private var _vidStream:VideoStream;
		/**
		 * @private
		 * handles the ready state for a VideoStream as the source of a VideoFill
		 * @param	evt an ExternalDataAsset.STATUS_READY event
		 */
		private function bitmapChangeHandler(evt:Event):void {
			//TODO: consider redispatching from VideoFill	

			switch(evt.type)
			{
			case ExternalDataAsset.STATUS_READY:
				var oldValue:Object = bitmapData;
				if (_vidStream) {
					_vidStream.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,streamUpdater);
				}

				if (_alphaRequests)  {
					for (var _requester:Object in _alphaRequests){
						 _vidStream.deregisterCopyTarget(AlphaRequest(_alphaRequests[_requester]).alphaBitmap,true);
						
						_alphaRequests[_requester]=null;
						delete _alphaRequests[_requester];
					}
				}
				
				
				_vidStream=VideoStream(evt.target);	
				bitmapData = _vidStream.content;

				
				_vidStream.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,streamUpdater,false,0,true);
				//correction matrix is to allow for pixelmargins on the video bitmap (useful to avoid color bleeds on rotation and scaling
				_correctionMatrix=_vidStream.reverseOffset;

				initChange("source", oldValue, bitmapData, this);
				waiting = false;
			break;
			}
		}
		
		/**
		 * @private
		 * streamUpdater
		 * */		
		private function streamUpdater(e:PropertyChangeEvent):void{
			var property:String=e.property.toString();
			if (property=="content" || property=="pixelMargin") {
				var oldBMP:BitmapData=bitmapData;
				
				bitmapData = _vidStream.content;
				if (_alphaRequests)  {
					for (var _requester:Object in _alphaRequests){
						_vidStream.deregisterCopyTarget(AlphaRequest(_alphaRequests[_requester]).alphaBitmap,true);
						
						_alphaRequests[_requester]=null;
						delete _alphaRequests[_requester];
					}
				}
				if (property=="pixelMargin") _correctionMatrix=_vidStream.reverseOffset;
				//trigger a redraw
				initChange("source",oldBMP,bitmapData,this);
			//if (oldBMP) _vidStream.deregisterCopyTarget(oldBMP,true);
			}
		}
		
		/**
		 * Optional loadingLocation reference. Only relevant when a subsequent source assignment is made as 
		 * a url string. Using a LoadingLocation simplifies management of loading from external domains
		 * and is required if a crossdomain policy file is not in the default location (web root) and with the default name (crossdomain.xml)
		 * In actionscript, a loadingLocation assignment MUST precede a change in the url assigned to the source property
		 * If a LoadingLocation is being used, the url assigned to the source property MUST be relative to the base path
		 * defined in the LoadingLocation, otherwise loading will fail.
		 * If a LoadingLocation is NOT used and the source property assignment is an external domain url, then the crossdomain permissions
		 * must exist in the default location and with the default name crossdomain.xml, otherwise loading will fail.
		*/
		public function get loadingLocation():LoadingLocation { return _loadingLocation; }
		
		public function set loadingLocation(value:LoadingLocation):void 
		{
			if (value) 	_loadingLocation = value;
		} 
		
		[Bindable(event="propertyChange")]
		/**
		 * The source used for the Video fill.
		 * The source can either be a VideoStream instance or a url.<br/>
		 * NOT YET FUNCTIONING (BUT COMING):A url string, if used, can be either a relative url (relative within the local domain or relative to a LoadingLocation
		 * specified in the loadingLocation property) or absolute with no LoadingLocation (see loadingLocation property)
		 **/
		public function get source():Object { return bitmapData; }
		public function set source(value:Object):void {

			var oldValue:Object = bitmapData;
			var v:VideoStream;
			if (!value) {
				bitmapData = null;
				if (_vidStream) _vidStream.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,streamUpdater);
				if (oldValue!=null)	initChange("source", oldValue, null, this);
				return;
			}
			
			if (value is VideoStream) {
				v=VideoStream(value);
				if (v.content) {		
					bitmapData = value.content as BitmapData;
					if (_vidStream) {
						_vidStream.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,streamUpdater);
						_vidStream.removeEventListener(VideoStream.STATUS_READY, bitmapChangeHandler);
					}
					_vidStream=v;
					_vidStream.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,streamUpdater,false,0,true);
					initChange("source", oldValue, bitmapData, this);
					return;
				} else {
					//trace('waiting for READY:'+value.id)
					VideoStream(value).addEventListener(VideoStream.STATUS_READY, bitmapChangeHandler,false,0,true)
					waiting = true;
				return;
				}
			}
			else if (value is String)
			{
					//assume url string for a VideoStream
					//and wait for isInitialized to check/access loadingLocation mxml assignment
					//if not isInitialized after 5 ms, assume actionscript instantiation and not mxml (5 ms is arbitrary)
					if (!isInitialized && instantiationTimer) {
						instantiationTimer--;
						setTimeout(
							function():void	{source = value }, 1);
					} else {
						v = new VideoStream();
						//ExternalBitmapData.getUniqueInstance(value as String, _loadingLocation);
						v.url = value as String;
						source = v;
					}
					return;

			}
			else
			{
				//option:
				//source = null;
				//or:
				bitmapData = null;
				if (oldValue!=null)	initChange("source", oldValue, null, this);
				return;
			}
		}
		
		/**
		 * @private
		* reference to the requesting geometry
		**/		
		private var _requester:IGeometryComposition;
		/**
		 * @private
		* reference to the requesting geometry
		**/
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		/**
		 * @private
		 * _lastRect
		 * */			
		private var _lastRect:Rectangle;
		/**
		 * Provides access to the last rectangle that was relevant for this fill.
		 */
		public function get lastRectangle():Rectangle {
			return (_lastRect)?_lastRect.clone():null;
		}
		/**
		 * @private
		 * _lastContext
		 * */			
		private var _lastContext:Graphics;
		/**
		 * @private
		 * _lastArgs
		 * */	
		private var _lastArgs:Array = [];
		
		/**
		 * Provide access to the lastArgs array
		 */
		public function get lastArgs():Array {
			return _lastArgs;
		}
		
		/**
		 * Provides quick access to a cached function for restarting the last used fill either in the last used context, or, if a context is provided as an argument,
		 * then to an alternate context. If no last used context is available then this will do nothing;
		 */
		public function get restartFunction():Function {
			var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
			return function(alternate:Graphics = null):void {
					if (alternate) alternate.beginBitmapFill.apply(alternate, copy);
					else if (last) last.beginBitmapFill.apply(last,copy);
			}

		}
		
		/**
		* Begins the Videofill.
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void {
			
			if(!bitmapData) {
				return;
			}
			if (_coordType == "absolute") rc= new Rectangle(x,  y, width, height);
			else if (_coordType == "ratio") rc= new Rectangle(rc.x + x * rc.width, rc.y + y * rc.height, width * rc.width, height * rc.height);
			var template:BitmapData = bitmapData;
			var repeat:Boolean = true;
			var positionX:Number = 0; 
			var positionY:Number = 0;
			var deLetterBoxing:Boolean;
			
			var matrix:Matrix = _correctionMatrix? _correctionMatrix.clone():new Matrix();
			
			if (_vidStream && _vidStream.detectLetterBox && _vidStream.isLetterBoxed){
					matrix.translate(-_vidStream.letterBoxContent.x,-_vidStream.letterBoxContent.y);
					deLetterBoxing=true;
			}
			
			if (_insetFromStroke && _requester && (_requester as Geometry).stroke){
				var strokeoffset:uint;
				strokeoffset = int((_requester as Geometry).stroke.weight *0.5);

				// for a zero weight stroke, give it a 1 pixel offset
				if (!strokeoffset) strokeoffset = 1;
				rc = rc.clone(); 
				rc.inflate( -strokeoffset, -strokeoffset); //inset by strokeoffset - used for scaling if needed

			}
				var sx:Number;
				var sy:Number;
				var tx:Number;
				var ty:Number;
				var twidth:Number;
				var theight:Number;
			if (_targetSetting) 
			{
				repeat=false;
				switch(_targetSetting)
				{
					case 1:
						//targetbounds
						twidth= deLetterBoxing? _vidStream.letterBoxContent.width   :(template.width+matrix.tx*2);
						theight= deLetterBoxing? _vidStream.letterBoxContent.height   :(template.height+matrix.ty*2);
						sx = (rc.width)/twidth;
						sy = (rc.height)/theight;

						matrix.scale(sx,sy);
	
						matrix.translate(rc.x, rc.y);
						break;
					case 2:
						//if match targetboundsmaintainaspectratio, then centre it to the target bounds
						twidth= deLetterBoxing? _vidStream.letterBoxContent.width   :(template.width+matrix.tx*2);
						theight= deLetterBoxing? _vidStream.letterBoxContent.height   :(template.height+matrix.ty*2);
							
						sx = (rc.width)/twidth;
						sy = (rc.height)/theight;
						tx=(sx>sy)? (sx-sy)*twidth/2 :0;
						ty=(sy>sx)? (sy-sx)*theight/2 :0;
						
						if (sx>sy) sx=sy;
						if (sy>sx) sy=sx;

						matrix.scale(sx,sy);

						matrix.translate(rc.x+tx, rc.y+ty);

						break;
					case 3 :
						//center target
						 matrix.identity(); //don't need to compensate for the offset here
						 //no scaling, just positioning:
						//deLetterBoxing has no effect here as it is assumed that a letterbox is centered (this may not be true all the time perhaps)				 
						 matrix.translate(rc.x+(rc.width-bitmapData.width)/2,rc.y+(rc.height-bitmapData.height)/2)
						//allow repeating in both directions on this setting otherwise ignore.
						if (_repeatX == VideoFill.REPEAT && _repeatY == VideoFill.REPEAT) repeat = true;
						
						break;
					default:

						
					break;
				}
				
			}
				
		   else {
			 repeat = (((repeatX == VideoFill.REPEAT) && (repeatY == VideoFill.REPEAT)) || ((repeatX == VideoFill.STRETCH) && (repeatY == VideoFill.REPEAT)) || ((repeatX == VideoFill.REPEAT) && (repeatY == VideoFill.STRETCH)));
			// deal with stretching
			if(repeatX == VideoFill.STRETCH || repeatY == VideoFill.STRETCH) {
				twidth= deLetterBoxing? _vidStream.letterBoxContent.width   :(template.width+matrix.tx*2);
				theight= deLetterBoxing? _vidStream.letterBoxContent.height   :(template.height+matrix.ty*2);
				sx =  repeatX == STRETCH ?(rc.width)/twidth : 1;
				sy =  repeatY == STRETCH ? (rc.height)/theight :1;		
				if (sx!=1 || sy!=1)	matrix.scale(sx, sy);
			}
				matrix.translate(rc.x, rc.y);

            }
			
			
			if (_scaleX!=1 || _scaleY!=1) matrix.scale(_scaleX, _scaleY);
			if (_rotation) matrix.rotate(_rotation*(Math.PI/180));
	
			
			var regPoint:Point;
			var transformRequest:ITransform;
			var tempmat:Matrix;
			//handle layout transforms - only renderLayouts so far
			if (_requester && (_requester as Geometry).hasLayout) {
				var geom:Geometry = _requester as Geometry;
				if (geom._layoutMatrix) matrix.concat( geom._layoutMatrix);
			}
			if (_transform && ! _transform.isIdentity) {
					tempmat= new Matrix();
					regPoint = _transform.getRegPointForRectangle(rc);
					tempmat.translate(-regPoint.x,-regPoint.y);
					tempmat.concat(_transform.transformMatrix);
					tempmat.translate( regPoint.x,regPoint.y);
					matrix.concat(tempmat);
			}
			if (_requester && ((transformRequest  = (_requester as Geometry).transform) || (_requester as Geometry).transformContext)) {
				if (transformRequest) matrix.concat(transformRequest.getTransformFor(_requester));
				else matrix.concat((_requester as Geometry).transformContext);
				//remove the requester reference
			}

			var csAlpha:Number = CommandStack.currentAlpha;
			var alpha:Number = this.alpha;
			if (csAlpha != 1) { alpha *= csAlpha;	}
			
			//TODO: consider an approach keyed by alpha key as well so that if an alpha key version exists and it has another requester it is reused rather than reinstanced per requester
			if (alpha<0.997 && _requester){
				var key:int = alpha*255;
				var _alphaBitmapData:BitmapData;
				if (!_alphaRequests)_alphaRequests=new Dictionary(true);

				//this will not work as expected with repeaters that use alpha modifiers....but such use should be avoided in any case for videofill for performance reasons
				if (!_alphaRequests[_requester]){
					//make a quick copy:
					_alphaBitmapData = new BitmapData(template.width,template.height,true,key<<24);
					_alphaBitmapData.copyPixels(template,template.rect,new Point(0,0),_alphaBitmapData,new Point(0,0));
					//set up the recurring alpha request for the VideoStream
					_alphaRequests[_requester]=new AlphaRequest(_alphaBitmapData,new ColorTransform(1,1,1,key/255));
					_vidStream.registerCopyTarget(_alphaBitmapData,AlphaRequest(_alphaRequests[_requester]).colorTransform);
				} else {
					//update the colortransform on the existing alpharequest
					AlphaRequest(_alphaRequests[_requester]).colorTransform.alphaMultiplier=key/255;
					_alphaBitmapData=AlphaRequest(_alphaRequests[_requester]).alphaBitmap;
				}
				if (_vidStream.isPaused) _vidStream.requestPausedBitmapdataUpdate();
					template=_alphaBitmapData;

			} else if (_alphaRequests && _alphaRequests[_requester]) {
				//deregister and delete, because we're not using it
				_vidStream.deregisterCopyTarget(AlphaRequest(_alphaRequests[_requester]).alphaBitmap,true);
				_alphaRequests[_requester]=null;
				delete _alphaRequests[_requester];
			}
			
			_lastArgs.length = 0;
			_lastArgs[0] = template;
			_lastArgs[1] = matrix;
			_lastArgs[2] = repeat;
			_lastArgs[3] = smooth;
			_lastContext = graphics;
			_lastRect = rc;

			if (graphics) graphics.beginBitmapFill(template, matrix, repeat, smooth); 
			_requester = null;
		}
		
		/**
		* Ends the Video fill.
		**/
		public function end(graphics:Graphics):void {
			graphics.endFill();
		}
		
		/**
		 * @private
		 * _transform
		 * */			
		private var _transform:ITransform;		
		
		[Bindable(event="propertyChange")]
		/**
		* Defines the transform object that will be used for 
		* altering this VideoFill object.
		**/
		public function get transform():ITransform{
			return _transform;
		}
		public function set transform(value:ITransform):void{
			
			if(_transform != value){
				var oldValue:Object=_transform;
				if(_transform){
					if(_transform.hasEventManager){
						_transform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}		
				_transform = value;
				if(enableEvents){
					_transform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				//call local helper to dispatch event
				initChange("transform", oldValue, _transform, this);
			}
		}
		
		/**
		 * @private
		 * */	
		private var _alpha:Number=1;

		[Bindable(event="propertyChange")]
		/**
		 * an alpha property that will be applied to this fill.
		 **/
		public function get alpha():Number{
			return _alpha;
		}
		public function set alpha(value:Number):void{
			//clamp to valid range
			if (value<0) value=0;
			if (value>1) value=1;
			if(_alpha != value){		
				var oldValue:Number=_alpha;
				_alpha = value;
				//call local helper to dispatch event
				initChange("alpha", oldValue, _alpha, this);
			}
		}

		/**
		 * @private
		 * propertyChangeHandler
		 * */		
		private function propertyChangeHandler(event:PropertyChangeEvent):void
		{
			dispatchEvent(event);
		}

	}
}

//----------------------------------------
import flash.display.BitmapData;
import flash.geom.ColorTransform;


//local alpharequest objects
class AlphaRequest{
	/**
	 * @private
	 * */	
	public var colorTransform:ColorTransform;
	/**
	 * @private
	 * */
	public var alphaBitmap:BitmapData;
	/**
	 * @private
	 * */		
	public function AlphaRequest(b:BitmapData=null,c:ColorTransform=null):void{
		colorTransform=c;
		alphaBitmap=b;
	}
}