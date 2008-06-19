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
	import com.degrafa.core.Measure;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.transform.ITransform;
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
	import flash.utils.setTimeout;
	
	[DefaultProperty("source")]
	[Bindable(event="propertyChange")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("BitmapFill.png")]
	
	/**
	 * Used to fill an area on screen with a bitmap or other DisplayObject.
	 */
	public class GeometryFill extends DegrafaObject implements IGraphicsFill, IBlend{
		
		// static constants
		public static const NONE:String = "none";
		public static const REPEAT:String = "repeat";
		public static const SPACE:String = "space";
		public static const STRETCH:String = "stretch";
		
		// private variables
		private var shape:Shape;
		private var target:IGeometryComposition;
		private var bitmapData:BitmapData;

		
		
		public function GeometryFill(source:IGeometryComposition = null){
			if (source) this.source = source;
			shape = new Shape();
		}
		
		private var _blendMode:String="normal";
		[Inspectable(category="General", enumeration="normal,layer,multiply,screen,lighten,darken,difference,add,subtract,invert,alpha,erase,overlay,hardlight", defaultValue="normal")]
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
		* The horizontal origin for the Geometry fill.
		* The Geometry fill is offset so that this point appears at the origin.
		* Scaling and rotation of the GeometryFill are performed around this point.
		* @default 0
		*/
		private var _originX:Number = 0;
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
		* The vertical origin for the Geometry fill.
		* The Geometry fill is offset so that this point appears at the origin.
		* Scaling and rotation of the bitmap are performed around this point.
		* @default 0
		*/
		private var _originY:Number = 0;
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
		* How far the Geometry is horizontally offset from the origin.
		* This adjustment is performed after rotation and scaling.
		* @default 0
		*/
		private var _offsetX:Measure = new Measure();
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
		public function get offsetXUnit():String { return _offsetX.unit; }
		public function set offsetXUnit(value:String):void {
			if(_offsetX.unit != value) {
				initChange("offsetXUnit", _offsetX.unit, _offsetX.unit = value, this);
			}
		}
		
		
		/**
		 * How far the Geometry is vertically offset from the origin.
		 * This adjustment is performed after rotation and scaling.
		 * @default 0
		 */
		private var _offsetY:Measure = new Measure();
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
		public function set offsetYUnit(value:String):void {
			if(_offsetY.unit != value) {
				initChange("offsetYUnit", _offsetY.unit, _offsetY.unit = value, this);
			}
		}
		
		/**
		 * How the Geometry repeats horizontally.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatX:String = "repeat";
		[Inspectable(category="General", enumeration="none,repeat,space,stretch")]
		
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
		 * How the Geometry repeats vertically.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatY:String = "repeat";
		[Inspectable(category="General", enumeration="none,repeat,space,stretch")]
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
		* The number of degrees to rotate the Geometry.
		* Valid values range from 0.0 to 360.0.
		* @default 0
		*/
		private var _rotation:Number = 0;
		
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
		 * The percent to horizontally scale the Geometry when filling, from 0.0 to 1.0.
		 * If 1.0, the Geometry is filled at its natural size.
		 * @default 1.0
		 */
	 	private var _scaleX:Number = 1;
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
		 * The percent to vertically scale the Geometry when filling, from 0.0 to 1.0.
		 * If 1.0, the Geometry is filled at its natural size.
		 * @default 1.0
		 */
		private var _scaleY:Number = 1;
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
		[Inspectable(category="General", enumeration="true,false")]
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
		 * listener to handle the property changes from the source geometry
		 * @param	event
		 */
		private function geomListener(event:Event):void
		{
			var oldValue:Object = bitmapData;
			preRender();
			
			initChange("source", oldValue, bitmapData, this);
			//clear the old bitmapdata from memory
			if (oldValue) oldValue.dispose();
		}
		
		private function preRender():void
		{
			
			bitmapData = null;
			
			//target should never be null at this point..
			if(target != null)
			{
				var sourceBounds:Rectangle = target.bounds;
				
				if (!sourceBounds) {
					//seems to happen with GeometryComposition, force a preDraw:
					target.preDraw();
					sourceBounds = target.bounds;
				}
				//above code is now potentially redundant, using the display object for bounds...
				shape.graphics.clear();
				target.draw(shape.graphics, target.bounds);
				//getRect here returns the same as Degrafa Geom....but we'll use getBounds to include stroke widths
				sourceBounds = shape.getBounds(shape);
				bitmapData = new BitmapData(sourceBounds.width, sourceBounds.height, true, 0);
				bitmapData.draw(shape,new Matrix(1,0,0,1,-sourceBounds.x,-sourceBounds.y));
				
			}
			
		}
		
		/**
		 * The source used for the Geometry fill.
		 * An IGeometryComposition object
		 **/
		public function get source():IGeometryComposition { return target; }
		public function set source(value:IGeometryComposition):void {

			//no change
			if (target == value) return;
			//no value
			if (!value) {
				return;
			}	
			var oldValue:Object = bitmapData;
			//remove old listener
			if (target) {
				(target as DegrafaObject).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, geomListener);
			}
			target = value;
			//add new listener
			(target as DegrafaObject).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, geomListener);
			preRender();
			
			initChange("source", oldValue, bitmapData, this);
			//clear the old bitmapdata from memory
			if (oldValue) oldValue.dispose();
		}
		
		
		//reference to the requesting geometry
		private var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		
		public function begin(graphics:Graphics, rectangle:Rectangle):void {
		
			if(!bitmapData) {
				return;
			}
		
			// todo: optimize all this with cacheing
			var template:BitmapData = bitmapData;
			
			var repeat:Boolean = true;
			var positionX:Number = 0; 
			var positionY:Number = 0;
			
			var matrix:Matrix = new Matrix();
			

			matrix.translate(rectangle.x, rectangle.y);
			// deal with stretching
			if(repeatX == BitmapFill.STRETCH || repeatY == BitmapFill.STRETCH) {
				var stretchX:Number = repeatX == STRETCH ? rectangle.width : template.width;
				var stretchY:Number = repeatY == STRETCH ? rectangle.height : template.height;
				if(target) {
				//	target.width = stretchX;
				//	target.height = stretchY;
					template = new BitmapData(stretchX, stretchY, true, 0);
					// use sprite to render 9-slice Bitmap
					if(shape) { 
						template.draw(shape);
					} //else {
					//	template.draw(target);
					//}
				} else {
					matrix.scale(stretchX/template.width, stretchY/template.height);
				}
			}
			
			// deal with spacing
			if(repeatX == BitmapFill.SPACE || repeatY == BitmapFill.SPACE) {
				// todo: account for rounding issues here
				var spaceX:Number = repeatX == BitmapFill.SPACE ? Math.round((rectangle.width % template.width) / int(rectangle.width/template.width)) : 0;
				var spaceY:Number = repeatY == BitmapFill.SPACE ? Math.round((rectangle.height % template.height) / int(rectangle.height/template.height)) : 0;
				var pattern:BitmapData = new BitmapData(Math.round(spaceX+template.width), Math.round(spaceY+template.height), true, 0);
				pattern.copyPixels(template, template.rect, new Point(Math.round(spaceX/2), Math.round(spaceY/2)));
				template = pattern;
			} 
			
			if(repeatX == BitmapFill.NONE || repeatX == BitmapFill.REPEAT) {
				positionX = _offsetX.relativeTo(rectangle.width-template.width)
			}
			
			if(repeatY == BitmapFill.NONE || repeatY == BitmapFill.REPEAT) {
				positionY = _offsetY.relativeTo(rectangle.height-template.height)
			}

			
			
			// deal with repeating (or no-repeating rather)
			if(repeatX == BitmapFill.NONE || repeatY == BitmapFill.NONE) {
				var area:Rectangle = new Rectangle(1, 1, rectangle.width, rectangle.height);
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
			if (_transform) {
				var temp:Matrix = _transform.transformMatrix.clone();
				temp.translate(-template.width/2,-template.height/2)
				matrix.concat(temp);
				
			}
			matrix.scale(_scaleX, _scaleY);
			matrix.rotate(_rotation);
			matrix.translate(positionX, positionY);

			
			var transformRequest:ITransform;
			if (_requester && (transformRequest  = (_requester as Geometry).transform)) {
				matrix.concat(transformRequest.getTransformFor(_requester));
				//remove the requester reference
				_requester = null;
			}
			graphics.beginBitmapFill(template, matrix, repeat, true);
		}
		
		public function end(graphics:Graphics):void {
			graphics.endFill();
		}
		
		private var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* altering this bitmapfill object.
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
		
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			dispatchEvent(event);
		}
	}
}