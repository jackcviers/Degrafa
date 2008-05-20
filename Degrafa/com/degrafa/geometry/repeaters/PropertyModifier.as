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
package com.degrafa.geometry.repeaters
{
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.geometry.Geometry;

	public class PropertyModifier extends DegrafaObject implements IRepeaterModifier
	{
	
		private var _sourceGeometry:Geometry;
		private var _targetObject:Object;
		private var _targetProperty:String;
		
		//Property chain (array or string) that we will apply the offset to
		private var _property:String
		
		public function set property(value:String):void {
			_property=value;
			_targetProperty=null;
		}
		
		public function get property():String { return _property }
		
		
		//Numeric amount to offset property by
		private var _offset:Object;
		public function set offset(value:Object):void {
			_offset=value;
		}
		public function get offset():Object { return _offset };
		
		public function PropertyModifier()
		{
			super(); 
		}
		
		/**
		 * We want to find the property we are offsetting and cache them.
		 * If the sourceObject has changed then we need to find the property again
		 */
		private function setTargetProperty(sourceObject:Geometry):void {
			//If we don't have a valid property set one
			_sourceGeometry=sourceObject;
			
			if (_targetObject==null) {
			
				if (_property.indexOf(".")<0) {
					_targetObject=_sourceGeometry;
					_targetProperty=_property;
				} 
				else {
					//We must have a property chain lets use it
					var propChain:Array=_property.split(".");
					
					var tempObject:Object=sourceObject;
					
					for (var i:int=0;i<propChain.length-1;i++) {
						tempObject=tempObject[propChain[i]];
					}
				
					_targetObject=tempObject;
					_targetProperty=propChain[i];
				}
			
			}

			
		}
		
		/**
		 * This applies our numeric offset or array of offsets to the property of our geometryObject
		 */
		public function apply(geometry:Geometry,iteration:Number=0):Geometry {
			if (geometry!=_sourceGeometry)  //Our source object has changed
				setTargetProperty(geometry);
				
			_targetObject[_targetProperty]+=offset;
			
			return geometry;
		}
		
		
	}
}