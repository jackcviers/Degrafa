package com.degrafa.states
{
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;

	public class AddChild implements IOverride
	{
		public var relativeTo:Geometry;
		public var target:Geometry;
		
		public var position:String;
		
		private var _added:Boolean;
		
		public function AddChild(relativeTo:Geometry = null, target:Geometry = null, position:String = "lastChild")
		{
			this.relativeTo = relativeTo;
        	this.target = target;
        	this.position = position;
		}

		public function initialize():void {}
		
		public function apply(parent:Geometry):void
		{
			var obj:Geometry = relativeTo ? relativeTo : parent;
			
			_added = false;
			
			switch (position)
	        {
	            
	            case "before":
	            {
	                parent.geometryCollection.addItemAt(IGeometry(target),
	                    parent.geometryCollection.getItemIndex(IGeometry(obj)));
	                break;
	            }
	
	            case "after":
	            {
	                parent.geometryCollection.addItemAt(IGeometry(target),
	                    parent.geometryCollection.getItemIndex(IGeometry(obj)) + 1);
	                break;
	            }
	
	            case "firstChild":
	            {
	                parent.geometryCollection.addItemAt(IGeometry(target), 0);
	                break;
	            }
	
	            case "lastChild":
	            default:
	            {
	                parent.geometryCollection.addItem(IGeometry(target));
	            }
	        }
	
	        _added = true;
		}
		
		public function remove(parent:Geometry):void
		{
			var obj:Geometry = relativeTo ? relativeTo : parent;
			
			parent.geometryCollection.removeItem(IGeometry(target));
		}
	}
}