package com.degrafa.utilities
{
	import com.degrafa.utilities.swf.SWFFontReader;
	import com.degrafa.utilities.swf.SWFTag;
	
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SWFReader 
	{
		private var _bytes:ByteArray;
		private var _data:ByteArray;
		private var _tags:Array;
		private var _fileSize:uint;
		private var _uncompressedFileSize:uint;
		private var _compressed:Boolean;
		private var _version:uint;
		private var _size:Rectangle;
		private var _frameRate:uint;
		private var _frameCount:uint;
		
		private static var _bitPos:int;
		private static var _bitBuf:int;

		[Bindable]
		public var fonts:Array;

		public function get tags():Array { return _tags; }

		public function SWFReader()
		{
			super();
		}
		
		public function loadBytes(bytes:ByteArray):void
		{
			_bytes = bytes;
			decode();
		}
		
		private function decode():void
		{

			_bytes.endian = Endian.LITTLE_ENDIAN;
			_bytes.position = 0;
			
			var version:uint = _bytes.readUnsignedInt();
			var csize:int;

			_fileSize = _bytes.length;

			switch (version) {		
			case 67|87<<8|83<<16|9<<24: // CWS9
			case 67|87<<8|83<<16|8<<24: // CWS8
			case 67|87<<8|83<<16|7<<24: // CWS7
			case 67|87<<8|83<<16|6<<24: // CWS6
				_compressed = true;
				_data = new ByteArray();
				_data.endian = Endian.LITTLE_ENDIAN;
				_bytes.position = 8;
				_bytes.readBytes(_data, 0, _bytes.length - _bytes.position);
				csize = _data.length;
				_data.uncompress();
				trace("{SWFReader.decode} Decompressed SWF " + csize + " -> " + _data.length + " bytes...");
				_uncompressedFileSize = _data.length + 8;
				_data.position = 0	
				break;
			case 70|87<<8|83<<16|9<<24: // FWS9
			case 70|87<<8|83<<16|8<<24: // FWS8
			case 70|87<<8|83<<16|7<<24: // FWS7
			case 70|87<<8|83<<16|6<<24: // FWS6
			case 70|87<<8|83<<16|5<<24: // FWS5
			case 70|87<<8|83<<16|4<<24: // FWS4
				_uncompressedFileSize = _bytes.length;
				_compressed = false;
				_bytes.position = 8 // skip header and length
			    _data = _bytes;
			    trace("{SWFReader.decode} Parsed SWF " + _bytes.length + " bytes...");
				break
			default:
				trace('{SWFReader.decode} Unknown format ' + version);
				break;
			}
			
			_version = version >> 24;
		
			_size = decodeRect(_data);
			_frameRate = ( _data.readUnsignedByte() << 8 | _data.readUnsignedByte() );
			_frameCount = _data.readUnsignedShort();
			
			decodeTags();									
			
			var fr:SWFFontReader = new SWFFontReader();
			for (var i:int = 0; i < _tags.length; i++) {
				if (fr.isFontTag(_tags[i])) {
					fr.decodeTag(_tags[i]);
				}
			}
			fonts = fr.fonts;
			
		}
			
		private function decodeTags():void
		{
			var dataLength:int = _data.length;
	        var type:int, h:int, length:int;
			var offset:int;
			var tag:SWFTag;

			_tags = [];
	
	        while (_data.position < dataLength)
	        {
	            type = (h = _data.readUnsignedShort()) >> 6;
	
	            if (((length = h & 0x3F) == 0x3F))
	                length = _data.readInt();

				tag = new SWFTag();
				tag.type = type;
				tag.start = _data.position;
				tag.length = length;
				tag.bytes = _data;
				
				_tags.push(tag);
					
				_data.position += length;				
	        }
		}	
			
	    public static function decodeRect(data:ByteArray):Rectangle
	    {
	        syncBits();
	
	        var rect:Rectangle = new Rectangle();
	
	        var nBits:int = readUBits(5, data)
	        rect.x = readSBits(nBits, data);
	        rect.width = readSBits(nBits, data);
	        rect.y = readSBits(nBits, data);
	        rect.height = readSBits(nBits, data);
	
	        return rect;
	    }

		public static function syncBits():void
		{
			_bitPos = 0;
		}
	    
	    public static function unreadBits(n:int):void {
	    	_bitPos = Math.max(0, _bitPos - n);
	    }
	    
	    public static function readSBits(numBits:int, data:ByteArray):int
	    {
	        if (numBits > 32)
	            throw new Error("Number of bits > 32");

	        var num:int = readUBits(numBits, data);
	        var shift:int = 32 - numBits;
	       
	        // sign extension
	        num = (num << shift) >> shift;
	       
	        return num;
	    }
	    
		public static function readUBits(numBits:int, data:ByteArray):uint
	    {
	        if (numBits == 0)
	        	return 0;
	
	        var bitsLeft:int = numBits;
	        var result:int = 0;
	
	        if (_bitPos == 0) //no value in the buffer - read a byte
	        {
	            _bitBuf = data.readUnsignedByte();
	            _bitPos = 8;
	        }
	
	        while (true)
	        {
	            var shift:int = bitsLeft - _bitPos;
	            if (shift > 0)
	            {
	                // Consume the entire buffer
	                result |= _bitBuf << shift;
	                bitsLeft -= _bitPos;
	
	                // Get the next byte from the input stream
	                _bitBuf = data.readUnsignedByte();
	                _bitPos = 8;
	            }
	            else
	            {
	                // Consume a portion of the buffer
	                result |= _bitBuf >> -shift;
	                _bitPos -= bitsLeft;
	                _bitBuf &= 0xff >> (8 - _bitPos); // mask off the consumed bits	
	                return result;
	            }
	        }
	        
	        return 0;
	    }
		
	}
}