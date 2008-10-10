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
	
	[IconFile("RoundedRectangleComplex.png")]
	
	[Bindable]	
	/**
 	*  The RoundedRectangleComplex element draws a complex rounded rectangle using the specified x,y,
 	*  width, height and top left radius, top right radius, bottom left radius and bottom right 
 	*  radius.
 	*  
 	*  @see http://samples.degrafa.com/RoundedRectangleComplex/RoundedRectangleComplex.html
 	*  
 	**/	
	public class RoundedRectangleComplex extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The complex rounded rectangle constructor accepts 8 optional arguments that define it's 
	 	* x, y, width, height, top left radius, top right radius, bottom left radius 
	 	* and bottom right radius.</p>
	 	* 
	 	* @param x A number indicating the upper left x-axis coordinate.
	 	* @param y A number indicating the upper left y-axis coordinate.
	 	* @param width A number indicating the width.
	 	* @param height A number indicating the height. 
	 	* @param topLeftRadius A number indicating the top left corner radius.
	 	* @param topRightRadius A number indicating the top right corner radius.
	 	* @param bottomLeftRadius A number indicating the bottom left corner radius.
	 	* @param bottomRightRadius A number indicating the bottom right corner radius.
	 	*/		
		public function RoundedRectangleComplex(x:Number=NaN,y:Number=NaN,width:Number=NaN,
		height:Number=NaN,topLeftRadius:Number=NaN,topRightRadius:Number=NaN,
		bottomLeftRadius:Number=NaN,bottomRightRadius:Number=NaN){
			
			super();
			
			this.x=x;
			this.y=y;
			this.width=width;
			this.height=height;
			this.topLeftRadius=topLeftRadius;
			this.topRightRadius=topRightRadius;
			this.bottomLeftRadius=bottomLeftRadius;
			this.bottomRightRadius=bottomRightRadius;
		}
		
		/**
		* RoundedRectangleComplex short hand data value.
		* 
		* <p>The complex rounded rectangle data property expects exactly 8 values x, 
		* y, width, height, top left radius, top right radius, bottom left radius 
	 	* and bottom right radius separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{			
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 8){
					_x=tempArray[0];
					_y=tempArray[1];
					_width=tempArray[2];
					_height=tempArray[3];
					_topLeftRadius=tempArray[4];
					_topRightRadius=tempArray[5];
					_bottomLeftRadius=tempArray[6];
					_bottomRightRadius=tempArray[7];
				}	
				
				invalidated = true;
				
			}
		} 
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the complex rounded rectangle. If not specified 
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
		* The y-axis coordinate of the upper left point of the complex rounded rectangle. If not specified 
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
		* The width of the complex rounded rectangle.
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
		* The height of the complex rounded rectangle.
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
		
		
		private var _topLeftRadius:Number;
		/**
		* The radius for the top left corner of the complex rounded rectangle.
		**/
		public function get topLeftRadius():Number{
			if(!_topLeftRadius){return 0;}
			return _topLeftRadius;
		}
		public function set topLeftRadius(value:Number):void{
			if(_topLeftRadius != value){
				_topLeftRadius = value;
				invalidated = true;
			}
			
		}
		
		
		private var _topRightRadius:Number;
		/**
		* The radius for the top right corner of the complex rounded rectangle.
		**/
		public function get topRightRadius():Number{
			if(!_topRightRadius){return 0;}
			return _topRightRadius;
		}
		public function set topRightRadius(value:Number):void{
			if(_topRightRadius != value){
				_topRightRadius = value;
				invalidated = true;
			}
			
		}
		
		
		private var _bottomLeftRadius:Number;
		/**
		* The radius for the bottom left corner of the complex rounded rectangle.
		**/
		public function get bottomLeftRadius():Number{
			if(!_bottomLeftRadius){return 0;}
			return _bottomLeftRadius;
		}
		public function set bottomLeftRadius(value:Number):void	{
			if(_bottomLeftRadius != value){
				_bottomLeftRadius = value;
				invalidated = true;
			}
		}
		
		
		private var _bottomRightRadius:Number;
		/**
		* The radius for the bottom right corner of the complex rounded rectangle.
		**/
		public function get bottomRightRadius():Number{
			if(!_bottomRightRadius){return 0;}
			return _bottomRightRadius;
		}
		public function set bottomRightRadius(value:Number):void{
			if(_bottomRightRadius != value){
				_bottomRightRadius = value;
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
		
		private var _originalBounds:Rectangle;
		override public function get originalBounds():Rectangle{
			return _originalBounds;	
		}
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds():void{
			_bounds = new Rectangle(x,y,width,height);
			
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
				
				if(topLeftRadius==0 && topRightRadius==0 && bottomLeftRadius==0 && bottomRightRadius==0){
					commandStack.addMoveTo(x,y);
					commandStack.addLineTo(x+width,y);
					commandStack.addLineTo(x+width,y+height)
					commandStack.addLineTo(x,y+height);
					commandStack.addLineTo(x,y);
				}				
				else{
					
					//Copied from the Flex framework but modified to fill our command stack needs
					//see mx.utils.GraphicsUtil
					var xw:Number = x + width;
					var yh:Number = y + height;
			
					var minSize:Number = width < height ? width * 2 : height * 2;
					
					var topLeftRadius:Number = this.topLeftRadius < minSize ? this.topLeftRadius : minSize;;
					var topRightRadius:Number = this.topRightRadius < minSize ? this.topRightRadius : minSize;
					var bottomLeftRadius:Number = this.bottomLeftRadius < minSize ? this.bottomLeftRadius : minSize;
					var bottomRightRadius:Number =  this.bottomRightRadius < minSize ? this.bottomRightRadius : minSize;
																				
					// bottom-right corner
					var a:Number = bottomRightRadius * 0.292893218813453;		// radius - anchor pt;
					var s:Number = bottomRightRadius * 0.585786437626905; 	// radius - control pt;
					
					commandStack.addMoveTo(xw,yh - bottomRightRadius);
					commandStack.addCurveTo(xw,yh-s,xw-a,yh-a);
					commandStack.addCurveTo(xw - s,yh,xw - bottomRightRadius,yh);
							
					// bottom-left corner
					a = bottomLeftRadius * 0.292893218813453;
					s = bottomLeftRadius * 0.585786437626905;
					
					commandStack.addLineTo(x + bottomLeftRadius,yh);
					commandStack.addCurveTo(x + s,yh,x + a,yh - a);
					commandStack.addCurveTo(x,yh - s,x,yh - bottomLeftRadius);
							
					// top-left corner
					a = topLeftRadius * 0.292893218813453;
					s = topLeftRadius * 0.585786437626905;
					
					commandStack.addLineTo(x,y + topLeftRadius);
					commandStack.addCurveTo(x,y+s,x + a,y + a);
					commandStack.addCurveTo(x + s,y,x + topLeftRadius,y);
					
					// top-right corner
					a = topRightRadius * 0.292893218813453;
					s = topRightRadius * 0.585786437626905;
					
					commandStack.addLineTo(xw - topRightRadius, y);
					commandStack.addCurveTo(xw - s,y,xw - a,y + a);
					commandStack.addCurveTo(xw,y + s,xw,y + topRightRadius);
					commandStack.addLineTo(xw,yh - bottomRightRadius);
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
		public function set derive(value:RoundedRectangleComplex):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_bottomLeftRadius){_bottomLeftRadius = value.bottomLeftRadius;}
			if (!_bottomRightRadius){_bottomRightRadius = value.bottomRightRadius;}
			if (!_topLeftRadius){_topLeftRadius = value.topLeftRadius;}
			if (!_topRightRadius){_topRightRadius = value.topRightRadius;}
			
		}
		
	}
}