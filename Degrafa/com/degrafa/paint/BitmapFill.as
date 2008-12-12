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
package com.degrafa.paint{
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IBlend;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.ITransformablePaint;
	import com.degrafa.core.Measure;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.transform.ITransform;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEventKind;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flash.utils.getDefinitionByName;
	import mx.events.PropertyChangeEvent;
	import com.degrafa.utilities.external.ExternalBitmapData;
	import com.degrafa.utilities.external.ExternalDataAsset;
	import com.degrafa.utilities.external.LoadingLocation;
	import com.degrafa.utilities.external.ExternalDataPropertyChangeEvent;
	import flash.utils.setTimeout;
	
	[DefaultProperty("source")]
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("BitmapFill.png")]
	
	/**
	 * Used to fill an area on screen with a bitmap or other DisplayObject.
	 */
	public class BitmapFill extends DegrafaObject implements IGraphicsFill, IBlend,ITransformablePaint{
		
		// static constants
		public static const NONE:String = "none";
		public static const REPEAT:String = "repeat";
		public static const SPACE:String = "space";
		public static const STRETCH:String = "stretch";
		
		// private variables
		private var sprite:Sprite;
		private var target:DisplayObject;
		private var bitmapData:BitmapData;
		private var _externalBitmapData:ExternalBitmapData;
		private var _loadingLocation:LoadingLocation;
		
		
		public function BitmapFill(source:Object = null,loc:LoadingLocation=null){
			this._loadingLocation = loc;
			this.source = source;
			
		}
		
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
		
		/**
		* The horizontal origin for the bitmap fill.
		* The bitmap fill is offset so that this point appears at the origin.
		* Scaling and rotation of the bitmap are performed around this point.
		* @default 0
		*/
		private var _originX:Number = 0;
		[Bindable(event="propertyChange")]
		public function get originX():Number { 
			return _originX; 
		}
		
		public function set originX(value:Number):void {
			
			if(_originX != value){
				
				var oldValue:Number=_originX;
				
				_originX = value;
				
				//call local helper to dispatch event	
				initChange("originX",oldValue,_originX,this);
				
			}
			
		}
		
		
		/**
		* The vertical origin for the bitmap fill.
		* The bitmap fill is offset so that this point appears at the origin.
		* Scaling and rotation of the bitmap are performed around this point.
		* @default 0
		*/
		private var _originY:Number = 0;
		[Bindable(event="propertyChange")]
		public function get originY():Number { 
			return _originY; 
		}
		public function set originY(value:Number):void {
			
			if(_originY != value){
				
				var oldValue:Number=_originY;
				
				_originY = value;
	
				//call local helper to dispatch event	
				initChange("originY",oldValue,_originY,this);
			}
		}
		
		
		/**
		* How far the bitmap is horizontally offset from the origin.
		* This adjustment is performed after rotation and scaling.
		* @default 0
		*/
		private var _offsetX:Measure = new Measure();
		[Bindable(event="propertyChange")]
		public function get offsetX():Number { 
			return _offsetX.value; 
		}
		
		public function set offsetX(value:Number):void {
			
			if(_offsetX.value != value){
				
				var oldValue:Number=value;
				
				_offsetX.value = value;
				
				//call local helper to dispatch event	
				initChange("offsetX",oldValue,_offsetX,this);
				
			}
			
		}
		
		/**
		 * The unit of measure corresponding to offsetX.
		 */
		[Bindable(event="propertyChange")]
		public function get offsetXUnit():String { return _offsetX.unit; }
		public function set offsetXUnit(value:String):void {
			if(_offsetX.unit != value) {
				initChange("offsetXUnit", _offsetX.unit, _offsetX.unit = value, this);
			}
		}
		
		
		/**
		 * How far the bitmap is vertically offset from the origin.
		 * This adjustment is performed after rotation and scaling.
		 * @default 0
		 */
		private var _offsetY:Measure = new Measure();
		[Bindable(event="propertyChange")]
		public function get offsetY():Number { 
			return _offsetY.value; 
		}
		
		public function set offsetY(value:Number):void {
			
			if(_offsetY.value != value){
				
				var oldValue:Number=value;
				
				_offsetY.value = value;
				
				//call local helper to dispatch event	
				initChange("offsetY",oldValue,_offsetY,this);
				
			}
			
		}
		
		/**
		 * The unit of measure corresponding to offsetY.
		 */
		public function get offsetYUnit():String { return _offsetY.unit; }
		[Bindable(event="propertyChange")]
		public function set offsetYUnit(value:String):void {
			if(_offsetY.unit != value) {
				initChange("offsetYUnit", _offsetY.unit, _offsetY.unit = value, this);
			}
		}
		
		/**
		 * How the bitmap repeats horizontally.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatX:String = "repeat";
		[Inspectable(category="General", enumeration="none,repeat,space,stretch")]
		[Bindable(event="propertyChange")]
		public function get repeatX():String{ 
			return _repeatX;
		}
		
		public function set repeatX(value:String):void {
			if(_repeatX != value){
				
				var oldValue:String=value;
				
				_repeatX = value;
				
				//call local helper to dispatch event	
				initChange("repeatX",oldValue,_repeatX,this);
				
			}
			
		}
		
		
		/**
		 * How the bitmap repeats vertically.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatY:String = "repeat";
		[Inspectable(category = "General", enumeration = "none,repeat,space,stretch")]
		[Bindable(event="propertyChange")]
		public function get repeatY():String{ 
			return _repeatY; 
		}
		
		public function set repeatY(value:String):void {
			if(_repeatY != value){
				
				var oldValue:String=value;
				
				_repeatY = value;
				
				//call local helper to dispatch event	
				initChange("repeatY",oldValue,_repeatY,this);
				
			}
			
		}
		
		
		/**
		* The number of degrees to rotate the bitmap.
		* Valid values range from 0.0 to 360.0.
		* @default 0
		*/
		private var _rotation:Number = 0;
		[Bindable(event="propertyChange")]
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
		
		
		/**
		 * The percent to horizontally scale the bitmap when filling, from 0.0 to 1.0.
		 * If 1.0, the bitmap is filled at its natural size.
		 * @default 1.0
		 */
	 	private var _scaleX:Number = 1;
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
		
		
		/**
		 * The percent to vertically scale the bitmap when filling, from 0.0 to 1.0.
		 * If 1.0, the bitmap is filled at its natural size.
		 * @default 1.0
		 */
		private var _scaleY:Number = 1;
		[Bindable(event="propertyChange")]
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
		
		
		/**
		 * A flag indicating whether to smooth the bitmap data when filling with it.
		 * @default false
		 */
		private var _smooth:Boolean = false; 
		[Inspectable(category = "General", enumeration = "true,false")]
		[Bindable(event="propertyChange")]
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
		
		//EXTERNAL BITMAP SUPPORT
		/**
		 * A support property for binding to in the event of an external loading wait.
		 * permits a simple binding to indicate that the wait is over
		 */
		private var _waiting:Boolean;
		[Bindable("externalDataPropertyChange")] 
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
		 * handles the ready state for an ExternalBitmapData as the source of a BitmapFill
		 * @param	evt an ExternalDataAsset.STATUS_READY event
		 */
		private function externalBitmapHandler(evt:Event):void {
	//TODO: consider passing all ExternalBitmapData events through here and redispatching from BitmapFill		
			switch(evt.type)
			{
			case ExternalDataAsset.STATUS_READY:
				var oldValue:Object = bitmapData;
				bitmapData = evt.target.content;
				initChange("source", oldValue, bitmapData, this);
				waiting = false;
			break;
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
		
		
		/**
		 * The source used for the bitmap fill.
		 * The fill can render from various graphical sources, including the following: 
		 * A Bitmap or BitmapData instance. 
		 * A class representing a subclass of DisplayObject. The BitmapFill instantiates the class and creates a bitmap rendering of it. 
		 * An instance of a DisplayObject. The BitmapFill copies it into a Bitmap for filling. 
		 * The name of a subclass of DisplayObject. The BitmapFill loads the class, instantiates it, and creates a bitmap rendering of it.
		 * An instance of an ExternalBitmapData to be loaded at runtime.
		 * A url string to either as a relative url (local domain or with a LoadingLocation) or absolute with no LoadingLocation (see loadingLocation property)
		 **/
		[Bindable(event="propertyChange")]
		public function get source():Object { return bitmapData; }
		public function set source(value:Object):void {

			var oldValue:Object = bitmapData;
			
			target = null;
			
			if (_externalBitmapData) {
				_externalBitmapData.removeEventListener(ExternalDataAsset.STATUS_READY, externalBitmapHandler);
				_externalBitmapData = null;
			}
			
			if (!value) {
				//set to null ?
				//todo: evaluate bitmapdata GC handling...*tricky* if fill is used outside defrafa geometry targets		
				//	if (bitmapData) bitmapData.dispose();
				bitmapData = null;
				if (oldValue!=null)	initChange("source", oldValue, null, this);
				return;
			}
			
			if (value is ExternalBitmapData) {
				_externalBitmapData = value as ExternalBitmapData;
				if (value.content) {		
					value = value.content;
				} else {
					value.addEventListener(ExternalDataAsset.STATUS_READY, externalBitmapHandler)
					waiting = true;
				return;
				}
			}
			
			if (value is BitmapData)
			{
				bitmapData = value as BitmapData;
				initChange("source", oldValue, bitmapData, this);
				return;
			}
			//var sprite:DisplayObject;
			if (value is Class)
			{
				//var cls:Class = value as Class;
				target = new value();
				//if(target is Bitmap) {
					sprite = new Sprite();
					sprite.addChild(target);
				//}
			}
			else if (value is Bitmap)
			{
				bitmapData = value.bitmapData;
				target = value as Bitmap;
			}
			else if (value is DisplayObject)
			{
				target = value as DisplayObject;
			}
			else if (value is String)
			{
				//is it a class name or an external url?
				try {
					var cls:Class = Class(getDefinitionByName(value as String));	
				} catch (e:Error)
				{
					//if its not a class name, assume url string for an ExternalBitmapData
					//and wait for isInitialized to check/access loadingLocation mxml assignment
					if (!isInitialized) {
						setTimeout(
							function():void
							{source = value }, 1);
							
					} else {
						source = ExternalBitmapData.getUniqueInstance(value as String, _loadingLocation);
					}
					return;
				}
				target = new cls();
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
			//original:	if (bitmapData == null && target != null)
			if( target != null)
			{
				//handle displayObjects with zero width and height
				if (!target.width || !target.height)
				{
					//check the bounds and if they're not empty use them.
					var tempRect:Rectangle = target.getBounds(target);

					if (!tempRect.isEmpty())
					{
						bitmapData = new BitmapData(Math.ceil(tempRect.width), Math.ceil(tempRect.height), true, 0);
						bitmapData.draw(target, new Matrix(1, 0, 0, 1, -tempRect.x, -tempRect.y));
					} else bitmapData = null;
				} else {

				bitmapData = new BitmapData(target.width, target.height, true, 0);
				bitmapData.draw(target);
				}
			}
			
			initChange("source", oldValue, bitmapData, this);
		}
		
		
		//reference to the requesting geometry
		private var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		
		private var _lastRect:Rectangle;
		/**
		 * Provides access to the last rectangle that was relevant for this fill.
		 */
		public function get lastRectangle():Rectangle {
			return (_lastRect)?_lastRect.clone():null;
		}
		private var _lastContext:Graphics;
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
		if (!_lastContext) {
			return function(alternate:Graphics = null):void { 
				//if (alternate) alternate.beginBitmapFill.apply(alternate, copy);
			}
			}
		else {
			return function(alternate:Graphics = null):void {
					if (alternate) alternate.beginGradientFill.apply(alternate, copy);
					else last.beginBitmapFill.apply(last,copy);
				}
			}
		}
		
		
		public function begin(graphics:Graphics, rc:Rectangle):void {
			
			if(!bitmapData) {
				return;
			}
			// todo: optimize all this with cacheing
			var template:BitmapData = bitmapData;
			
			var repeat:Boolean = true;
			var positionX:Number = 0; 
			var positionY:Number = 0;
			
			var matrix:Matrix = new Matrix();
			

			matrix.translate(rc.x, rc.y);
			// deal with stretching
			if(repeatX == BitmapFill.STRETCH || repeatY == BitmapFill.STRETCH) {
				var stretchX:Number = repeatX == STRETCH ? rc.width : template.width;
				var stretchY:Number = repeatY == STRETCH ? rc.height : template.height;
				if(target) {
					target.width = stretchX;
					target.height = stretchY;
					template = new BitmapData(stretchX, stretchY, true, 0);
					// use sprite to render 9-slice Bitmap
					if(sprite) { 
						template.draw(sprite);
					} else {
						template.draw(target);
					}
				} else {
					matrix.scale(stretchX/template.width, stretchY/template.height);
				}
			}
			
			// deal with spacing
			if(repeatX == BitmapFill.SPACE || repeatY == BitmapFill.SPACE) {
				// todo: account for rounding issues here
				var spaceX:Number = repeatX == BitmapFill.SPACE ? Math.round((rc.width % template.width) / int(rc.width/template.width)) : 0;
				var spaceY:Number = repeatY == BitmapFill.SPACE ? Math.round((rc.height % template.height) / int(rc.height/template.height)) : 0;
				var pattern:BitmapData = new BitmapData(Math.round(spaceX+template.width), Math.round(spaceY+template.height), true, 0);
				pattern.copyPixels(template, template.rect, new Point(Math.round(spaceX/2), Math.round(spaceY/2)));
				template = pattern;
			} 
			
			if(repeatX == BitmapFill.NONE || repeatX == BitmapFill.REPEAT) {
				positionX = _offsetX.relativeTo(rc.width-template.width)
			}
			
			if(repeatY == BitmapFill.NONE || repeatY == BitmapFill.REPEAT) {
				positionY = _offsetY.relativeTo(rc.height-template.height)
			}
				
			// deal with repeating (or no-repeating rather)
			if(repeatX == BitmapFill.NONE || repeatY == BitmapFill.NONE) {
				var area:Rectangle = new Rectangle(1, 1, rc.width, rc.height);
				var areaMatrix:Matrix = new Matrix();
				
				if(repeatX == BitmapFill.NONE) {
					area.width = template.width
				} else {
					areaMatrix.translate(positionX, 0)
					positionX = 0;
				}
				
				if(repeatY == BitmapFill.NONE) {
					area.height = template.height
				} else {
					areaMatrix.translate(0, positionY);
					positionY = 0;
				}
				
				// repeat onto a shape as needed
				var shape:Shape = new Shape(); // todo: cache for performance
				shape.graphics.beginBitmapFill(template, areaMatrix);
				shape.graphics.drawRect(0, 0, area.width, area.height);
				shape.graphics.endFill();
				
				// use the shape to create a new template (with transparent edges)
				template = new BitmapData(area.width+2, area.height+2, true, 0);
				template.draw(shape, new Matrix(1, 0, 0, 1, 1, 1), null, null, area);
				
				repeat = false;
			}
			
			matrix.translate( -_originX, -_originY);

			matrix.scale(_scaleX, _scaleY);
			matrix.rotate(_rotation*(Math.PI/180));
			matrix.translate(positionX, positionY);
			
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
				_requester = null;
			}
		//	CommandStack.currentFill = this;
			_lastArgs.length = 0;
			_lastArgs[0] = template;
			_lastArgs[1] = matrix;
			_lastArgs[2] = repeat;
			_lastArgs[3] = smooth;
			_lastContext = graphics;
			_lastRect = rc;
		//	CommandStack.currentFill = ["beginBitmapFill",[template, matrix, repeat, smooth]];
			graphics.beginBitmapFill(template, matrix, repeat, smooth);
		}
		
		public function end(graphics:Graphics):void {
			graphics.endFill();
		}
		
		private var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* altering this bitmapfill object.
		**/
		[Bindable(event="propertyChange")]
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
		
		private function propertyChangeHandler(event:PropertyChangeEvent):void
		{
			dispatchEvent(event);
		}

	}
}