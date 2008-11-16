////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states
{
	import com.degrafa.IGeometry;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.geometry.Geometry;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("RemoveChild.png")]

	public class RemoveChild implements IOverride{
		
		public var target:IDegrafaStateClient;
		
		private var oldParent:IDegrafaStateClient;
		private var oldIndex:int;
		
		private var removed:Boolean;
		
		public function RemoveChild(target:IDegrafaStateClient = null)
		{
			this.target = target;
		}

		public function initialize():void {}
		
		public function apply(parent:IDegrafaStateClient):void
		{
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
		
		public function remove(parent:IDegrafaStateClient):void
		{
			oldParent.geometryCollection.addItemAt(target as IGeometry, oldIndex);

			var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(parent.geometryCollection.items);
	        parent.geometry = tempGeometry;
	        
			removed = false;
		}
	}
}