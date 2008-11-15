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
	
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
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
					_cornerRadius = tempArray[4];
					invalidated = true;
				}	
				
				
				
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
			if (_cornerRadius != value) {
				var oldval:Number = _cornerRadius;
				_cornerRadius = value;
				invalidated = true;
			}
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return commandStack.bounds;	
		}
		
		

		private static const TRIG:Number = 0.4142135623730950488016887242097; //tan(22.5 degrees)
		
		private function updateCommandStack(cStack:CommandStack=null, item:CommandStackItem=null, graphics:Graphics=null):CommandStackItem {
			
				var _cornerRadius:Number = cornerRadius;
				
			

				//use local vars instead of the main getters
				var x:Number;
				var y:Number;
				var width:Number ;
				var height:Number
				if (hasLayout && cStack) { //handle layout variant call at render time
					CommandStack.transMatrix = CommandStack.currentTransformMatrix;

					x = layoutRectangle.x;
					y = layoutRectangle.y;
					width = layoutRectangle.width;
					height = layoutRectangle.height;
					
				} else {
					x = this.x;
					y = this.y;
					width = this.width;
					height = this.height;
					
				}
				// make sure that width + h are larger than 2*cornerRadius
					if(width>0 && height>0){
						if (_cornerRadius>Math.min(width, height)/2) {
							_cornerRadius = Math.min(width, height)/2;
						}
					}
				//round to nearest
				_cornerRadius = Math.round(_cornerRadius);
				if (_cornerRadius < 0) _cornerRadius = 0;
					var bottom:Number = y + height;
					var right:Number = x + width;
					var innerRight:Number = right - _cornerRadius;
					var innerLeft:Number = x + _cornerRadius;
					var innerTop:Number = y + _cornerRadius;
					var innerBottom:Number = bottom - _cornerRadius;
					// manipulate the commandStack but do not invalidate its bounds
					//basic rectangle:
					startPoint.x = innerLeft;
					startPoint.y = y;
					topLine.x = innerRight;
					topLine.y = y;
					rightLine.x = right;
					rightLine.y = innerBottom;
					bottomLine.x = innerLeft;
					bottomLine.y = bottom;
					leftLine.x = x;
					leftLine.y = innerTop;
					//corners if necessary
					if (_cornerRadius) {	
						var cornersplitoffset:Number = Math.SQRT1_2 * _cornerRadius;
						var controlPointOffset:Number = TRIG*_cornerRadius;
						var innerRightcx:Number = innerRight + controlPointOffset;
						var innerRightx:Number = innerRight + cornersplitoffset;
						var innerBottomcy:Number = innerBottom + controlPointOffset;
						var innerBottomy:Number = innerBottom + cornersplitoffset;
						var innerLeftcx:Number = innerLeft - controlPointOffset;
						var innerLeftx:Number = innerLeft - cornersplitoffset;
						var innerTopcy:Number = innerTop - controlPointOffset;
						var innerTopy:Number = innerTop - cornersplitoffset;
						
						if (!topRightCorner.length) { //create items
							topRightCorner.addCurveTo(innerRightcx, y, innerRightx, innerTopy);
							topRightCorner.addCurveTo(right, innerTopcy, right, innerTop)

							bottomRightCorner.addCurveTo(right, innerBottomcy, innerRightx, innerBottomy);
							bottomRightCorner.addCurveTo(innerRightcx, bottom, innerRight , bottom);
							
							bottomLeftCorner.addCurveTo(innerLeftcx, bottom, innerLeftx,innerBottomy);
							bottomLeftCorner.addCurveTo(x, innerBottomcy, x, innerBottom );
							
							topLeftCorner.addCurveTo(x, innerTopcy, innerLeftx, innerTopy);
							topLeftCorner.addCurveTo(innerLeftcx,y, innerLeft, y);
						} else { //manipulate
							topRightCorner.source[0].cx = innerRightcx;
							topRightCorner.source[0].cy = y;
							topRightCorner.source[0].x1 = innerRightx;
							topRightCorner.source[0].y1 = innerTopy;
							topRightCorner.source[1].cx = right;
							topRightCorner.source[1].cy = innerTopcy;
							topRightCorner.source[1].x1 = right;
							topRightCorner.source[1].y1 = innerTop;
							
							bottomRightCorner.source[0].cx = right;
							bottomRightCorner.source[0].cy = innerBottomcy;
							bottomRightCorner.source[0].x1 = innerRightx;
							bottomRightCorner.source[0].y1 = innerBottomy;
							bottomRightCorner.source[1].cx = innerRightcx;
							bottomRightCorner.source[1].cy = bottom;
							bottomRightCorner.source[1].x1 = innerRight;
							bottomRightCorner.source[1].y1 = bottom;
							
							bottomLeftCorner.source[0].cx = innerLeftcx;
							bottomLeftCorner.source[0].cy = bottom;
							bottomLeftCorner.source[0].x1 = innerLeftx;
							bottomLeftCorner.source[0].y1 = innerBottomy;
							bottomLeftCorner.source[1].cx = x;
							bottomLeftCorner.source[1].cy = innerBottomcy;
							bottomLeftCorner.source[1].x1 = x;
							bottomLeftCorner.source[1].y1 = innerBottom;
							
							topLeftCorner.source[0].cx = x;
							topLeftCorner.source[0].cy = innerTopcy;
							topLeftCorner.source[0].x1 = innerLeftx;
							topLeftCorner.source[0].y1 = innerTopy;
							topLeftCorner.source[1].cx = innerLeftcx;
							topLeftCorner.source[1].cy = y;
							topLeftCorner.source[1].x1 = innerLeft;
							topLeftCorner.source[1].y1 = y;
							
						}
						
					} else {
						topRightCorner.length = 0;
						bottomRightCorner.length = 0;
						bottomLeftCorner.length = 0;
						topLeftCorner.length = 0;
					}
					return commandStack.source[0];

		}

		
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds():void{
			if (commandStack.length == 0) { return; }
		}	
		
		private var startPoint:CommandStackItem;
		private var topLine:CommandStackItem;
		private var topRightCorner:CommandStack;
		private var rightLine:CommandStackItem;
		private var bottomRightCorner:CommandStack;
		private var bottomLine:CommandStackItem;
		private var bottomLeftCorner:CommandStack;	
		private var leftLine:CommandStackItem;
		private var topLeftCorner:CommandStack;
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				if (!commandStack.length) {
					//one top level item permits a single renderDelegate call
					var commandStackItem:CommandStackItem = commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())) ;	
					commandStackItem.renderDelegateStart.push(updateCommandStack);
					var commandStack:CommandStack = commandStackItem.commandStack;
					//set up quick references to manipulate items directly
					startPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.MOVE_TO));
					topLine = commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					topRightCorner=commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())).commandStack ;
					rightLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					bottomRightCorner=commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())).commandStack ;
					bottomLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					bottomLeftCorner=commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())).commandStack ;
					leftLine=commandStack.addItem(new CommandStackItem(CommandStackItem.LINE_TO));
					topLeftCorner=commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())).commandStack ;
				}
				updateCommandStack();
				//commandStack.length=0;
	
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
					_layoutRectangle = _layoutConstraint.layoutRectangle;


					if (isNaN(_width) || isNaN(_height)) {
						//layout defined initial state
						_width = layoutRectangle.width;
						_height = layoutRectangle.height;
						_x = layoutRectangle.x;
						_y = layoutRectangle.y;
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
			
		
		 	if(_layoutConstraint) calculateLayout();
		 	//re init if required
		 	if (invalidated) preDraw();
		 	
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