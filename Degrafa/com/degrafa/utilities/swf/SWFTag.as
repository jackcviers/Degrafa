package com.degrafa.utilities.swf
{
	import flash.utils.ByteArray;
		
	public class SWFTag
	{

		public static const END:String = "End";
		public static const SHOW_FRAME:String = "ShowFrame";
		public static const DEFINE_SHAPE:String = "DefineShape";
		public static const PLACE_OBJECT:String = "PlaceObject";
		public static const REMOVE_OBJECT:String = "RemoveObject";
		public static const DEFINE_BITS:String = "DefineBits";
		public static const DEFINE_BUTTON:String = "DefineButton";
		public static const JPEG_TABLES:String = "JPEGTables";
		public static const SET_BACKGROUND_COLOR:String = "SetBackgroundColor";
		public static const DEFINE_FONT:String = "DefineFont";
		public static const DEFINE_TEXT:String = "DefineText";
		public static const DO_ACTION:String = "DoAction";
		public static const DEFINE_FONT_INFO:String = "DefineFontInfo";
		public static const DEFINE_SOUND:String = "DefineSound";
		public static const START_SOUND:String = "StartSound";
		public static const DEFINE_BUTTON_SOUND:String = "DefineButtonSound";
		public static const SOUND_STREAM_HEAD:String = "SoundStreamHead";
		public static const SOUND_STREAM_BLOCK:String = "SoundStreamBlock";
		public static const DEFINE_BITS_LOSSLESS:String = "DefineBitsLossless";
		public static const DEFINE_BITS_JPEG_2:String = "DefineBitsJPEG2";
		public static const DEFINE_SHAPE_2:String = "DefineShape2";
		public static const DEFINE_BUTTON_CX_FORM:String = "DefineButtonCxForm";
		public static const PROTECT:String = "Protect";
		public static const PLACE_OBJECT_2:String = "PlaceObject2";
		public static const REMOVE_OBJECT_2:String = "RemoveObject2";
		public static const DEFINE_SHAPE_3:String = "DefineShape3";
		public static const DEFINE_TEXT_2:String = "DefineText2";
		public static const DEFINE_BUTTON_2:String = "DefineButton2";
		public static const DEFINE_BITS_JPEG_3:String = "DefineBitsJPEG3";
		public static const DEFINE_BITS_LOSSLESS_2:String = "DefineBitsLossless2";
		public static const DEFINE_EDIT_TEXT:String = "DefineEditText";
		public static const DEFINE_SPRITE:String = "DefineSprite";
		public static const FRAME_LABEL:String = "FrameLabel";
		public static const SOUND_STREAM_HEAD_2:String = "SoundStreamHead2";
		public static const DEFINE_MORPH_SHAPE:String = "DefineMorphShape";
		public static const DEFINE_FONT_2:String = "DefineFont2";
		public static const EXPORT_ASSETS:String = "ExportAssets";
		public static const IMPORT_ASSETS:String = "ImportAssets";
		public static const ENABLE_DEBUGGER:String = "EnableDebugger";
		public static const DO_INIT_ACTION:String = "DoInitAction";
		public static const DEFINE_VIDEO_STREAM:String = "DefineVideoStream";
		public static const VIDEO_FRAME:String = "VideoFrame";
		public static const DEFINE_FONT_INFO_2:String = "DefineFontInfo2";
		public static const ENABLE_DEBUGGER_2:String = "EnableDebugger2";
		public static const SCRIPT_LIMITS:String = "ScriptLimits";
		public static const SET_TAB_INDEX:String = "SetTabIndex";
		public static const FILE_ATTRIBUTES:String = "FileAttributes";
		public static const PLACE_OBJECT_3:String = "PlaceObject3";
		public static const IMPORT_ASSETS_2:String = "ImportAssets2";
		public static const DEFINE_FONT_ALIGN_ZONES:String = "DefineFontAlignZones";
		public static const CSM_TEXT_SETTINGS:String = "CSMTextSettings";
		public static const DEFINE_FONT_3:String = "DefineFont3";
		public static const SYMBOL_CLASS:String = "SymbolClass";
		public static const METADATA:String = "Metadata";
		public static const DEFINE_SCALING_GRID:String = "DefineScalingGrid";
		public static const DO_ABC:String = "DoABC";
		public static const DEFINE_SHAPE_4:String = "DefineShape4";
		public static const DEFINE_MORPH_SHAPE_2:String = "DefineMorphShape2";
		public static const DEFINE_SCENE_AND_FRAME_LABEL_DATA:String = "DefineSceneAndFrameLabelData";
		public static const DEFINE_BINARY_DATA:String = "DefineBinaryData";
		public static const DEFINE_FONT_NAME:String = "DefineFontName";
		public static const START_SOUND_2:String = "StartSound2";
	
		public static const UNKNOWN:String = 'Unknown';
		
		public static const TAG_NAMES_BY_VALUE:Array = [

		/*  0 */ END, 
		/*  1 */ SHOW_FRAME,
		/*  2 */ DEFINE_SHAPE,
		/*  3 */ UNKNOWN,
		/*  4 */ PLACE_OBJECT,
		/*  5 */ REMOVE_OBJECT,
		/*  6 */ DEFINE_BITS,
		/*  7 */ DEFINE_BUTTON,
		/*  8 */ JPEG_TABLES,
		/*  9 */ SET_BACKGROUND_COLOR,
		/* 10 */ DEFINE_FONT,
		
		/* 11 */ DEFINE_TEXT,
		/* 12 */ DO_ACTION,
		/* 13 */ DEFINE_FONT_INFO,
		/* 14 */ DEFINE_SOUND,
		/* 15 */ START_SOUND,
		/* 16 */ UNKNOWN,
		/* 17 */ DEFINE_BUTTON_SOUND,
		/* 18 */ SOUND_STREAM_HEAD,
		/* 19 */ SOUND_STREAM_BLOCK,
		/* 20 */ DEFINE_BITS_LOSSLESS,
		
		/* 21 */ DEFINE_BITS_JPEG_2,
		/* 22 */ DEFINE_SHAPE_2,
		/* 23 */ DEFINE_BUTTON_CX_FORM,
		/* 24 */ PROTECT,
		/* 25 */ UNKNOWN,
		/* 26 */ PLACE_OBJECT_2,
		/* 27 */ UNKNOWN,
		/* 28 */ REMOVE_OBJECT_2,
		/* 29 */ UNKNOWN,
		/* 30 */ UNKNOWN,
		
		/* 31 */ UNKNOWN,
		/* 32 */ DEFINE_SHAPE_3,
		/* 33 */ DEFINE_TEXT_2,
		/* 34 */ DEFINE_BUTTON_2,
		/* 35 */ DEFINE_BITS_JPEG_3,
		/* 36 */ DEFINE_BITS_LOSSLESS_2,
		/* 37 */ DEFINE_EDIT_TEXT,
		/* 38 */ UNKNOWN,
		/* 39 */ DEFINE_SPRITE,
		/* 40 */ UNKNOWN,
		
		/* 41 */ UNKNOWN,
		/* 42 */ UNKNOWN,
		/* 43 */ FRAME_LABEL,
		/* 44 */ UNKNOWN,
		/* 45 */ SOUND_STREAM_HEAD_2,
		/* 46 */ DEFINE_MORPH_SHAPE,
		/* 47 */ UNKNOWN,
		/* 48 */ DEFINE_FONT_2,
		/* 49 */ UNKNOWN,
		/* 50 */ UNKNOWN,
		
		/* 51 */ UNKNOWN,
		/* 52 */ UNKNOWN,
		/* 53 */ UNKNOWN,
		/* 54 */ UNKNOWN,
		/* 55 */ UNKNOWN,
		/* 56 */ EXPORT_ASSETS,
		/* 57 */ IMPORT_ASSETS,
		/* 58 */ ENABLE_DEBUGGER,
		/* 59 */ DO_INIT_ACTION,
		/* 60 */ DEFINE_VIDEO_STREAM,
		
		/* 61 */ VIDEO_FRAME,
		/* 62 */ DEFINE_FONT_INFO_2,
		/* 63 */ UNKNOWN,
		/* 64 */ ENABLE_DEBUGGER_2,
		/* 65 */ SCRIPT_LIMITS,
		/* 66 */ SET_TAB_INDEX,
		/* 67 */ UNKNOWN,
		/* 68 */ UNKNOWN,
		/* 69 */ FILE_ATTRIBUTES,
		/* 70 */ PLACE_OBJECT_3,
		
		/* 71 */ IMPORT_ASSETS_2,
		/* 72 */ UNKNOWN,
		/* 73 */ DEFINE_FONT_ALIGN_ZONES,
		/* 74 */ CSM_TEXT_SETTINGS,
		/* 75 */ DEFINE_FONT_3,
		/* 76 */ SYMBOL_CLASS,
		/* 77 */ METADATA,
		/* 78 */ DEFINE_SCALING_GRID,
		/* 79 */ UNKNOWN,
		/* 80 */ UNKNOWN,
		/* 81 */ UNKNOWN,
		/* 82 */ DO_ABC,
		/* 83 */ DEFINE_SHAPE_4,
		/* 84 */ DEFINE_MORPH_SHAPE_2,
		/* 85 */ UNKNOWN,
		/* 86 */ DEFINE_SCENE_AND_FRAME_LABEL_DATA,
		/* 87 */ DEFINE_BINARY_DATA,
		/* 88 */ DEFINE_FONT_NAME,
		/* 89 */ START_SOUND_2
		
		];
				
		public var type: int;
		public var start: int;
		public var length: int;
		public var bytes:ByteArray;	
		
		public function toString():String {
			return '[SWFTag ' + TAG_NAMES_BY_VALUE[type] + '(' + type + ') ' + length + ' bytes]'; 
		}
		
		public function readString():String {
			var pointer:int = bytes.position;
			while (pointer < bytes.length) {
				if (bytes[pointer] == 0) {
					break;
				}
				pointer++;
			}
			if (pointer >= bytes.length) {
				throw new Error('{SWFTag.readString} Out of Bounds');
			}
			return bytes.readUTFBytes(pointer - bytes.position);
		}
	}
}