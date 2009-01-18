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
package com.degrafa.geometry.autoshapes{
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	/**
 	* The RightTriangleAutoShape element draws a obtuse triangle 
 	* including an offset1 passed.
 	**/
	public class RightTriangleAutoShape extends AutoShape{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The RightTriangleAutoShape constructor has no parameters.</p>
	 	* 
	 	* @param offset1 A number indicating the offset1.
	 	*/	
		public function RightTriangleAutoShape(){
			super();
		
		}
		
		/**
		* RightTriangleAutoShape short hand data value.
		* 
		* <p>The RightTriangleAutoShape data property expects exactly 1 value an offset1</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:Object):void{		} 
		

		
		/**
		* Draw the objects part(s) based on passed parameters.
		*/
		private function preDrawPart():void{
			
			commandStack.addMoveTo(0,0);
			commandStack.addLineTo(width,height);
			commandStack.addLineTo(0,height);
			commandStack.addLineTo(0,0);
			
		}

		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				commandStack.source.length = 0;
				
				preDrawPart();
				
				invalidated = false;
			}
			
		}
		
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used or the most appropriate size is calculated. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					//default to bounds if no width or height is set
					//and we have layout
					if(isNaN(_layoutConstraint.width)){
						tempLayoutRect.width = bounds.width;
					}
					 
					if(isNaN(_layoutConstraint.height)){
						tempLayoutRect.height = bounds.height;
					}
					
					if(isNaN(_layoutConstraint.x)){
			 			tempLayoutRect.x = bounds.x;
			 		}
			 		
			 		if(isNaN(_layoutConstraint.y)){
			 			tempLayoutRect.y = bounds.y;
			 		}
			 		
					super.calculateLayout(tempLayoutRect);
					_layoutRectangle = _layoutConstraint.layoutRectangle;
			 		invalidated = true;
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
			if (hasLayout) calculateLayout();
			//re init if required
			if (invalidated) preDraw();
	

			super.draw(graphics, (rc)? rc:bounds);
	    }
	    
	    /**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:RightTriangleAutoShape):void{
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}

		}
	}
}