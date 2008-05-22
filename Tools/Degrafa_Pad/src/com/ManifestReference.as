package com
{
	import com.ReferenceUtil;
	//imports extracted from manifest.xml
	import com.degrafa.transform.*
	import com.degrafa.core.manipulators.*
	import com.degrafa.paint.*
	import com.degrafa.utilities.*
	import com.decorations.*
	import com.degrafa.*
	import com.degrafa.geometry.*
	import com.degrafa.geometry.repeaters.*
	import com.degrafa.skins.*
	import com.degrafa.geometry.segment.*

	public class ManifestReference
	{
		
		private static var forceInclusionReferences:Array = [
				GeometryGroup,
				Surface,
				GraphicImage,
				GraphicPoint,
				GraphicPointEX,
				GraphicText,
				GeometryComposition,
				MatrixTransform,
				RotateTransform,
				ScaleTransform,
				SkewTransform,
				TransformGroup,
				TranslateTransform,
				DegrafaSkinManipulator,
				BitmapFill,
				BlendFill,
				ComplexFill,
				GradientStop,
				LinearGradientFill,
				LinearGradientStroke,
				RadialGradientFill,
				RadialGradientStroke,
				SolidFill,
				SolidStroke,
				AdvancedRectangle,
				Circle,
				CubicBezier,
				Ellipse,
				EllipticalArc,
				HorizontalLine,
				Line,
				Move,
				Path,
				Polygon,
				Polyline,
				QuadraticBezier,
				RegularRectangle,
				RoundedRectangle,
				RoundedRectangleComplex,
				VerticalLine,
				CircleRepeater,
				CubicBezierRepeater,
				EllipseRepeater,
				EllipticalArcRepeater,
				HorizontalLineRepeater,
				LineRepeater,
				PolygonRepeater,
				PolyLineRepeater,
				QuadraticBezierRepeater,
				RegularRectangleRepeater,
				RoundedRectangleRepeater,
				RoundedRectangleComplexRepeater,
				VerticalLineRepeater,
				ClosePath,
				CubicBezierTo,
				EllipticalArcTo,
				HorizontalLineTo,
				LineTo,
				MoveTo,
				QuadraticBezierTo,
				VerticalLineTo,
				CSSSkin,
				GraphicBorderSkin,
				GraphicProgrammaticSkin,
				GraphicRectangularBorderSkin,
				LoadingLocation,
				CurveToLineDecorator,
				StrokeDecorator,
				CurveDecorator
		];
	
	// utility method for updating imports in this class file from the manifest
		public static function getManifestUpdates():void
		{
			//get all imports
			var imports:Object = new Object();
			var classList:XMLList = manifest.component.attribute("class");
			var pckg:String;
			for each(var className:XML in classList)
			{
				pckg = className.toString()
				pckg = pckg.substr(0, pckg.lastIndexOf("."));
				if (!imports[pckg]) imports[pckg] = pckg + ".*";
			}
			trace('//imports from manifest.xml');
			for each(pckg in imports)
			{
				trace('import ' + pckg);
			}
			//create dummy reference array
			var output:Array = ReferenceUtil.mxmlList;
			trace("//forceInclusionReferences extracted from manifest.xml");
			trace("private static var forceInclusionReferences:Array = [");
			for (var i:uint = 0; i < output.length-1; i++)
			{
				trace(output[i] + ",");
			}
			trace(output[i] + "];");
			trace('//END OF UPDATES');
		}
		
		//TODO: set this up to embed the manifest.xml file so its always up to date
		public static var manifest:XML= <componentPackage>
    
    <!--root-->
    <component id="GeometryGroup" class="com.degrafa.GeometryGroup"/>
	<component id="Surface" class="com.degrafa.Surface"/>
	<component id="GraphicImage" class="com.degrafa.GraphicImage"/>
	<component id="GraphicPoint" class="com.degrafa.GraphicPoint"/>
	<component id="GraphicPointEX" class="com.degrafa.GraphicPointEX"/>
	<component id="GraphicText" class="com.degrafa.GraphicText"/>
	
	<component id="GeometryComposition" class="com.degrafa.GeometryComposition"/>
		
	<!--Transforms-->
	<component id="MatrixTransform" class="com.degrafa.transform.MatrixTransform"/>
	<component id="RotateTransform" class="com.degrafa.transform.RotateTransform"/>
	<component id="ScaleTransform" class="com.degrafa.transform.ScaleTransform"/>
	<component id="SkewTransform" class="com.degrafa.transform.SkewTransform"/>
	<component id="TransformGroup" class="com.degrafa.transform.TransformGroup"/>
	<component id="TranslateTransform" class="com.degrafa.transform.TranslateTransform"/>

	<!--core-->
	<component id="DegrafaSkinManipulator" class="com.degrafa.core.manipulators.DegrafaSkinManipulator"/>
	
	<!--paint-->
	<component id="BitmapFill" class="com.degrafa.paint.BitmapFill"/>
	<component id="BlendFill" class="com.degrafa.paint.BlendFill"/>
	<component id="ComplexFill" class="com.degrafa.paint.ComplexFill"/>
	<component id="GradientStop" class="com.degrafa.paint.GradientStop"/>
	<component id="LinearGradientFill" class="com.degrafa.paint.LinearGradientFill"/>
	<component id="LinearGradientStroke" class="com.degrafa.paint.LinearGradientStroke"/>
	<component id="RadialGradientFill" class="com.degrafa.paint.RadialGradientFill"/>
	<component id="RadialGradientStroke" class="com.degrafa.paint.RadialGradientStroke"/>
	<component id="SolidFill" class="com.degrafa.paint.SolidFill"/>
	<component id="SolidStroke" class="com.degrafa.paint.SolidStroke"/>
	
		
	<!--geometry-->
	<component id="AdvancedRectangle" class="com.degrafa.geometry.AdvancedRectangle"/>
	<component id="Circle" class="com.degrafa.geometry.Circle"/>
	<component id="CubicBezier" class="com.degrafa.geometry.CubicBezier"/>
	<component id="Ellipse" class="com.degrafa.geometry.Ellipse"/>
	<component id="EllipticalArc" class="com.degrafa.geometry.EllipticalArc"/>
	<component id="HorizontalLine" class="com.degrafa.geometry.HorizontalLine"/>
	<component id="Line" class="com.degrafa.geometry.Line"/>
	<component id="Move" class="com.degrafa.geometry.Move"/>
	<component id="Path" class="com.degrafa.geometry.Path"/>
	<component id="Polygon" class="com.degrafa.geometry.Polygon"/>
	<component id="Polyline" class="com.degrafa.geometry.Polyline"/>
	<component id="QuadraticBezier" class="com.degrafa.geometry.QuadraticBezier"/>
	<component id="RegularRectangle" class="com.degrafa.geometry.RegularRectangle"/>
	<component id="RoundedRectangle" class="com.degrafa.geometry.RoundedRectangle"/>
	<component id="RoundedRectangleComplex" class="com.degrafa.geometry.RoundedRectangleComplex"/>
	<component id="VerticalLine" class="com.degrafa.geometry.VerticalLine"/>
	
	
	<!--repeaters-->
	<component id="CircleRepeater" class="com.degrafa.geometry.repeaters.CircleRepeater"/>
	<component id="CubicBezierRepeater" class="com.degrafa.geometry.repeaters.CubicBezierRepeater"/>
	<component id="EllipseRepeater" class="com.degrafa.geometry.repeaters.EllipseRepeater"/>
	<component id="EllipticalArcRepeater" class="com.degrafa.geometry.repeaters.EllipticalArcRepeater"/>
	<component id="HorizontalLineRepeater" class="com.degrafa.geometry.repeaters.HorizontalLineRepeater"/>
	<component id="LineRepeater" class="com.degrafa.geometry.repeaters.LineRepeater"/>
	<component id="PolygonRepeater" class="com.degrafa.geometry.repeaters.PolygonRepeater"/>
	<component id="PolyLineRepeater" class="com.degrafa.geometry.repeaters.PolyLineRepeater"/>
	<component id="QuadraticBezierRepeater" class="com.degrafa.geometry.repeaters.QuadraticBezierRepeater"/>
	<component id="RegularRectangleRepeater" class="com.degrafa.geometry.repeaters.RegularRectangleRepeater"/>
	<component id="RoundedRectangleRepeater" class="com.degrafa.geometry.repeaters.RoundedRectangleRepeater"/>
	<component id="RoundedRectangleComplexRepeater" class="com.degrafa.geometry.repeaters.RoundedRectangleComplexRepeater"/>
	<component id="VerticalLineRepeater" class="com.degrafa.geometry.repeaters.VerticalLineRepeater"/>
	
	<!--segments-->
	<component id="ClosePath" class="com.degrafa.geometry.segment.ClosePath"/>
	<component id="CubicBezierTo" class="com.degrafa.geometry.segment.CubicBezierTo"/>
	<component id="EllipticalArcTo" class="com.degrafa.geometry.segment.EllipticalArcTo"/>
	<component id="HorizontalLineTo" class="com.degrafa.geometry.segment.HorizontalLineTo"/>
	<component id="LineTo" class="com.degrafa.geometry.segment.LineTo"/>
	<component id="MoveTo" class="com.degrafa.geometry.segment.MoveTo"/>
	<component id="QuadraticBezierTo" class="com.degrafa.geometry.segment.QuadraticBezierTo"/>
	<component id="VerticalLineTo" class="com.degrafa.geometry.segment.VerticalLineTo"/>
	
	<!--skins-->
	<component id="CSSSkin" class="com.degrafa.skins.CSSSkin"/>
	<component id="GraphicBorderSkin" class="com.degrafa.skins.GraphicBorderSkin"/>
	<component id="GraphicProgrammaticSkin" class="com.degrafa.skins.GraphicProgrammaticSkin"/>
	<component id="GraphicRectangularBorderSkin" class="com.degrafa.skins.GraphicRectangularBorderSkin"/>
	
	<!--runtime bitmaps-->
	<component id="LoadingLocation" class="com.degrafa.utilities.LoadingLocation" />
	
	<!--decorations TEMPORARY, not yet in degrafa dev-->
	<component id="CurveToLineDecorator" class="com.decorations.CurveToLineDecorator" />
	<component id="StrokeDecorator" class="com.decorations.StrokeDecorator" />
	<component id="CurveDecorator" class="com.decorations.CurveDecorator" />

	
</componentPackage> ;
	}
}