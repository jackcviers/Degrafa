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
package com.degrafa.core.collections{
	
	import flash.display.DisplayObject;
	
	
	/**
 	* The DisplayObjectCollection stores a collection of flash.display.DisplayObject 
 	* objects.
 	**/
	public class DisplayObjectCollection extends DegrafaCollection{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The display object collection constructor accepts 2 optional arguments 
	 	* that specify the display objects to be added and a event operation flag.</p>
	 	* 
	 	* @param array An array of DisplayObject objects.
	 	* @param suppressEvents A boolean value indicating if events should not be 
	 	* dispatched for this collection.
	 	*/		
		public function DisplayObjectCollection(array:Array=null,suppressEvents:Boolean=false){
			super(DisplayObject,array,suppressEvents);
			
		}
		
		
		/**
		* Adds a DisplayObject item to the collection.  
		* 
		* @param value The DisplayObject object to be added.
		* @return The DisplayObject object that was added.   
		**/		
		public function addItem(value:DisplayObject):DisplayObject{
			return super._addItem(value);
		}
		
		/**
		* Removes an DisplayObject item from the collection.  
		* 
		* @param value The DisplayObject object to be removed.
		* @return The DisplayObject object that was removed.   
		**/	
		public function removeItem(value:DisplayObject):DisplayObject{
			return super._removeItem(value);
		}
		
		/**
		* Retrieve a DisplayObject item from the collection based on the index value 
		* requested.  
		* 
		* @param index The collection index of the DisplayObject object to retrieve.
		* @return The DisplayObject object that was requested if it exists.   
		**/
		public function getItemAt(index:Number):DisplayObject{
			return super._getItemAt(index);
		}
		
		/**
		* Retrieve a DisplayObject item from the collection based on the object value.  
		* 
		* @param value The DisplayObject object for which the index is to be retrieved.
		* @return The DisplayObject index value that was requested if it exists. 
		**/
		public function getItemIndex(value:DisplayObject):int{
			return super._getItemIndex(value);
		}
		
		/**
		* Adds a DisplayObject item to this collection at the specified index.  
		* 
		* @param value The DisplayObject object that is to be added.
		* @param index The position in the collection at which to add the DisplayObject object.
		* 
		* @return The DisplayObject object that was added.   
		**/
		public function addItemAt(value:DisplayObject,index:Number):DisplayObject{
			return super._addItemAt(value,index);	
		}
		
		/**
		* Removes a DisplayObject object from this collection at the specified index.  
		* 
		* @param index The index of the DisplayObject object to remove.
		* @return The DisplayObject object that was removed.   
		**/
		public function removeItemAt(index:Number):DisplayObject{
			return super._removeItemAt(index);
		}
		
		/**
		* Change the index of the DisplayObject object within this collection.  
		* 
		* @param value The DisplayObject object that is to be repositioned.
		* @param newIndex The position at which to place the DisplayObject object within the collection.
		* @return True if the operation is successful False if unsuccessful.   
		**/
		public function setItemIndex(value:DisplayObject,newIndex:Number):Boolean{
			return super._setItemIndex(value,newIndex);
		}
		
		/**
		* Adds a series of DisplayObject objects to this collection.  
		*
		* @param value The collection to be added to this DisplayObject collection.  
		* @return The resulting DisplayObjectCollection after the objects are added.   
		**/
		public function addItems(value:DisplayObjectCollection):DisplayObjectCollection{
			//todo
			super.concat(value.items)
			return this;
		}
		
		
	}
}