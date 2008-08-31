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

////////////////////////////////////////////////////////////////////////////////
// Algorithims translated from and/or based on prefuse ColorLib.java.
// Copyright (c) 2004-2006 Regents of the University of California.
// All rights reserved.
//////////////////////////////////////////////////////////////////////////////// 
package  com.degrafa.paint.palette{
	
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	use namespace flash_proxy;
	
	import com.degrafa.core.utils.ColorUtil;
	import mx.utils.ObjectProxy;
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	import mx.utils.NameUtil;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	
	[Event(name="initialize", type="mx.events.FlexEvent")]
	[Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]
	
	[DefaultProperty("entries")]
	
	[Bindable]	
	public dynamic class Palette extends ObjectProxy implements IMXMLObject {
		
		public var paletteEntries:Dictionary = new Dictionary();
		public var palette:Palette = this as Palette;
		
		public function Palette(){}
		
		private var _colorFrom:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
		* The color value from which the palette wil start. Only used when the 
		* defaultPaletteType is equal to interpolated.
		**/
		public function get colorFrom():Object{
			return _colorFrom;
		}
		public function set colorFrom(value:Object):void{	
			value = ColorUtil.resolveColor(value);
			if(_colorFrom != value){
				_colorFrom= value as uint;
			}
			
			//make sure the default palette is setup
			initDefaultPalette();
			
		}
		
		private var _colorTo:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
		* The color value from which the palette wil end. Only used when the 
		* defaultPaletteType is equal to interpolated.
		**/
		public function get colorTo():Object{
			return _colorTo;
		}
		public function set colorTo(value:Object):void{	
			value = ColorUtil.resolveColor(value);
			if(_colorTo != value){
				_colorTo= value as uint;
			}
			
			//make sure the default palette is setup
			initDefaultPalette();
			
		}
		
		private var _paletteEntryPrefix:String;
		/**
		* The prefix to use for item names. When not specified and using defaultPaletteType the 
		* defaultPaletteType value will be used for items automatically added.  
		**/
		public function get paletteEntryPrefix():String{
			if(!_paletteEntryPrefix){return "";}
			return _paletteEntryPrefix;
		}
		public function set paletteEntryPrefix(value:String):void{			
			if(_paletteEntryPrefix != value){
				_paletteEntryPrefix = value;
			}
		}
		
		
		private var _defaultPaletteCount:int;
		/**
		* The number of entries to be generated. Only used when 
		* defaultPaletteType is one of cool,hot,greyscale or interpolated.
		**/
		public function get defaultPaletteCount():int{
			if(!_defaultPaletteCount){return 12;}
			return _defaultPaletteCount;
		}
		public function set defaultPaletteCount(value:int):void{			
			if(_defaultPaletteCount != value){
				_defaultPaletteCount = value;
			}
		}
		
		private var _defaultPaletteType:String;
		[Inspectable(category="General", enumeration="none,cool,hot,greyscale,interpolated", defaultValue="none")]
		/**
 		* Sets the initial seed type for the palette
 		**/
		public function get defaultPaletteType():String{
			if(!_defaultPaletteType){return "normal";}
			return _defaultPaletteType;
		}
		public function set defaultPaletteType(value:String):void{			
			if(_defaultPaletteType != value){
				_defaultPaletteType = value;
			}
			
			//make sure the default palette is setup
			initDefaultPalette();
			
		}
					
		private var _entries:Array=[]; 
		
		[Inspectable(category="General", arrayType="com.degrafa.palette.PaletteEntry")]
		[ArrayElementType("com.degrafa.palette.PaletteEntry")]
		/**
		* A setter for the items 	
		**/
		public function set entries(value:Array):void{
			
			//make sure the default palette is setup
			initDefaultPalette();
			
			_entries = value;
			
			for each(var entry:PaletteEntry in _entries){
				//at this time value can not be an array so 
				//take the first item and use that
				if(entry.value is Array){
					entry.value = entry.value[0];
				}	
				
				paletteEntries[entry.name] = entry;
			}
			
		}
		
		//remove any entries that are marked as auto
		private function clearAutoEntries():void{
			for each(var entry:PaletteEntry in _entries){
				if (entry.isAutoGenerated){
					var index:int = _entries.indexOf(entry,0);
					entry=null;
					_entries.splice(index,1)[1];
				}
			}
		}
		
		private function initDefaultPalette():void{
			
			if(!_defaultPaletteType){return;}
			
			clearAutoEntries();
			
			//store the return array locally.
			var colorArray:Array;
			
			//make sure we have everything we need depending on the type
			//the below calls return an array we need to change 
			//this array return value to match what entries expect
			//and add them to the dictionary.
			switch(_defaultPaletteType){
				case "none":
					break;
				case "cool":
					colorArray = PaletteUtils.getCoolPalette(defaultPaletteCount);
					break;
				case "hot":
					colorArray = PaletteUtils.getHotPalette(defaultPaletteCount);
					break;
				case "greyscale":
					colorArray = PaletteUtils.getGreyScalePalette(defaultPaletteCount);
					break;		
				case "interpolated":
					colorArray = PaletteUtils.getInterpolatedPalette(defaultPaletteCount,
					colorFrom as uint,colorTo as uint);
					break;		
			
			}
			
			var entryPrefix:String = (paletteEntryPrefix)? paletteEntryPrefix:_defaultPaletteType + "_";
			
			for(var i:int =0;i<colorArray.length;i++){
				if(paletteEntries){
					if(paletteEntries[entryPrefix + i]){
						paletteEntries[entryPrefix + i].value = colorArray[i];
					}
					else{
						paletteEntries[entryPrefix + i] = new PaletteEntry(
						_defaultPaletteType + "_" + i, colorArray[i] ,true);
					}
				}
				else{
					paletteEntries[entryPrefix + i] = new PaletteEntry(
					_defaultPaletteType + "_" + i, colorArray[i] ,true);
				}
			}
			
			
		}
		
		
		public function getItemByName(value:String):*{
			return paletteEntries[value];
		}
		
		public function getItemByIndex(value:int):*{
			return paletteEntries[PaletteEntry(_entries[value]).name];
		}

		public function getValueByName(value:String):*{
			return PaletteEntry(paletteEntries[value]).value;
		}
		
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
	    

	}
}