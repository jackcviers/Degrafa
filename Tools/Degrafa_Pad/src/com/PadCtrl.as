package com
{
	import com.degrafa.*;
	import mx.controls.Label;
	import mx.controls.textClasses.TextRange;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.RichTextEditor;
	import mx.controls.ComboBox;
	import mx.core.Application;
	import mx.events.FlexEvent;
	

	public class PadCtrl extends Application
	{
		public var txt_source:RichTextEditor;
		public var degrafa_Class:ComboBox;
		public var selectedClass:Label;
		public var delayTimer:Timer;
		public var holder:GeometryComposition = new GeometryComposition();
		[Bindable] 
		public var target1:Canvas;
		
		public var selectedTagType:String;
		
		
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
			txt_source.addEventListener(Event.CHANGE, updateWhenTypingStops);
		//	txt_source.doubleClickEnabled = false;
			txt_source.addEventListener(MouseEvent.DOUBLE_CLICK, contextualDoubleClick);
			txt_source.addEventListener(MouseEvent.CLICK, updateContextDisplay);
			txt_source.addEventListener(KeyboardEvent.KEY_UP, updateContextDisplay);
			delayTimer = new Timer(200,1);
			delayTimer.addEventListener(TimerEvent.TIMER, capture);
		}
		
		public function updateContextDisplay(event:Event):void
		{
			getSelectedTagType();
		}
		public function updateWhenTypingStops(event:Event):void
		{
			//getSelectedTagType();
			delayTimer.reset();
			delayTimer.start();
		}
		public function contextualDoubleClick(event:MouseEvent):void
		{
			//Event handler not firing yet.
		//TODO: 
			//fix the dbl-click selection behavior as follows:
			// a) select whole node names only if we're on a node name
			// b) select ONLY the attribute name if we're on an attribute name
			// c) select ONLY between attribute value quotes if that's where we are
			trace("DBL:"+event);
		}
		public function showStub(event:Event):void
		{
			var stub:String = ReferenceUtil.getStub(degrafa_Class.selectedItem as String); 
			if (txt_source.selection.modifiesSelection) txt_source.selection.text = stub;
		}
		
		public function getSelectedTagType():void
		{
			if (txt_source.text.length)
			{
				var tRange:TextRange = txt_source.selection;
				
				if (tRange.text.length > 0 && tRange.text.indexOf(">")>-1 && tRange.text.indexOf(">") < tRange.text.length)
				{
					selectedTagType = "";
					
				} else
				{
					//get the preceding opening tag
					var cursor:uint = tRange.beginIndex;
					if (cursor == 0 || cursor == tRange.text.length) {
						selectedTagType = "";
					} else {
						
					var start:int = txt_source.text.substr(0, cursor).lastIndexOf("<") + 1;
					var previousEnd:int=txt_source.text.substr(0, cursor).lastIndexOf(">")
					var len:int = txt_source.text.substr(start, 1000).indexOf(" ");
					var thistag:String = txt_source.text.substr(start, len);
					//?closing
					if (thistag.charAt(0) == "/" || previousEnd>start) selectedTagType = "";
					else selectedTagType = thistag;
				
					}
				}
			}
			txt_source.title = "Degrafa Mark-up : " + selectedTagType;
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