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
	            /*******************
	            * 
	            * 	Cannot get a reference to the parent geometry collection
	            * 
	            *********************/
	            /*
	            case "before":
	            {
	                obj.parent.addChildAt(target,
	                    obj.parent.getChildIndex(obj));
	                break;
	            }
	
	            case "after":
	            {
	                obj.parent.addChildAt(target,
	                    obj.parent.getChildIndex(obj) + 1);
	                break;
	            } */
	
	            case "firstChild":
	            {
	                obj.geometryCollection.addItemAt(IGeometry(target), 0);
	                break;
	            }
	
	            case "lastChild":
	            default:
	            {
	                obj.geometryCollection.addItem(IGeometry(target));
	            }
	        }
	
	        _added = true;
		}
		
		public function remove(parent:Geometry):void
		{
			var obj:Geometry = relativeTo ? relativeTo : parent;
			
			obj.geometryCollection.removeItem(IGeometry(target));
		}
	}
}