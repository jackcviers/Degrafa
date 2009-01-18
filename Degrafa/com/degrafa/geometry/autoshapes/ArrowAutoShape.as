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
 	* The ArrowAutoShape element draws a down arrow
 	* including an offset passed.
 	**/
	public class ArrowAutoShape extends AutoShape{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The ArrowAutoShape constructor accepts 2 optional 
	 	* argument that defines it's properties.</p>
	 	* 
	 	* @param offset1 A number indicating the offset1.
	 	* @param offset2 A number indicating the offset2.
	 	*/	
		public function ArrowAutoShape(offset1:Number=NaN,offset2:Number=NaN){
			super();
			if (offset1) this.offset1=offset1;
			if (offset2) this.offset2=offset2;
			
		}
		
		/**
		* ArrowAutoShape short hand data value.
		* 
		* <p>The ArrowAutoShape data property expects exactly 2 values for offsets</p>
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
					_offset1=	tempArray[0];
					_offset2=	tempArray[1];
					
					invalidated = true;
				}	
			}
		} 
		
		private var _offset1:Number;
		/**
		* The offset1 for the ArrowAutoShape.
		**/
		public function get offset1():Number{
			if(!_offset1){return (hasLayout)? 0:0;}
			return _offset1;
		}
		public function set offset1(value:Number):void{
			
			if (_offset1 != value) {
				_offset1 = value;
				invalidated = true;
			}
		}
		
		private var _offset2:Number;
		/**
		* The offset1 for the ArrowAutoShape.
		**/
		public function get offset2():Number{
			if(!_offset2){return (hasLayout)? 0:0;}
			return _offset2;
		}
		public function set offset2(value:Number):void{
			
			if (_offset2 != value) {
				_offset2 = value;
				invalidated = true;
			}
		}
		
		/**
		* Draw the objects part(s) based on passed parameters.
		*/
		private function preDrawPart():void{
	
			if (isNaN(_offset1) && hasLayout){
				if(layoutConstraint.width){
					_offset1 = height/2;	
				}
				else{
					_offset1 = 0;
				}
			}
			else{
				if(isNaN(_offset1)){
					_offset1 = 0;
				}
			}
			
			if (isNaN(_offset2) && hasLayout){
				if(layoutConstraint.width){
					_offset2 = width/4;	
				}
				else{
					_offset2 = 0;
				}
			}
			else{
				if(isNaN(_offset2)){
					_offset2 = 0;
				}
			}
			
			//Arrow with point begin drawing
			commandStack.addMoveTo(0, _offset1);
            commandStack.addLineTo(_offset2, _offset1);
            commandStack.addLineTo(_offset2, 0);
            commandStack.addLineTo(width-_offset2, 0);
            commandStack.addLineTo(width-_offset2, _offset1);
            commandStack.addLineTo(width, _offset1);
            commandStack.addLineTo(width/2, height);
            commandStack.addLineTo(0, _offset1);
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
			
			if (commandStack.length==0){invalidated=true;}
			
			//re init if required
			if (invalidated) preDraw();
	
			super.draw(graphics, (rc)? rc:bounds);
	    }
	    
	    /**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:ArrowAutoShape):void{
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_offset1){_offset1 = value.offset1}
		}
	}
}