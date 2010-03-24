package com.degrafa.utilities{
	

	import flash.utils.Dictionary;
	import flash.net.registerClassAlias;
	
	//import classes for registering
	
	import flash.geom.*
	import com.degrafa.*
	import com.degrafa.geometry.*
	import com.degrafa.geometry.segment.*
	import com.degrafa.geometry.command.*
	import com.degrafa.core.*
	import com.degrafa.core.collections.*
	import com.degrafa.paint.*
	import com.degrafa.repeaters.*
	import com.degrafa.skins.*
	import com.degrafa.transform.*
	import com.degrafa.utilities.external.*
	
	/**
	* The Aliases helper is for registering a Degrafa manifest of class aliases.
    * This class is supportive for potential ByteArray cacheing, if used, or for 
	* future runtime loading of externally created amf-encoded degrafa objects.
	**/
	public class Aliases{
		
		//reference object package/manifest for classes
		//requires manual update if/when changes are made to the structure of the
		//alias mapping
		private static var manifest:Object = {
			flash: {
				geom: {
					Point:Point,
					Matrix:Matrix,
					Rectangle:Rectangle
				}
			},
			com: {
				degrafa:
				{	
					GeometryComposition:GeometryComposition,
					GeometryGroup:GeometryGroup,
					GraphicPoint:GraphicPoint,
					GraphicPointEX:GraphicPointEX,
					GraphicText:GraphicText,
					Surface:Surface,

					core: {
						Measure:Measure,
						
						collections: {
							DegrafaCollection:DegrafaCollection,
							DisplayObjectCollection:DisplayObjectCollection,
							FillCollection:FillCollection,
							GeometryCollection:GeometryCollection,
							GradientStopsCollection:GradientStopsCollection,
							GraphicPointCollection:GraphicPointCollection,
							GraphicPointEXCollection:GraphicPointEXCollection,
							GraphicsCollection:GraphicsCollection,
							GraphicSkinColletion:GraphicSkinCollection,
							RepeaterModifierCollection:RepeaterModifierCollection,
							SegmentsCollection:SegmentsCollection,
							StrokeCollection:StrokeCollection,
							TransformCollection:TransformCollection														
						}
					},
					geometry: {
						AdvancedRectangle:AdvancedRectangle,
						Circle:Circle,
						CubicBezier:CubicBezier,
						Ellipse:Ellipse,
						EllipticalArc:EllipticalArc,
						HorizontalLine:HorizontalLine,
						Line:Line,
						Move:Move,
						Path:Path,
						Polygon:Polygon,
						Polyline:Polyline,
						QuadraticBezier:QuadraticBezier,
						RegularRectangle:RegularRectangle,
						RoundedRectangleComplex:RoundedRectangleComplex,
						VerticalLine:VerticalLine,
						
						segment: {
							ClosePath:ClosePath,
							CubicBezierTo:CubicBezierTo,
							EllipticalArcTo:EllipticalArcTo,
							HorizontalLineTo:HorizontalLineTo,
							LineTo:LineTo,
							MoveTo:MoveTo,
							QuadraticBezierTo:QuadraticBezierTo,
							VerticalLineTo:VerticalLineTo
						},
						command: {
							CommandStack:CommandStack,
							CommandStackItem:CommandStackItem,
							CommandCollection:CommandCollection
						}
						
					},
					paint: {
						BitmapFill:BitmapFill,
						BlendFill:BlendFill,
						ComplexFill:ComplexFill,
						GradientStop:GradientStop,
						LinearGradientFill:LinearGradientFill,
						LinearGradientStroke:LinearGradientStroke,
						RadialGradientStroke:RadialGradientStroke,
						SolidFill:SolidFill,
						SolidStroke:SolidStroke
					},
					repeaters: {
						GeometryRepeater:GeometryRepeater,
						PropertyModifier:PropertyModifier
					},
					skins: {
						CSSSkin:CSSSkin,
						GraphicBorderSkin:GraphicBorderSkin,
						GraphicProgrammaticSkin:GraphicProgrammaticSkin,
						GraphicRectangularBorderSkin:GraphicRectangularBorderSkin
					},
					transform: {
						MatrixTransform:MatrixTransform,
						RotateTransform:RotateTransform,
						ScaleTransform:ScaleTransform,
						SkewTransform:SkewTransform,
						TransformGroup:TransformGroup,
						TranslateTransform:TranslateTransform
					},
					utilities: { 
						external:{
								ExternalBitmapData:ExternalBitmapData,
								LoadingLocation:LoadingLocation
								}
					}
				}
			}
			
		}
		
		private static var registeredAliases:Dictionary = new Dictionary();
		private static var registeredClasses:Dictionary = new Dictionary();
		
		/**
		 * 
		 * @param	classOrAlias either a Class reference or an alias to check
		 * @return  true if the Class or alias is already registered.
		 */
		public static function isRegistered(classOrAlias:*):Boolean
		{
			if (classOrAlias is String)
			{
				if (registeredAliases[classOrAlias]) return true;
				return false;
			} else if (classOrAlias is Class)
			{
				if (registeredClasses[classOrAlias]) return true;
				return false;
			}
			throw new Error('invalid argument');
		}
		/**
		 * Provides a method of Class retrieval that is faster than 
		 * flash.utils.getDefinitionByName for specific class references 
		 * stored here.
		 * @param	alias, a string that represents the alias for the class being requested
		 * @return  a reference to the Class from the alias
		 */
		public static function getClassReference(alias:String):Class
		{
			if (registeredAliases[alias])
			{
				return registeredAliases[alias];
			}
			return ArgumentError;
		}
		/**
		 * Registers class aliases in the manifest object from the package level specified
		 * @param	including , the package path or fully qualified class path to register
		 */

		private static function registerFrom(including:String = "com"):void
		{
			if (_all) return;
			var pckg:Array = including.split('.');
			var i:uint = 0;
			var base:Object=manifest;
			for (; i < pckg.length; i++) base = base[pckg[i]];
			if (base is Class) {
				if (!registeredClasses[base]) {
					registerClassAlias(including, base as Class );
					registeredClasses[base] = including;
					registeredAliases[including] = base;
				}
				return;
			}
			if (base is Object)
				{
					for (var prop:String in base)
					{
						var newInclude:String = including + "." + prop;
						registerFrom(newInclude);
					}
			}
		
			
		}
		
		private static var _all:Boolean = false;

		/**
		 * Registers all classes stored in the Aliases class static manifest object
		 */
		public static function registerAll():void
		{
			//dev note: registerAll incurs around 10 ms in testing
			// likely to be faster if the manifest is a simple array, 
			//   so that's an option if a structured representation offers no utility
			//also consider releasing the manifest object for garbage collection if _all is true
			if (!_all)
			{
				for (var s:String in manifest)
				{
					registerFrom(s);
				}
				_all = true;
			}

		}
	}
}