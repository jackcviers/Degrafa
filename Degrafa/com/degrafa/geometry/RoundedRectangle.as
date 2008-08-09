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
	
	[IconFile("RoundedRectangle.png")]
	
	[Bindable]		
	/**
 	*  The RoundedRectangle element draws a rounded rectangle using the specified x,y,
 	*  width, height and corner radius.
 	*  
 	*  @see http://samples.degrafa.com/RoundedRectangle/RoundedRectangle.html
 	*  
 	**/
	public class RoundedRectangle extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The rounded rectangle constructor accepts 5 optional arguments that define it's 
	 	* x, y, width, height and corner radius.</p>
	 	* 
	 	* @param x A number indicating the upper left x-axis coordinate.
	 	* @param y A number indicating the upper left y-axis coordinate.
	 	* @param width A number indicating the width.
	 	* @param height A number indicating the height. 
	 	* @param cornerRadius A number indicating the radius of each corner.
	 	*/		
		public function RoundedRectangle(x:Number=NaN,y:Number=NaN,width:Number=NaN,height:Number=NaN,cornerRadius:Number=NaN){
			
			super();
			
			this.x=x;
			this.y=y;
			this.width=width;
			this.height=height;
			this.cornerRadius=cornerRadius;
			
		}
		
		/**
		* RoundedRectangle short hand data value.
		* 
		* <p>The rounded rectangle data property expects exactly 5 values x, 
		* y, width, height and corner radius separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 5){
					_x=tempArray[0];
					_y=tempArray[1];
					_width=tempArray[2];
					_height=tempArray[3];
					_cornerRadius =tempArray[4];
				}	
				
				invalidated = true;
				
			}
		} 
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the rounded rectangle. If not specified 
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
		* The y-axis coordinate of the upper left point of the rounded rectangle. If not specified 
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
		
						
		private var _width:Number;
		/**
		* The width of the rounded rectangle.
		**/
		public function get width():Number{
			if(!_width){return 0;}
			return _width;
		}
		public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated = true;
			}
		}
		
		
		private var _height:Number;
		/**
		* The height of the rounded rectangle.
		**/
		public function get height():Number{
			if(!_height){return 0;}
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
		
		
		private var _cornerRadius:Number;
		/**
		* The radius to be used for each corner of the rounded rectangle.
		**/
		public function get cornerRadius():Number{
			if(!_cornerRadius){return 0;}
			return _cornerRadius;
		}
		public function set cornerRadius(value:Number):void{
			if(_cornerRadius != value){
				_cornerRadius = value;
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
			_bounds = new Rectangle(x,y,width,height);
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				commandStack.length=0;
								
				// by Ric Ewing (ric@formequalsfunction.com) 
				if (cornerRadius>0) {
					// init vars
					var theta:Number;
					var angle:Number;
					var cx:Number;
					var cy:Number;
					var x1:Number;
					var y1:Number;
					
					//exit if the minimum requirements to properly calculate are not met
					if(!_width || !_height){return;}
					
					// make sure that width + h are larger than 2*cornerRadius
					if (cornerRadius>Math.min(width, height)/2) {
						cornerRadius = Math.min(width, height)/2;
					}
					
					// theta = 45 degrees in radians
					theta = Math.PI/4;
					
					// draw top line
					commandStack.addMoveTo(x+cornerRadius,y)
					commandStack.addLineTo(x+width-cornerRadius,y);
					
					//angle is currently 90 degrees
					angle = -Math.PI/2;
					// draw tr corner in two parts
					cx = x+width-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+width-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);

					angle += theta;
					cx = x+width-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+width-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw right line 
					commandStack.addLineTo(x+width,y+height-cornerRadius);
					// draw br corner
					angle += theta;
					cx = x+width-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+height-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+width-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+height-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					
					angle += theta;
					cx = x+width-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+height-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+width-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+height-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw bottom line
					commandStack.addLineTo(x+cornerRadius,y+height);
					
					// draw bl corner
					angle += theta;
					cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+height-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+height-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					angle += theta;
					cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+height-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+height-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw left line
					commandStack.addLineTo(x,y+cornerRadius);
					
					// draw tl corner
					angle += theta;
					cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					angle += theta;
					
					cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
					x1 = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
					y1 = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
				} else {
					commandStack.addMoveTo(x,y);
					commandStack.addLineTo(x+width,y);
					commandStack.addLineTo(x+width,y+height)
					commandStack.addLineTo(x,y+height);
					commandStack.addLineTo(x,y);
				}
				
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
		public function set derive(value:RoundedRectangle):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_cornerRadius){_cornerRadius = value.cornerRadius;}
		}
		
	}
}