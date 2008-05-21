package com
{
	import com.degrafa.*;
	
	import flash.events.*;
	import flash.net.*;
	
	import mx.containers.Canvas;
	import mx.controls.RichTextEditor;
	import mx.controls.ComboBox;
	import mx.core.Application;
	import mx.events.FlexEvent;

	public class PadCtrl extends Application
	{
		public var txt_source:RichTextEditor;
		public var degrafa_Class:ComboBox;
		public var holder:GeometryComposition = new GeometryComposition();
		[Bindable] public var target1:Canvas;
		
		public function PadCtrl()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, init);
		}
		
		protected function init(event:FlexEvent):void
		{
			capture(null);
			degrafa_Class.dataProvider = ReferenceUtil.mxmlList;
			ReferenceUtil.buildStubs();
			degrafa_Class.addEventListener(Event.CHANGE, showStub);
			txt_source.addEventListener(KeyboardEvent.KEY_UP, capture);
		}
		
		public function showStub(event:Event):void
		{
			var stub:String = ReferenceUtil.getStub(degrafa_Class.selectedItem as String); 
			if (txt_source.selection.modifiesSelection) txt_source.selection.text = stub;
		}
		
		
		public function capture(event:Event):void
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