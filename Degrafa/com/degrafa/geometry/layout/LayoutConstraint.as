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

//Based on code from Trevor McCauley, www.senocular.com 

package com.degrafa.geometry.layout
{
	import com.degrafa.core.DegrafaObject;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	[IconFile("LayoutConstraint.png")]
	/**
	* Defines constraint based layout.
	**/
	public class LayoutConstraint extends DegrafaObject implements ILayout
	{
		//The rectangle we are laying out to. Parent Geometry bounds or target bounds
		//depending
		private var container:Rectangle;
		
		public function LayoutConstraint(){}
				
		/**
		* Specifies whether this layout object has changed and is to be 
		* recalculated on the next cycle. 
		**/
		private var _invalidated:Boolean;
		public function get invalidated():Boolean{
			return _invalidated;
		}
		public function set invalidated(value:Boolean):void{
			_invalidated = value;
		}
		 
		
		private var _x:Number;
		[Bindable]
		/**
		* Defines the x location (top left) of the layout.
		*/
		public function get x():Number {
			if(!_x){return 0;}
			return _x;
		}
		public function set x(value:Number):void {
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		private var _minX:Number;
		[Bindable]
		/**
		* The minimum x location that can be applied
		* to the layout.
		*/
		public function get minX():Number {
			return _minX;
		}
		public function set minX(value:Number):void {
			if(_minX != value){
				_minX = value;
				invalidated = true;
			}
		}
		
		private var _maxX:Number;
		[Bindable]
		/**
		* The maximum x location that can be applied
		* to the layout.
		*/
		public function get maxX():Number {
			return _maxX;
		}
		public function set maxX(value:Number):void {
			if(_maxX != value){
				_maxX = value;
				invalidated = true;
			}
		}


		private var _y:Number;
		[Bindable]
		/**
		* Defines the y location (top left) of the layout.
		*/
		public function get y():Number {
			if(!_y){return 0;}
			return _y;
		}
		public function set y(value:Number):void {
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
		private var _minY:Number;
		[Bindable]
		/**
		* The minimum y location that can be applied
		* to the layout.
		*/
		public function get minY():Number {
			return _minY;
		}
		public function set minY(value:Number):void {
			if(_minY != value){
				_minY = value;
				invalidated = true;
			}
		}
		
		private var _maxY:Number;
		[Bindable]
		/**
		* The maximum y location that can be applied
		* to the layout.
		*/
		public function get maxY():Number {
			return _maxY;
		}
		/** */
		public function set maxY(value:Number):void {
			if(_maxY != value){
				_maxY = value;
				invalidated = true;
			}
		}

  		
  		private var _width:Number;
  		[PercentProxy("percentWidth")]
  		[Bindable]
		/**
		* Defines the width of the layout.
		* Once left (or percentLeft) or right (or percentRight)
		* is set, the width value no longer applies. If
		* percentWidth exists when width is set, percentWidth
		* will be overridden and be given a value of NaN. This 
		* property also accepts a percent value for example 75%.
		*/
		public function get width():Number {
			if(!_width){return 0;}
			return _width;
		}
		public function set width(value:Number):void {
			if(_width != value){
				_width = value;
				_percentWidth = NaN;
				invalidated = true;
			}
		}
  		
  		private var _minWidth:Number;
  		[Bindable]
		/**
		* The minimum width that can be applied
		* to the layout.
		*/
		public function get minWidth():Number {
			return _minWidth;
		}
		/** */
		public function set minWidth(value:Number):void {
			if(_minWidth != value){
				_minWidth = value;
				invalidated = true;
			}
		}
		private var _maxWidth:Number;
		[Bindable]
		/**
		* The maximum width that can be applied
		* to the layout.
		*/
		public function get maxWidth():Number {
			return _maxWidth;
		}
		public function set maxWidth(value:Number):void {
			if(_maxWidth != value){
				_maxWidth = value;
				invalidated = true;
			}
		}
  		
  		private var _percentWidth:Number;
  		[Bindable]
		/**
		* When set, the width of the layout will be
		* set as the value of this property multiplied
		* by the containing width.
		* A value of 0 represents 0% and 1 represents 100%
		* a value of 75 represents 75%.
		*/
		public function get percentWidth():Number {
			if(!_percentWidth){return NaN;}
			return _percentWidth;
		}
		public function set percentWidth(value:Number):void {
			if(_percentWidth != value){
				_percentWidth = value;
				invalidated = true;
			}
		}


  		private var _height:Number;
  		[PercentProxy("percentHeight")]
  		[Bindable]
		/**
		* Defines the height of the layout boundary.
		* Once top (or percentTop) or bottom (or percentBottom)
		* is set, the width value no longer applies. If
		* percentWidth exists when width is set, percentWidth
		* will be overridden and be given a value of NaN. This 
		* property also accepts a percent value for example 75%.
		*/
		public function get height():Number {
			if(!_height){return 0;}
			return _height;
		}
		public function set height(value:Number):void {
			if(_height != value){
				_height = value;
				_percentHeight = NaN;
				invalidated = true;
			}
		}
		
		private var _minHeight:Number;
		[Bindable]
		/**
		* The minimum height that can be applied
		* to the layout.
		*/
		public function get minHeight():Number {
			return _minHeight;
		}
		public function set minHeight(value:Number):void {
			if(_minHeight != value){
				_minHeight = value;
				invalidated = true;
			}
		}
		private var _maxHeight:Number;
		[Bindable]
		/**
		* The maximum height that can be applied
		* to the layout.
		*/
		public function get maxHeight():Number {
			return _maxHeight;
		}
		public function set maxHeight(value:Number):void {
			if(_maxHeight != value){
				_maxHeight = value;
				invalidated = true;
			}
		}
		
		private var _percentHeight:Number;
		[Bindable]
		/**
		* When set, the height of the layout will be
		* set as the value of this property multiplied
		* by the containing height.
		* A value of 0 represents 0% and 1 represents 100%
		* a value of 75 represents 75%.
		*/
		public function get percentHeight():Number {
			if(!_percentHeight){return NaN;}
			return _percentHeight;
		}
		public function set percentHeight(value:Number):void {
			if(_percentHeight != value){
				_percentHeight = value;
				invalidated = true;
			}
		}
		
  		private var _top:Number;
  		[Bindable]
		/**
		* When set, the top of the layout will be located
		* offset from the top of it's parent.
		*/
		public function get top():Number {
			if(!_top){return NaN;}
			return _top;
		}
		public function set top(value:Number):void {
			if(_top != value){
				_top = value;
				invalidated = true;
			}
		}

		private var _right:Number;
		[Bindable]
		/**
		* When set, the right of the layout will be located
		* offset by the value of this property multiplied
		* by the containing width.
		*/
		public function get right():Number {
			if(!_right){return NaN;}
			return _right;
		}
		public function set right(value:Number):void {
			if(_right != value){
				_right = value;
				invalidated = true;
			}
		}
  		
  		private var _bottom:Number;
  		[Bindable]
		/**
		* When set, the bottom of the layout will be located
		* offset from the bottom of it's parent.
		*/
		public function get bottom():Number {
			if(!_bottom){return NaN;}
			return _bottom;
		}
		public function set bottom(value:Number):void {
			if(_bottom != value){
				_bottom = value;
				invalidated = true;
			}
		}
  		
  		private var _left:Number;
  		[Bindable]
		/**
		 * When set, the left of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing width.
		 */
		public function get left():Number {
			if(!_left){return NaN;}
			return _left;
		}
		public function set left(value:Number):void {
			if(_left != value){
				_left = value;
				invalidated = true;
			}
		}
		
		private var _horizontalCenter:Number;
		[Bindable]
		/**
		 * When set, if left or right is not set, the layout
		 * will be centered horizontally offset by the numeric
		 * value of this property.
		 */
		public function get horizontalCenter():Number {
			if(!_horizontalCenter){return NaN;}
			return _horizontalCenter;
		}
		public function set horizontalCenter(value:Number):void {
			if(_horizontalCenter != value){
				_horizontalCenter = value;
				invalidated = true;
			}
		}
		
		private var _verticalCenter:Number;
		[Bindable]
		/**
		* When set, if top or bottom is not set, the layout
		* will be centered vertically offset by the numeric
		* value of this property.
		*/
		public function get verticalCenter():Number {
			if(!_verticalCenter){return NaN;}
			return _verticalCenter;
		}
		public function set verticalCenter(value:Number):void {
			if(_verticalCenter != value){
				_verticalCenter = value;
				invalidated = true;
			}
		}
		

		private var _maintainAspectRatio:Boolean=false;
		[Bindable]
		/**
		* When true, the size of the layout will always
		* maintain an aspect ratio relative to the ratio
		* of the current width and height properties, even
		* if those properties are not in control of the
		* height and width of the layout.
		*/
		[Inspectable(category="General", enumeration="true,false")]
		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}
		public function set maintainAspectRatio(value:Boolean):void {
			if(_maintainAspectRatio != value){
				_maintainAspectRatio = value;
				invalidated = true;
			}
		}
		
		private var _targetCoordinateSpace:DisplayObject;
		[Bindable]
		/**
		* The display object that defines the coordinate system to use.
		**/
		public function get targetCoordinateSpace():DisplayObject{
			if(!_targetCoordinateSpace){return null;}
			return _targetCoordinateSpace;
		}
		public function set targetCoordinateSpace(value:DisplayObject):void {
			if(_targetCoordinateSpace != value){
				_targetCoordinateSpace = value;
				invalidated = true;
			}
		}
		
		/**
		* The final offset x value of the layout.
		**/
		public var xOffset:Number=0;
		
		/**
		* The final offset y value of the layout.
		**/
		public var yOffset:Number=0;
		
		/**
		* The minimum x of the objects bounds befor layout.
		*/
		public var xMin:Number;
		
		/**
		* The minimum y of the objects bounds befor layout.
		*/
		public var yMin:Number;
		
		/**
		* The maximum x of the objects bounds befor layout.
		*/
		public var xMax:Number;
		
		/**
		* The maximum y of the objects bounds befor layout.
		*/
		public var yMax:Number;
		
		/**
		* The calculated x ratio by which to multiply points at render time.
		*/
		public var xMultiplier:Number; 
		
		/**
		* The calculated y ratio by which to multiply points at render time.
		*/
		public var yMultiplier:Number;
				
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:LayoutConstraint):void{
			if (!_x){_x = value.x;}
			if (!_minX){_minX = value.minX;}
			if (!_maxX){_maxX = value.maxX;}
						
			if (!_y){_y = value.y;}
			if (!_minY){_minY = value.minY;}
			if (!_maxY){_maxY = value.maxY;}
			
			if (!_width){_width = value.width;}
			if (!_minWidth){_minWidth = value.minWidth;}
			if (!_maxWidth){_maxWidth = value.maxWidth;}
			if (!_percentWidth){_percentWidth = value.percentWidth;}
			
			if (!_height){_height = value.height;}
			if (!_minHeight){_minHeight = value.minHeight;}
			if (!_maxHeight){_maxHeight = value.maxHeight;}
			if (!_percentHeight){_percentHeight = value.percentHeight;}
			
			if (!_top){_top = value.top;}
			if (!_right){_right = value.right;}
			if (!_bottom){_bottom = value.bottom;}
			if (!_left){_left = value.left;}
			
			if (!_horizontalCenter){_horizontalCenter = value.horizontalCenter;}
			if (!_verticalCenter){_verticalCenter = value.verticalCenter;}
			
			if (!_maintainAspectRatio){_maintainAspectRatio = value.maintainAspectRatio;}
			if (!_targetCoordinateSpace){_targetCoordinateSpace = value.targetCoordinateSpace;}
			
			invalidated = true;
		}
		
		private var _layoutRectangle:Rectangle = new Rectangle();
		/**
		* The resulting calculated read only rectangle from which to 
		* layout/modify the geometry.
		**/
		public function get layoutRectangle():Rectangle {
			return _layoutRectangle.clone();
		}
				
		/**
		* Given a parent and a child bounds rectangle calculates the optimal layout
		* based on set properties.
		**/
		public function computeLayoutRectangle(childBounds:Rectangle,parentBounds:Rectangle):Rectangle{
			
			if(parentBounds.isEmpty()){return null;}
			
			//***Calculate the destination rectangle
			
			//the layout rectangle is the same as the childBounds rectangle and is modified in the 
			//calculateLayoutRectangle method
			_layoutRectangle = childBounds.clone();
			
			//Setup the size and position is none set already
			if(!_width){
				_width=(layoutRectangle.width)? layoutRectangle.width:1;
			}
			
			if(!_height){
				_height=(layoutRectangle.height)? layoutRectangle.height:1;
			}
			
			if(isNaN(_x)){
				_x=(layoutRectangle.x)? layoutRectangle.x:0;
			}
			
			if(isNaN(_y)){
				_y=(layoutRectangle.y)? layoutRectangle.y:0;
			}
			
			//retrive the bounds we need to layout to
			container = parentBounds.clone(); 
					 			 	
		 	//get the final rectangle we need to layout to and 
		 	//base our point calcualtions on
		 	calculateLayoutRectangle();
		 			 			 	
		 	return layoutRectangle;
		 				
		}
		
		//Performs the final calculation. 
		private function calculateLayoutRectangle():void{
			
			// reusable value
			var currValue:Number;
			
			// horizontal placement
			var noLeft:Boolean = isNaN(_left);
			var noRight:Boolean = isNaN(_right);
			var noHorizontalCenter:Boolean = isNaN(_horizontalCenter);
			var alignedLeft:Boolean = !Boolean(noLeft);
			var alignedRight:Boolean = !Boolean(noRight);
			
			if (container){
				if (!alignedLeft && !alignedRight) {
					if (noHorizontalCenter) { 
						// normal
						_layoutRectangle.width = isNaN(_percentWidth) ? _width : (_percentWidth>1)? (_percentWidth/100)*container.width:_percentWidth *container.width;
						_layoutRectangle.x = isNaN(_x)? 0:_x + container.left;
					}else{ 
						// centered
						_layoutRectangle.width = isNaN(_percentWidth) ? _width : (_percentWidth>1)? (_percentWidth/100)*container.width:_percentWidth *container.width;
						_layoutRectangle.x = _horizontalCenter - _layoutRectangle.width/2 + container.left + container.width/2;
					}
					
				}else if (!alignedRight) { 
					// left
					_layoutRectangle.width = isNaN(_percentWidth) ? _width : (_percentWidth>1)? (_percentWidth/100)*container.width:_percentWidth *container.width;
					_layoutRectangle.x = container.left + _left;
				}else if (!alignedLeft) { 
					// right
					_layoutRectangle.width = isNaN(_percentWidth) ? _width : (_percentWidth>1)? (_percentWidth/100)*container.width:_percentWidth *container.width;
					_layoutRectangle.x = container.right - _right - _layoutRectangle.width;
				}else{ 
					// right and left (boxed)
					_layoutRectangle.right = container.right - _right;
					_layoutRectangle.left = container.left + _left;
				}
			}
			
			// apply limits
			if (!isNaN(_minX)){
				currValue = container.x + _minX;
				if (currValue > _layoutRectangle.x) _layoutRectangle.x = currValue;
			}
			if (!isNaN(_maxX)){
				currValue = container.x + _maxX;
				if (currValue < _layoutRectangle.x) _layoutRectangle.x = currValue;
			}
			
			currValue = 0;
			if (!isNaN(_minWidth) && _minWidth > _layoutRectangle.width){
				currValue = _layoutRectangle.width - _minWidth;
			}else if (!isNaN(_maxWidth) && _maxWidth < _layoutRectangle.width){
				currValue = _layoutRectangle.width - _maxWidth;
			}
			
			if (currValue){ // if change in width, adjust position
				if (!alignedLeft) {
					if (alignedRight) { // right 
						_layoutRectangle.x += currValue;
					}else if (!noHorizontalCenter) { // centered
						_layoutRectangle.x += currValue/2;
					}
				}else if (alignedLeft && alignedRight) { // boxed
					_layoutRectangle.x += currValue/2;
				}
				// fit width
				_layoutRectangle.width -= currValue;
			}
			
			// vertical placement
			var noTop:Boolean = isNaN(_top);
			var noBottom:Boolean = isNaN(_bottom);
			var noVerticalCenter:Boolean = isNaN(_verticalCenter);
			var alignedTop:Boolean = !Boolean(noTop);
			var alignedBottom:Boolean = !Boolean(noBottom);
			
			if (container){
				if (!alignedTop && !alignedBottom) {
					
					if (noVerticalCenter) { 
						// normal
						_layoutRectangle.height = isNaN(_percentHeight) ? _height : (_percentHeight>1)? (_percentHeight/100)*container.height:_percentHeight *container.height;
						_layoutRectangle.y = isNaN(_y)? 0:_y + container.top;
						
					}else{ 
						// centered
						_layoutRectangle.height = isNaN(_percentHeight) ? _height : (_percentHeight>1)? (_percentHeight/100)*container.height:_percentHeight *container.height;
						_layoutRectangle.y = _verticalCenter - _layoutRectangle.height/2 + container.top + container.height/2;
					}
					
				}else if (!alignedBottom) { 
					// top
					_layoutRectangle.height = isNaN(_percentHeight) ? _height : (_percentHeight>1)? (_percentHeight/100)*container.height:_percentHeight *container.height;
					_layoutRectangle.y = container.top + _top;
					
				}else if (!alignedTop) { 
					// bottom
					_layoutRectangle.height = isNaN(_percentHeight) ? _height : (_percentHeight>1)? (_percentHeight/100)*container.height:_percentHeight *container.height;
					_layoutRectangle.y = container.bottom - _bottom - _layoutRectangle.height;
					
				}else{ 
					// top and bottom (boxed)
					_layoutRectangle.bottom = container.bottom - _bottom;
					_layoutRectangle.top = container.top + _top;
				}
			}
			
			// apply limits
			if (!isNaN(_minY)){
				currValue = container.y + _minY;
				if (currValue > _layoutRectangle.y) _layoutRectangle.y = currValue;
			}
			if (!isNaN(_maxY)){
				currValue = container.y + _maxY;
				if (currValue < _layoutRectangle.y) _layoutRectangle.y = currValue;
			}
			
			currValue = 0;
			if (!isNaN(_minHeight) && _minHeight > _layoutRectangle.height){
				currValue = _layoutRectangle.height - _minHeight;
			}else if (!isNaN(_maxHeight) && _maxHeight < _layoutRectangle.height){
				currValue = _layoutRectangle.height - _maxHeight;
			}
			
			if (currValue){ // if change in height, adjust position
				if (!alignedTop) {
					if (alignedBottom) { // bottom 
						_layoutRectangle.y += currValue;
					}else if (!noVerticalCenter) { // centered
						_layoutRectangle.y += currValue/2;
					}
				}else if (alignedTop && alignedBottom) { // boxed
					_layoutRectangle.y += currValue/2;
				}
				// fit height
				_layoutRectangle.height -= currValue;
			}

			
			
			// maintaining aspect if applicable; use width and height for aspect
			// only apply if one dimension is static and the other dynamic
			// maintaining aspect has highest priority so it is evaluated last
			if (_maintainAspectRatio && _height && _width) {
								
				var sizeRatio:Number = _height/_width;
				var rectRatio:Number = _layoutRectangle.height/_layoutRectangle.width;
				
				if (sizeRatio > rectRatio) { 
					// width
					currValue = _layoutRectangle.height/sizeRatio;
					
					if (!alignedLeft) {
						if (alignedRight) { 
							// right 
							_layoutRectangle.x += _layoutRectangle.width - currValue;
						}else if (!(noHorizontalCenter)) { 
							// centered
							_layoutRectangle.x += (_layoutRectangle.width - currValue)/2;
						}
					}else if (alignedLeft && alignedRight) { 
						// boxed
						_layoutRectangle.x += (_layoutRectangle.width - currValue)/2;
					}
					_layoutRectangle.width = currValue;
					
				}else if (sizeRatio < rectRatio) { 
					// height
					currValue = _layoutRectangle.width * sizeRatio;
					
					if (!alignedTop) {
						if (alignedBottom) { 
							// bottom 
							_layoutRectangle.y += _layoutRectangle.height - currValue;
						}else if (!(noVerticalCenter)) { 
							// centered
							_layoutRectangle.y += (_layoutRectangle.height - currValue)/2;
						}
					}else if (alignedTop && alignedBottom) { 
						// boxed
						_layoutRectangle.y += (_layoutRectangle.height - currValue)/2;
					}
					_layoutRectangle.height = currValue;
				}
			}
		}
	}
}