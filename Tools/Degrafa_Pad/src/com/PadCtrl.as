package com
{
	import com.degrafa.*;
	
	import flash.events.*;
	import flash.net.*;
	
	import mx.containers.Canvas;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.FlexEvent;

	public class PadCtrl extends Application
	{
		public var txt_source:TextArea;
		public var holder:GeometryComposition = new GeometryComposition();
		[Bindable] public var target1:Canvas;
		
		public function PadCtrl()
		{
			super();
			
			addEventListener(FlexEvent.CREATION_COMPLETE, init);
		}
		
		protected function init(event:FlexEvent):void
		{
			capture();
		}
		
		public function capture():void
		{
			Parser.capture(clean());
			
			render(Parser.geos);
		}
		
		public function render(geos:Object):void
		{
			holder.geometry.length = 0;
			for each(var geo:Object in geos)
			{
				holder.geometryCollection.addItem(IGeometry(geo));
			}
		}
		
		public function clean():String
		{
			var output:String = txt_source.text;
			output = output.replace('\\r','');
			output = output.replace('\\n','');
			output = output.replace('\\t','');
			return output;
		}
		

	}
}