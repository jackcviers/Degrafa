package com.degrafa.geometry.layout
{
	import com.degrafa.core.DegrafaObject;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class StandardLayout extends DegrafaObject implements ILayout
	{
		//The rectangle we are laying out to. Parent Geometry bounds or target bounds
		//depending
		private var container:Rectangle;
		
		public function StandardLayout(){}
		
		
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
		
		public function get isInvalidated():Boolean{
			return _invalidated;
		} 
		
		private var _x:Number;
		/**
		* Doc
		**/
		public function get x():Number {
			return _x;
		}
		public function set x(value:Number):void {
			_x = value;
		}
		
		private var _y:Number;
		/**
		* Doc
		**/
		public function get y():Number {
			return _y;
		}
		public function set y(value:Number):void {
			_y = value;
		}
  		
  		private var _width:Number;
		/**
		* Doc
		**/
		public function get width():Number {
			return _width;
		}
		public function set width(value:Number):void {
			_width = value;
		}
  		
  		private var _percentWidth:Number;
		/**
		 * When set, the width of the layout will be
		 * set as the value of this property multiplied
		 * by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentWidth():Number {
			return _percentWidth;
		}
		/** */
		public function set percentWidth(value:Number):void {
			_percentWidth = value;
		}


  		private var _height:Number;
		/**
		* Doc
		**/
		public function get height():Number {
			return _height;
		}
		public function set height(value:Number):void {
			_height = value;
		}
		
		private var _percentHeight:Number;
		/**
		 * When set, the height of the layout will be
		 * set as the value of this property multiplied
		 * by the parent height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentHeight():Number {
			return _percentHeight;
		}
		/** */
		public function set percentHeight(value:Number):void {
			_percentHeight = value;
		}
		
  		private var _top:Number;
		/**
		* Doc
		**/
		public function get top():Number {
			return _top;
		}
		public function set top(value:Number):void {
			_top = value;
		}

		private var _right:Number;
		/**
		* Doc
		**/
		public function get right():Number {
			return _right;
		}
		public function set right(value:Number):void {
			_right = value;
		}
  		
  		private var _bottom:Number;
		/**
		* Doc
		**/
		public function get bottom():Number {
			return _bottom;
		}
		public function set bottom(value:Number):void {
			_bottom = value;
		}
  		
  		private var _left:Number;
		/**
		* Doc
		**/
		public function get left():Number {
			return _left;
		}
		public function set left(value:Number):void {
			_left = value;
		}
		
		private var _horizontalCenter:Number;
		/**
		 * If set and left or right are not set then the resulting 
		 * geometry will be centered horizontally offset by the value. 
		 */
		public function get horizontalCenter():Number {
			return _horizontalCenter;
		}
		public function set horizontalCenter(value:Number):void {
			_horizontalCenter = value;
		}
		
		private var _verticalCenter:Number;
		/**
		 * If set and top or bottom are not set then the resulting 
		 * geometry will be centered vertically offset by the value. 
		 */
		public function get verticalCenter():Number {
			return _verticalCenter;
		}
		public function set verticalCenter(value:Number):void {
			_verticalCenter = value;
		}
		

		private var _maintainAspectRatio:Boolean;
		/**
		 * If true the drawn result of the geometry 
		 * will maintain an aspect ratio relative to the ratio
		 * of the precalculated bounds width and height.
		 */
		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}
		public function set maintainAspectRatio(value:Boolean):void {
			_maintainAspectRatio = value;
		}
		

		private var _layoutRectangle:Rectangle = new Rectangle();
		/**
		* The resulting calculated rectangle from which to 
		* layout/modify the geometry command stack items.
		**/
		public function get layoutRectangle():Rectangle {
			return _layoutRectangle.clone();
		}
		public function set layoutRectangle(value:Rectangle):void {
			_layoutRectangle = value;
		}
		
		private var _targetCoordinateSpace:DisplayObject;
		/**
		* The display object that defines the coordinate system to use.
		**/
		public function get targetCoordinateSpace():DisplayObject{
			return _targetCoordinateSpace;
		}
		public function set targetCoordinateSpace(value:DisplayObject):void {
			_targetCoordinateSpace = value;
		}
				
		//takes the child bounds (item being layed out) and the parent bounds the 
		//item we are laying out to and returns the calculated destination result 
		//rectangle
		public function computeLayoutRectangle(childBounds:Rectangle,parentBounds:Rectangle):Rectangle{
			
			//***Calculate the destination rectangle
			
			//parent can be either a geometry or a display object depending
			//on the case
			layoutRectangle = childBounds.clone();
			
			//bounds from a geometry should never be NaN
			_width=layoutRectangle.width;
			_height=layoutRectangle.height;
			_x=layoutRectangle.x;
			_y=layoutRectangle.y;
			
			//retrive the bounds we need to layout to
			container = parentBounds.clone(); 
					 			 	
		 	//get the final rectangle we need to layout to and 
		 	//base our point calcualtions on
		 	calculateLayoutRectangle();
		 	
		 	//returns the resulting rectangle
		 	return layoutRectangle;
		 				
		}
		
		//Based on code from Trevor McCauley, www.senocular.com
		//based on the layout settings calculates a 
		//rectangle object from which to adjust the 
		//drawing commands when compared to the calculated 
		//bounds. 
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
						_layoutRectangle.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
						_layoutRectangle.x = isNaN(_x)? 0:_x + container.left;
					}else{ 
						// centered
						_layoutRectangle.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
						_layoutRectangle.x = _horizontalCenter - _layoutRectangle.width/2 + container.left + container.width/2;
					}
					
				}else if (!alignedRight) { 
					// left
					_layoutRectangle.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
					_layoutRectangle.x = container.left + _left;
				}else if (!alignedLeft) { 
					// right
					_layoutRectangle.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
					_layoutRectangle.x = container.right - _right - _layoutRectangle.width;
				}else{ 
					// right and left (boxed)
					_layoutRectangle.right = container.right - _right;
					_layoutRectangle.left = container.left + _left;
				}
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
						_layoutRectangle.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
						_layoutRectangle.y = isNaN(_y)? 0:_y + container.top;
						
					}else{ 
						// centered
						_layoutRectangle.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
						_layoutRectangle.y = _verticalCenter - _layoutRectangle.height/2 + container.top + container.height/2;
					}
					
				}else if (!alignedBottom) { 
					// top
					_layoutRectangle.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
					_layoutRectangle.y = container.top + _top;
					
				}else if (!alignedTop) { 
					// bottom
					_layoutRectangle.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
					_layoutRectangle.y = container.bottom - _bottom - _layoutRectangle.height;
					
				}else{ 
					// top and bottom (boxed)
					_layoutRectangle.bottom = container.bottom - _bottom;
					_layoutRectangle.top = container.top + _top;
				}
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