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
	
	import mx.rpc.xml.SimpleXMLDecoder;
	
	public class Parser
	{
		public static var geos:Object = {};
		public static var fills:Object = {};
		public static var strokes:Object = {};
		public static var decorators:Object = {};
		public static var geoLate:Array = [];
		
		public static var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
		
		public function Parser()
		{
		}

		public static function capture(value:String):Object
		{
			geos = {};
			fills = {};
			strokes = {};
			geoLate = [];
			
			try
			{
				var xmlSrc:XML = new XML("<x>"+value+"</x>");
				var resultObj:Object = decoder.decodeXML(new XMLDocument(xmlSrc.toXMLString()));
				var resultArray:Array = [];
				
				for each(var o:Object in resultObj.x) {
					resultArray.push(o);
				}
				
				var i:int = 0;
				for(var name:String in resultObj.x)
				{
					var cls:Class = ReferenceUtil.bigSwitch(name);
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
								{
									if(obj is GradientFillBase)
										fills[obj.id] = parseGradient(resultArray[i],cls);
									else
										fills[obj.id] = obj;
								}
								else if(obj is IGraphicsStroke)
								{
									if(obj is GradientStrokeBase)
										strokes[obj.id] = parseGradient(resultArray[i],cls);
									else
										strokes[obj.id] = obj;
								}
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
					{
						if(obj is GradientFillBase)
							fills[obj.id] = parseGradient(resultArray[i],cls);
						else
							fills[obj.id] = obj;
					}
					else if(obj is IGraphicsStroke)
					{
						if(obj is GradientStrokeBase)
							strokes[obj.id] = parseGradient(resultArray[i],cls);
						else
							strokes[obj.id] = obj;
					}
					else if(obj is IDrawDecorator)
						decorators[obj.id] = obj;
						
					i++;
				}
				
				typeGeometry();
				
				return geos;
			}
			catch(e:Error) 
			{
				trace(e.message)
			}
			
			return null;
		}
		
		public static function parseGradient(value:Object, cls:Class):Object
		{
			var stops:Array = value.GradientStop;
			var obj:Object = ObjectTranslator.objectToInstance(value,cls);
			
			for each(var stop:Object in stops)
			{
				obj.gradientStops.push(ObjectTranslator.objectToInstance(stop,GradientStop));
			}
			
			return obj;
		}
		
		public static function typeGeometry():void
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
	}
}