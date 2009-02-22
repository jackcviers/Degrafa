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
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("AddChild.png")]
	
	[DefaultProperty("target")]
	
	/**
	* The AddChild class adds a child Geometry object, such as a Circle, 
	* to the target as part of a view state.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
	**/
	public class AddChild implements IOverride{
		
		/**
		* The object relative to which the child is added.
		**/
		public var relativeTo:IDegrafaStateClient;
		
		/**
		* The child to be added.
		**/
		public var target:IDegrafaStateClient;
		
		/**
		* The position of the child.
		**/
		public var position:String;
		
		private var _added:Boolean;
		
		/**
		* Constructor.
		**/
		public function AddChild(relativeTo:IDegrafaStateClient = null, target:IDegrafaStateClient = null, position:String = "lastChild"){
			this.relativeTo = relativeTo;
        	this.target = target;
        	this.position = position;
		}
		
		/**
		* Initializes the override.
		**/
		public function initialize():void {}
		
		/**
		* Applies the override.
		**/
		public function apply(parent:IDegrafaStateClient):void{
			
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			_added = false;
			
			switch (position)
	        {
	            
	            case "before":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry,
	                    obj.geometryCollection.getItemIndex(obj as IGeometry));
	                break;
	            }
	
	            case "after":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry,
	                    obj.geometryCollection.getItemIndex(obj  as IGeometry) + 1);
	                break;
	            }
	
	            case "firstChild":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry, 0);
	                break;
	            }
	
	            case "lastChild":
	            default:
	            {
	                obj.geometryCollection.addItem(target as IGeometry);
	            }
	        }
	
	        _added = true;
	        
	        //required so we are sure the parent is reset as required.	        
	        var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(obj.geometryCollection.items);
	        obj.geometry = tempGeometry;
	        	        
		}
		
		/**
		* Removes the override.
		**/
		public function remove(parent:IDegrafaStateClient):void{
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			parent.geometryCollection.removeItem(target as IGeometry);
		}
	}
}