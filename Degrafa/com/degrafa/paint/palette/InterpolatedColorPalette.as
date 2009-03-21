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
package com.degrafa.paint.palette{
	import com.degrafa.core.utils.ColorUtil;
	
	
	[Bindable]
	/**
	* A color palette that auto generates and will interpolate between 
	* the colorFrom and colorTo values.
	**/
	public dynamic class InterpolatedColorPalette extends AutoPalette{
		
		public function InterpolatedColorPalette(){
			super();
		}
		
		private var _colorFrom:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
		* The starting color to interpolate. 
		**/
		public function get colorFrom():Object{
			return _colorFrom;
		}
		public function set colorFrom(value:Object):void{	
			value = ColorUtil.resolveColor(value);
			if(_colorFrom != value){
				_colorFrom= value as uint;
			}
		}
		
		private var _colorTo:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
		* The ending color to interpolate. 
		**/
		public function get colorTo():Object{
			return _colorTo;
		}
		public function set colorTo(value:Object):void{	
			value = ColorUtil.resolveColor(value);
			if(_colorTo != value){
				_colorTo= value as uint;
			}
		}
		
		private var _colors:Array=[];
		/**
		* The ending color to interpolate. 
		**/
		public function get colors():Array{
			return _colors;
		}
		public function set colors(value:Array):void{	
			value = value;
			if(_colors != value){
				_colors= value;
			}
		}
		
		
		/**
		* Generates the entries for this palette.
		**/
		override protected function generatePalette():void{
			
			//clear the existing palette entries
			clear();
			
			if(_colors.length!=0){
				currentLength=0;
				var itemSizeCount:int = requestedSize/(_colors.length-1)
				for (var i:int=0;i<_colors.length-1;i++){
					appendItems(PaletteUtils.getInterpolatedPalette(itemSizeCount,
					ColorUtil.resolveColor(_colors[i]) as uint,
					ColorUtil.resolveColor(_colors[i+1]) as uint));
				}
			}
			else{
				if(colorFrom && colorTo){
					appendItems(PaletteUtils.getInterpolatedPalette(this.requestedSize,colorFrom as uint,colorTo as uint));
				}	
			}
			
			
					
				
		}
				
	}
}