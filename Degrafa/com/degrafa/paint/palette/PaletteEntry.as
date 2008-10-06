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
package  com.degrafa.paint.palette{
	import com.degrafa.core.DegrafaObject;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	[DefaultProperty("value")]
	
	public class PaletteEntry extends DegrafaObject{
		
		public function PaletteEntry(name:String=undefined, value:Object=null){
			super();
			
			this.name = name;
			this.value = value;
			
		}
				
		protected var typeName:String;
		protected var type:Class;
		
				
		private var _name:String;
		//override so this can be explicitly set
		override public function get name():String{
			return _name;
		}
		public function set name(value:String):void{
			_name=value;
		}
		
		private var _value:Object;
		
		public function get value():Object{
			return _value;
		}
		public function set value(value:Object):void{
			if(_value != value){ 
				var oldValue:Object =_value;
				_value=value;
			
				//set the type
				typeName = getQualifiedClassName(_value);
				typeName = typeName.replace("::",".");
				type = Class(getDefinitionByName(typeName));
				
				initChange("value",oldValue,_value,this);
			}
			
		}
		
		
		
	}
}