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
	
	import com.degrafa.filters.DegrafaFilter;
	
	import flash.filters.BitmapFilter;
	
	import mx.events.PropertyChangeEvent;
	 
	
	
	/**
 	*  The FilterCollection stores a collection of BitmapFilter objects
 	**/
	public class FilterCollection extends DegrafaCollection{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The filter collection constructor accepts 2 optional arguments 
	 	* that specify the filters to be added and a event operation flag.</p>
	 	* 
	 	* @param array An array of BitmapFilter objects.
	 	* @param suppressEvents A boolean value indicating if events should not be 
	 	* dispatched for this collection.
	 	*/		
		public function FilterCollection(array:Array=null,suppressEvents:Boolean=false){
			super(BitmapFilter,array,suppressEvents);
			
		}

		//Internal list of watched degrafa filter proxies
		private var degrafaFilters:Array=[];

		override public function set items(value:Array):void
		{
			if (!value)
				value=[];

			removeAllWatchers();

			degrafaFilters=[];
			var actualFilters:Array=[];

			var i:uint;

			for (i=0; i < value.length; i++)
			{
				var item:*=value[i];
				var df:DegrafaFilter=item as DegrafaFilter;

				if (df)
				{
					actualFilters.push(df.bitmapFilter);
					degrafaFilters.push(df);
					addWatcher(df);
				}
				else
				{
					actualFilters.push(item);
				}
			}

			super.items=actualFilters;
		}

		private function removeAllWatchers():void
		{
			for each (var df:DegrafaFilter in degrafaFilters)
			{
				df.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, filterPropertyChangeHandler);
			}
		}

		private function addWatcher(df:DegrafaFilter):void
		{
			df.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, filterPropertyChangeHandler, false, 0, true);
		}

		private function filterPropertyChangeHandler(event:PropertyChangeEvent):void
		{
			var actualFilter:BitmapFilter=DegrafaFilter(event.target).bitmapFilter;
			dispatchPropertyChange(false, event.property, event.oldValue, event.newValue, actualFilter);
		}
		
		/**
		* Adds a BitmapFilter item to the collection.  
		* 
		* @param value The BitmapFilter object to be added.
		* @return The BitmapFilter object that was added.   
		**/		
		public function addItem(value:BitmapFilter):BitmapFilter{
			return super._addItem(value);
		}
		
		/**
		* Removes an BitmapFilter item from the collection.  
		* 
		* @param value The BitmapFilter object to be removed.
		* @return The BitmapFilter object that was removed.   
		**/	
		public function removeItem(value:BitmapFilter):BitmapFilter{
			return super._removeItem(value);
		}
		
		/**
		* Retrieve a BitmapFilter item from the collection based on the index value 
		* requested.  
		* 
		* @param index The collection index of the BitmapFilter object to retrieve.
		* @return The BitmapFilter object that was requested if it exists.   
		**/
		public function getItemAt(index:Number):BitmapFilter{
			return super._getItemAt(index);
		}
		
		/**
		* Retrieve a BitmapFilter item from the collection based on the object value.  
		* 
		* @param value The BitmapFilter object for which the index is to be retrieved.
		* @return The BitmapFilter index value that was requested if it exists. 
		**/
		public function getItemIndex(value:BitmapFilter):int{
			return super._getItemIndex(value);
		}
		
		/**
		* Adds a BitmapFilter item to this collection at the specified index.  
		* 
		* @param value The BitmapFilter object that is to be added.
		* @param index The position in the collection at which to add the BitmapFilter object.
		* 
		* @return The BitmapFilter object that was added.   
		**/
		public function addItemAt(value:BitmapFilter,index:Number):BitmapFilter{
			return super._addItemAt(value,index);	
		}
		
		/**
		* Removes a BitmapFilter object from this collection at the specified index.  
		* 
		* @param index The index of the BitmapFilter object to remove.
		* @return The BitmapFilter object that was removed.   
		**/
		public function removeItemAt(index:Number):BitmapFilter{
			return super._removeItemAt(index);
		}
		
		/**
		* Change the index of the BitmapFilter object within this collection.  
		* 
		* @param value The BitmapFilter object that is to be repositioned.
		* @param newIndex The position at which to place the BitmapFilter object within the collection.
		* @return True if the operation is successful False if unsuccessful.   
		**/
		public function setItemIndex(value:BitmapFilter,newIndex:Number):Boolean{
			return super._setItemIndex(value,newIndex);
		}
		
		/**
		* Adds a series of BitmapFilter objects to this collection.  
		*
		* @param value The collection to be added to this BitmapFilter collection.  
		* @return The resulting FillCollection after the objects are added.   
		**/
		public function addItems(value:FilterCollection):FilterCollection{
			//todo
			super.concat(value.items)
			return this;
		}
		
		
	}
}