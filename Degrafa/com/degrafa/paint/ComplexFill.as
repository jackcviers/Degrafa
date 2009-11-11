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
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.transform.ITransform;
	import flash.geom.Point;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	import mx.events.PropertyChangeEvent;
	import mx.graphics.IFill;
	
	[DefaultProperty("fills")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("ComplexFill.png")]
	
	/**
	 * Used to render multiple, layered IGraphicsFill objects as a single fill.
	 * This allows complex background graphics to be rendered with a single drawing pass.
	 */
	public class ComplexFill extends DegrafaObject implements IGraphicsFill, IBlend, ITransformablePaint{
		
		//*********************************************
		// Constructor
		//*********************************************
		
		public function ComplexFill(fills:Array = null){
			shape = new Shape();
			this.fills = fills;
			
		}
		
		
		//************************************
		// Static Methods
		//************************************
		
		/**
		 * Combines an IFill object with the target ComplexFill, merging ComplexFills if necessary.
		 */
		public static function add(value:IFill, target:ComplexFill):void {
			// todo: update this to account for events
			var complex:ComplexFill = target;
			if(complex == null) {
				complex = new ComplexFill();
			}
			if(complex.fills == null) {
				complex.fills = new Array();
			}
			if(value is ComplexFill) {
				for each(var fill:IFill  in (value as ComplexFill).fills) {
					complex.fills.push(fill);
					complex.refresh();
				}
			} else if(value != null) {
				complex.fills.push(value);
				complex.refresh();
			}
		}
		
		
		private var shape:Shape;
		private var bitmapData:BitmapData;
		
		
		private var _fills:Array; // property backing var
		private var fillsChanged:Boolean; // dirty flag
		
		
		//**************************************
		// Public Properties
		//**************************************
		
		private var _blendMode:String="normal";
		/**
		* Blend mode effect to use for this fill.
		* You may use any constant provided in the flash.display.BlendMode class.
		**/
		[Inspectable(category="General", enumeration="normal,layer,multiply,screen,lighten,darken,difference,add,subtract,invert,alpha,erase,overlay,hardlight", defaultValue="normal")]
		public function get blendMode():String { return _blendMode; }
		public function set blendMode(value:String):void {
			if(_blendMode != value) {
				initChange("blendMode", _blendMode, _blendMode = value, this);
			}
		}
		
		/**
		 * Array of IGraphicsFill Objects to be rendered
		 */
		[Inspectable(category="General", arrayType="com.degrafa.core.IGraphicsFill")]
		[ArrayElementType("com.degrafa.core.IGraphicsFill")]
		public function get fills():Array { return _fills; }
		public function set fills(value:Array):void {
			if(_fills != value) {
				removeFillListeners(_fills);
				addFillListeners(_fills = value);
				fillsChanged = true;
			}
		}
		
		
		
		private var _requester:IGeometryComposition;
		/**
		 * Reference to the requesting geometry.
		 **/
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
			return function(alternate:Graphics = null):void {
					if (alternate) alternate.beginBitmapFill.apply(alternate, copy);
					else if (last) last.beginBitmapFill.apply(last,copy);
				}
		}
		
		
		//*********************************************
		// Public Methods
		//*********************************************
		/**
		* Begins the complex fill.
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void {
			// todo: optimize with more cacheing
			if(rc.width > 0 && rc.height > 0 && _fills != null && _fills.length > 0) {
				if (_fills.length == 1) { // short cut
					if (_fills[0] is ITransformablePaint) (_fills[0] as ITransformablePaint).requester = _requester;
					(_fills[0] as IFill ).begin(graphics, rc);
				} else {
					var matrix:Matrix = new Matrix(1, 0, 0, 1, rc.x*-1, rc.y*-1);
					if(fillsChanged || bitmapData == null || Math.ceil(rc.width) != bitmapData.width || Math.ceil(rc.height) != bitmapData.height) { // cacheing
						bitmapData = new BitmapData(Math.ceil(rc.width), Math.ceil(rc.height), true, 0);
						var g:Graphics = shape.graphics;
						g.clear();
						var lastType:String;
						for each(var fill:IFill in _fills) {
							if(fill is IBlend) {
								if(lastType == "fill") {
									bitmapData.draw(shape, matrix,null,null,null,true);
								}
								g.clear();
								fill.begin(g, rc);
								g.drawRect(rc.x, rc.y, rc.width, rc.height);
								fill.end(g);
								bitmapData.draw(shape, matrix, null, (fill as IBlend).blendMode,null,true);
								lastType = "blend";
							} else {
								fill.begin(g, rc);
								g.drawRect(rc.x, rc.y, rc.width, rc.height);
								fill.end(g);
								lastType = "fill";
							}
						}
						
						if(lastType == "fill") {
							bitmapData.draw(shape, matrix);
						}
						fillsChanged = false;
					}
					matrix.invert();
						//handle layout transforms - only renderLayouts so far
			if (_requester && (_requester as Geometry).hasLayout) {
					var geom:Geometry = _requester as Geometry;
					if (geom._layoutMatrix) matrix.concat( geom._layoutMatrix);
				}
			
			if (_transform && ! _transform.isIdentity) {
					var regPoint:Point ;
					var tempmat:Matrix = new Matrix();
					regPoint = _transform.getRegPointForRectangle(rc);
					tempmat.translate(-regPoint.x,-regPoint.y);
					tempmat.concat(_transform.transformMatrix);
					tempmat.translate( regPoint.x,regPoint.y);
					matrix.concat(tempmat);
				}
				
			var transformRequest:ITransform;
			if (_requester && ((transformRequest  = (_requester as Geometry).transform) || (_requester as Geometry).transformContext)) {
				if (transformRequest) matrix.concat(transformRequest.getTransformFor(_requester));
				else matrix.concat((_requester as Geometry).transformContext);
				//remove the requester reference
				_requester = null;
			}

					_lastArgs.length = 0;
					_lastArgs[0] = bitmapData;
					_lastArgs[1] = matrix;
					_lastRect = rc;
					if (graphics) graphics.beginBitmapFill(bitmapData, matrix);
				}
			}
		}
		
		/**
		* Ends the complex fill.
		**/
		public function end(graphics:Graphics):void {
			graphics.endFill();
		}
		
		/**
		* Refreshs the complex fill.
		**/
		public function refresh():void {
			fillsChanged = true;
		}
		
		
		protected var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* altering this gradientfill object.
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
				initChange("transform",oldValue,_transform,this);
			}
			
		}
		
		//********************************************
		// Private Methods
		//********************************************
		
		private function addFillListeners(fills:Array):void {
			var fill:IGraphicsFill;
			for each(fill in fills) {
				if(fill is IGraphicsFill) {
					(fill as IGraphicsFill).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler, false, 0, true);
				}
			}
		}
		
		private function removeFillListeners(fills:Array):void {
			var fill:IGraphicsFill;
			for each(fill in fills) {
				if(fill is IGraphicsFill) {
					(fill as IGraphicsFill).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler, false);
				}
			}
		}
		
		
		//******************************************
		// Event Handlers
		//******************************************
		
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			refresh();
			dispatchEvent(event);
		}
		
	}
}