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
	import com.degrafa.repeaters.IRepeaterModifier;
	
	
	/**
 	*  The RepeaterModifierCollection stores a collection of RepeaterModifier objects
 	**/	
	public class RepeaterModifierCollection extends DegrafaCollection{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The repeater modifier collection constructor accepts 2 optional arguments 
	 	* that specify the repeater modifiers to be added and a event operation flag.</p>
	 	* 
	 	* @param array An array of RepeaterModifier objects.
	 	* @param suppressEvents A boolean value indicating if events should not be 
	 	* dispatched for this collection.
	 	*/	
		public function RepeaterModifierCollection(array:Array=null,suppressEvents:Boolean=false){
			super(IRepeaterModifier,array,suppressEvents);
		
			
		}
		
		/**
		* Adds a RepeaterModifier item to the collection.  
		* 
		* @param value The RepeaterModifier object to be added.
		* @return The RepeaterModifier object that was added.   
		**/			
		public function addItem(value:IRepeaterModifier):IRepeaterModifier{
			return super._addItem(value);
		}
		
		/**
		* Removes an RepeaterModifier item from the collection.  
		* 
		* @param value The RepeaterModifier object to be removed.
		* @return The RepeaterModifier object that was removed.   
		**/	
		public function removeItem(value:IRepeaterModifier):IRepeaterModifier{
			return super._removeItem(value);
		}
		
		/**
		* Retrieve a RepeaterModifier item from the collection based on the index value 
		* requested.  
		* 
		* @param index The collection index of the RepeaterModifier object to retrieve.
		* @return The RepeaterModifier object that was requested if it exists.   
		**/
		public function getItemAt(index:Number):IRepeaterModifier{
			return super._getItemAt(index);
		}
		
		/**
		* Retrieve a RepeaterModifier item from the collection based on the object value.  
		* 
		* @param value The RepeaterModifier object for which the index is to be retrieved.
		* @return The RepeaterModifier index value that was requested if it exists. 
		**/
		public function getItemIndex(value:IRepeaterModifier):int{
			return super._getItemIndex(value);
		}
		
		/**
		* Adds a RepeaterModifier item to this collection at the specified index.  
		* 
		* @param value The RepeaterModifier object that is to be added.
		* @param index The position in the collection at which to add the RepeaterModifier object.
		* 
		* @return The RepeaterModifier object that was added.   
		**/
		public function addItemAt(value:IRepeaterModifier,index:Number):IRepeaterModifier{
			return super._addItemAt(value,index);	
		}
		
		/**
		* Removes a RepeaterModifier object from this collection at the specified index.  
		* 
		* @param index The index of the RepeaterModifier object to remove.
		* @return The RepeaterModifier object that was removed.   
		**/
		public function removeItemAt(index:Number):IRepeaterModifier{
			return super._removeItemAt(index);
		}
		
		/**
		* Change the index of the RepeaterModifier object within this collection.  
		* 
		* @param value The RepeaterModifier object that is to be repositioned.
		* @param newIndex The position at which to place the RepeaterModifier object within the collection.
		* @return True if the operation is successful False if unsuccessful.   
		**/
		public function setItemIndex(value:IRepeaterModifier,newIndex:Number):Boolean{
			return super._setItemIndex(value,newIndex);
		}
		
		/**
		* Adds a series of RepeaterModifier objects to this collection.  
		*
		* @param value The collection to be added to this RepeaterModifier collection.  
		* @return The resulting RepeaterModifiersCollection after the objects are added.   
		**/
		public function addItems(value:RepeaterModifierCollection):RepeaterModifierCollection{
			//todo
			super.concat(value.items)
			return this;
		}
	}
}