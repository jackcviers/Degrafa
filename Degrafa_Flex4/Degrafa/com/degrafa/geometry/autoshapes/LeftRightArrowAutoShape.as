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
	
	import com.degrafa.geometry.command.CommandStack;
				
	[Exclude(name="offset4", kind="property")]
	[Exclude(name="offset4Percent", kind="property")]
		
	/**
 	* The LeftRightArrowAutoShape element draws an arrow with a left and right head..
 	**/
	public class LeftRightArrowAutoShape extends AutoShapeTypeOffsets{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The LeftRightArrowAutoShape constructor accepts 3 optional 
	 	* argument that defines it's properties.</p>
	 	* 
	 	* @param offset1 A number indicating the offset1.
	 	* @param offset2 A number indicating the offset2.
	 	* @param offset3 A number indicating the offset3.
	 	*/	
		public function LeftRightArrowAutoShape(offset1:Number=NaN,offset2:Number=NaN,offset3:Number=NaN){
			super();
			if (offset1) this.offset1=offset1;
			if (offset2) this.offset2=offset2;
			if (offset3) this.offset3=offset3;
		}
		
		/**
		* LeftRightArrowAutoShape short hand data value.
		* 
		* <p>The LeftRightArrowAutoShape data property expects exactly 3 values for offsets</p>
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
					_offset3=	tempArray[2];
					invalidated = true;
				}	
			}
		} 
				
		/**
		* Draw the LeftRightArrowAutoShape part(s) based on the parameters.
		*/
		override protected function preDrawPart():void{
						
			//store local to calculate
			var _Offset1:Number=_offset1;
			var _Offset2:Number=_offset2;
			var _Offset3:Number=_offset3;
			
			//calc desired offset 1
			if (isNaN(_Offset1) && hasLayout && isNaN(_offset1Percent)){
				if(_layoutRectangle.width){
						_Offset1 = _layoutRectangle.height/2;		
				}
				else{
					_Offset1 = 0;
				}
			}
			else if (!isNaN(_offset1Percent) && hasLayout){
				if(_offset1Percent >= 1){
					_Offset1 = (_offset1Percent/100)*_layoutRectangle.width;
				}
				else{
					_Offset1 = _offset1Percent*_layoutRectangle.width;
				}		
			}
			else{
				if(isNaN(_Offset1)){
					_Offset1 = 0;	
				}
			}
			
			//calc desired offset 2
			if (isNaN(_Offset2) && hasLayout && isNaN(_offset2Percent)){
				if(_layoutRectangle.width){
						_Offset2 = _layoutRectangle.width/2;		
				}
				else{
					_Offset2 = 0;
				}
			}
			else if (!isNaN(_offset2Percent) && hasLayout){
				if(_offset2Percent >= 1){
					_Offset2 = (_offset2Percent/100)*_layoutRectangle.width;
				}
				else{
					_Offset2 = _offset2Percent*_layoutRectangle.width;
				}		
			}
			else{
				if(isNaN(_Offset2)){
					_Offset2 = 0;	
				}
			}
			
			//calc desired offset 3
			if (isNaN(_Offset3) && hasLayout && isNaN(_offset3Percent)){
				if(_layoutRectangle.width){
						_Offset3 = _layoutRectangle.width/2;		
				}
				else{
					_Offset3 = 0;
				}
			}
			else if (!isNaN(_offset3Percent) && hasLayout){
				if(_offset3Percent >= 1){
					_Offset3 = (_offset3Percent/100)*_layoutRectangle.width;
				}
				else{
					_Offset3 = _offset3Percent*_layoutRectangle.width;
				}		
			}
			else{
				if(isNaN(_Offset3)){
					_Offset3 = 0;	
				}
			}
			
			//begin drawing
			commandStack.addMoveTo(0,_layoutRectangle.height/2);
			commandStack.addLineTo(_Offset2+_Offset3,0);
			commandStack.addLineTo(_Offset2,_Offset1);
			commandStack.addLineTo(_layoutRectangle.width-_Offset2,_Offset1);
			commandStack.addLineTo(_layoutRectangle.width-(_Offset2+_Offset3),0);
			commandStack.addLineTo(_layoutRectangle.width,_layoutRectangle.height/2);
			commandStack.addLineTo(_layoutRectangle.width-(_Offset2+_Offset3),_layoutRectangle.height);
			commandStack.addLineTo(_layoutRectangle.width-_Offset2,_layoutRectangle.height-_Offset1);
			commandStack.addLineTo(_layoutRectangle.width-_Offset2,_layoutRectangle.height-_Offset1);
			commandStack.addLineTo(_Offset2,_layoutRectangle.height-_Offset1);
			commandStack.addLineTo(_Offset2+_Offset3,_layoutRectangle.height);
			commandStack.addLineTo(0,_layoutRectangle.height/2);
			
		}
	    
	    /**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:LeftRightArrowAutoShape):void{
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_offset1){_offset1 = value.offset1}
			if (!_offset2){_offset2 = value.offset2}
			if (!_offset3){_offset3 = value.offset3}
			if (!_offset1Percent){_offset1Percent = value.offset1Percent}
			if (!_offset2Percent){_offset2Percent = value.offset2Percent}
			if (!_offset3Percent){_offset3Percent = value.offset3Percent}
		}
	}
}