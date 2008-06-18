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
	import flash.geom.Matrix;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CommandStack{
		
		public var source:Array = [];
		public var cmdSource:Array;
		public var pointer:Point = new Point(0,0);
		
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
			
			//exit if no command stack
			if(source.length==0){return;}
	
			var requester:Geometry = owner;
			//establish a transform context if there are ancestral transforms
			while (requester.parent)
				{
					//assign a transformContext based on the closest ancestral transform
					requester = (requester.parent as Geometry);
					if (requester.transform) {
						owner.transformContext = requester.transform.getTransformFor(requester);
						break;
					}
				}

						
			//setup the stroke
			owner.initStroke(graphics,rc);
			
			//setup the fill
			owner.initFill(graphics,rc);
			
			if(owner.decorators.length !=0){
				cmdSource = CloneUtil.clone(source)
				_cursor = new DegrafaCursor(cmdSource);
				
				for each(var decorator:Object in owner.decorators){
					if(decorator is IDrawDecorator){
						decorator.execute(this);
					}
				}
			
			}
			else{
				_cursor = new DegrafaCursor(source);	
			}
			
			renderCommandStack(graphics,rc,_cursor);
			        	
        	if(owner.decorators.length !=0){
        		cmdSource.length = 0;
        	}
        	
        	//endDraw(graphics);
		}

		private function renderCommandStack(graphics:Graphics,rc:Rectangle,cursor:DegrafaCursor=null):void{
		
			var item:CommandStackItem;
			
			
			var trans:Boolean =  (owner.transformContext ||(owner.transform && !owner.transform.isIdentity));
			
			var transXY:Point;
			var transCP:Point;
			
			if (trans ) {
				var transMatrix:Matrix = (owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext;
				transXY = new Point();
				transCP = new Point();
			}
			while(cursor.moveNext()){	   			
	   			
	   			item = cursor.current;
					
				switch(item.type){
					
        			case CommandStackItem.MOVE_TO:
					    if (trans)
					    {
							transXY.x = item.x; transXY.y = item.y;
							transXY = transMatrix.transformPoint(transXY);
							graphics.moveTo(transXY.x,transXY.y);
						} else graphics.moveTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.LINE_TO:
        				 if (trans)
					    {
							transXY.x = item.x; transXY.y = item.y;
							transXY = transMatrix.transformPoint(transXY);
							graphics.lineTo(transXY.x,transXY.y);
						} else graphics.lineTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.CURVE_TO:
        				 if (trans)
					    {
							transXY.x = item.x1; transXY.y = item.y1;
							transCP.x = item.cx; transCP.y = item.cy;
							transXY = transMatrix.transformPoint(transXY);
							transCP = transMatrix.transformPoint(transCP);
							graphics.curveTo(transCP.x,transCP.y,transXY.x,transXY.y);
						} else graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
        				break;
        				
        			case CommandStackItem.DELEGATE_TO:
        				item.delegate(graphics,rc,this);
        				break;
        			
        			//recurse if required
        			case CommandStackItem.COMMAND_STACK:
        				//renderCommandStack(graphics,rc,new DegrafaCursor(item.commandStack.source))
        				item.commandStack.draw(graphics,rc);
        		}
        		
        		updatePointer(item);
        	}
			
				
		}
		
		/*protected function endDraw(graphics:Graphics):void{
			if (owner.fill){ 
	        	owner.fill.end(graphics);  
	        }
	        
	        //draw children
	        if (owner.geometry){
				for each (var geometryItem:IGeometryComposition in owner){
					geometryItem.draw(graphics,null);
				}
			}
	    }*/
		
		//create and add move to item
		public function addMoveTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.MOVE_TO,
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
		}
		
		//create and add line to item
		public function addLineTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.LINE_TO,
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
			
			lengthIsValid = false;
		}
		
		//create and add curve to item
		public function addCurveTo(cx:Number,cy:Number,x1:Number,y1:Number):void{
			source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy,currentPointX,currentPointY));
			
			currentPointX =x1;
			currentPointY =y1;
		
			lengthIsValid = false;
		}
		
		//create and add delegate function item
		public function addDelegate(delegate:Function):void{
			source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO));
		}
		
		//create and add command stack item
		public function addCommandStack(commandStack:CommandStack):void{
			source.push(new CommandStackItem(CommandStackItem.COMMAND_STACK,
			NaN,NaN,NaN,NaN,NaN,NaN,currentPointX,currentPointY,commandStack));
			
			//currentPointX =x;
			//currentPointY =y;
		}
		
		public function getItem(index:int):CommandStackItem{
			return source[index];
		}
		
		//add an already created item		
		public function addItem(value:CommandStackItem):void{
			
			//we have to set the origin and init the points as this is not
			//always done when the iteam is created.
			if(value.type == CommandStackItem.COMMAND_STACK){
				//if command stack then set the first items origin
				var firstSegment:CommandStackItem =value.commandStack.firstSegmentWithLength;
				firstSegment.originX=currentPointX;
				firstSegment.originY=currentPointY;
				firstSegment.initPoints();
				
				//set current to last command stack item end point
				
				var lastSegment:CommandStackItem = value.commandStack.lastSegmentWithLength;
				currentPointX =lastSegment.end.x;
				currentPointY =lastSegment.end.y;
			
			}
			else{
				value.originX=currentPointX;
				value.originY=currentPointY;
				value.initPoints();
				currentPointX =value.end.x;
				currentPointY =value.end.y;
			}
			
			source.push(value);
						
			if(value.type != CommandStackItem.COMMAND_STACK){
				lengthIsValid = false;
			}
			
		}
		
		protected function updatePointer(item:CommandStackItem):void{
			item.originX = pointer.x;
			item.originY = pointer.y;
			
			pointer.x = item.end.x;
			pointer.y = item.end.y;
			
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
		public function get pathLength():Number{
			if(!lengthIsValid){
				lengthIsValid = true;
				for each (var item:CommandStackItem in source){
					_pathLength += item.segmentLength;
				}
			}
			return _pathLength;
		}
		
		//walk from the start to get the first item with length
		public function get firstSegmentWithLength():CommandStackItem{
			
			for each (var item:CommandStackItem in source){
				switch(item.type){
					
					case 1:
					case 2:
						return item;
					case 4:
						//recurse todo
						return item.commandStack.firstSegmentWithLength;
				}
			}
			
			return source[0];
		}
		
		//walk the source backwards to get the last item that has length
		public function get lastSegmentWithLength():CommandStackItem{
			
			var i:int = source.length-1;
			while(i>0){
				if(source[i].type == 1 || source[i].type == 2){
					return source[i];
				}
				
				if(source[i].type == 4){
					//recurse todo
					return source[i].commandStack.lastSegmentWithLength;
				}
				
				i--
			}
			
			return source[length-1];
		}
		
		
		/**
		* Returns the point at t(0-1) on the path.
		**/
		public function pathPointAt(t:Number):Point {
			t = cleant(t);
			
			var curLength:Number = 0;
			
			if (t == 0){
				var firstSegment:CommandStackItem =firstSegmentWithLength;
				curLength = firstSegment.segmentLength;
				return firstSegment.segmentPointAt(t);
			}
			else if (t == 1){
				return lastSegmentWithLength.segmentPointAt(t);
			}
			
			var tLength:Number = t*pathLength;
			var lastLength:Number = 0;
			var item:CommandStackItem;
			var n:Number = source.length;
			
			for each (item in source){
				if (item.type != 0){
					curLength += item.segmentLength;
				}
				else{
					continue;
				}
				if (tLength <= curLength){
					return item.segmentPointAt((tLength - lastLength)/item.segmentLength);
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
			
			var curLength:Number = 0;
			
			if (t == 0){
				var firstSegment:CommandStackItem =firstSegmentWithLength;
				curLength = firstSegment.segmentLength;
				return firstSegment.segmentAngleAt(t);
			}
			else if (t == 1){
				return lastSegmentWithLength.segmentAngleAt(t);
			}
			
			var tLength:Number = t*pathLength;
			var lastLength:Number = 0;
			var item:CommandStackItem;
			var n:Number = source.length;
			
			for each (item in source){
								
				if (item.type != 0){
					curLength += item.segmentLength;
				}
				else{
					continue;
				}
				
				if (tLength <= curLength){
					return item.segmentAngleAt((tLength - lastLength)/item.segmentLength);
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