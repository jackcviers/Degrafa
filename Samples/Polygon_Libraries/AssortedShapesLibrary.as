package PolyShapeLibs{
	
	import com.degrafa.geometry.PolygonLibrary;
	
	public class AssortedShapesLibrary extends PolygonLibrary{
		
		public static const CROSS_MALTESE:String="7,6 7.5,5 7,4 9,5 8,3 9,3.5 10,3 9,5 11,4 10.5,5 11,6 9,5 10,7 9,6.5 8,7 9,5";
		public static const CROSS_SWISS:String="2.55,3.05 2.55,2.55 3.05,2.55 3.05,2.05 3.55,2.05 3.55,2.55 4.05,2.55 4.05,3.05 3.55,3.05 3.55,3.55 3.05,3.55 3.05,3.05";
		public static const DIAMOND:String="1,0 2,1 1,2 0,1";
		public static const HEPTAGON:String="0,6 0.5,2 5,0 9.5,2 10,6 7.5,9.5 2.5,9.5";
		public static const HEXAGON:String="1.5,1 3,1 4,2.5 3,4 1.5,4 0.5,2.5";
		public static const OCTAGON:String="3.55,2.05 5.05,2.05 6.05,3.05 6.05,4.55 5.05,5.55 3.55,5.55 2.55,4.55 2.55,3.05";
		public static const PARALLELOGRAM_HORIZONTAL:String="1,0 2,0 1,1 0,1";
		public static const PARALLELOGRAM_VERTICAL:String= "0,1 1,0 1,1 0,2";
		public static const PENTAGON:String= "0,1.5 2,0 4,1.5 3,3.5 1,3.5";
		public static const STAR_4:String= "0,2.5 1.5,2 2,0.5 2.5,2 4,2.5 2.5,3 2,4.5 1.5,3";
		public static const STAR_5:String= "0,4.5 5,4.5 7,0 9,4.5 14,4.5 10,7.5 12,12.5 7,9 2,12.5 4,7.5"; 
		public static const STAR_6:String= "0,1 1,1 1.5,0 2,1 3,1 2.5,2 3,3 2,3 1.5,4 1,3 0,3 0.5,2";
		public static const STAR_7:String= "5,0 6.5,2 9,2 8.5,4.5 10,6.5 8,7 7.5,9.5 5,8 2.5,9.5 2,7 0,6.5 1.5,4.5 1,2 3.5,2"; 
		public static const STAR_8:String= "0,3.5 1,2.5 1,1 2.5,1 3.5,0 4.5,1 6,1 6,2.5 7,3.5 6,4.5 6,6 4.5,6 3.5,7 2.5,6 1,6 1,4.5";
		public static const STAR_8_SHARP:String= "0,7.5 5,6.5 2.5,2.5 6.5,5 7.5,0 8.5,5 12.5,2.5 10,6.5 15,7.5 10,8.5 12.5,12.5 8.5,10 7.5,15 6.5,10 2.5,12.5 5,8.5";
		public static const TRAPEZOID:String= "1,0 3,0 4,2 0,2";
		public static const TRIANGLE_ISOCELES:String= "5.5,4 6.5,6 4.5,6";
		public static const TRIANGLE_RIGHTANGLE:String= "0,2 2,2 0,0";
				
		
		public function AssortedShapesLibrary(item:String="CROSS_MALTESE"){
			super();
			
			_selected = item;
				
			//build the list of available objects
			_shapeList.push({id:0, label:"CROSS_MALTESE"});
			_shapeList.push({id:1, label:"CROSS_SWISS"});
			_shapeList.push({id:2, label:"DIAMOND"});
			_shapeList.push({id:3, label:"HEPTAGON"});
			_shapeList.push({id:4, label:"HEXAGON"});
			_shapeList.push({id:5, label:"OCTAGON"});
			_shapeList.push({id:6, label:"PARALLELOGRAM_HORIZONTAL"});
			_shapeList.push({id:7, label:"PARALLELOGRAM_VERTICAL"});
			_shapeList.push({id:8, label:"PENTAGON"});
			_shapeList.push({id:9, label:"STAR_4"});
			_shapeList.push({id:10, label:"STAR_5"});
			_shapeList.push({id:11, label:"STAR_6"});
			_shapeList.push({id:12, label:"STAR_7"});
			_shapeList.push({id:13, label:"STAR_8"});
			_shapeList.push({id:14, label:"STAR_8_SHARP"});
			_shapeList.push({id:15, label:"TRAPEZOID"});
			_shapeList.push({id:16, label:"TRIANGLE_ISOCELES"});
			_shapeList.push({id:17, label:"TRIANGLE_RIGHTANGLE"});
			
		}
		
		private var _selected:String;
		public function get selected():String{
			return _selected
		}
		
		[Inspectable(category="General", 
		enumeration="CROSS_MALTESE,CROSS_SWISS,DIAMOND,HEPTAGON,HEXAGON,OCTAGON,PARALLELOGRAM_HORIZONTAL,PARALLELOGRAM_VERTICAL,PENTAGON,STAR_4,STAR_5,STAR_6,STAR_7,STAR_8,STAR_8_SHARP,TRAPEZOID,TRIANGLE_ISOCELES,TRIANGLE_RIGHTANGLE",				
		defaultValue="CROSS_MALTESE")]
		override public function set type(value:String):void{
			data = AssortedShapesLibrary[value];
			_selected = value;
			super.type=value;
		}
	}
}