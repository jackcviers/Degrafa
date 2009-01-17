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
 	* The ObtuseTriangleAutoShape element draws a obtuse triangle 
 	* including an offset passed.
 	**/
	public class ObtuseTriangleAutoShape extends AutoShape{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The ObtuseTriangleAutoShape constructor accepts 1 optional 
	 	* argument that defines it's properties.</p>
	 	* 
	 	* @param offset A number indicating the offset.
	 	*/	
		public function ObtuseTriangleAutoShape(offset:Number=NaN){
			super();
			if (offset) this.offset=offset;
		}
		
		/**
		* ObtuseTriangleAutoShape short hand data value.
		* 
		* <p>The ObtuseTriangleAutoShape data property expects exactly 1 value an offset</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:Object):void{
			if(super.data != value){

				//parse the string
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 1)
				{	
					super.data = value;
					_offset=	tempArray[0];
					invalidated = true;
				}	
			}
		} 
		
		private var _offset:Number;
		/**
		* The offset for the ObtuseTriangleAutoShape.
		**/
		public function get offset():Number{
			if(!_offset){return (hasLayout)? 0:0;}
			return _offset;
		}
		public function set offset(value:Number):void{
			
			if (_offset != value) {
				_offset = value;
				invalidated = true;
			}
		}
		
		/**
		* Draw the objects part(s) based on passed parameters.
		*/
		private function preDrawPart():void{
	
			if (isNaN(_offset) && hasLayout){
				if(layoutConstraint.width){
					_offset = width/2;	
				}
				else{
					_offset = 0;
				}
			}
			else{
				if(isNaN(_offset)){
					_offset = 0;
				}
			}
			
			commandStack.addMoveTo(0,0);
			commandStack.addLineTo(width,height);
			commandStack.addLineTo(_offset,height);
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
		public function set derive(value:ObtuseTriangleAutoShape):void{
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_offset){_offset = value.offset}
		}
	}
}