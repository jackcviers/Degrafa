package PolyShapeLibs{
	import com.degrafa.geometry.PolygonLibrary;
	
	[Bindable]	
	public class ArrowsLibrary extends PolygonLibrary {
		public static const ARROW_CHEVRON:String="0,0 2,0 3,1 2,2 0,2 1,1";
		public static const ARROW_DOWN:String="1,0 1,2 0,2 2,4 4,2 3,2 3,0";
		public static const ARROW_LEFT_NOTCHED:String="4,1 2,1 2,0 0,2 2,4 2,3 4,3 3,2";
		public static const ARROW_LEFT_RIGHT:String="6,1 2,1 2,0 0,2 2,4 2,3 6,3 6,4 8,2 6,0";
		public static const ARROW_LEFT_RIGHT_UP:String="8,4 6,4 6,2 7,2 5,0 3,2 4,2 4,4 2,4 2,3 0,5 2,7 2,6 8,6 8,7 10,5 8,3";
		public static const ARROW_LEFT_UP:String="6,2 7,2 5,0 3,2 4,2 4,4 2,4 2,3 0,5 2,7 2,6 6,6";
		public static const ARROW_PENTAGON:String="0,0 2,0 3,1 2,2 0,2";
		
				
		public function ArrowsLibrary(item:String="ARROW_CHEVRON"){
			super();
			
			_selected = item;
						
			//build the list of available objects
			_shapeList.push({id:0, label:"ARROW_CHEVRON"});
			_shapeList.push({id:1, label:"ARROW_DOWN"});
			_shapeList.push({id:2, label:"ARROW_LEFT_NOTCHED"});
			_shapeList.push({id:3, label:"ARROW_LEFT_RIGHT"});
			_shapeList.push({id:4, label:"ARROW_LEFT_RIGHT_UP"});
			_shapeList.push({id:5, label:"ARROW_LEFT_UP"});
			_shapeList.push({id:6, label:"ARROW_PENTAGON"});
			
		}
		
		private var _selected:String;
		public function get selected():String{
			return _selected
		}
		
		[Inspectable(category="General", 
		enumeration="ARROW_CHEVRON,ARROW_DOWN,ARROW_LEFT_NOTCHED,ARROW_LEFT_RIGHT,ARROW_LEFT_RIGHT_UP,ARROW_LEFT_UP,ARROW_PENTAGON",				
		defaultValue="ARROW_CHEVRON")]
		override public function set type(value:String):void{
			data = ArrowsLibrary[value];
			_selected = value;
			super.type=value;
		}
	}
}