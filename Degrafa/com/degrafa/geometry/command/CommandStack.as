package com.degrafa.geometry.command
{
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.core.utils.CloneUtil;
	import com.degrafa.decorators.IDrawDecorator;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CommandStack
	{
		public var source:Array = [];
		public var cmdSource:Array = [];
		public var pointer:Point = new Point(0,0);
		public var graphics:Graphics;
		
		public var owner:Geometry;
		
		public function CommandStack(geometry:Geometry = null)
		{
			super();
			
			this.owner = geometry;
		}
		
		public function draw(graphics:Graphics,rc:Rectangle):void{
			
			this.graphics = graphics;
			
			//if(!owner.visible){return;}
			
			//exit if no command stack
			if(source.length==0){return;}
			
			if(owner.transform){
				owner.transform.apply(owner);
			}
						
			//setup the stroke
			owner.initStroke(graphics,rc);
			
			//setup the fill
			owner.initFill(graphics,rc);
			
			var item:CommandStackItem;
			
			cloneSource()

			_cursor = new DegrafaCursor(cmdSource);
			
			for each(var decorator:Object in owner.decorators)
			{
				if(decorator is IDrawDecorator)
				{
					decorator.execute(this);
				}
			}
			
			while(_cursor.moveNext())
	   		{
	   			item = CommandStackItem(_cursor.current);
					
				switch(item.type)
				{
        			case CommandStackItem.MOVE_TO:
        				graphics.moveTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.LINE_TO:
        				graphics.lineTo(item.x1,item.y1);
        				break;
        			
        			case CommandStackItem.CURVE_TO:
        				graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
        				break;
        				
        			case CommandStackItem.DELEGATE_TO:
        				item.delegate(this);
        				break;
        		}
        		
        		updatePointer(item);
        	}
        	
        	cmdSource = [];
        	
        	endDraw(graphics);
		}
		
		protected function endDraw(graphics:Graphics):void{
			if (owner.fill){ 
	        	owner.fill.end(graphics);  
	        }
	        
	        //draw children
	        if (owner.geometry){
				for each (var geometryItem:IGeometryComposition in owner){
					geometryItem.draw(graphics,null);
				}
			}
	    }
		
		public function addMoveTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.MOVE_TO,
			x,y));
		}
		
		public function addLineTo(x1:Number,y1:Number):void{
			source.push(new CommandStackItem(CommandStackItem.LINE_TO,
			NaN,NaN,x1,y1));
		}
		
		public function addCurveTo(cx:Number,cy:Number,x1:Number,y1:Number):void{
			source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy));
		}
		
		public function addDelegate(delegate:Function):void{
			source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO));
		}
		
		protected function updatePointer(item:CommandStackItem):void
		{
			item.ox = pointer.x;
			item.oy = pointer.y;
			
			if(item.x)
				pointer.x = item.x;
    		if(item.y)
    			pointer.y = item.y;
    		if(item.x1)
				pointer.x = item.x1;
    		if(item.y1)
    			pointer.y = item.y1;
		}
		
		protected function cloneSource():void
		{
			for each(var cmd:Object in source)
			{
				cmdSource.push(CloneUtil.clone(cmd));
			}
		}
		
		protected var _cursor:DegrafaCursor;
		public function get cursor():DegrafaCursor
		{
			if(!_cursor)
				_cursor = new DegrafaCursor(source);
				
			return _cursor;
		}
		
		public function get length():int {
			return source.length;
		}
		
		public function set length(v:int):void {
			source.length = v;
		}
	}
}