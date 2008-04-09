/* SVN FILE: $Id$ */
/**
 * Description
 *
 * Fake
 * Copyright 2008, Sean Chatman and Garrett Woodworth
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @filesource
 * @copyright		Copyright 2008, Sean Chatman and Garrett Woodworth
 * @link			http://code.google.com/p/fake-as3/
 * @package			fake
 * @subpackage		com.fake.utils
 * @since			2008-03-06
 * @version			$Revision$
 * @modifiedby		$LastChangedBy$
 * @lastmodified	$Date$
 * @license			http://www.opensource.org/licenses/mit-license.php The MIT License
 */
package com.degrafa.core.collections
{
	import mx.collections.CursorBookmark;
	
	[Bindable]
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
		public function get current():Object
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
	    	currentIndex = source.length
	    }
	    
	    /**
	     * Inserts a Object into the array at the currentIndex.
	     * 
	     * @param value The Object to be inserted into the array.
	     * 
	     */	    
	    public function insert(value:Object):void
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
		public function remove():Object
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
	    public function get previousObject():Object
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
	    public function get nextObject():Object
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