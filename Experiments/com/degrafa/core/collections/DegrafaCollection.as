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
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IDegrafaObject;
	
	
	import flash.utils.getQualifiedClassName;
	
	import mx.events.PropertyChangeEvent;
	
	//base degrafa collection that proxies the array type
	[DefaultProperty("items")]
	/**
 	*  The Degrafa collection stores a collection of objects 
 	*  of a specific type and is the base class for all collection
 	*  objects.
 	**/
	public class DegrafaCollection extends DegrafaObject
	{
		/**
 		*  The type of objects being stored in this colelction.
 		**/
		private var type:Class;
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The Degrafa collection constructor accepts 4 optional arguments 
	 	* that specify it's type, an array of values of the expected type to be added 
	 	* and 2 event operation flags.</p>
	 	* 
	 	* @param type An class value specifing the types of objects being stored here.
	 	* @param array An array of objects that are of the specified type.
	 	* @param suppressEvents A boolean value indicating if events should not be 
	 	* dispatched for this collection.
	 	* @param enableTypeChecking A boolean value indicating if type checking should be performed.
	 	*/							
		public function DegrafaCollection(type:Class,array:Array=null,suppressEvents:Boolean=false,enableTypeChecking:Boolean=true){
	       	
	       	this.type = type;
	       	_enableTypeChecking = enableTypeChecking;
	       	
	       	suppressEventProcessing = suppressEvents;
	       	 
	       	if(array){
	       		items =array;
	       	}
	       	
	    }
				
		private var _enableTypeChecking:Boolean=true;
		/**
		* Allows internal type checking to be turned off.
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get enableTypeChecking():Boolean{
			return _enableTypeChecking;
		}
		public function set enableTypeChecking(value:Boolean):void{
			_enableTypeChecking=value;
		}
		
		
		/**
		* Verifies each item in the passed array for a valid 
		* type and throws a runtime error if an object with 
		* out a valid type is found.
		*
		* @param value An array of objects to test on.
		**/
		private function checkValidTypes(value:Array):void{
			//type check and throw exception if invalid type found
			if(_enableTypeChecking){
				for each (var item:Object in value){
					if(!item is type){
						throw new TypeError(flash.utils.getQualifiedClassName(item) + 
						" is not a valid " + 
						flash.utils.getQualifiedClassName(type));
						
						return;		
					}
				}
			}
		}
		
		
		private var _items:Array=[];
		/**
		* An array of items being stored in this collection.
		**/
		public function get items():Array{
			return _items;
		}
		public function set items(value:Array):void{
						
			//type check items
			checkValidTypes(value);
			//compare and update
			if(value !=_items){
				
				//clear any event listeners
				if(_items && _items.length && enableEvents && hasEventManager){
					removeListeners();
				}
				
				var oldValue:Array = _items;
				_items=value;
				
				if(enableEvents && hasEventManager){
					//call local helper to dispatch event	
					initChange("items",oldValue,_items,this);
				}
			}
			
			//add event listeners
			if (value && value.length) addListeners();
			
		}
		
		
		/**
		* Adds a new item to the collection.
		* 
		* @param value The item to add. 
		* @return The item added. 
		**/
		protected function _addItem(value:*):*{
			addListener(value);
			concat(value);
			return value;
		}
		
		/**
		* Removes a item from the collection.
		*
		* @param value The item to remove.
		* @return The item removed. 
		**/
		protected function _removeItem(value:*):*{
			
			//get the index
			var index:int = indexOf(value,0);
			_removeItemAt(index);
			
			return null;
		}
		
		/**
		* Return a item at the given index.
		*
		* @param value The item index to return.
		* @return The item requested. 
		**/
		protected function _getItemAt(index:Number):*{
			return items[index];
		}
		
		/**
		* Return the index for the item in the collection.
		*
		* @param value The item to find.
		* @return The index location of the item. 
		**/
		protected function _getItemIndex(value:*):int{
			return indexOf(value,0);
		}
		
		
		/**
		* Add a item at the given index.
		*
		* @param value The item to add to the collection.
		* @param index The index at which to add the item.
		* @return The item added.
		**/
		protected function _addItemAt(value:Object,index:Number):*{
			addListener(value);
			splice(index,0,value);
			return value;
		}
		
		/**
		* Removes a item from the collection.
		*
		* @param value The item index to remove. 
		* @return The removed item.
		**/
		protected function _removeItemAt(index:Number):*{
			//clean up
			removeListener(items[index]);
			return splice(index,1)[0];
		}
		
		/**
		* Change the position of an item in the collection
		*
		* @param index The items new index. 
		* @param value The item to be repositioned.
		* @return True if the item was repositioned. 
		**/
		protected function _setItemIndex(value:*,newIndex:Number):Boolean{
			var spliced:Array = items.splice(items.indexOf(value),1);
     		items.splice(newIndex, 0, spliced[0]);
     		return true;
		}
		
		//to be overidden in subclasse if nessesary
		
		/**
		* Addes a property change event listener and a parent reference to each item in the collection.
		**/
		public function addListeners():void{
			if(enableEvents){
				for each (var item:Object in items){
					if(item is IDegrafaObject){
						//update parent reff
						IDegrafaObject(item).parent = this.parent;
						
						if(IDegrafaObject(item).enableEvents){
							IDegrafaObject(item).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
						}
					}
					
				}
			}
		}
		
		/**
		* Removes the property change event listener and parent reference from each item in the collection.
		**/
		public function removeListeners():void{
			for each (var item:Object in items){
				if(item is IDegrafaObject){
					//update parent reff
					IDegrafaObject(item).parent = null;
					
					IDegrafaObject(item).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Addes a property change event listener and a parent reference to the passed object.
		**/
		public function addListener(value:*):void{
			if(value is IDegrafaObject){
				//update parent reff
				IDegrafaObject(value).parent = this.parent;
				
				if(enableEvents){
					if(IDegrafaObject(value).enableEvents){
						IDegrafaObject(value).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
			}
		}
		
		/**
		* Removes the property change event listener and parent reference from the passed object.
		**/
		public function removeListener(value:*):void{
			if(value is IDegrafaObject){
				//update parent reff
				IDegrafaObject(value).parent = null;
				
				IDegrafaObject(value).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
			}
			
		}
		
		
		/**
		* Property change event handler for this collection.
		**/
		public function propertyChangeHandler(event:PropertyChangeEvent):void{
			if(!suppressEventProcessing){
				dispatchEvent(event);
			}
		}
		
		
		//proxy for array calls in some cases the subclasses may override these
		//to provide additional function or safety
		
		/**
		* Concatenates the elements specified in the parameters with the elements in an array and creates a new array.
		* 
		* @see Array
		**/
		public function concat(... args):Array{
			
			var oldValue:Array = _items;
			 	
			//type check item(s)
			checkValidTypes(args);
			
			var i:int = 0
			var length:int = args.length
			
			for (; i<length;i++){
				addListener(args[i]);
			}	
			
			_items = items.concat(args);
			
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
			 
			return _items;
			
		} 
		
		/**
		* Executes a test function on each item in the array until an item is reached that returns false for the specified function.
		* 
		* @see Array
		**/
		public function every(callback:Function, thisObject:* = null):Boolean{
			return items.every(callback,thisObject);
		}
		
		/**
		* Executes a test function on each item in the array and constructs a new array for all items that return true for the specified function.
		* 
		* @see Array
		**/
		public function filter(callback:Function, thisObject:* = null):Array{
			return items.filter(callback,thisObject);
		}
		
		/**
		* Executes a function on each item in the array.
		* 
		* @see Array
		**/
		public function forEach(callback:Function, thisObject:* = null):void{
			items.forEach(callback, thisObject);
		}
		
		/**
		* Searches for an item in an array by using strict equality (===) and returns the index position of the item.
		* 
		* @see Array
		**/
		public function indexOf(searchElement:*, fromIndex:int = 0):int{
			return items.indexOf(searchElement, fromIndex);
		}
		
		/**
		* Converts the elements in an array to strings, inserts the specified separator between the elements, concatenates them, and returns the resulting string.
		* 
		* @see Array
		**/
		public function join(sep:*):String{
			return items.join(sep);
		}
		
		/**
		* Searches for an item in an array, working backward from the last item, and returns the index position of the matching item using strict equality (===).
		* 
		* @see Array
		**/
		public function lastIndexOf(searchElement:*, fromIndex:int = 0x7fffffff):int{
			return items.lastIndexOf(searchElement, fromIndex);
		}
		
		/**
		* Executes a function on each item in an array, and constructs a new array of items corresponding to the results of the function on each item in the original array.
		* 
		* @see Array
		**/
		public function map(callback:Function, thisObject:* = null):Array{
			return items.map(callback, thisObject);
		}
		
		/**
		* Removes the last element from an array and returns the value of that element.
		* 
		* @see Array
		**/
		public function pop():*{
			removeListener(items[items.length-1]);
			
			var oldValue:Array = _items;
			
			var item:* =items.pop();
			
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
			
			return item;
		}
		
		/**
		* Adds one or more elements to the end of an array and returns the new length of the array.
		* 
		* @see Array
		**/
		public function push(... args):uint{
						
			var oldValue:Array = _items;
			 
			 //type check item(s)
			checkValidTypes(args);
			
			var i:int=0;	
			var len:int=args.length;
			
			for (i; i<len;i++){
				addListener(args[i]);
				items.push(args[i]);
			}	
			 			
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
						 	
			return items.length;
			
		}
		
		/**
		* Reverses the array in place.
		* 
		* @see Array
		**/
		public function reverse():Array{
			var oldValue:Array = _items;
			
			items = items.reverse();
						
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
			
			return items;
		}
		
		/**
		* Removes the first element from an array and returns that element.
		* 
		* @see Array
		**/
		public function shift():*{
			
			removeListener(items[0]);
			
			var oldValue:Array = _items;
			
			var item:* =items.shift();
			
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
			
			return item;
		}
		
		/**
		* Returns a new array that consists of a range of elements from the original array, without modifying the original array.
		* 
		* @see Array
		**/
		public function slice(startIndex:int = 0, endIndex:int = 16777215):Array{
			return items.slice(startIndex, endIndex);
		}
		
		/**
		* Executes a test function on each item in the array until an item is reached that returns true.
		* 
		* @see Array
		**/
		public function some(callback:Function, thisObject:* = null):Boolean{
			return items.some(callback, thisObject);
		}
		
		/**
		* Sorts the elements in an array.
		* 
		* @see Array
		**/
		public function sort(... args):Array{
			return items.sort(args);
		}
		
		/**
		* Sorts the elements in an array according to one or more fields in the array.
		* 
		* @see Array
		**/
		public function sortOn(fieldName:Object, options:Object = null):Array{
			return items.sortOn(fieldName,options);
		}
		
		/**
		* Adds elements to and removes elements from an array.
		* 
		* @see Array
		**/
		public function splice(startIndex:int, deleteCount:uint, ... values):Array{
				
			//type check item(s)
			checkValidTypes(values);
			
			var i:int=0;	
			var len:int=values.length;
				
			for (i; i<len;i++){
				addListener(values[i]);
			}
						 
			var oldValue:Array = _items;
			
			var returnArray:Array
			
			if(values.length == 1){
				returnArray=_items.splice(startIndex,deleteCount,values[0]);
			}
			else if(values.length > 1){
				returnArray=_items.splice(startIndex,deleteCount,values);
			}
			else{
				returnArray=_items.splice(startIndex,deleteCount);
			}
			
			if(returnArray){
				len=returnArray.length;
			 	for (i= 0; i<len;i++){
			 		removeListener(returnArray[i]);
				}	
			}
				
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
			
			return returnArray;
		}
		
		/**
		* Adds one or more elements to the beginning of an array and returns the new length of the array.
		* 
		* @see Array
		**/
		public function unshift(... args):uint{
			 
			//type check item(s)
			checkValidTypes(args);
			
			var oldValue:Array = _items;
			
			var i:int=0;	
			var len:int=args.length;
				
			for (i; i<len;i++){
				addListener(args[i]);
				items.unshift(args[i]);
			}	
			
			//call local helper to dispatch event	
			initChange("items",oldValue,_items,this);
						 
			return items.length;
			
		}
		
		/**
		 * Gets a cursor for the items Array 
		 */		
		protected var _cursor:DegrafaCursor;
		public function get cursor():DegrafaCursor
		{
			if(!_cursor)
				_cursor = new DegrafaCursor(items);
				
			return _cursor;
		}
	}
}