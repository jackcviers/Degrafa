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
package  com.degrafa.paint.palette{
	
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	use namespace flash_proxy;
	import mx.utils.ObjectProxy;
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	import mx.utils.NameUtil;
	import mx.graphics.IStroke;
	import mx.graphics.IFill;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	 
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("Palette.png")]
	
	[Event(name="initialize", type="mx.events.FlexEvent")]
	[Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]
	
	[DefaultProperty("entries")]
	
	[Bindable]
	/**
	* Base palette object.
	**/	
	public dynamic class Palette extends ObjectProxy implements IMXMLObject {
		
		/**
		* An dictionary of palette entries.
		**/
		public var paletteEntries:Dictionary = new Dictionary();
		
		public var palette:Palette = this as Palette;
		
		public function Palette(){
		}
					
		private var _entries:Array=[]; 
		/**
		* An array of PaletteEntry objects.
		**/
		public function get entries():Array{
			return _entries;
		}
		[Inspectable(category="General", arrayType="com.degrafa.paint.palette.PaletteEntry")]
		[ArrayElementType("com.degrafa.paint.palette.PaletteEntry")]
		public function set entries(value:Array):void{
			
			//still have to store the array local so the items 
			//can be requested in various ways 		
			_entries = value;
			
			//add all the items to the local dictionary
			for each(var entry:PaletteEntry in _entries){
				//at this time value can not be an array so 
				//take the first item and use that
				if(entry.value is Array){
					entry.value = entry.value[0];
				}	
				
				paletteEntries[entry.name] = entry;
			}
			
		}
		
		/**
		* Removes all palette entries.
		**/ 
		public function clear():void{
			_entries.length =0;
		}
		
		/**
		* Returns a palette entry item by name.
		* @return a palette entry object.
		**/		
		public function getItemByName(value:String):*{
			return paletteEntries[value];
		}
		
		/**
		* Returns a palette entry item by index.
		* @return a palette entry object.
		**/
		public function getItemByIndex(value:int):*{
			return paletteEntries[PaletteEntry(_entries[value]).name];
		}
		
		/**
		* Returns a palette entry value by name.
		* @return a palette entry objects value.
		**/
		public function getValueByName(value:String):*{
			return PaletteEntry(paletteEntries[value]).value;
		}
		
		/**
		* Returns a palette entry value by index.
		* @return a palette entry objects value. 
		**/
		public function getValueByIndex(value:int):*{
			return PaletteEntry(paletteEntries[PaletteEntry(_entries[value]).name]).value;
		}
		
		override flash_proxy function callProperty(name:*, ... rest):* {
	       
	        var res:*;
	        
	        switch (name.toString()) {
	        	default:
	        		if(paletteEntries[name] is IFill || paletteEntries[name] is IStroke){
	        			res=paletteEntries[name].value;
	        		}
	        		else{
	        			res=paletteEntries[name];	
	        		}
	        		
	        }

	        return res;
	    }
	
	    override flash_proxy function getProperty(name:*):* {
	    	if(paletteEntries[name].value is IFill || paletteEntries[name].value is IStroke){
	        	return paletteEntries[name].value;
	        }
	        else{
	        	return paletteEntries[name] as PaletteEntry;
	        }
	        
	    }
	
	    override flash_proxy function setProperty(name:*, value:*):void {
	        PaletteEntry(paletteEntries[name]).value = value;
	    }
		
		private var _id:String;
		/**
		* The identifier used by document to refer to this object.
		**/ 
		public function get id():String{
			
			if(_id){
				return _id;	
			}
			else{
				_id =NameUtil.createUniqueName(this);
				return _id;
			}
		}
		public function set id(value:String):void{
			_id = value;
		}
		
		/**
		* The name that refers to this object.
		**/ 
		public function get name():String{
			return id;
		}

		private var _document:Object;
		/**
		*  The MXML document that created this object.
		**/
		public function get document():Object{
			return _document;
		}
		
		/**
		* Called after the implementing object has been created and all component properties specified on the MXML tag have been initialized.
		* 
		* @param document The MXML document that created this object.
		* @param id The identifier used by document to refer to this object.  
		**/
    	public function initialized(document:Object, id:String):void{
	        
	        //if the id has not been set (through as perhaps)
	        if(!_id){	        
		        if(id){
		        	_id = id;
		        }
		        else{
		        	//if no id specified create one
		        	_id = NameUtil.createUniqueName(this);
		        }
	        }
	        _document=document;
	        
	        
	        _isInitialized = true;
	         	        
	        dispatchEvent(new FlexEvent(FlexEvent.INITIALIZE));
	        
	    }
	    
	    /**
		* A boolean value indicating that this object has been initialized
		**/
		private var _isInitialized:Boolean;
	    public function get isInitialized():Boolean{
	    	return _isInitialized;
	    }	    
	    

		/**
		* END Standard code
		**/

	}
}