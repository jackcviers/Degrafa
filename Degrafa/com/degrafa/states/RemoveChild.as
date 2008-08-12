package com.degrafa.states
{
	import com.degrafa.IGeometry;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.geometry.Geometry;

	public class RemoveChild implements IOverride
	{
		public var target:Geometry;
		
		private var oldParent:GeometryCollection;
		private var oldIndex:int;
		
		private var removed:Boolean;
		
		public function RemoveChild(target:Geometry = null)
		{
			this.target = target;
		}

		public function initialize():void {}
		
		public function apply(parent:Geometry):void
		{
			removed = false;
		
			oldParent = parent.geometryCollection;
			oldIndex = oldParent.getItemIndex(IGeometry(target));
			oldParent.removeItem(IGeometry(target));
			
			removed = true;
		}
		
		public function remove(parent:Geometry):void
		{
			oldParent.addItemAt(IGeometry(target), oldIndex);

			removed = false;
		}
	}
}