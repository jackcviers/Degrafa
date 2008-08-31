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

	public class RemoveChild implements IOverride
	{
		public var target:IDegrafaStateClient;
		
		private var oldParent:GeometryCollection;
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
		
			oldParent = parent.geometryCollection;
			oldIndex = oldParent.getItemIndex(target as IGeometry);
			oldParent.removeItem(target as IGeometry);
			
			removed = true;
		}
		
		public function remove(parent:IDegrafaStateClient):void
		{
			oldParent.addItemAt(target as IGeometry, oldIndex);

			removed = false;
		}
	}
}