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
	
	[Bindable]
	/**
	* A color palette that auto generates one of 3 presets cool, hot or grey.
	**/
	public dynamic class PresetColorPalette extends AutoPalette{
		
		public function PresetColorPalette(){
			super();
		}
		
		private var _type:String="cool";
		/**
		* The type of color space to use one of cool, hot or grey.
		**/
		[Inspectable(category="General", enumeration="cool,hot,grey", defaultValue="cool")]
		public function get type():String{
			if(!_type){return "cool";}
			return _type;
		}
		public function set type(value:String):void{			
			if(_type != value){
				_type = value;
			}
		}
		
		/**
		* Generates the entries for this palette.
		**/
		override protected function generatePalette():void{
			
			//clear the existing palette entries
			clear();
			
			switch(type){
				case "cool":
					appendItems(PaletteUtils.getCoolPalette(this.requestedSize));
					break;
				case "hot":
					appendItems(PaletteUtils.getHotPalette(this.requestedSize));
					break;
				case "grey":
					appendItems(PaletteUtils.getGreyScalePalette(this.requestedSize));
					break;
					
			}
				
		}
				
	}
}