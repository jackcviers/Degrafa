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
	import flash.utils.Dictionary;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("SetProperty.png")]
	/**
	* The SetProperties class specifies an array properties and values that 
	* get modified for this state.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
	**/
	public class SetProperties implements IOverride{
		
		/**
		* Constructor.
		**/
	    public function SetProperties(target:Object = null, names:Array = null,values:Array=null){
	        this.target = target;
	        this.names = names;
	        this.values = values;
	    }
		
		//stores the old values and properties changed in a name value pair
		//so they can be reverted on remove.
	    private var oldValues:Dictionary = new Dictionary(true);
	    
		
		/**
		* An array of property nanmes being changed.
		**/
	    public var names:Array;
		
		/**
		* The object containing the properties to be changed.
		**/
	    public var target:Object;
		
		/**
		* The new values to be applied to the properties list.
		**/
	    public var values:Array;
		
		/**
		* Initializes the override.
		**/
	    public function initialize():void{}
	    
		/**
		* Resolves the target Reference
		**/
		public function targetRef(parent:IDegrafaStateClient):Object{
			var obj:Object;
			//variant over the flex3 approach (a string is assumed to be a property of the parent)
			//consistent with outcome of code in flex4
			if (target is String ) obj=parent[target];
			else obj = target ? target : parent;
			return obj;
		}
		
		
	    /**
	    * Applies the override.
	    **/
	    public function apply(parent:IDegrafaStateClient):void{
	        
	        //get the object being modified if no target is passed then
	        //assume states container (i.e. the passed parent)
			var obj:Object;

			 obj = targetRef(parent);
	        
	        var newValue:*;
	        var propName:String;
	        
	        //the name/value arrays should be of equal length
	        for (var i:int=0;i< names.length;i++){
	        	
	        	propName=names[i];
	        	newValue=values[i];
	        	
	        	//make sure the object has the property if not fail gracefully 
	        	//and just continue
	        	if(obj.hasOwnProperty(names[i])){
	        		
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
	        			        		
	        		//store for later revert
	        		oldValues[propName] = {name:propName,value:obj[propName]}
	        		
	        		//finally set it
	        		setPropertyValue(obj, propName, newValue, obj[propName]);
	        		
	        	}
	        	else{
	        		continue;
	        	}
	        }
	    }
				
		/**
		* Removes the override.
		**/
	    public function remove(parent:IDegrafaStateClient):void{

			var obj:Object;
			obj = targetRef(parent);
	        
	        // Restore the old values
	        for each (var item:Object in oldValues){
	        	setPropertyValue(obj, item.name, item.value, item.value);
	        }
	    }
		
		//apply the property setting
	    private function setPropertyValue(obj:Object, name:String, value:*,valueForType:Object):void{
	        	        
	        if (valueForType is Number){
	            obj[name] = Number(value);
	        }
	        else if (valueForType is Boolean){
	            obj[name] = toBoolean(value);
	        }
	        else{
	            obj[name] = value;
	        }
	    }
				
	    private function toBoolean(value:Object):Boolean{
	        if (value is String)
	            return value.toLowerCase() == "true";
	
	        return value != false;
	    }
	}

}
