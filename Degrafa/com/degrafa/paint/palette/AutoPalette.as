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
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	[Bindable]
	/**
	* Base class for auto palettes not intended to be instanced directly.
	**/
	public dynamic class AutoPalette extends Palette
	{
		public function AutoPalette(){
			super();
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onChange);
		}
		
		/**
		* Triggeres the re generation of entry items when internal properties change.
		**/
		public function onChange(event:PropertyChangeEvent):void{
			generatePalette();
		}
		
		private var _entryPrefix:String;
		/**
		* The prefix to use for item names so that they can be properly refferenced.
		* If not specified a default value of "pal_" is used. The items can then be 
		* retrived via myPalette.pal_1
		**/
		public function get entryPrefix():String{
			if(!_entryPrefix){return "pal_";}
			return _entryPrefix;
		}
		public function set entryPrefix(value:String):void{			
			if(_entryPrefix != value){
				_entryPrefix = value;
			}
		}
		
		private var _requestedSize:int;
		/**
		* The number of entries to be generated. Only used with AutoPalettes. 
		* If not specified the default value of 12 is used.
		**/
		public function get requestedSize():int{
			if(!_requestedSize){return 12;}
			return _requestedSize;
		}
		public function set requestedSize(value:int):void{			
			if(_requestedSize != value){
				_requestedSize = value;
			}
		}
		
		/**
		* Overriden in subclasses. Does the work required to populate the palette.
		**/
		protected function generatePalette():void{}
		
		/**
		* Appends the passed array of values to the palette entries array and dictionary.
		**/
		protected function appendItems(value:Array):void{
			for(var i:int =0;i<value.length;i++){
				if(paletteEntries){
					if(paletteEntries[entryPrefix + i]){
						paletteEntries[entryPrefix + i].value = value[i];
					}
					else{
						paletteEntries[entryPrefix + i] = new PaletteEntry(
						entryPrefix + i, value[i]);
					}
				}
				else{
					paletteEntries[entryPrefix + i] = new PaletteEntry(
					entryPrefix + i, value[i]);
				}
			}
		}
		
		
	}
}