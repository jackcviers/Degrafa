package com
{
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import com.ManifestReference;
	

	public class ReferenceUtil
	{
		private static var manifest:XML=ManifestReference.manifest;
		
		public static function getClassReference(name:String):Class
		{
			try{
				var clazz:Class = getDefinitionByName(manifest.component.(@id == name).attribute("class")) as Class;
			} catch (e:Error)
			{
				clazz = String;
			}
			return clazz;
		}
		
		private static var _degrafaList:Array;
		public static function get mxmlList():Array
		{
			if (_degrafaList) return _degrafaList;
			//else
			_degrafaList = new Array();
			var degrafaList:XMLList = ReferenceUtil.manifest.component.attribute('id');
			for each(var componentName:XML in degrafaList)
			{
				_degrafaList.push(componentName.toString())
			}
			_degrafaList.sort();
			return _degrafaList;
		}
		private static var _stubs:Object = new Object();
		
		//do not include these attributes in any stub tags
		//far from finished.
		private static var _globalIgnore:Object = {
			suppressEventProcessing:true,
			parent:true,
			enableEvents:true,
			commandStack:true,
			state:true,
			stateEvent:true,
			commandArray:true
		}
		
				
		public static function buildStubs():void
		{
			var i:uint = 0;
			var list:Array = mxmlList;
			for (; i < list.length; i++)
			{
			var clazz:Class = getClassReference(String(list[i]));
			var desc:XML = describeType( clazz);
			var writeable_accessors:XMLList = desc.factory.accessor.(@access.search('write') > -1);
			var xString:String = "<" + String(list[i]);
			var attributes:String = "";
			for each(var accessor:XML in writeable_accessors)
			{
				//don't have default values yet.. for now just indicate type
				if (!_globalIgnore[accessor.@name]) attributes = " " + accessor.@name + "=\""+accessor.@type+"\""+attributes;
			}

			xString += attributes+" />";
			_stubs[list[i]] = xString;
			}
		}
		
		public static function getStub(name:String):String
		{
			return _stubs[name].toString();
		}
		
		
		
		
		
		
		
	}
}