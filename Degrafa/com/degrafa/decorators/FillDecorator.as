package com.degrafa.decorators
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.core.utils.CloneUtil;

	public class FillDecorator implements IGlobalDecorator
	{
		public var parent:Geometry;
		protected var decFill:SolidFill = new SolidFill("forestgreen");
		protected var oldFill:IGraphicsFill;
		
		public function FillDecorator()
		{
		}

		public function execute(parent:Geometry):void
		{
			this.parent = parent;
			oldFill = CloneUtil.clone(parent.fill);
			parent.fill = decFill;
		}
		
		public function cleanup():void
		{
			if(parent.fill == decFill)
			{
				parent.fill = oldFill;
			}
		}
		
	}
}