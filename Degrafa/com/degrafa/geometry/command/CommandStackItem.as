package com.degrafa.geometry.command
{
	public class CommandStackItem
	{
		public static const MOVE_TO:String="m";
		public static const LINE_TO:String="l";
		public static const CURVE_TO:String="c";
		public static const DELEGATE_TO:String="d";
		
		public function CommandStackItem(type:String="",x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN,cx:Number=NaN,cy:Number=NaN,ox:Number=NaN,oy:Number=NaN)
		{
			this.type = type;
			
			this.x=x;
			this.y=y;
			this.x1=x1;
			this.y1=y1;
			this.cx=cx;
			this.cy=cy;
			this.ox=ox;
			this.oy=oy;
		}
				
		public var type:String;
		public var id:String;
		public var reference:String;
		
		public var x:Number;
		public var y:Number;
		
		public var x1:Number;
		public var y1:Number;
		
		public var cx:Number;
		public var cy:Number;
		
		// Origin points 
		public var ox:Number;
		public var oy:Number;
		
		// Funciton used in a DELEGATE_TO command
		public var delegate:Function;
	}
}