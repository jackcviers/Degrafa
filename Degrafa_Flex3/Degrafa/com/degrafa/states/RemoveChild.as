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
	
	[IconFile("RemoveChild.png")]
	
	/**
	* The RemoveChild class removes a Geomerty object, such as a Circle, 
	* from a target as part of a view state.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
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
		 * Resolves the target Reference
		 **/
		public function targetRef(parent:IDegrafaStateClient):Object{
			oldParent=null;
			if(Geometry(target).parent){
				oldParent = IDegrafaStateClient(Geometry(target).parent); 
			}
			else{//else it's root
				oldParent = parent;
			}
			return oldParent;
		}
		/**
		* Applies the override.
		**/
		public function apply(parent:IDegrafaStateClient):void{
			removed = false;
			
			oldParent = targetRef(parent) as IDegrafaStateClient;
			if(!oldParent){return;}
			
			oldIndex = oldParent.geometryCollection.getItemIndex(target as IGeometry);
			oldParent.geometryCollection.removeItem(target as IGeometry);
									
			removed = true;
		}
		
		/**
		* Removes the override.
		**/
		public function remove(parent:IDegrafaStateClient):void{
			oldParent = (targetRef(parent) as IDegrafaStateClient);
			
			oldParent.geometryCollection.addItemAt(target as IGeometry, oldIndex);
			if(!oldParent){return;}
			//required so we are sure the parent is reset as required.	
			var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(parent.geometryCollection.items);
	        parent.geometry = tempGeometry;
	        
			removed = false;
		}
	}
}