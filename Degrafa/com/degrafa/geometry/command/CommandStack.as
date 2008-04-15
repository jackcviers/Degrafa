package com.degrafa.geometry.command
{
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CommandStack
	{
		public var source:Array = [];
		public var cmdSource:Array = [];
		public var pointer:Point = new Point(0,0);
		
		public var owner:Geometry;
		
		public function CommandStack(geometry:Geometry = null)
		{
			super();
			
			this.owner = geometry;
		}
		
		public function draw(graphics:Graphics,rc:Rectangle):void{
			
			//exit if no command stack
			if(source.length==0){return;}
						
			//setup the stroke
			owner.initStroke(graphics,rc);
			
			//setup the fill
			owner.initFill(graphics,rc);
			
			var item:CommandStackItem;
			cmdSource = source.reverse(); // Copy
			cmdSource = cmdSource.reverse();
			var cmdCursor:DegrafaCursor = new DegrafaCursor(cmdSource);
			
			/* for each(var decorator:Object in owner.decorators)
			{
				if(decorator is IDecorator)
				{
					decorator.execute(this);
				}
			} */
			
			while(cmdCursor.moveNext())
	   		{
	   			item = CommandStackItem(cmdCursor.current);
					
				switch(item.type)
				{
        			case CommandStackItem.MOVE_TO:
        				graphics.moveTo(item.px,item.py);
        				break;
        			
        			case CommandStackItem.LINE_TO:
        				graphics.lineTo(item.px,item.py);
        				break;
        			
        			case CommandStackItem.CURVE_TO:
        				graphics.curveTo(item.cx,item.cy,item.px,item.py);
        				break;
        				
        			case CommandStackItem.DELEGATE_TO:
        				item.delegate(this, graphics);
        				break;
        		}
        		
        		updatePointer(item);
        	}
        	cmdCursor.moveFirst();
        	
        	endDraw(graphics);
		}
		
		public function endDraw(graphics:Graphics):void{
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
		
		public function addMoveTo(px:Number,py:Number):void{
			source.push(new CommandStackItem(CommandStackItem.MOVE_TO,this,
			px,py));
		}
		
		public function addLineTo(px:Number,py:Number):void{
			source.push(new CommandStackItem(CommandStackItem.LINE_TO,this,
			px,py));
		}
		
		public function addCurveTo(px:Number,py:Number,cx:Number,cy:Number):void{
			source.push(new CommandStackItem(CommandStackItem.CURVE_TO,this,
			px,py,cx,cy));
		}
		
		public function addDelegate(delegate:Function):void{
			source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO,this));
		}
		
		protected function updatePointer(item:CommandStackItem):void
		{
			item.ox = pointer.x;
			item.oy = pointer.y;
			
			if(item.px)
				pointer.x = item.px;
    		if(item.py)
    			pointer.y = item.py;
		}
		
		protected var _cursor:DegrafaCursor;
		public function get cursor():DegrafaCursor
		{
			if(!_cursor)
				_cursor = new DegrafaCursor(source);
				
			return _cursor;
		}
		
		public function push(value:Object):void
		{
			source.push(value);
		}
		
		public function get length():int
	    {
	    	return source.length;
	    }
	    
	    public function set length(value:int):void
	    {
	    	source.length = value;
	    }
	}
}