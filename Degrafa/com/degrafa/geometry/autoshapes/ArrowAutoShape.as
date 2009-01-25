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
	
	//only need 2 offsets here so need to exclude		
	[Exclude(name="offset3", kind="property")]
	[Exclude(name="offset3Percent", kind="property")]
	
	[Exclude(name="offset4", kind="property")]
	[Exclude(name="offset4Percent", kind="property")]
	
	/**
 	* The ArrowAutoShape element draws a basic arrow.
 	**/
	public class ArrowAutoShape extends AutoShapeTypeOffsets{
		
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
				
		/**
		* Draw the ArrowAutoShape part(s) based on the parameters.
		*/
		override protected function preDrawPart():void{
			
			//store local to calculate
			var _Offset1:Number=_offset1;
			var _Offset2:Number=_offset2;
			
			//calc desired final offset 1
			if (isNaN(_Offset1) && hasLayout && isNaN(_offset1Percent)){
				if(layoutConstraint.width){
					_Offset1 = height/4;		
				}
				else{
					_Offset1 = 0;
				}
			}
			else if (!isNaN(_offset1Percent) && hasLayout){
				if(_offset1Percent >= 1){
					_Offset1 = (_offset1Percent/100)*width;
				}
				else{
					_Offset1 = _offset1Percent*width;
				}		
			}
			else{
				if(isNaN(_Offset1)){
					_Offset1 = 0;	
				}
			}
			
			//calc desired final offset 2
			if (isNaN(_Offset2) && hasLayout && isNaN(_offset2Percent)){
				if(layoutConstraint.width){
					_Offset2 = width/4;		
				}
				else{
					_Offset2 = 0;
				}
			}
			else if (!isNaN(_offset2Percent) && hasLayout){
				if(_offset2Percent >= 1){
					_Offset2 = (_offset2Percent/100)*width;
				}
				else{
					_Offset2 = _offset2Percent*width;
				}		
			}
			else{
				if(isNaN(_Offset2)){
					_Offset2 = 0;	
				}
			}
			
			//Arrow with point begin drawing
			commandStack.addMoveTo(0, _Offset1);
            commandStack.addLineTo(_Offset2, _Offset1);
            commandStack.addLineTo(_Offset2, 0);
            commandStack.addLineTo(width-_Offset2, 0);
            commandStack.addLineTo(width-_Offset2, _Offset1);
            commandStack.addLineTo(width, _Offset1);
            commandStack.addLineTo(width/2, height);
            commandStack.addLineTo(0, _Offset1);
		}
	    
	    /**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:ArrowAutoShape):void{
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_offset1){_offset1 = value.offset1}
			if (!_offset2){_offset2 = value.offset2}
		}
	}
}