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
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("Line.png")]
	
	[Bindable]	
	/**
 	*  The Line element draws a line using the specified x, y, 
 	*  x1 and y1 coordinate values.
 	*  
 	*  @see http://samples.degrafa.com/Line/Line.html	    
 	* 
 	**/
	public class Line extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The circle constructor accepts 4 optional arguments that define it's 
	 	* center point and radius.</p>
	 	* 
	 	* @param x A number indicating the starting x-axis coordinate.
	 	* @param y A number indicating the starting y-axis coordinate.
	 	* @param x1 A number indicating the ending x-axis coordinate.
	 	* @param y1 A number indicating the ending y-axis coordinate.
	 	* 
	 	*/	
		public function Line(x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN){
			super();
			
			this.x=x;
			this.y=y;
			this.x1=x1;
			this.y1=y1;
			
			
		}
		
		//excluded here
		override public function set fill(value:IGraphicsFill):void{}
		
		/**
		* Line short hand data value.
		* 
		* <p>The line data property expects exactly 3 values x, 
		* y, x1 and y1 separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 4){
					_x=tempArray[0];
					_y=tempArray[1];
					_x1=tempArray[2];
					_y1=tempArray[3];
				}	
				
				invalidated = true;
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
			if(!_x1){return (hasLayout)? 1:0;}
			return _x1;
		}
		public function set x1(value:Number):void{
			if(_x1 != value){
				_x1 = value;
				invalidated = true;
			}
		}
		
		
		private var _y1:Number;
		/**
		* The y-coordinate of the end point of the line. If not specified 
		* a default value of 0 is used.
		**/
		public function get y1():Number{
			if(!_y1){return (hasLayout)? 1:0;}
			return _y1;
		}
		public function set y1(value:Number):void{
			if(_y1 != value){
				_y1 = value;
				invalidated = true;
			}
			
		}
		
		private var _length:Number;
		/**
		* The length of the line in pixels. Setting this value will modify 
		* the end point of the line to the appropriate length. If both x1 
		* and y1 are not set then setting the length will impact x1 only, 
		* set y1 to y and effectively create a horizontal line. 
		**/
		public function get length():Number{
			var dx:Number = x1 - x;
			var dy:Number = y1 - y;
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		public function set length(value:Number):void{
			if(_length != value){
				_length = value;
				
				//if both x1 and y1 are NaN then set x1 to length
				if(!_x1 && !_y1 ){
					_x1 = _length;
				}
			
				//this needs to be done before setting the values
				var newX1:Number = Math.abs(_length * Math.cos(angle));
				var newY1:Number = Math.abs(_length * Math.sin(angle));
								
				_x1=newX1;
				_y1=newY1;
				
				invalidated = true;
			}
		}
		
		/**
		* The angle of the line in radians. 
		**/
		public function get angle():Number{
			return  Math.atan((y1 - y)/(x1 - x));
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			//return _bounds;
			return commandStack.bounds;	
		}
		
		private var _originalBounds:Rectangle;
		override public function get originalBounds():Rectangle{
			return _originalBounds;	
		}
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds():void{
			if(commandStack.length==0){return;}
			if(!_originalBounds && (_x1 || _y1)){
				_originalBounds=bounds;
			}
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				commandStack.length=0;
				
				commandStack.addMoveTo(x,y);	
				commandStack.addLineTo(x1,y1);
			
				calcBounds();
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
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					if(_x1){
			 			tempLayoutRect.width = _x1-_x;
			 		}
					
					if(_y1){
			 			tempLayoutRect.height = _y1-_y;
			 		}
			 		
			 		if(_x){
			 			tempLayoutRect.x = _x;
			 		}
			 		
			 		if(_y){
			 			tempLayoutRect.y = _y;
			 		}
			 				 		
			 		super.calculateLayout(tempLayoutRect);	
			 					
					_layoutConstraint.xMax=bounds.bottomRight.x;
					_layoutConstraint.yMax=bounds.bottomRight.y;
					
					_layoutConstraint.xMin=bounds.x;
					_layoutConstraint.yMin=bounds.y;
					
					_layoutConstraint.xOffset = layoutRectangle.x;
					_layoutConstraint.yOffset = layoutRectangle.y;
					
					_layoutConstraint.xMultiplier=layoutRectangle.width/(_layoutConstraint.xMax-bounds.x);
					_layoutConstraint.yMultiplier=layoutRectangle.height/(_layoutConstraint.yMax-bounds.y);
				
				
					if(!_originalBounds){
						if(layoutRectangle.width!=0 && layoutRectangle.height!=0){
							_originalBounds = layoutRectangle;
						}
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
		
			//re init if required
		 	preDraw();
		
			calculateLayout();
		 	
			super.draw(graphics,(rc)? rc:bounds);
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:Line):void{
			
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_x1){_x1 = value.x1;}
			if (!_y1){_y1 = value.y1;}
			if (!_length){_length = value.length;}
			
		}
		
	}
}