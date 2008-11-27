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
package com.degrafa.geometry{
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.IGraphicsFill;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	//excluded here		
	[Exclude(name="fill", kind="property")]
	[Exclude(name="height", kind="property")] 
	[Exclude(name="percentHeight", kind="property")] 
	[Exclude(name="maxHeight", kind="property")] 
	[Exclude(name="minHeight", kind="property")] 
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("HorizontalLine.png")]
	
	[Bindable]	
	/**
 	*  The HorizontalLine element draws a horizontal line using the specified x, y, 
 	 * and x1 coordinate values.
 	*  
 	*  @see http://samples.degrafa.com/HorizontalLine/HorizontalLine.html	    
 	* 
 	**/
	public class HorizontalLine extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The horizontal line constructor accepts 3 optional arguments that define it's 
	 	* center point and radius.</p>
	 	* 
	 	* @param x A number indicating the starting x-axis coordinate.
	 	* @param y A number indicating the starting y-axis coordinate.
	 	* @param x1 A number indicating the ending x-axis coordinate.
	 	*/		 
		public function HorizontalLine(x:Number=NaN,y:Number=NaN,x1:Number=NaN){
			super();
			
			if (x) this.x=x;
			if (y) this.y=y;
			if (x1) this.x1=x1;
			
			
		}
		
		//excluded here
		override public function set fill(value:IGraphicsFill):void{}
		override public function set height(value:Number):void{}
		override public function set percentHeight(value:Number):void{}
		override public function set maxHeight(value:Number):void{}
		override public function set minHeight(value:Number):void{}
		
		/**
		* HorizontalLine short hand data value.
		* 
		* <p>The horizontal line data property expects exactly 3 values x, 
		* y and x1 separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 3){
					_x=tempArray[0];
					_y=tempArray[1];
					_x1 = tempArray[2];	
					invalidated = true;
				}
				
			
			}
			
		}  
		
		
		private var _x:Number;
		/**
		* The x-coordinate of the start point of the line. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		
		private var _y:Number;
		/**
		* The y-coordinate of the start point of the line. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
				
						
		private var _x1:Number;
		/**
		* The x-coordinate of the end point of the line. If not specified 
		* a default value of 0 is used.
		**/
		public function get x1():Number{
			if(isNaN(_x1)){return (hasLayout)? 0.0001:0;}
			return _x1;
		}
		public function set x1(value:Number):void{
			if(_x1 != value){
				_x1 = value;
				invalidated = true;
			}
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				commandStack.length=0;
				commandStack.addMoveTo(x,y);	
				commandStack.addLineTo(x1,y);
				invalidated = false;
			}
		}
				
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
				
					var tempLayoutRect:Rectangle = new Rectangle(0,0,0.0001,0.0001);
					
					if(!isNaN(_x1) || !isNaN(_x)){
			 			if (_x1?_x1:0 - _x?_x:0) tempLayoutRect.width = Math.abs(_x1?_x1:0 - _x?_x:0);
						tempLayoutRect.x = Math.min(_x?_x:0,_x1?_x1:0);
			 		}
							 		
			 		if(_y){
			 			tempLayoutRect.y = _y;
			 		}
			 				 		
			 		super.calculateLayout(tempLayoutRect);	
					_layoutRectangle = _layoutConstraint.layoutRectangle;
					//force the layout to minimum height in this case
					_layoutRectangle.height = 0.0001;
					if (isNaN(_x1)) {
						//layout defined initial settings
						if (isNaN(_x)) _x = _layoutRectangle.x;
						if (isNaN(_y)) _y = _layoutRectangle.y;
						_x1 = _layoutRectangle.right;
						invalidated = true;
					}
			

				}
			}
		}
		
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics,rc:Rectangle):void{
			
			//init the layout in this case done before predraw.
			if (_layoutConstraint) calculateLayout();
			
			//re init if required
		 	if (invalidated) preDraw();
			
			super.draw(graphics,(rc)? rc:bounds);
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:HorizontalLine):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_x1){_x1 = value.x1;}
		}
		
	}
}