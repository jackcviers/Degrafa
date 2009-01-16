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
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("Ellipse.png")]
	
	[Bindable]	
	/**
 	*  The Ellipse element draws a ellipse using the specified x,y,
 	*  width and height.
 	*  
 	*  @see http://samples.degrafa.com/Ellipse/Ellipse.html
 	*  
 	**/	
	public class Ellipse extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The ellipse constructor accepts 4 optional arguments that define it's 
	 	* x, y, width and height.</p>
	 	* 
	 	* @param x A number indicating the upper left x-axis coordinate.
	 	* @param y A number indicating the upper left y-axis coordinate.
	 	* @param width A number indicating the width.
	 	* @param height A number indicating the height. 
	 	*/		
		public function Ellipse(x:Number=NaN,y:Number=NaN,width:Number=NaN,height:Number=NaN){
			super();
			if (x)		this.x=x;
			if (y)		this.y=y;
			if (width)	this.width=width;
			if (height)	this.height=height;
		}
		
		
		/**
		* Ellipse short hand data value.
		* 
		* <p>The ellipse data property expects exactly 4 values x, 
		* y, width and height separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:Object):void{
			if(super.data != value){
				super.data = value;
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 4){
					_x=tempArray[0];
					_y=tempArray[1];
					_width=tempArray[2];
					_height=tempArray[3];
				}	
				
				invalidated = true;
			}
		} 
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the ellipse. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			if(isNaN(_x)){return 0;}
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
		* The y-axis coordinate of the upper left point of the ellipse. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			if(isNaN(_y)){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
						
		private var _width:Number;
		/**
		* The width of the ellipse.
		**/
		[PercentProxy("percentWidth")]
		override public function get width():Number{
			if(isNaN(_width)){return (hasLayout)? 1:0;}
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated = true;
			}
			
		}
		
		
		private var _height:Number;
		/**
		* The height of the ellipse.
		**/
		[PercentProxy("percentHeight")]
		override public function get height():Number{
			if(isNaN(_height)){return (hasLayout)? 1:0;}
			return _height;
		}
		override public function set height(value:Number):void{			
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
		
		private var _accuracy:Number;
		/**
		* The accuracy of the ellipse. If not specified a default value of 8 
		* is used.
		**/
		public function get accuracy():Number{
			if(!_accuracy){return 8;}
			return _accuracy;
		}
		public function set accuracy(value:Number):void{
			if(_accuracy != value){
				_accuracy = value;
				invalidated = true;
			}
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				commandStack.length=0;
				
				var angleDelta:Number = Math.PI / (accuracy/2); 
				
				var rx: Number = width/2;
			   	var ry: Number = height/2;
			   	var dx:Number = rx/Math.cos(angleDelta/2);
			   	var dy:Number = ry/Math.cos(angleDelta/2);
			   	
			   	commandStack.addMoveTo((x+rx) + rx,(y+ry));
			   	
			   	var i:Number = 0
			   	var angle:Number=0;
			   				   	
			   	for (i= 0; i < accuracy; i++) {
			   		angle += angleDelta;
			   		
      				commandStack.addCurveTo(
      				(x+rx) + Math.cos(angle-(angleDelta/2))*(dx),
      				(y+ry) + Math.sin(angle-(angleDelta/2))*(dy),
      				(x+rx) + Math.cos(angle)*rx,
      				(y+ry) + Math.sin(angle)*ry);
      			}
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
					
					if(_width){
			 			tempLayoutRect.width = _width;
			 		}
					
					if(_height){
			 			tempLayoutRect.height = _height;
			 		}
			 		
			 		if(_x){
			 			tempLayoutRect.x = _x;
			 		}
			 		
			 		if(_y){
			 			tempLayoutRect.y = _y;
			 		}
			 				 		
			 		super.calculateLayout(tempLayoutRect);	
			 					
					_layoutRectangle = _layoutConstraint.layoutRectangle;
				
					if (isNaN(_width) || isNaN(_height)) {
						//layout defined initial state:
						_width = isNaN(_width)? layoutRectangle.width:_width;
						_height =  isNaN(_height) ? layoutRectangle.height: _height;
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
		public function set derive(value:Ellipse):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_accuracy){_accuracy = value.accuracy;}
		}
		
	}
}