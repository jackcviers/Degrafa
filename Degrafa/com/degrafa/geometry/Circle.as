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
	
	[IconFile("Circle.png")]
	
	[Bindable]	
	/**
 	*  The Circle element draws a circle using the specified center point 
 	*  and radius.
 	*  
 	*  @see http://samples.degrafa.com/Circle/Circle.html	    
 	* 
 	**/
	public class Circle extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The circle constructor accepts 3 optional arguments that define it's 
	 	* center point and radius.</p>
	 	* 
	 	* @param centerX A number indicating the center x-axis coordinate.
	 	* @param centerY A number indicating the center y-axis coordinate.
	 	* @param radius A number indicating the radius of the circle. 
	 	*/		
		public function Circle(centerX:Number=NaN,centerY:Number=NaN,radius:Number=NaN){			
			super();
			
			this.centerX=centerX;
			this.centerY=centerY;
			this.radius=radius;
			
		
		}
		
		/**
		* Circle short hand data value.
		* 
		* <p>The circle data property expects exactly 3 values centerX, 
		* centerY and radius separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
			
				//parse the string
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 3)
				{
					_centerX=tempArray[0];
					_centerY=tempArray[1];
					_radius=tempArray[2];
				}	
				
				invalidated = true;
			}
		} 
		
		 
		private var _centerX:Number;
		/**
		* The x-axis coordinate of the center of the circle. If not specified 
		* a default value of 1 is used in order for layout to work properly.
		**/
		public function get centerX():Number{
			if(!_centerX){return (hasLayout)? 1:0;}
			return _centerX;
		}
		public function set centerX(value:Number):void{
			if(_centerX != value){
				_centerX = value;
				invalidated = true;
			}
		}
				
		private var _centerY:Number;
		/**
		* The y-axis coordinate of the center of the circle. If not specified 
		* a default value of 1 is used in order for layout to work properly.
		**/
		public function get centerY():Number{
			if(!_centerY){return (hasLayout)? 1:0;}
			return _centerY;
		}
		public function set centerY(value:Number):void{
			if(_centerY != value){
				_centerY = value;
				invalidated = true;
			}
			
		}
		
						
		private var _radius:Number;
		/**
		* The radius of the circle. If not specified a default value of 0 
		* is used in order for layout to work properly.
		**/
		public function get radius():Number{
			if(!_radius){return (hasLayout)? 1:0;}
			return _radius;
		}
		public function set radius(value:Number):void{
			if(_radius != value){
				_radius = value;
				invalidated = true;
			}
		}
		
		private var _accuracy:Number;
		/**
		* The accuracy of the circle. If not specified a default value of 8 
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
			_bounds = new Rectangle(centerX-radius,centerY-radius,radius*2,radius*2);
		}		
		
		/**
		* Indicates that this geometry has enough required properties 
		* to properly render. This is tested in the predraw phase for each 
		* geometry object.
		*
		* In order for this object to render we need a minimum of a
		* radius or a layout constraint. This objects
		* children will not be drawn unless this object is valid.
		**/
		override public function get hasValideProperties():Boolean{
			_hasValideProperties = (_radius || hasLayout);
			return _hasValideProperties;
		}
			
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
						
			if(invalidated){
				
				if(!hasValideProperties){return;}
				
							
				commandStack.length = 0;
								
			    var span:Number = Math.PI/accuracy;
			    var controlRadius:Number = radius/Math.cos(span);
			    var anchorAngle:Number=0
			    var controlAngle:Number=0;
			    
			   	//add the move to the command stack
			    commandStack.addMoveTo(
			    centerX+Math.cos(anchorAngle)*radius,
			    centerY+Math.sin(anchorAngle)*radius);
					
			    var i:int=0;
			    
			    //loop through and add the curve commands
			    for (i; i<accuracy; ++i) {
			        controlAngle = anchorAngle+span;
			        anchorAngle = controlAngle+span;
			    
			        commandStack.addCurveTo(
			        centerX + Math.cos(controlAngle)*controlRadius,
			        centerY + Math.sin(controlAngle)*controlRadius,
			        centerX + Math.cos(anchorAngle)*radius,
			        centerY + Math.sin(anchorAngle)*radius)
				};

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
		 	
		 	if(!_hasValideProperties){return;}
		 							
			//apply the fill retangle for the draw
			super.draw(graphics,(rc)? rc:_bounds);
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:Circle):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke;}
			if (!_centerX){_centerX = value.centerX;}
			if (!_centerY){_centerY = value.centerY;}
			if (!_radius){_radius = value.radius;}
			if (!_accuracy){_accuracy = value.accuracy;}
		
		}		
	}
}