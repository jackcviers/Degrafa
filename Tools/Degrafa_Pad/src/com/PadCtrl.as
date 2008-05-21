package com
{
	import com.darronschall.serialization.ObjectTranslator;
	import com.degrafa.*;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.decorators.IDrawDecorator;
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	
	import flash.events.*;
	import flash.net.*;
	import flash.xml.XMLDocument;
	
	import mx.containers.Canvas;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.rpc.xml.SimpleXMLDecoder;

	public class PadCtrl extends Application
	{
		public var geos:Object = {};
		public var fills:Object = {};
		public var strokes:Object = {};
		public var decorators:Object = {};
		public var geoLate:Array = [];
		
		public var txt_source:TextArea;
		public var holder:GeometryComposition = new GeometryComposition();
		[Bindable] public var target1:Canvas;
		public var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
		
		
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
			geos = {};
			fills = {};
			strokes = {};
			geoLate = [];
			
			try
			{
				var xmlSrc:XML = new XML("<x>"+clean()+"</x>");
				var resultObj:Object = decoder.decodeXML(new XMLDocument(xmlSrc.toXMLString()));
				var resultArray:Array = [];
				
				for each(var o:Object in resultObj.x) {
					resultArray.push(o);
				}
				
				var i:int = 0;
				for(var name:String in resultObj.x)
				{
					var cls:Class = bigSwitch(name);
					var tester:Object = new cls();
					
					if(resultArray[i] is Array)
					{
						for each(var tObj:Object in resultArray[i])
						{
							var tester2:Object = new cls();
							
							if(tester2 is Geometry)
							{
								geoLate.push({geo:tObj,cls:cls});
							}
							else
							{
								var obj:Object = ObjectTranslator.objectToInstance(tObj,cls);
					
								if(obj is IGraphicsFill)
									fills[obj.id] = obj;
								else if(obj is IGraphicsStroke)
									strokes[obj.id] = obj;
								else if(obj is IDrawDecorator)
									decorators[obj.id] = obj; 
							}
						}
						i++;
						continue;
					}
					
					if(tester is Geometry)
					{
						geoLate.push({geo:resultArray[i],cls:cls});
						i++;
						continue;
					}
						
					obj = ObjectTranslator.objectToInstance(resultArray[i],cls);
					
					if(obj is IGraphicsFill)
						fills[obj.id] = obj;
					else if(obj is IGraphicsStroke)
						strokes[obj.id] = obj;
					else if(obj is IDrawDecorator)
						decorators[obj.id] = obj;  
						
					i++;
				}
				
				typeGeometry();
				
				render();
			 }
			catch(e:Error) 
			{
				trace(e.message)
			} 
		}
		
		public function typeGeometry():void
		{
			for each(var value:Object in geoLate)
			{
				var geo:Object = value.geo;
				var cls:Class = value.cls as Class;
				
				if(geo.fill)
				{
					var fillID:String = String(geo.fill).slice(1,-1);
					geo.fill = fills[fillID];
				}
				
				if(geo.stroke)
				{
					var sID:String = String(geo.stroke).slice(1,-1);
					geo.stroke = strokes[sID];
				}
				
				if(geo.decorators)
				{
					var dID:String = String(geo.decorators).slice(2,-2);
					var da:Array = [];
					
					for each(var dec:String in dID.split(","))
					{
						da.push(decorators[dec]);	
					}
					
					geo.decorators = da;
				}
				
				var obj:Object = ObjectTranslator.objectToInstance(geo,cls);
				
				geos[obj.id] = obj;
			}
		}
		
		public function render():void
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
		
		public function bigSwitch(node:String):Class
		{
			switch(node)
			{
				case "AdvancedRectangle":
					return AdvancedRectangle;
				case "Circle":
					return Circle;
				case "Ellipse":
					return Ellipse;
				case "EllipticalArc":
					return EllipticalArc;
				case "HorizontalLine":
					return HorizontalLine;
				case "Path":
					return Path;
				case "Polygon":
					return Polygon;
				case "Polyline":
					return Polyline;
				case "RegularRectangle":
					return RegularRectangle;
				case "RoundedRectangle":
					return RoundedRectangle;
				case "RoundedRectangleComplex":
					return RoundedRectangleComplex;
				case "VerticalLine":
					return VerticalLine;
				case "SolidFill":
					return SolidFill;
				case "LinearGradientFill":
					return LinearGradientFill;
				case "RadialGradientFill":
					return RadialGradientFill;
				case "SolidStroke":
					return SolidStroke;
				case "LinearGradientStroke":
					return LinearGradientStroke;
				case "RadialGradientStroke":
					return RadialGradientStroke;
				
			}
			return null
		}
	}
}