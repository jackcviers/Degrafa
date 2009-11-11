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
//
// Based on the Adobe Flex 2 and 3 state implementation and modified for use in 
// Degrafa.
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states{

	import com.degrafa.geometry.Geometry;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("SetProperty.png")]
	/**
	* The SetProperty class specifies a property value that is in effect 
	* only during the parent view state.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
	**/
	public class SetProperty implements IOverride{
		
		/**
		* Constructor.
		**/
	    public function SetProperty(target:Object = null, name:String = null,value:* = undefined){
	        this.target = target;
	        this.name = name;
	        this.value = value;
	    }
	
	    private var oldValue:Object;
	    
		/**
		* The name of the property to change.
		**/
	    public var name:String;
		
		/**
		* The object containing the property to be changed.
		**/
	    public var target:Object;
		
		/**
		* The new value for the property.
		**/
	    public var value:*;
		
		/**
		* Initializes the override.
		**/
	    public function initialize():void{}
	    
	    /**
	    * Applies the override.
	    **/
	    public function apply(parent:IDegrafaStateClient):void{
	        var obj:Object = target ? target : parent;
	        
	        var propName:String = name;
	        var newValue:* = value;
			
			//make sure the object has the property if not fail gracefully 
        	//and just continue
        	if(obj.hasOwnProperty(propName)){
        		
        		//Setting a percent value through AS on width doesn’t work even though the property 
				//has the proxy will not work .. so we need this dirty hack.
        		if (propName=='width'||propName=='height' && String(newValue).indexOf("%")!=-1){
        			newValue = Number(String(newValue).replace("%",""));
				
					if(propName=='width'){
						if(obj.hasOwnProperty("percentWidth")){
							propName = "percentWidth";
						}
					}
					 
					if(propName=='height'){
						if(obj.hasOwnProperty("percentHeight")){
							propName = "percentHeight";
						}
					} 
        		}
			
	        	// Remember the current value so it can be restored
	        	oldValue = obj[propName];
	        
	        	// Set new value
	        	setPropertyValue(obj, propName, newValue, oldValue);
	        	
        	}
        	
	        	
	    }
		
		/**
		* Removes the override.
		**/
	    public function remove(parent:IDegrafaStateClient):void{
	        var obj:Object = target ? target : parent;
	        
	        var propName:String = name;
	        
	        // Restore the old value
	        setPropertyValue(obj, propName, oldValue, oldValue);
	    }
		
		
	    private function setPropertyValue(obj:Object, name:String, value:*,valueForType:Object):void{
	        if (valueForType is Number)
	            obj[name] = Number(value);
	        else if (valueForType is Boolean)
	            obj[name] = toBoolean(value);
	        else
	            obj[name] = value;
	    }
	
	    private function toBoolean(value:Object):Boolean{
	        if (value is String)
	            return value.toLowerCase() == "true";
	
	        return value != false;
	    }
	}

}
