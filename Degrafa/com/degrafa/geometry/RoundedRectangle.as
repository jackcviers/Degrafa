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
		* The y-axis coordinate of the upper left point of the rounded rectangle. If not specified 
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
		
						
		private var _width:Number;
		/**
		* The width of the rounded rectangle.
		**/
		[PercentProxy("percentWidth")]
		override public function get width():Number{
			if(!_width){return (hasLayout)? 1:0;}
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
		* The height of the rounded rectangle.
		**/
		[PercentProxy("percentHeight")]
		override public function get height():Number{
			if(!_height){return (hasLayout)? 1:0;}
			return _height;
		}
		override public function set height(value:Number):void{
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
			if(!_originalBounds && (_bounds.width !=0 || _bounds.height!=0)){
				_originalBounds=_bounds;
			}
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				commandStack.length=0;
				
				var _cornerRadius:Number = cornerRadius;
								
				// by Ric Ewing (ric@formequalsfunction.com) 
				if (_cornerRadius>0) {
					// init vars
					var theta:Number;
					var angle:Number;
					var cx:Number;
					var cy:Number;
					var x1:Number;
					var y1:Number;
										
					// make sure that width + h are larger than 2*cornerRadius
					if(width>0 && height>0){
						if (_cornerRadius>Math.min(width, height)/2) {
							_cornerRadius = Math.min(width, height)/2;
						}
					}
					
					// theta = 45 degrees in radians
					theta = Math.PI/4;
					
					// draw top line
					commandStack.addMoveTo(x+_cornerRadius,y)
					commandStack.addLineTo(x+width-_cornerRadius,y);
					
					//angle is currently 90 degrees
					angle = -Math.PI/2;
					// draw tr corner in two parts
					cx = x+width-_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+width-_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);

					angle += theta;
					cx = x+width-_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+width-_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw right line 
					commandStack.addLineTo(x+width,y+height-_cornerRadius);
					// draw br corner
					angle += theta;
					cx = x+width-_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+height-_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+width-_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+height-_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					
					angle += theta;
					cx = x+width-_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+height-_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+width-_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+height-_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw bottom line
					commandStack.addLineTo(x+_cornerRadius,y+height);
					
					// draw bl corner
					angle += theta;
					cx = x+_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+height-_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+height-_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					angle += theta;
					cx = x+_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+height-_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+height-_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					// draw left line
					commandStack.addLineTo(x,y+_cornerRadius);
					
					// draw tl corner
					angle += theta;
					cx = x+_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
					commandStack.addCurveTo(cx,cy,x1,y1);
					
					angle += theta;
					
					cx = x+_cornerRadius+(Math.cos(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					cy = y+_cornerRadius+(Math.sin(angle+(theta/2))*_cornerRadius/Math.cos(theta/2));
					x1 = x+_cornerRadius+(Math.cos(angle+theta)*_cornerRadius);
					y1 = y+_cornerRadius+(Math.sin(angle+theta)*_cornerRadius);
					
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