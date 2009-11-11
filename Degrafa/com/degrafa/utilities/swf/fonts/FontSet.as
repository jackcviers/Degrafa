package com.degrafa.utilities.swf.fonts
{
	import com.degrafa.utilities.swf.SWFTag;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class FontSet
	{

		public static var excludeEmptyGlyphs:Boolean = true;

		public var tag:SWFTag;
		
		public var fontID:uint;

		public var hasLayout:Boolean;
		public var shiftJIS:Boolean;	
		public var smallText:Boolean;
		public var ansi:Boolean;
		public var wideOffsets:Boolean;
		public var wideCodes:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		
		public var languageCode:uint;
		
		public var fontName:String;
		
		public var numGlyphs:uint;
		
		public var offsetTableOffset:uint;
		
		public var offsetTable:Array;
		
		public var codeTableOffset:uint;
		
		public var glyphShapeTable:Array;

		public var fontAscent:int;
		public var fontDescent:int;
		public var fontLeading:int;		
		public var kerningCount:uint;
		
		private var _children:Array;
		public function get children():Array {
			if (!_children) {
				generateGlyphMap();
			}
			

			return _children;			
		}
		
		private var _glyphs:Dictionary;	
		public function get glyphs():Dictionary {
					
			if (!_glyphs) {
				generateGlyphMap();
			}
			
			return _glyphs;
		}	
		
		private function generateGlyphMap():void {
		
			var bytes:ByteArray = tag.bytes;

			_children = [];
			_glyphs = new Dictionary();
			
			for (var i:int = 0; i < numGlyphs; i++) {
				var glyph:FontGlyph = new FontGlyph();
				bytes.position = offsetTableOffset + codeTableOffset + i * 2;
				glyph.codePoint = bytes.readUnsignedShort();
				glyph.shapeOffset = offsetTableOffset + offsetTable[i];
				
				if (i < (numGlyphs - 1)) {
					glyph.shapeOffsetEnd = offsetTableOffset + offsetTable[i + 1];
				}
				else {
					glyph.shapeOffsetEnd = codeTableOffset - 1;
				}

				glyph.fontSet = this;
				glyph.index = i;

				if (excludeEmptyGlyphs && ((glyph.shapeOffset + 2) == glyph.shapeOffsetEnd)) {
					//trace('empty glyph skipped...');
				}
				else {
					_glyphs[glyph.codePoint] = glyph;				
					_children.push(glyph);		
				}
			}			
		}
			
/*
		public function getShapeFromCharCode(charCode:uint):void {
			
			var sr:ShapeReader = new ShapeReader();
			
			var offset:int = getShapeOffsetFromCharCode(charCode);
			
			if (offset != -1) {
				sr.readShape(offset, tag.bytes);
			}
			else {
				// TODO: No shape, warn developer.
			}
			
		}

		private function getShapeOffsetFromCharCode(charCode:uint):int {
			
			var bytes:ByteArray = tag.bytes;
			var oldPos:uint = bytes.position;
			var oldEndian:String = bytes.endian;
			var i:int, len:int = numGlyphs;
			var notFound:Boolean = true;
			var offset:uint;
			
	
			for (i = 0; i < numGlyphs; i++) {
				if (charCode == bytes.readUnsignedShort()) {
					notFound = false;
					break;
				}
			}
			
			if (notFound) { return -1; }
			
			bytes.position = offsetTableOffset  + (i * (wideOffsets ? 4 : 2));
			offset = wideOffsets ? bytes.readUnsignedInt() : bytes.readUnsignedShort();
			
			bytes.position = oldPos;
			bytes.endian = oldEndian;
			
			trace('wideOffsets: ' + wideOffsets);
			trace('inner offset: ' + offset);
			trace('tag start: ' + tag.start);
			trace('table offset: ' + offsetTableOffset);
			
			return offsetTableOffset + offset;
		}

		

*/
/*
		public function dumpCodeTable():void {
			
			var bytes:ByteArray = tag.bytes;

			var oldPos:uint = bytes.position;
			var oldEndian:String = bytes.endian;

			var i:int, len:int = numGlyphs;
			var codePoint:uint;
			var codes:Array = [];
			var chars:Array = [];
			
			bytes.position = offsetTableOffset + codeTableOffset;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			for (i = 0; i < numGlyphs; i++) {
				codePoint = bytes.readUnsignedShort(); 
				codes.push('U+' + codePoint.toString(16).toUpperCase());
				if (codePoint == 0 || codePoint == 10 || codePoint == 13) {
					chars.push('?');
				}
				else {
					chars.push(String.fromCharCode(codePoint));
				}
			}
			trace('Glyph Count: ' + len);
			trace(' Code Count: ' + codes.length);
			trace('Codes: ' + codes.join(', '));
			trace('Chars: ' + chars.join(', '));
			
			bytes.position = oldPos;
			bytes.endian = oldEndian;
		}
		*/
	}
}
