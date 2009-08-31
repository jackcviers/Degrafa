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
package com.degrafa.core.collections
{
	import mx.collections.CursorBookmark;
	
	/**
	 *	The DegrafaCursor is a class that aids enumeration and modification of the enclosed Array. 
	 */	
	public class DegrafaCursor
	{
		public var source:Array;
		/**
		 *	The value representing the current location of the cursor. 
		 */		
		public var currentIndex:int;
				
		protected static const BEFORE_FIRST_INDEX:int = -1;
		protected static const AFTER_LAST_INDEX:int = -2;
		
		/**
		 * @param source A reference to the enclosed Array.
		 */		
		public function DegrafaCursor(source:Array)
		{
			this.source = source;
			currentIndex = BEFORE_FIRST_INDEX;
		}
		
		/**
		 * Returns the Object at the currentIndex.
		 * If the currentIndex is before the first index, a null value is returned;
		 * 
		 * @return Object or null.
		 */		
		public function get current():*
		{
			if(currentIndex > BEFORE_FIRST_INDEX)
				return source[currentIndex];
			else
				return null;
		}
		
		/**
		 * Moves the cursor up one item in the currentIndex unless it is at the end.
		 * 
		 * @return Boolean value of whether or not the cursor is at the end of the array.
		 * 
		 */		
		public function moveNext():Boolean
	    {
	        //the afterLast getter checks validity and also checks length > 0
	        if (afterLast)
	        {
	            return false;
	        }
	        // we can't set the index until we know that we can move there first.
	        var tempIndex:int = beforeFirst ? 0 : currentIndex + 1;
	        if (tempIndex >= source.length)
	        {
	            tempIndex = AFTER_LAST_INDEX;
	        }
	        currentIndex = tempIndex;
	        return !afterLast;
	    }
		
		/**
		 * Moves the cursor down one item in the currentIndex unless it is at the beginning.
		 * 
		 * @return Boolean value of whether or not the cursor is at the beginning of the array.
		 * 
		 */		
	    public function movePrevious():Boolean
	    {
	        //the afterLast getter checks validity and also checks length > 0
	        if (beforeFirst)
	        {
	            return false;
	        }
	        // we can't set the index until we know that we can move there first
	        var tempIndex:int = afterLast ? source.length - 1 : currentIndex - 1;
	        
	        currentIndex = tempIndex;
	        return !beforeFirst;
	    }
	    
	    /** 
	     * Moves cursor to the front.
	     */	    
	    public function moveFirst():void
	    {
	    	currentIndex = BEFORE_FIRST_INDEX;
	    }
	    
	    /** 
	     * Moves cursor to the end.
	     */	  
	    public function moveLast():void
	    {
	    	currentIndex = source.length;
	    }
	    
	    /**
	     * Inserts a Object into the array at the currentIndex.
	     * 
	     * @param value The Object to be inserted into the array.
	     * 
	     */	    
	    public function insert(value:*):void
		{
			var insertIndex:int;
	        if (afterLast || beforeFirst)
	        {
	            source.push(value);
	        }
	        else
	        {
	            source.splice(currentIndex, 0, value);
	        }
		}
		
		/**
		 * Removes a Object from the array at the currentIndex.
		 * 
		 * @return The Object removed from the array.
		 */		
		public function remove():*
		{
			var value:Object = source[currentIndex];
			
			source = source.splice(currentIndex, 1);
			
			return value;
		}
	    
        /**
         * Moves the currentIndex using the bookmark and offset.
         * 
         * @param bookmark CursorBookmark used to assist the seek. The enumeration values are FIRST, CURRENT, LAST.
         * @param offset Number of places away from the bookmark the currentIndex should be moved.
         */	    
        public function seek(bookmark:CursorBookmark, offset:int = 0):void
	    {
	        if (source.length == 0)
	        {
	            currentIndex = AFTER_LAST_INDEX;
	            return;
	        }
	
	        var newIndex:int = currentIndex;
	        if (bookmark == CursorBookmark.FIRST)
	        {
	            newIndex = 0;
	        }
	        else if (bookmark == CursorBookmark.LAST)
	        {
	            newIndex = source.length - 1;
	        }
	
	        newIndex += offset;
	
	        if (newIndex >= source.length)
	        {
	            currentIndex = AFTER_LAST_INDEX;
	        }
	        else if (newIndex < 0)
	        {
	            currentIndex = BEFORE_FIRST_INDEX;
	        }
	        else
	        {
	            currentIndex = newIndex;
	        }
	    }
	    
	    /**
	     * Checks whether or not the cursor is before the first item.
	     */	    
	    public function get beforeFirst():Boolean
	    {
	        return currentIndex == BEFORE_FIRST_INDEX || source.length == 0;
	    }
	    
	    /**
	     * Checks whether or not the cursor is after the last item.
	     */	 
        public function get afterLast():Boolean
	    {
	        return currentIndex == AFTER_LAST_INDEX || source.length == 0;
	    }
	    
	    /**
	     * Gets the Object before the currentIndex
	     */	    
	    public function get previousObject():*
	    {
	    	if (beforeFirst)
	        	return null;
	        
			var tempIndex:int = afterLast ? source.length - 1 : currentIndex - 1;
	        
	        if (tempIndex == BEFORE_FIRST_INDEX)
	        	return null;
	        
	        return source[tempIndex];
	    }
	    /**
	     * Gets the Object after the currentIndex
	     */
	    public function get nextObject():*
	    {
	    	if(afterLast)
	        	return null;
	        
	        var tempIndex:int = beforeFirst ? 0 : currentIndex + 1;
	        
	        if (tempIndex >= source.length)
	        	return null;
	        
	        return source[tempIndex];
	    }
	}
}