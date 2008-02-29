////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki 
// and Pavan Podila.
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

package com.degrafa.transform{
	import com.degrafa.core.collections.TransformCollection;
	
	import mx.events.PropertyChangeEvent;
	
		
	[DefaultProperty("transforms")]	
	/**
	* TransformGroup is a transformation class to store composit transformations.
	* 
	* Coming Soon. 
	**/
	public class TransformGroup extends Transform{
		public function TransformGroup(){
			super();
		}
		
		private var _transforms:TransformCollection;
		[Inspectable(category="General", arrayType="com.degrafa.transform.ITransform")]
		[ArrayElementType("com.degrafa.transform.ITransform")]
		/**
		* A array of ITransform objects. 	
		**/
		public function get transforms():Array{
			initTransformsCollection();
			return _transforms.items;
		}
		public function set transforms(value:Array):void{
			
			initTransformsCollection();
			_transforms.items = value;
		}
		
		/**
		* Access to the Degrafa transforms collection object for this geometry object.
		**/
		public function get transformCollection():TransformCollection{
			initTransformsCollection();
			return _transforms;
		}
		
		/**
		* Initialize the transforms collection by creating it and adding an event listener.
		**/
		private function initTransformsCollection():void{
			if(!_transforms){
				_transforms = new TransformCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_transforms.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Principle event handler for any property changes to a 
		* transforms object or it's child objects.
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			dispatchEvent(event)
		}
		
		
	}
}