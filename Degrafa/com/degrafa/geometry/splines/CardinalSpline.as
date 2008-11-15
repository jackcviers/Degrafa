package  com.degrafa.geometry.splines {
	import com.degrafa.geometry.Geometry;
	
	
	public class CardinalSpline extends Geometry{
		
		public function CardinalSpline(){
		
		}
		
		private var pts:Array=[];
		
		override public function set data(value:String):void{
			if(data != value){
				super.data = value;
			
				//parse the string on the space
				var pointsArray:Array = value.split(" ");
				var pointItem:Array;
				
				var i:int = 0;
				var length:int = pointsArray.length;
				for (; i< length;i++){
					pointItem = String(pointsArray[i]).split(",");
					
					if(pointItem.length==2){
						pts.push(pointItem[0],pointItem[1]);
					}
					
				}
				
				invalidated = true;
				
			}
			
		}
			
					
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				pointsToCardinalSpline();
				
				//if(!_points || !_points.items){return;}
				//commandStack.length=0;
			}
		}
		
		private var _slack:Number;
		/**
		* The y-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		public function get slack():Number{
			if(!_slack){return 0;}
			return _slack;
		}
		public function set slack(value:Number):void{
			if(_slack != value){
				_slack = value;
				invalidated = true;
			}
		}
		
		private var _start:Number;
		public function get start():Number{
			if(!_start){return 0;}
			return _start;
		}
		public function set start(value:Number):void{
			if(_start != value){
				_start = value;
				invalidated = true;
			}
		}
		
		private var _npoints:Number;
		public function get npoints():Number{
			if(!_npoints){return 0;}
			return _npoints;
		}
		public function set npoints(value:Number):void{
			if(_npoints != value){
				_npoints = value;
				invalidated = true;
			}
		}
		
		private var _closed:Boolean;
		public function get closed():Boolean{
			if(!_closed){return false;}
			return _closed;
		}
		public function set closed(value:Boolean):void{
			if(_closed != value){
				_closed = value;
				invalidated = true;
			}
		}
		
		private var _tx:Number;
		/**
		* The y-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		public function get tx():Number{
			if(!_tx){return 0;}
			return _tx;
		}
		public function set tx(value:Number):void{
			if(_tx != value){
				_tx = value;
				invalidated = true;
			}
		}
		
		private var _ty:Number;
		/**
		* The y-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		public function get ty():Number{
			if(!_ty){return 0;}
			return _ty;
		}
		public function set ty(value:Number):void{
			if(_ty != value){
				_ty = value;
				invalidated = true;
			}
		}
		
		private function get p():Array{
			return commandStack.source;
		}
		
		private function pointsToCardinalSpline():void{
			
			// compute the size of the path
	        var len:int = 2*npoints;
	        var end:int = start+len;
	
	        var dx1:Number;
	        var dy1:Number;
	        var dx2:Number;
	        var dy2:Number;
	        
	
	        // compute first control point
	        /*if ( closed ) {
	            dx2 = pts[start+2]-pts[end-2];
	            dy2 = pts[start+3]-pts[end-1];
	        } else {*/
	            dx2 = pts[start+4]-pts[start];
	            dy2 = pts[start+5]-pts[start+1];
	       // }
	
	        // repeatedly compute next control point and append curve
	        /*var i:int;
	        for ( i=start+2; i<end-2; i+=2 ) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = pts[i+2]-pts[i-2];
	            dy2 = pts[i+3]-pts[i-1];
	           
	           
	            p.push(String("curveTo("+ tx+pts[i-2]+slack*dx1 + "," + ty+pts[i-1]+slack*dy1 + ","+
	                      tx+pts[i]  -slack*dx2 + "," + ty+pts[i+1]-slack*dy2 + ","+
	                      tx+pts[i] +","+             ty+pts[i+1] + ")"));
	        }*/
	
	        // compute last control point
	        /*if ( closed ) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = pts[start]-pts[i-2];
	            dy2 = pts[start+1]-pts[i-1];
	            p.curveTo(tx+pts[i-2]+slack*dx1, ty+pts[i-1]+slack*dy1,
	                      tx+pts[i]  -slack*dx2, ty+pts[i+1]-slack*dy2,
	                      tx+pts[i],             ty+pts[i+1]);
	
	            dx1 = dx2; dy1 = dy2;
	            dx2 = pts[start+2]-pts[end-2];
	            dy2 = pts[start+3]-pts[end-1];
	            p.curveTo(tx+pts[end-2]+slack*dx1, ty+pts[end-1]+slack*dy1,
	                      tx+pts[0]    -slack*dx2, ty+pts[1]    -slack*dy2,
	                      tx+pts[0],               ty+pts[1]);
	            p.closePath();
	        } else {*/
	          /*  p.push(String(curveTo(tx+pts[i-2]+slack*dx2, ty+pts[i-1]+slack*dy2,
	                      tx+pts[i]  -slack*dx2, ty+pts[i+1]-slack*dy2,
	                      tx+pts[i],             ty+pts[i+1])));
	       // }*/
		}
		
	}
}