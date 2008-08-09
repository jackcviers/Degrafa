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
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
		
	[Exclude(name="fill", kind="property")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("VerticalLine.png")]
	
	[Bindable]	
	/**
 	*  The VerticalLine element draws a vertical line using the specified x, y, 
 	 * and y1 coordinate values.
 	*  
 	*  @see http://samples.degrafa.com/VerticalLine/VerticalLine.html	    
 	* 
 	**/
	public class VerticalLine extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The vertical line constructor accepts 3 optional arguments that define it's 
	 	* center point and radius.</p>
	 	* 
	 	* @param x A number indicating the starting x-axis coordinate.
	 	* @param y A number indicating the starting y-axis coordinate.
	 	* @param y1 A number indicating the ending y-axis coordinate.
	 	*/		
		public function VerticalLine(x:Number=NaN,y:Number=NaN,y1:Number=NaN){
			super();
			
			this.x=x;
			this.y=y;
			this.y1=y1;
		
				
		}
		
		/**
		* VerticalLine short hand data value.
		* 
		* <p>The vertical line data property expects exactly 3 values x, 
		* y and y1 separated by spaces.</p>
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
					_y1=tempArray[2];
				}	
				
				invalidated = true;
			}
			
		}  
		
		
		private var _x:Number;
		/**
		* The x-coordinate of the start point of the line. If not specified 
		* a default value of 0 is used.
		**/
		public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		public function set x(value:Number):void{
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
		public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
				
		private var _y1:Number;
		/**
		* The y-coordinate of the end point of the line. If not specified 
		* a default value of 0 is used.
		**/
		public function get y1():Number{
			if(!_y1){return 0;}
			return _y1;
		}
		public function set y1(value:Number):void{			
			if(_y1 != value){
				_y1 = value;
				invalidated = true;
			}
			
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return _bounds;	
		}
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds():void{
			_bounds = new Rectangle(x,Math.min(y,y1),1,y1-y);
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				commandStack.length=0;
				
				commandStack.addMoveTo(x,y);	
				commandStack.addLineTo(x,y1);
			
				calcBounds();
				invalidated = false;
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
			//re init if required
		 	preDraw();
			super.draw(graphics,(rc)? rc:_bounds);
		}		
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:VerticalLine):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_y1){_y1 = value.y1;}
		}
		
	}
}