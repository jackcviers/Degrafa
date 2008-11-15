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
	
	import com.degrafa.decorators.IDecorator;
	
	
	/**
 	*  The FillCollection stores a collection of IGraphicsFill objects
 	**/
	public class DecoratorCollection extends DegrafaCollection{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The fill collection constructor accepts 2 optional arguments 
	 	* that specify the fills to be added and a event operation flag.</p>
	 	* 
	 	* @param array An array of IGraphicsFill objects.
	 	* @param suppressEvents A boolean value indicating if events should not be 
	 	* dispatched for this collection.
	 	*/		
		public function DecoratorCollection(array:Array=null,suppressEvents:Boolean=false){
			super(IDecorator,array,suppressEvents);
		}
		
		/**
		* Adds a IGraphicsFill item to the collection.  
		* 
		* @param value The IGraphicsFill object to be added.
		* @return The IGraphicsFill object that was added.   
		**/		
		public function addItem(value:IDecorator):IDecorator{
			return super._addItem(value);
		}
		
		/**
		* Removes an IDecorator item from the collection.  
		* 
		* @param value The IDecorator object to be removed.
		* @return The IDecorator object that was removed.   
		**/	
		public function removeItem(value:IDecorator):IDecorator{
			return super._removeItem(value);
		}
		
		/**
		* Retrieve a IDecorator item from the collection based on the index value 
		* requested.  
		* 
		* @param index The collection index of the IDecorator object to retrieve.
		* @return The IDecorator object that was requested if it exists.   
		**/
		public function getItemAt(index:Number):IDecorator{
			return super._getItemAt(index);
		}
		
		/**
		* Retrieve a IDecorator item from the collection based on the object value.  
		* 
		* @param value The IDecorator object for which the index is to be retrieved.
		* @return The IDecorator index value that was requested if it exists. 
		**/
		public function getItemIndex(value:IDecorator):int{
			return super._getItemIndex(value);
		}
		
		/**
		* Adds a IDecorator item to this collection at the specified index.  
		* 
		* @param value The IDecorator object that is to be added.
		* @param index The position in the collection at which to add the IDecorator object.
		* 
		* @return The IDecorator object that was added.   
		**/
		public function addItemAt(value:IDecorator,index:Number):IDecorator{
			return super._addItemAt(value,index);	
		}
		
		/**
		* Removes a IDecorator object from this collection at the specified index.  
		* 
		* @param index The index of the IDecorator object to remove.
		* @return The IDecorator object that was removed.   
		**/
		public function removeItemAt(index:Number):IDecorator{
			return super._removeItemAt(index);
		}
		
		/**
		* Change the index of the IDecorator object within this collection.  
		* 
		* @param value The IDecorator object that is to be repositioned.
		* @param newIndex The position at which to place the IDecorator object within the collection.
		* @return True if the operation is successful False if unsuccessful.   
		**/
		public function setItemIndex(value:IDecorator,newIndex:Number):Boolean{
			return super._setItemIndex(value,newIndex);
		}
		
		/**
		* Adds a series of IDecorator objects to this collection.  
		*
		* @param value The collection to be added to this IDecorator collection.  
		* @return The resulting FillCollection after the objects are added.   
		**/
		public function addItems(value:DecoratorCollection):DecoratorCollection{
			//todo
			super.concat(value.items)
			return this;
		}
		
		
	}
}