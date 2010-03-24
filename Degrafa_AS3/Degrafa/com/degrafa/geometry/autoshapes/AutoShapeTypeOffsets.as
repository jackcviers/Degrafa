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
	
	[Bindable]
	
	/**
	* Provides a base class that has common logic for offset type AutoShapes.
	* 4 Offset values are provided and AutoShapes that extend this base class
	* should use the exclude tag for any undesired properties. i.e. If the 
	* subclass requires only 1 offset then the other offset related properties 
	* should be excluded.
	**/
	public class AutoShapeTypeOffsets extends AutoShape{
		
		/**
		* Constructor.
		**/
		public function AutoShapeTypeOffsets(){
			super();
		}
		
		protected var _offset1:Number;
		/**
		* The offset1 value. A percent value is also accepted here (50%). 
		* If no value is specified then 0 is used. Some subclasses will use a 
		* value other then 0 during their calculation.
		**/
		[PercentProxy("offset1Percent")]
		public function get offset1():Number{
			if(!_offset1){return (hasLayout)? 0:0;}
			return _offset1;
		}
		public function set offset1(value:Number):void{
			
			if (_offset1 != value) {
				_offset1 = value;
				_offset1Percent = NaN;
				invalidated = true;
			}
		}
		
		protected var _offset1Percent:Number;
		/**
		* The offset1 percent value. Acceptable values include .5 
		* or 50 both equating to 50%. How this rule is applied to the 
		* rendered output is specific to subclasses.
		**/
		public function get offset1Percent():Number{
			if(!_offset1Percent){return NaN;}
			return _offset1Percent;
		}
		public function set offset1Percent(value:Number):void{
			if (_offset1Percent != value) {
				_offset1Percent = value;
				invalidated = true;
			}
		}
		
		protected var _offset2:Number;
		/**
		* The offset2 value. A percent value is also accepted here (50%). 
		* If no value is specified then 0 is used. Some subclasses will use a 
		* value other then 0 during their calculation.
		**/
		[PercentProxy("offset2Percent")]
		public function get offset2():Number{
			if(!_offset2){return (hasLayout)? 0:0;}
			return _offset2;
		}
		public function set offset2(value:Number):void{
			
			if (_offset2 != value) {
				_offset2 = value;
				_offset2Percent = NaN;
				invalidated = true;
			}
		}
		
		protected var _offset2Percent:Number;
		/**
		* The offset2 percent value. Acceptable values include .5 
		* or 50 both equating to 50%. How this rule is applied to the 
		* rendered output is specific to subclasses.
		**/
		public function get offset2Percent():Number{
			if(!_offset2Percent){return NaN;}
			return _offset2Percent;
		}
		public function set offset2Percent(value:Number):void{
			if (_offset2Percent != value) {
				_offset2Percent = value;
				invalidated = true;
			}
		}
		
		protected var _offset3:Number;
		/**
		* The offset3 value. A percent value is also accepted here (50%). 
		* If no value is specified then 0 is used. Some subclasses will use a 
		* value other then 0 during their calculation.
		**/
		[PercentProxy("offset3Percent")]
		public function get offset3():Number{
			if(!_offset3){return (hasLayout)? 0:0;}
			return _offset3;
		}
		public function set offset3(value:Number):void{
			
			if (_offset3 != value) {
				_offset3 = value;
				_offset3Percent = NaN;
				invalidated = true;
			}
		}
		
		protected var _offset3Percent:Number;
		/**
		* The offset3 percent value. Acceptable values include .5 
		* or 50 both equating to 50%. How this rule is applied to the 
		* rendered output is specific to subclasses.
		**/
		public function get offset3Percent():Number{
			if(!_offset3Percent){return NaN;}
			return _offset3Percent;
		}
		public function set offset3Percent(value:Number):void{
			if (_offset3Percent != value) {
				_offset3Percent = value;
				invalidated = true;
			}
		}
		
		protected var _offset4:Number;
		/**
		* The offset4 value. A percent value is also accepted here (50%). 
		* If no value is specified then 0 is used. Some subclasses will use a 
		* value other then 0 during their calculation.
		**/
		[PercentProxy("offset4Percent")]
		public function get offset4():Number{
			if(!_offset4){return (hasLayout)? 0:0;}
			return _offset4;
		}
		public function set offset4(value:Number):void{
			
			if (_offset4 != value) {
				_offset4 = value;
				_offset4Percent = NaN;
				invalidated = true;
			}
		}
		
		protected var _offset4Percent:Number;
		/**
		* The offset4 percent value. Acceptable values include .5 
		* or 50 both equating to 50%. How this rule is applied to the 
		* rendered output is specific to subclasses.
		**/
		public function get offset4Percent():Number{
			if(!_offset4Percent){return NaN;}
			return _offset4Percent;
		}
		public function set offset4Percent(value:Number):void{
			if (_offset4Percent != value) {
				_offset4Percent = value;
				invalidated = true;
			}
		}
		
		/**
		* Draw the objects part(s) based on passed parameters.
		* Intended to be overridden by subclasses to draw the base geometry 
		* and calculations that make up it's AutoShape. 
		*/
		protected function preDrawPart():void{
			//overridden in sub classes.
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
			
			//invalidate as perhaps no offset settings
			if(commandStack.length==0){invalidated=true;}
			
			//re init if required
			if (invalidated) preDraw();
	
			super.draw(graphics, (rc)? rc:bounds);
	    }
		
		
	}
}