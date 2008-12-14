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
// Based on Adobe Code
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states{
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("RemoveChild.png")]
	
	/**
	* The RemoveChild class removes a Geomerty object, such as a Circle, 
	* from a target as part of a view state.
	**/
	public class RemoveChild implements IOverride{
		
		/**
		* The child to remove from the view.
		**/
		public var target:IDegrafaStateClient;
		
		private var oldParent:IDegrafaStateClient;
		private var oldIndex:int;
		
		private var removed:Boolean;
		
		/**
		* Constructor.
		**/
		public function RemoveChild(target:IDegrafaStateClient = null){
			this.target = target;
		}

		/**
		* Initializes the override.
		**/
		public function initialize():void {}
		
		/**
		* Applies the override.
		**/
		public function apply(parent:IDegrafaStateClient):void{
			removed = false;
			
			if(Geometry(target).parent){
				oldParent = IDegrafaStateClient(Geometry(target).parent); 
			}
			else{
				oldParent = parent;
			}
			
			if(!oldParent){return;}
			
			oldIndex = oldParent.geometryCollection.getItemIndex(target as IGeometry);
			oldParent.geometryCollection.removeItem(target as IGeometry);
			
			var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(parent.geometryCollection.items);
	        parent.geometry = tempGeometry;
			
			removed = true;
		}
		
		/**
		* Removes the override.
		**/
		public function remove(parent:IDegrafaStateClient):void{
			oldParent.geometryCollection.addItemAt(target as IGeometry, oldIndex);

			var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(parent.geometryCollection.items);
	        parent.geometry = tempGeometry;
	        
			removed = false;
		}
	}
}