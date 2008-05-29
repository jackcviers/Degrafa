package com.degrafa.utilities.swf.fonts
{
	public class FontName
	{
		public var fontID:uint;
		public var fontName:String;
		public var fontCopyright:String;
		
		public function toString():String {
			return '[FontName {id: ' + fontID + ', name: "' + fontName + '", copyright: "' + fontCopyright + '"}]';
		}
	}
}