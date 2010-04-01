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
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	
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
 	*  @see http://degrafa.org/source/RoundedRectangleComplex/RoundedRectangleComplex.html
 	*  
 	**/	
	public class RoundedRectangleComplex extends Geometry implements IGeometry{
		/**
		 *  private constant used to avoid unnecessary trignometry calculations
		 */
		private static const TRIG:Number = 0.4142135623730950488016887242097; 
		
		
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
			
			if (x) this.x=x;
			if (y) this.y=y;
			if (width) this.width=width;
			if (height) this.height=height;
			if (topLeftRadius) this.topLeftRadius=topLeftRadius;
			if (topRightRadius) this.topRightRadius=topRightRadius;
			if (bottomLeftRadius) this.bottomLeftRadius=bottomLeftRadius;
			if (bottomRightRadius) this.bottomRightRadius=bottomRightRadius;
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
		override public function set data(value:Object):void{			
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
					_bottomRightRadius = tempArray[7];
					invalidated = true;
				}	
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
				if (hasLayout) super.x=value
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
				if (hasLayout) super.y=value
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
				if (hasLayout) super.width=value
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
				if (hasLayout) super.height=value
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
		
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return new Rectangle(x, y, width, height);
		}
		
		private var _permitCornerInversion:uint;
		[Inspectable(category="General", enumeration="true,false")]
		/**
		 * If any of the corner radii are negative, the corners with negative values will cut inwards if permitCornerInversion is true. 
		 * Defaults to false, in which case negative corner radius values represent a zero corner radius.
		 */
		public function get permitCornerInversion():Boolean {
			return _permitCornerInversion? true:false;
		}
		public function set permitCornerInversion(value:Boolean):void {
			if (value=!_permitCornerInversion) {
				_permitCornerInversion = value?1:0;
				invalidated = true;
			}
		}
		
		
		private static const  _sides:Array=["none","top","right","bottom","left"];
		private var _unclosedSide:int=-1;
		[Inspectable(category="General", enumeration="top,left,right,bottom,none")]
		/**
		 * A utility setting to prevent a stroke rendering on one side of this RoundedRectangleComplex, if set to one of top,left,right,bottom.
		 * The default value is none which means the RoundedRectangleComplex will draw with a complete stroke on all sides - the usual case.
		 * This option can be useful for skinning 'appendages' such as tab navigator tabs etc, where the side adjacent to a larger rectangular region should not have a delimiting stroke
		 */
		public function get unclosedSide():String {
			if (_unclosedSide<0) return _sides[0];
			return _sides[_unclosedSide];
		}
		
		public function set unclosedSide(value:String):void {
			if (value!=_sides[_unclosedSide]){
				var idx:int=_sides.indexOf(value);
				var oldval:int;
				if (idx!=-1){
					oldval=_unclosedSide;
					_unclosedSide = idx;
					processUnclosedSide(_unclosedSide,oldval);
					initChange("unclosedSide",_sides[oldval],_sides[_unclosedSide],this)
				}
			} 
		}
		
		
		/**
		 * @private
		 * */
		private function processUnclosedSide(newSide:int,oldSide:int=0):void{
			var sideName:String
			var item:CommandStackItem;
			var newSequence:Array
			if (oldSide>0 ) {
				sideName=_sides[oldSide];
				item=this[sideName+'Line'] as CommandStackItem;
				if (item) item.type=CommandStackItem.LINE_TO;
				if (newSide<1){
					newSequence=sequence.concat();
					newSequence.unshift(startPoint);
					item=CommandStackItem(newSequence[newSequence.length-1]);
					while(item.skip) item=item.previous;
					startPoint.x= (item.type==2)? item.x1:item.x;
					startPoint.y= (item.type==1)? item.y1:item.y;
					commandStack.source=newSequence;
				}
			}

			if (newSide>0) {
				
				sideName=_sides[newSide];
				item=this[sideName+'Line'] as CommandStackItem;

				if (item){
					newSequence=sequence.concat();
					 item.type=CommandStackItem.MOVE_TO;
					 newSide--;
					 while(newSide){
					 	newSide--;
					 	newSequence.push(newSequence.shift());newSequence.push(newSequence.shift());newSequence.push(newSequence.shift());
					 }
					 newSequence.unshift(startPoint);
					 var from:CommandStackItem=CommandStackItem(newSequence[newSequence.length-1]);
					 while (from.skip) from=from.previous;
					 startPoint.x= (from.type==2)? from.x1:from.x;
					 startPoint.y= (from.type==1)? from.y1:from.y;
					 commandStack.source=newSequence;
				} 	
			} 
		}

		/**
		 * private internal function to update the values in the commandStack for rendering. 
		 * This approach is taken to enforce the cornerRadius rules under layout. This method handles the corner calculations and variants with cornerInversion settings
		 * called from the render pipeline in CommandStack and also in preDraw for when layout is not active.
		 * @param	cStack
		 * @param	item
		 * @param	graphics
		 * @param	currentIndex
		 * @return
		 */
		private function updateCommandStack(cStack:CommandStack=null, item:CommandStackItem=null, graphics:Graphics=null,currentIndex:int=0):CommandStackItem {
				
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
				
				
					// make sure that cornerRadii fit within the bounds of the rectangle
					var minSize:Number = Math.min(width, height)*.5;
					var topLeftRadius:Number = Math.abs(this.topLeftRadius) < minSize ? this.topLeftRadius : minSize* (this.topLeftRadius<0?-1:1) ;
					var topRightRadius:Number = Math.abs(this.topRightRadius) < minSize ? this.topRightRadius :minSize* (this.topRightRadius<0?-1:1);
					var bottomLeftRadius:Number = Math.abs(this.bottomLeftRadius) < minSize ? this.bottomLeftRadius : minSize* (this.bottomLeftRadius<0?-1:1);
					var bottomRightRadius:Number =  Math.abs(this.bottomRightRadius) < minSize ? this.bottomRightRadius : minSize* (this.bottomRightRadius<0?-1:1);
					
					//don't permit negative values from the corner radii unless permitCornerInversion is true
					if (!_permitCornerInversion) {
						if (topLeftRadius < 0) topLeftRadius = 0;
						if (topRightRadius < 0) topRightRadius = 0;
						if (bottomLeftRadius < 0) bottomLeftRadius = 0;
						if (bottomRightRadius < 0) bottomRightRadius = 0;
					}
					
					var adjx:Number = 0;
					var adjy:Number = 0;
					//apply fix for player rendering bug
					if ( stroke && stroke.weight < 4  ) {
					//player rendering bug workaround: make sure the coords are offset from integer pixel values by at least 3 twips
					//this seems to solve an anti-aliasing error with small stroke weights that is very obvious for RoundedRectangles
						var adjbase:Number = 0.15;
						var under:Boolean;
						var diff:Number;
						if ((stroke.weight != 2 &&  (diff = Math.abs(x -Math.round(x ))) < adjbase) ) {
							under== x < Math.round(x);
							adjx = (adjbase-diff)* (under?-1:1);
							x += adjx;
						} else {
							if (stroke.weight == 2) { //variation - artefact seems to be centered around midpixel values with stroke.weight==2
								under = x < Math.round(x * 2 ) / 2;
								if ((diff = Math.abs(x -Math.round(x * 2 ) / 2)) < adjbase) {
									adjx = (adjbase-diff)* (under?-1:1);
									x += adjx;
								}
							}
						}
						
						under = y < Math.round(y);
						if (stroke.weight!=2 && (diff = Math.abs(y -Math.round(y ))) < adjbase) {
							adjy = (adjbase-diff)* (under?-1:1);
							y += adjy;
						} else {
						if (stroke.weight == 2) { //variation - artefact seems to be centered around midpixel values with stroke.weight==2
							if ((diff = Math.abs(y -Math.round(y * 2 ) / 2)) < adjbase) {
								under = y < Math.round(y * 2 ) / 2;
								adjy = (adjbase-diff)* (under?-1:1);
								y += adjx;
								}
							}
						}
					}
					//dev note:through initial testing this seems fine, but may also need to test for being on a pixel boundaries as well
					var bottom:Number = y + height -adjx;
					var right:Number = x + width -adjy;
					var innerRightTop:Number = right - Math.abs(topRightRadius);
					var innerRightBottom:Number = right - Math.abs(bottomRightRadius);
					var innerLeftTop:Number = x + Math.abs(topLeftRadius);
					var innerLeftBottom:Number = x + Math.abs(bottomLeftRadius);
					var innerTopLeft:Number = y + Math.abs(topLeftRadius);
					var innerTopRight:Number = y + Math.abs(topRightRadius);
					var innerBottomLeft:Number = bottom - Math.abs(bottomLeftRadius);
					var innerBottomRight:Number = bottom - Math.abs(bottomRightRadius);
					// manipulate the commandStack but do not invalidate its bounds
					//basic rectangle:
					startPoint.x = innerLeftTop;
					startPoint.y = y;
					topLine.x = innerRightTop;
					topLine.y = y;
					rightLine.x = right;
					rightLine.y = innerBottomRight;
					bottomLine.x = innerLeftBottom;
					bottomLine.y = bottom;
					leftLine.x = x;
					leftLine.y = innerTopLeft;
					
					//set to skip
					topRightCorner1.skip = topRightCorner2.skip = topRightRadius? false:true;
					bottomRightCorner1.skip = bottomRightCorner2.skip = bottomRightRadius? false:true;
					bottomLeftCorner1.skip = bottomLeftCorner2.skip = bottomLeftRadius? false:true;
					topLeftCorner1.skip=topLeftCorner2.skip = topLeftRadius? false:true;
					//corners as necessary

						var cornersplitoffset:Number; 
						var controlPointOffset:Number
						var c1x:Number;
						var c1y:Number;
						var c2x:Number;
						var c2y:Number;
						var x1:Number;
						var y1:Number;
						//var manipulate:CommandStackItem;
						//topRightCorner
						if (topRightRadius) {
							cornersplitoffset= Math.SQRT1_2 * topRightRadius;
							controlPointOffset = TRIG * topRightRadius;
							if (topRightRadius < 0) {
								//inversion
								c1x = innerRightTop;
								c1y = y- controlPointOffset;
								x1 = right + cornersplitoffset;
								y1 = y - cornersplitoffset;
								c2x = right +controlPointOffset;
								c2y = innerTopRight;
							} else {
								//normal
								c1x = innerRightTop + controlPointOffset;
								c1y = y;
								c2x = right;
								c2y = innerTopRight - controlPointOffset;
								x1 = innerRightTop + cornersplitoffset;
								y1 = innerTopRight - cornersplitoffset;
							}
									topRightCorner1.cx = c1x;
									topRightCorner1.cy = c1y;
									topRightCorner1.x1 = x1;
									topRightCorner1.y1 = y1;
									topRightCorner2.cx = c2x;
									topRightCorner2.cy = c2y;
									topRightCorner2.x1 = right;
									topRightCorner2.y1 = innerTopRight;
							}
							
							//bottomRightCorner
						if (bottomRightRadius) {
							cornersplitoffset= Math.SQRT1_2 * bottomRightRadius;
							controlPointOffset = TRIG * bottomRightRadius;
							if (bottomRightRadius < 0) {
								//inversion
								c1x = right+ controlPointOffset;
								c1y = innerBottomRight;
								x1 = right + cornersplitoffset;
								y1 = bottom +  cornersplitoffset;
								c2x = innerRightBottom;
								c2y = bottom+controlPointOffset;
							} else {
								//normal
								c1x = right;
								c1y = innerBottomRight + controlPointOffset;
								c2x = innerRightBottom + controlPointOffset;
								c2y = bottom;
								x1 = innerRightBottom + cornersplitoffset;
								y1 = innerBottomRight + cornersplitoffset;
							}
									//manipulate:
									bottomRightCorner1.cx = c1x;
									bottomRightCorner1.cy = c1y;
									bottomRightCorner1.x1 = x1;
									bottomRightCorner1.y1 = y1;
									bottomRightCorner2.cx = c2x;
									bottomRightCorner2.cy = c2y;
									bottomRightCorner2.x1 = innerRightBottom;
									bottomRightCorner2.y1 = bottom;
							}
						
						//bottomLeftCorner
						if (bottomLeftRadius) {
							cornersplitoffset= Math.SQRT1_2 * bottomLeftRadius;
							controlPointOffset = TRIG * bottomLeftRadius;
							if (bottomLeftRadius < 0) {
								//inversion
								c1x = innerLeftBottom;
								c1y = bottom+controlPointOffset;
								x1 = x - cornersplitoffset;
								y1 = bottom +  cornersplitoffset;
								c2x = x-controlPointOffset;
								c2y = innerBottomLeft;
							} else {
								//normal
								c1x = innerLeftBottom - controlPointOffset;
								c1y = bottom;
								c2x = x;
								c2y = innerBottomLeft + controlPointOffset;
								x1 = innerLeftBottom - cornersplitoffset;
								y1 = innerBottomLeft + cornersplitoffset;
							}
									//manipulate:
									bottomLeftCorner1.cx = c1x;
									bottomLeftCorner1.cy = c1y;
									bottomLeftCorner1.x1 = x1;
									bottomLeftCorner1.y1 = y1;
									bottomLeftCorner2.cx = c2x;
									bottomLeftCorner2.cy = c2y;
									bottomLeftCorner2.x1 = x;
									bottomLeftCorner2.y1 = innerBottomLeft;
							}

						
						//topLeftCorner
						if (topLeftRadius) {
							cornersplitoffset= Math.SQRT1_2 * topLeftRadius;
							controlPointOffset = TRIG * topLeftRadius;
								if (topLeftRadius < 0) {
								//inversion
								c1x = x-controlPointOffset;
								c1y = innerTopLeft;
								x1 = x - cornersplitoffset;
								y1 = y -  cornersplitoffset;
								c2x = innerLeftTop;
								c2y = y-controlPointOffset;
							} else {
								//normal
								c1x = x;
								c1y = innerTopLeft - controlPointOffset;
								c2x = innerLeftTop - controlPointOffset;
								c2y = y;
								x1 = innerLeftTop - cornersplitoffset;
								y1 = innerTopLeft - cornersplitoffset;
							}
									//manipulate:
									topLeftCorner1.cx = c1x;
									topLeftCorner1.cy = c1y;
									topLeftCorner1.x1 = x1;
									topLeftCorner1.y1 = y1;
									topLeftCorner2.cx = c2x;
									topLeftCorner2.cy = c2y;
									topLeftCorner2.x1 = innerLeftTop;
									topLeftCorner2.y1 = y;
									
							}
						
					return commandStack.source[0];

		}
		
		
		protected var startPoint:CommandStackItem;
		protected var topLine:CommandStackItem;   
		
		protected var topRightCorner1:CommandStackItem;
		protected var topRightCorner2:CommandStackItem;
		
		protected var rightLine:CommandStackItem;
		
		protected var bottomRightCorner1:CommandStackItem;
		protected var bottomRightCorner2:CommandStackItem;
		
		protected var bottomLine:CommandStackItem;
		
		protected var bottomLeftCorner1:CommandStackItem
		protected var bottomLeftCorner2:CommandStackItem
			
		protected var leftLine:CommandStackItem;
		
		protected var topLeftCorner1:CommandStackItem;
		protected var topLeftCorner2:CommandStackItem;
		

		protected var sequence:Array
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
			
				if (!commandStack.length) {
					//one top level item permits a single renderDelegate call
					//var commandStackItem:CommandStackItem = commandStack.addItem(new CommandStackItem(CommandStackItem.COMMAND_STACK,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack())) ;	
					
					var commandStackItem:CommandStackItem = commandStack.addItem(new CommandStackItem(CommandStackItem.DELEGATE_TO));
					commandStackItem.delegate = updateCommandStack;
										
					//set up quick references to manipulate items directly
					startPoint=commandStack.addItem(new CommandStackItem(CommandStackItem.MOVE_TO));
					topLine = new CommandStackItem(CommandStackItem.LINE_TO);
					
					topRightCorner1=new CommandStackItem(CommandStackItem.CURVE_TO);
					topRightCorner2=new CommandStackItem(CommandStackItem.CURVE_TO);
					
					rightLine=new CommandStackItem(CommandStackItem.LINE_TO);
					
					bottomRightCorner1=new CommandStackItem(CommandStackItem.CURVE_TO);
					bottomRightCorner2=new CommandStackItem(CommandStackItem.CURVE_TO);
					
					bottomLine=new CommandStackItem(CommandStackItem.LINE_TO);
					
					bottomLeftCorner1=new CommandStackItem(CommandStackItem.CURVE_TO);
					bottomLeftCorner2=new CommandStackItem(CommandStackItem.CURVE_TO);
					
					leftLine=new CommandStackItem(CommandStackItem.LINE_TO);
					
					topLeftCorner1=new CommandStackItem(CommandStackItem.CURVE_TO);
					topLeftCorner2=new CommandStackItem(CommandStackItem.CURVE_TO);
					
					sequence=[topLine,topRightCorner1,topRightCorner2,rightLine,bottomRightCorner1,bottomRightCorner2,bottomLine,bottomLeftCorner1,bottomLeftCorner2,leftLine,topLeftCorner1,topLeftCorner2]
					for each(var item:CommandStackItem in sequence) commandStack.addItem(CommandStackItem(item))
					
					
					
				}
				updateCommandStack();
				if (_unclosedSide>0) processUnclosedSide(_unclosedSide);
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
						_width = _layoutRectangle.width;
						_height = _layoutRectangle.height;
						_x = isNaN(_x)? _layoutRectangle.x:_x;
						_y = isNaN(_y)?_layoutRectangle.y:_y;
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
		 	if(_layoutConstraint) calculateLayout();
		 	
		 	//re init if required
		 	if (invalidated) preDraw();
			
			super.draw(graphics, (rc)? rc:bounds);
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
			if (!_topRightRadius) { _topRightRadius = value.topRightRadius; }
			if (isNaN(_permitCornerInversion)) { _permitCornerInversion = value.permitCornerInversion?1:0; }
		}
		
	}
}