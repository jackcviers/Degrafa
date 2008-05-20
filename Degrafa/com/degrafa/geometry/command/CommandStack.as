////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.command{
	
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.core.utils.CloneUtil;
	import com.degrafa.decorators.IDrawDecorator;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CommandStack{
		
		public var source:Array = [];
		public var cmdSource:Array;
		public var pointer:Point = new Point(0,0);
		public var graphics:Graphics;
		
		//used to store the origin at creation time as items are added
		//and used to set the origin in the items as they are created
		private var currentPointX:Number=0;
		private var currentPointY:Number=0;
		
		private var lengthIsValid:Boolean;
		
		public var owner:Geometry;
		
		public function CommandStack(geometry:Geometry = null){
			super();
			
			this.owner = geometry;
		}
		
		public function draw(graphics:Graphics,rc:Rectangle):void{
			
			this.graphics = graphics;
						
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
			
			cmdSource = CloneUtil.clone(source)

			_cursor = new DegrafaCursor(cmdSource);
			
			//Dev Note :: need to make sure we are only decorating if the decorator 
			//or geom is invalid in this case we don't need to clone the 
			//source each time perhaps
			for each(var decorator:Object in owner.decorators){
				if(decorator is IDrawDecorator){
					decorator.execute(this);
				}
			}
			
			while(_cursor.moveNext()){	   			
	   			
	   			item = _cursor.current;
					
				switch(item.type){
					
        			case CommandStackItem.MOVE_TO:
        				graphics.moveTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.LINE_TO:
        				graphics.lineTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.CURVE_TO:
        				graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
        				break;
        				
        			case CommandStackItem.DELEGATE_TO:
        				////Dev Note ::?? can we *optionally* pass the source and or graphics/rc here .. ?
        				//to avoid storing it locally
        				item.delegate(this);
        				break;
        		}
        		
        		updatePointer(item);
        	}
        	
        	cmdSource.length = 0;
        	
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
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
		}
		
		public function addLineTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.LINE_TO,
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
			
			lengthIsValid = false
		}
		
		public function addCurveTo(cx:Number,cy:Number,x1:Number,y1:Number):void{
			source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy,currentPointX,currentPointY));
			
			currentPointX =x1;
			currentPointY =y1;
		
			lengthIsValid = false
		}
		
		public function addDelegate(delegate:Function):void{
			source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO));
		}
		
		protected function updatePointer(item:CommandStackItem):void{
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
				
		protected var _cursor:DegrafaCursor;
		public function get cursor():DegrafaCursor{
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
		
		private var _pathLength:Number=0;
		/**
		* Returns the length of the combined path elements.
		**/
		public function pathLength():Number{
			if(!lengthIsValid){
				lengthIsValid = true;
				for each (var item:CommandStackItem in source){
					_pathLength += item.segmentLength();
				}
			}
			return _pathLength;
		}
		
		/**
		* Returns the point at t(0-1) on the path.
		**/
		public function pathPointAt(t:Number):Point {
			t = cleant(t);
			if (t == 0){
				return CommandStackItem(source[0]).segmentPointAt(t);
				
			}else if (t == 1){
				var last:Number = source.length - 1;
				return source[last].segmentPointAt(t);
			}
			
			var tLength:Number = t*pathLength();
			var curLength:Number = 0;
			var lastLength:Number = 0;
			var seg:CommandStackItem;
			var n:Number = source.length;
			var i:Number;
			
			for (i=0; i<n; i++){
				seg = source[i];
				if (seg.type != "m"){
					curLength += seg.segmentLength();
				}
				else{
					continue;
				}
				if (tLength <= curLength){
					return seg.segmentPointAt((tLength - lastLength)/seg.segmentLength());
				}
				lastLength = curLength;
			}
			
			return new Point(0, 0);

		}
		
		/**
		* Returns the angle of a point t(0-1) on the path.
		**/
		public function pathAngleAt(t:Number):Number {
			t = cleant(t);
			
			var tLength:Number = t*pathLength();
			var curLength:Number = 0;
			var lastLength:Number = 0;
			var seg:CommandStackItem;
			var n:Number = source.length;
			var i:Number;
			
			for (i=0; i<n; i++){
				seg = source[i];
				
				if (seg.type != "m"){
					curLength += seg.segmentLength;
				}
				else{
					continue;
				}
				
				if (tLength <= curLength){
					return seg.segmentAngleAt((tLength - lastLength)/seg.segmentLength());
				}
				lastLength = curLength;
			}
			return 0;
		}

		
		private function cleant(t:Number, base:Number=NaN):Number {
			if (isNaN(t)) t = base;
			else if (t < 0 || t > 1){
				t %= 1;
				if (t == 0) t = base;
				else if (t < 0) t += 1;
			}
			return t;
		}


		
	}
}