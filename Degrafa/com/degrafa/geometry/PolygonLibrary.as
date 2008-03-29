package com.degrafa.geometry{
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
		
	[Exclude(name="data", kind="property")] 
	
	[Bindable]
	
	public class PolygonLibrary extends Polygon{
		
		public function PolygonLibrary(){
			super();
		} 
				 
		override public function set derive(value:Polygon):void{}
		
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
				
		/**
		* Proportionally sizes each point in the collection to the given width and height
		* taking into account any additional x or y offset that the data may have. 
		* This ensures that rendering is always started at point(0,0) and that the maximum
		* allotted spaced is used for both width and height.  
		**/
    	private function calculateRatios():void{
			
			var maxPointX:Number=0;
			var maxPointY:Number=0;
			
			var minPointX:Number=Number.POSITIVE_INFINITY;
			var minPointY:Number=Number.POSITIVE_INFINITY;
			
			var i:int = 0;
			
			//get the max x or y and compute a ratio of the width and height
			for (i=0;i < points.length; i++){
				maxPointX =Math.max(maxPointX,points[i].x);
				maxPointY =Math.max(maxPointY,points[i].y);
				
				minPointX =Math.min(minPointX,points[i].x);
				minPointY =Math.min(minPointY,points[i].y);
				
			}
			
			//get the percentage of the max points to width and height
			var xMultiplier:Number=_width/maxPointX;
			var yMultiplier:Number=_height/maxPointY;
			
			//multiply the axis by the difference
			for (i=0;i< points.length;i++){
				if(points[i].x!=0){
					points[i].x = (points[i].x-minPointX) * xMultiplier;
				}
				
				if(points[i].y!=0){
					points[i].y = (points[i].y-minPointY) * yMultiplier;
				}
				
			}
			
		}
		
				
		override public function preDraw():void{
			
			if(!data){return}
			
			if(invalidated){
				//calc ratio
				calculateRatios();
			}
			
			super.preDraw();
			
		}
		
	}
}