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
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.transform.ITransform;
	
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
	public class ComplexFill extends DegrafaObject implements IGraphicsFill, IBlend{
		
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
		
		private var _blendMode:String;
		private var _fills:Array; // property backing var
		private var fillsChanged:Boolean; // dirty flag
		
		
		//**************************************
		// Public Properties
		//**************************************
		
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
		
		
		//reference to the requesting geometry
		private var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		
		//*********************************************
		// Public Methods
		//*********************************************
		
		public function begin(graphics:Graphics, rectangle:Rectangle):void {
			// todo: optimize with more cacheing
			if(rectangle.width > 0 && rectangle.height > 0 && _fills != null && _fills.length > 0) {
				if (_fills.length == 1) { // short cut
					if (_fills[0] is IGraphicsFill) (_fills[0] as IGraphicsFill).requester = _requester;
					(_fills[0] as IFill ).begin(graphics, rectangle);
				} else {
					var matrix:Matrix = new Matrix(1, 0, 0, 1, rectangle.x*-1, rectangle.y*-1);
					if(fillsChanged || bitmapData == null || Math.ceil(rectangle.width) != bitmapData.width || Math.ceil(rectangle.height) != bitmapData.height) { // cacheing
						bitmapData = new BitmapData(Math.ceil(rectangle.width), Math.ceil(rectangle.height), true, 0);
						var g:Graphics = shape.graphics;
						g.clear();
						var lastType:String;
						for each(var fill:IFill in _fills) {
							if(fill is IBlend) {
								if(lastType == "fill") {
									bitmapData.draw(shape, matrix,null,null,null,true);
								}
								g.clear();
								fill.begin(g, rectangle);
								g.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
								fill.end(g);
								bitmapData.draw(shape, matrix, null, (fill as IBlend).blendMode,null,true);
								lastType = "blend";
							} else {
								fill.begin(g, rectangle);
								g.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
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
					var transformRequest:ITransform;
					if (_requester && (transformRequest  = (_requester as Geometry).transform)) {
						matrix.concat(transformRequest.getTransformFor(_requester));
						//remove the requester reference
						_requester = null;
					}
					graphics.beginBitmapFill(bitmapData, matrix);
				}
			}
		}
		
		public function end(graphics:Graphics):void {
			graphics.endFill();
		}
		
		public function refresh():void {
			fillsChanged = true;
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