package com.degrafa.geometry.command
{
	public class CommandStackItem
	{
		public static const MOVE_TO:int=0;
		public static const LINE_TO:int=1;
		public static const CURVE_TO:int=2;
		public static const DELEGATE_TO:int=3;
		
		public function CommandStackItem(type:int=0,commandStack:CommandStack=null,px:Number=NaN,py:Number=NaN,cx:Number=NaN,cy:Number=NaN,ox:Number=NaN,oy:Number=NaN)
		{
			this.type = type;
			this.commandStack = commandStack;
			
			this.px=px;
			this.py=py;
			this.cx=cx;
			this.cy=cy;
			this.ox=ox;
			this.oy=oy;
		}
				
		public var type:int=0;
		public var commandStack:CommandStack;
		public var id:String;
		public var reference:String;
		
		public var ox:Number;
		public var oy:Number;
		public var cx:Number;
		public var cy:Number;
		public var px:Number;
		public var py:Number;
		public var delegate:Function;
	}
}