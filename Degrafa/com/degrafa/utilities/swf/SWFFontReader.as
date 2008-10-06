package com.degrafa.utilities.swf
{
	import com.degrafa.utilities.swf.fonts.FontSet;
	
	import flash.utils.ByteArray;
	
	public class SWFFontReader
	{
	
		private static const DEFINE_FONT:int = 10;
		private static const DEFINE_FONT_2:int = 62;
		private static const DEFINE_FONT_3:int = 75;
		private static const DEFINE_FONT_INFO:int = 13;
		private static const DEFINE_FONT_INFO_2:int = 62;
		private static const DEFINE_FONT_ALIGN_ZONES:int = 73;
		private static const DEFINE_FONT_NAME:int = 88;
		
		public var fonts:Array;
		
		public function SWFFontReader() {
			fonts = [];
		}
		
		public function isFontTag(tag:SWFTag):Boolean {
			switch(tag.type) {
				case DEFINE_FONT:
				case DEFINE_FONT_2:
				case DEFINE_FONT_3:
				case DEFINE_FONT_INFO:
				case DEFINE_FONT_INFO_2:
				case DEFINE_FONT_ALIGN_ZONES:
				case DEFINE_FONT_NAME:
					return true;
				default:
					return false;	
			}			
		}
		
		public function decodeTag(tag:SWFTag):void {
			switch(tag.type) {
				case DEFINE_FONT:
					parseFont(tag);
					break;
				case DEFINE_FONT_2:
					parseFont2(tag);
					break;
				case DEFINE_FONT_3:
					parseFont3(tag);
					break;
				case DEFINE_FONT_INFO:
					parseFontInfo(tag);
					break;
				case DEFINE_FONT_INFO_2:
					parseFontInfo2(tag);
					break;
				case DEFINE_FONT_ALIGN_ZONES:
					parseFontAlignZones(tag);
					break;
				case DEFINE_FONT_NAME:
					parseFontName(tag);
					break;
				default:
					// TODO: Warn developer here.  Not a recognized font tag.
					break;
			}
		
		}
		
		private function parseFont(tag:SWFTag):void {
			//trace('{FontReader.parseFont} Not implemented.');
		
		}
		
		private function parseFont2(tag:SWFTag):void {
			//trace('{FontReader.parseFont2} Not implemented.');			
		}
		
		private function parseFont3(tag:SWFTag):void {
			
			//trace('{FontReader.parseFont3}');
			
			var fs:FontSet = new FontSet();
			var bytes:ByteArray = tag.bytes;
			var flags:uint, nameLen:uint, i:int, len:int;
			
			bytes.position = tag.start;
			
			fs.tag = tag;
			
			fs.fontID = bytes.readUnsignedShort();
			
			flags = bytes.readUnsignedByte();
			fs.hasLayout	= Boolean(flags & 128);
			fs.shiftJIS		= Boolean(flags & 64);			
			fs.smallText	= Boolean(flags & 32);
			fs.ansi			= Boolean(flags & 16);
			fs.wideOffsets	= Boolean(flags & 8);
			fs.wideCodes	= Boolean(flags & 4);
			fs.italic		= Boolean(flags & 2);
			fs.bold			= Boolean(flags & 1);
			
			fs.languageCode = bytes.readUnsignedByte();

			nameLen = bytes.readUnsignedByte();
			fs.fontName = bytes.readUTFBytes(nameLen);
			
			fs.numGlyphs = bytes.readUnsignedShort();			

			var offsetTableStartPtr:uint = fs.offsetTableOffset = bytes.position;
			
			fs.offsetTable = [];
			len = fs.numGlyphs;
			for (i = 0; i < len; i++) {
				fs.offsetTable.push(fs.wideOffsets ? bytes.readUnsignedInt() : bytes.readUnsignedShort());
			}

			fs.codeTableOffset = fs.wideOffsets ? bytes.readUnsignedInt() : bytes.readUnsignedShort();
			
			len = fs.offsetTable.length;
			
			/*
					
			if (fs.hasLayout) {
				fs.fontAscent = bytes.readShort();
				fs.fontDescent = bytes.readShort();
				fs.fontLeading = bytes.readShort();
			}
			
			*/

			fonts.push(fs);
		}
		
		private function parseFontInfo(tag:SWFTag):void {
			//trace('{FontReader.parseFontInfo} Not implemented.');			
		}

		private function parseFontInfo2(tag:SWFTag):void {
			//trace('{FontReader.parseFontInfo2} Not implemented.');			
		}
		
		private function parseFontAlignZones(tag:SWFTag):void {
			//trace('{FontReader.parseFontAlignZones} Not implemented.');			
		}
		
		private function parseFontName(tag:SWFTag):void {	
			//trace('{FontReader.parseFontName} Not implemented.');			
			
			/*	
			var fn:FontName = new FontName();
			var bytes:ByteArray = tag.bytes;
			bytes.position = tag.start;
			fn.fontID = bytes.readUnsignedShort();
			fn.fontName = tag.readString();
			fn.fontCopyright = tag.readString();			
			*/
		}
		
	}
}