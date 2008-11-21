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
	
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.command.CommandStackItem;
	import com.degrafa.geometry.utilities.ArcUtils;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EllipticalArc.png")]
	
	[Bindable]	
	/**
 	*  The EllipticalArc element draws an elliptical arc using the specified
 	*  x, y, width, height, start angle, arc and closure type.
 	*  
 	*  @see http://degrafa.com/samples/EllipticalArc_Element.html
 	*  
 	**/	
	public class EllipticalArc extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The elliptical arc constructor accepts 7 optional arguments that define it's 
	 	* x, y, width, height, start angle, arc and closure type.</p>
	 	* 
	 	* @param x A number indicating the upper left x-axis coordinate.
	 	* @param y A number indicating the upper left y-axis coordinate.
	 	* @param width A number indicating the width.
	 	* @param height A number indicating the height. 
	 	* @param startAngle A number indicating the beginning angle of the arc.
	 	* @param arc A number indicating the the angular extent of the arc, relative to the start angle.
	 	* @param closureType A string indicating the method used to close the arc. 
	 	*/	
		public function EllipticalArc(x:Number=NaN,y:Number=NaN,width:Number=NaN,
		height:Number=NaN,startAngle:Number=NaN,arc:Number=NaN,closureType:String=null){
			
			super();
			if (!isNaN(x)) this.x=x;
			if (!isNaN(y)) this.y=y;
			if (!isNaN(width)) this.width=width; 
			if (!isNaN(height)) this.height=height;
			if (!isNaN(startAngle)) this.startAngle=startAngle;
			if (!isNaN(arc)) this.arc=arc;
			if (closureType) this.closureType=closureType;
			
		}
		
		/**
		* EllipticalArc short hand data value.
		* 
		* <p>The elliptical arc data property expects exactly 6 values x, 
		* y, width, height, startAngle and arc separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 6){
					_x=tempArray[0];
					_y=tempArray[1];
					_width=tempArray[2]; //radius
					_height=tempArray[3]; //yRadius
					_startAngle=tempArray[4]; //angle
					_arc=tempArray[5]; //extent
					invalidated = true;
				}
			
			}
			
		} 
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the arcs enclosure. If not specified 
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
		* The y-axis coordinate of the upper left point of the arcs enclosure. If not specified 
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
		
		
		private var _startAngle:Number;
		/**
		* The beginning angle of the arc. If not specified 
		* a default value of 0 is used.
		**/
		public function get startAngle():Number{
			if(!_startAngle){return 0;}
			return _startAngle;
		}
		public function set startAngle(value:Number):void{
			if(_startAngle != value){
				_startAngle = value;
				invalidated = true;
			}
		}
		
		
		private var _arc:Number;
		/**
		* The angular extent of the arc. If not specified 
		* a default value of 0 is used.
		**/
		public function get arc():Number{
			if(!_arc){return 0;}
			return _arc;
		}
		public function set arc(value:Number):void{
			if(_arc != value){
				_arc = value;
				invalidated = true;
			}
		}
		
		
		private var _width:Number;
		/**
		* The width of the arc.
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
		* The height of the arc.
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
		
		
		private var _closureType:String;
		[Inspectable(category="General", enumeration="open,chord,pie", defaultValue="open")]
		/**
		* The method in which to close the arc.
		* <p>
		* <li><b>open</b> will apply no closure.</li>
		* <li><b>chord</b> will close the arc with a strait line to the start.</li>
		* <li><b>pie</b> will draw a line from center to start and end to center forming a pie shape.</li>
		* </p> 
		**/
		public function get closureType():String{
			if(!_closureType){return "open";}
			return _closureType;
		}
		public function set closureType(value:String):void{
			if(_closureType != value){
				_closureType = value;
				invalidated = true;
			}
		}
				
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				//calculate based on startangle, radius, width, and height to get the drawing
				//x and y so that our arc is always in the bounds of the rectangle. may want 
				//to store this local sometime
				var newX:Number = (width/2) + (width/2) * 
				Math.cos(startAngle * (Math.PI / 180))+x;
				
				var newY:Number = (height/2) - (height/2) * 
				Math.sin(startAngle * (Math.PI / 180))+y;
								
				
				commandStack.length=0;
			
				//Calculate the center point. We only needed is we have a pie type 
				//closeur. May want to store this local sometime
				var ax:Number=newX-Math.cos(-(startAngle/180)*Math.PI)*width/2;
				var ay:Number=newY-Math.sin(-(startAngle/180)*Math.PI)*height/2;
				
				//draw the start line in the case of a pie type
				if (closureType =="pie"){
					if(Math.abs(arc)<360){
						commandStack.addMoveTo(ax,ay);
						commandStack.addLineTo(newX,newY);
					}
				} else 	commandStack.addMoveTo(newX,newY);
				
			
				
				//fill the quad array with curve to segments 
				//which we'll use to draw and calc the bounds
				ArcUtils.drawEllipticalArc(newX,newY,startAngle,arc,width/2,height/2,commandStack);
				
				//close the arc if required
				if(Math.abs(arc)<360){
					if (closureType == "pie"){
						commandStack.addLineTo(ax,ay);
					}
					if(closureType == "chord"){
						commandStack.addLineTo(newX,newY);
					}
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
		public function set derive(value:EllipticalArc):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_startAngle){_startAngle = value.startAngle;}
			if (!_arc){_arc = value.arc;}
			if (!_closureType){_closureType = value.closureType;}
			
			
		}
		
	}
}