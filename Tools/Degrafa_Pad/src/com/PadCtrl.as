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
	import mx.controls.ColorPicker;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import com.degrafa.core.utils.ColorUtil;

	public class PadCtrl extends Application
	{
		public var txt_source:RichTextEditor;
		public var degrafa_Class:ComboBox;
		public var colorChooser:ColorPicker;
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
			txt_source.doubleClickEnabled = true;
			txt_source.addEventListener(MouseEvent.DOUBLE_CLICK, contextualDoubleClick,true);
			txt_source.addEventListener(MouseEvent.CLICK, updateContextDisplay);
			txt_source.addEventListener(KeyboardEvent.KEY_UP, updateContextDisplay);
			delayTimer = new Timer(200,1);
			delayTimer.addEventListener(TimerEvent.TIMER, capture);
		}
		
		public function updateContextDisplay(event:Event):void
		{
			firstClickIdx=txt_source.selection.beginIndex
			getSelectedTagType();
		}
		public function updateWhenTypingStops(event:Event):void
		{
			//getSelectedTagType();
			delayTimer.reset();
			delayTimer.start();
		}
		private var firstClickIdx:uint = 0;
		private var attrToggle:String = "value";
		private var selAttr:uint = 0;
		private function getAttributeToggle(reset:Boolean):Object
		{
			if (reset) {
				attrToggle = "";
				selAttr = 0;
				return false;
			}
			return true
		}
		
	
		
		 //regex
			private var nameTest:RegExp = /^[a-zA-Z]\w*/;
			private var spaceTest:RegExp=/ /;
			private var attributeValueTest:RegExp =/^\"(.*)\"$/;
			private var attributeNameTest:RegExp = /^(\w+)=$/;
			private var attributeRangeTest:RegExp =/^(?P<name>[a-zA-Z]\w+)(?:=\s*\")(?P<value>.*)\"/; //new RegExp("("+attributeNameTest.source+")"+attributeValueTest.source)
			private var booleanValueTest:RegExp =/^(true|false)$/;
			private var integerValueTest:RegExp =/^\d+$/;
			private var decimalValueTest:RegExp =/^(\d|-)?(\d|,)*\.?\d*$/;
			private var hexValueTest:RegExp= /^(0x|#)[0-9a-fA-F]+/;
			private var referenceTest:RegExp =/^\{(\[\w+\]|\w+)\}$/;
			private var csvListTest:RegExp =/^([a-zA-Z]\w*(?:\s*,\s*))*([a-zA-Z]\w*\s*)$/;
			
			private var reverseColorHash:Object = { }; //TODO: to retain named colors or short names if they are selected using the picker
			
		public function contextualDoubleClick(event:MouseEvent):void
		{
		var curSelection:TextRange = txt_source.selection;
		//dbl-click selection behavior as follows:
			// a) select whole node names only if we're on a node name
			// b) toggle between value/name/full with subsequent double-clicks on an attribute
			
			var split:int = curSelection.text.indexOf("/><");
			if (split != -1)
			{
				//clean
				split += curSelection.beginIndex;
				if (firstClickIdx > split + 2)
				{
					curSelection.beginIndex = split + 2;
				} else
				{
					curSelection.endIndex = split ;
				}
			}

			var attTest:Object = attributeRangeTest.exec(curSelection.text);
			if (attTest != null) {
				
			
			var endpos:uint = curSelection.beginIndex+attTest[0].length
			//always be prepared for full selection:
			curSelection.endIndex = endpos;
			if (selAttr != curSelection.beginIndex || attrToggle=="full") {
					selAttr = curSelection.beginIndex;
					attrToggle = "value";
					//value first
					curSelection.endIndex -= 1;// end quote;
					curSelection.beginIndex += curSelection.text.indexOf(attTest.value);
		
			} else {
					if (attrToggle == "value") {
						attrToggle = "name";
						curSelection.endIndex = curSelection.beginIndex + attTest.name.length;
					}
					else {
						attrToggle = "full";
						curSelection.beginIndex = selAttr+curSelection.text.search(attributeRangeTest);;
					}
				}
				if (attrToggle == "value") {
					
					switch (attTest.name)
					{
						case 'color':
						colorChooser.visible  = true;
						var col:uint=ColorUtil.resolveColor(attTest.value)
						colorChooser.selectedColor = col;
						break;
						default:
						colorChooser.visible = false;
						break;
					}
				} else {
					colorChooser.visible  = false;
				}
				return;
			}
			
			if (curSelection.text.substr(0,2) == "</") {
				curSelection.endIndex -= 2;
				curSelection.beginIndex += 2;
				return;
			}
			if (curSelection.text.charAt(0) == "<") {
				curSelection.beginIndex++;
				return;
			}
			
		
		}
		public function showStub(event:Event):void
		{
			var stub:String = ReferenceUtil.getStub(degrafa_Class.selectedItem as String); 
			if (txt_source.selection.modifiesSelection) txt_source.selection.text = stub;
		}
		
		public function updateColor():void
		{
			var sel:uint = colorChooser.selectedColor;
			//we haven't set up the reverselookup yet, just use regular hex
			var hexVal:String = "#"+sel.toString(16);
			txt_source.selection.text = hexVal;
			capture(new Event(Event.CHANGE));
			
		}
		
		public function getSelectedTagType():void
		{
			//TODO: update to use regex
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