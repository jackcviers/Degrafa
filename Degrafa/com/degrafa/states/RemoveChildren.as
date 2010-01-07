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
	
	import flash.utils.Dictionary;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("RemoveChild.png")]
	
	/**
	* The RemoveChildren class removes an array Geomerty objects, such as a Circles, 
	* from a target as part of a view state.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
	**/
	public class RemoveChildren implements IOverride{
		
		/**
		* The children to remove from the view.
		**/
		public var targets:Array;
		
		//stores the parent,index and reference to the removed items so we can revert
		//on remove.
		private var oldItemValues:Dictionary = new Dictionary(true);
		
		//store unique list of parents for when we reset the geometry
		private var oldParents:Dictionary = new Dictionary(true);
		
		private var removed:Boolean;
		
		/**
		* Constructor.
		**/
		public function RemoveChildren(targets:Array = null){
			this.targets = targets;
		}

		/**
		* Initializes the override.
		**/
		public function initialize():void {}

		/**
		 * Resolves the target Reference
		 **/
		public function targetRef(parent:IDegrafaStateClient):Object{
			//in this case return an array of oldParents
			var ret:Array=[];
			var i:int=0;
			var l:int=targets.length;
			//convert ids to Geometry references
			for (;i<l;i++){
				if (targets[i] is String) targets[i]=parent[targets[i]];
			}
			
			for each (var item:Geometry in targets){
				var oldParent:Geometry=null;
				
				if(item.parent){
					oldParent = item.parent as Geometry; 
				}
				else{//else it's root
					oldParent = parent as Geometry;
				}
				if (oldParent) ret.push(oldParent);
			}
			
			return ret;
		}		
		
		
		/**
		* Applies the override.
		**/
		public function apply(parent:IDegrafaStateClient):void{
			removed = false;
			
			for each (var item:Geometry in targets){
				var oldParent:Geometry=null;
				
				if(item.parent){
					oldParent = item.parent as Geometry; 
				}
				else{//else it's root
					oldParent = parent as Geometry;
				}
				
				//no valid parent skip to next
				if(!oldParent){continue;}
				
				oldParents[oldParent]=oldParent;
				
				//add to dictionary so it's remembered
				oldItemValues[item]= {value:item,parent:oldParent,index:oldParent.geometryCollection.getItemIndex(item)};
				
				//remove the item
				oldParent.geometryCollection.removeItem(item);
			}
						
			removed = true;
		}
		
		/**
		* Removes the override.
		**/
		public function remove(parent:IDegrafaStateClient):void{
			
			//in this verison because we store the parent we don't 
			//use the passed parent
			for each (var item:Object in oldItemValues){
				Geometry(item.parent).geometryCollection.addItemAt(item.value, item.index);
			}
			
			var tempGeometry:Array=[];
			
			//required so we are sure the parents are reset as required.
			for each (var oldParent:Geometry in oldParents){
				tempGeometry.length=0; 
		        tempGeometry = tempGeometry.concat(oldParent.geometryCollection.items);
		        oldParent.geometry = tempGeometry;
			}
							        
			removed = false;
		}
	}
}