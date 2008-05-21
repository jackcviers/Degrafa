package com
{
	import com.degrafa.geometry.*;
	import com.degrafa.paint.*;
	import com.decorations.*;
	
	public class ReferenceUtil
	{
		public function ReferenceUtil()
		{
		}
		
		public static function bigSwitch(node:String):Class
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
				case "CurveToLineDecorator":
					return CurveToLineDecorator;
				case "StrokeDecorator":
					return StrokeDecorator;
				case "CurveDecorator":
					return CurveDecorator;
				
			}
			return null
		}
	}
}