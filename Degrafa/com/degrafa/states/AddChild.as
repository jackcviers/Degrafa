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
	
	[DefaultProperty("target")]
	public class AddChild implements IOverride
	{
		public var relativeTo:IDegrafaStateClient;
		public var target:IDegrafaStateClient;
		
		public var position:String;
		
		private var _added:Boolean;
		
		public function AddChild(relativeTo:IDegrafaStateClient = null, target:IDegrafaStateClient = null, position:String = "lastChild")
		{
			this.relativeTo = relativeTo;
        	this.target = target;
        	this.position = position;
		}

		public function initialize():void {}
		
		public function apply(parent:IDegrafaStateClient):void
		{
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			_added = false;
			
			switch (position)
	        {
	            
	            case "before":
	            {
	                parent.geometryCollection.addItemAt(target as IGeometry,
	                    parent.geometryCollection.getItemIndex(obj as IGeometry));
	                break;
	            }
	
	            case "after":
	            {
	                parent.geometryCollection.addItemAt(target as IGeometry,
	                    parent.geometryCollection.getItemIndex(obj  as IGeometry) + 1);
	                break;
	            }
	
	            case "firstChild":
	            {
	                parent.geometryCollection.addItemAt(target  as IGeometry, 0);
	                break;
	            }
	
	            case "lastChild":
	            default:
	            {
	                parent.geometryCollection.addItem(target as IGeometry);
	            }
	        }
	
	        _added = true;
		}
		
		public function remove(parent:IDegrafaStateClient):void
		{
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			parent.geometryCollection.removeItem(target  as IGeometry);
		}
	}
}