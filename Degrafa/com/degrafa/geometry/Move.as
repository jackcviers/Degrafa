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
	[Exclude(name="stroke", kind="property")]
	
	[Bindable]	
	/**
 	*  The Move element moves the drawing context current point to a specified x and y 
 	*  coordinate value.
 	*  
 	*  @see http://degrafa.com/samples/Move_Element.html	    
 	* 
 	**/
	public class Move extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The move constructor accepts 2 optional arguments that define it's 
	 	* x, and y coordinate values.</p>
	 	* 
	 	* @param x A number indicating the x-axis coordinate to move to.
	 	* @param y A number indicating the y-axis coordinate to move to.
	 	* 
	 	*/	
		public function Move(x:Number=0,y:Number=0){
			super();
			
			this.x=x;
			this.y=y;
			
		}
		
		/**
		* Move short hand data value.
		* 
		* <p>The move data property expects exactly 2 values x and 
		* y separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 2){
					_x=tempArray[0];
					_y=tempArray[1];
				}	
				
				invalidated = true;
			}
		} 
		
		
		private var _x:Number=0;
		/**
		* The x-coordinate to move to. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		
		private var _y:Number=0;
		/**
		* The y-coordinate to move to. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
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
		 	if (invalidated) preDraw();
		 	
			super.draw(graphics,(rc)? rc:bounds);
		}
		
		
	}
}