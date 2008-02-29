package com.degrafa.geometry{
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
		
	[Exclude(name="data", kind="property")] 
	
	[Bindable]
	
	public class PolygonLibrary extends Polygon{
		
		//constructor
		public function PolygonLibrary(){
			super();
		} 
				 
		override public function set derive(value:Polygon):void{}
				
		//base point array that gets modified and set 
		private var basePoints:Array=[];
				
		protected function constToPointStruc(value:String):void{
			
			if(!value){return;}
			
			//parse the string on the space
			var pointsArray:Array = value.split(" ");
			
			//create a temporary point array
			var pointArray:Array=[];
			var pointItem:Array;
			 
			//and then create a point structure for each resulting pair
			//eventually throw exception is not matching properly
			for (var i:int = 0; i< pointsArray.length;i++){
				pointItem = String(pointsArray[i]).split(",");
				
				//skip past blank items as there may have been bad 
				//formatting in the value string, so make sure it is 
				//a length of 2 min	
				if(pointItem.length==2){
					pointArray.push(new GraphicPoint(pointItem[0],pointItem[1]));
				}
				
			}
			
			//set the points to the base
			basePoints=pointArray;
						
		}
		
		protected var _shapeList:Array = [];
		/**
		* Stores an array of objects that is a list of available shapes for this library.
		**/
		public function get shapeList():Array{
			return _shapeList;
		}
		
		private var _type:String;
		/**
		* Sets the type of object to be rendered.
		**/
		public function get type():String{
			return _type;
		}
		public function set type(value:String):void{
			if(_type != value){
			
				_type = value;
			
				invalidated = true;
			}
		}
				
		//data is this case is a const type defined in this class
		//override public function set data(value:String):void{}
		
		private var _width:Number=0;
		/**
		* The width of the object. If not specified 
		* a default value of 0 is used.
		**/
		public function get width():Number{
			return _width;
		}
		public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated = true;
			}
		}
		
		private var _height:Number=0;
		/**
		* The height of the object. If not specified 
		* a default value of 0 is used.
		**/
		public function get height():Number{
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
				
		private function calculateRatios():void{
			
			var maxPointX:Number=0;
			var maxPointY:Number=0;
			
			var i:int = 0;
			
			//get the max x or y and compute a ratio of the width and height
			for (i=0;i < basePoints.length; i++){
				maxPointX =Math.max(maxPointX,basePoints[i].x);
				maxPointY =Math.max(maxPointY,basePoints[i].y);
			}
			
			//get the percentage of the max points to width and height
			var xMultiplier:Number=_width/maxPointX;
			var yMultiplier:Number=_height/maxPointY;
			
			//multiply the axis by the difference
			for (i=0;i< basePoints.length;i++){
				if(basePoints[i].x!=0){
					basePoints[i].x = basePoints[i].x * xMultiplier;
				}
				
				if(basePoints[i].y!=0){
					basePoints[i].y = basePoints[i].y * yMultiplier;
				}
				
			}
			
		}
		
		override public function preDraw():void{
			if(invalidated){
				//calc ratio
				calculateRatios();
				
				//reset set the points			
				pointCollection.items=basePoints;
			}
			super.preDraw();
		}
		
	}
}