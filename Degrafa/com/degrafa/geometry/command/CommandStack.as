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
	
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.layout.LayoutConstraint;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	public class CommandStack{
		
		//TODO this has to be made private now and all access controlled through the command
		//stack otherwise we can loose previous and next references
		public var source:Array = [];
		
		public var lengthIsValid:Boolean;
		
		public var layoutCurveStreching:Boolean;
		
		public var owner:Geometry;
		
		private static var isRegistered:Boolean = false;
		
		public function CommandStack(geometry:Geometry = null){
			super();
			this.owner = geometry;
			
			if (!isRegistered) {
				registerClassAlias("com.degrafa.geometry.command.CommandStack", CommandStack);
				isRegistered = true;
			}
			
		}

		/**
		* Initiates the render phase.
		**/
		public function draw(graphics:Graphics,rc:Rectangle):void{
			
			//exit if no command stack
			if(source.length==0){return;}
						
			var requester:Geometry = owner;

			//establish a transform context if there are ancestral transforms
			while (requester.parent){
				//assign a transformContext based on the closest ancestral transform
				requester = (requester.parent as Geometry);
				if (requester.transform) {
					owner.transformContext = requester.transform.getTransformFor(requester);
					break;
				}
			}
			//setup a layout transform for paint (and later perhaps, in renderCommandStack)
			if (owner.hasLayout &&  owner.layoutConstraint.isRenderLayout && owner.bounds) {
			//this only handles renderLayouts at this point:
				var temp:Matrix = new Matrix();
			//	if (!owner.bounds) owner.preDraw();
			    //need original bounds here
				temp.translate(-owner.bounds.x, -owner.bounds.y)
				temp.scale(owner.layoutRectangle.width/owner.bounds.width,owner.layoutRectangle.height/owner.bounds.height);
				temp.translate(owner.layoutRectangle.x, owner.layoutRectangle.y);
				owner._layoutMatrix = temp;
			}
						
			//setup the stroke
			owner.initStroke(graphics,rc);
			
			//setup the fill
			owner.initFill(graphics,rc);
			
			//TODO decorations will work differently
			/*
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
			}*/
			
			_cursor = new DegrafaCursor(source);
			renderCommandStack(graphics,rc,_cursor);  
			        	
        	/*if(owner.decorators.length !=0){
        		cmdSource.length = 0;
        	}*/
        	
		}
		
		
		/**
		* Principle render loop. Use delgates to override specific items
		* while the render loop is processing.
		**/
		private function renderCommandStack(graphics:Graphics,rc:Rectangle,cursor:DegrafaCursor=null):void{
			
			var item:CommandStackItem;
			
			var trans:Boolean =  (owner.transformContext ||(owner.transform && !owner.transform.isIdentity));
			
			var transXY:Point;
			var transCP:Point;
			
			var xOffset:Number=0;
			var yOffset:Number=0;
			//setup the layout side
			//TODO : merge layout with transforms for rendering implementation
			if(owner.hasLayout){
				var layout:LayoutConstraint=(owner.layoutConstraint.isRenderLayout)? owner.layoutConstraint:null;
				
				if(layout){
					xOffset = layout.xOffset;
					yOffset = layout.yOffset;
				}
			}
			
			if (trans ) {
				var transMatrix:Matrix = (owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext;
				transXY = new Point();
				transCP = new Point();
			}
			while(cursor.moveNext()){	   			
	   			
	   			item = cursor.current;
	   			
				with(item){	
					switch(type){
						
	        			case CommandStackItem.MOVE_TO:
						    if (trans){
						    	transXY.x = layout? (x-layout.xMin)*layout.xMultiplier+xOffset:x; transXY.y = layout? (y-layout.yMin)*layout.yMultiplier+yOffset:y;
								transXY = transMatrix.transformPoint(transXY);
								graphics.moveTo(transXY.x,transXY.y);
							} 
							else {
								if (layout){
									graphics.moveTo(
										((x-layout.xMin)*layout.xMultiplier)+xOffset,
										((y-layout.yMin)*layout.yMultiplier)+yOffset
										);
								}
								else{
									graphics.moveTo(x,y);
								}
							}
							
	        				break;
	        			
	        			case CommandStackItem.LINE_TO:
	        				if (trans) {
								
								transXY.x = layout? (x-layout.xMin)*layout.xMultiplier+xOffset:x; transXY.y = layout? (y-layout.yMin)*layout.yMultiplier+yOffset:y;
								transXY = transMatrix.transformPoint(transXY);
								graphics.lineTo(transXY.x,transXY.y);
							} 
							else{
								if (layout){
									graphics.lineTo(
										((x-layout.xMin)*layout.xMultiplier)+xOffset,
										((y-layout.yMin)*layout.yMultiplier)+yOffset
										);
								}
								else{
									graphics.lineTo(x,y);
								}
							} 
							
	        				break;
	        			
	        			case CommandStackItem.CURVE_TO:
	        				if (trans) {
								transXY.x = layout? (x1-layout.xMin)*layout.xMultiplier+xOffset:x1; transXY.y = layout? (y1-layout.yMin)*layout.yMultiplier+yOffset:y1;
								//transXY.x = x1; transXY.y = y1;
								transCP.x = layout? (cx-layout.xMin)*layout.xMultiplier+xOffset:cx; transCP.y = layout? (cy-layout.yMin)*layout.yMultiplier+yOffset:cy;
							//	transCP.x = cx; transCP.y = cy;
								transXY = transMatrix.transformPoint(transXY);
								transCP = transMatrix.transformPoint(transCP);
								graphics.curveTo(transCP.x,transCP.y,transXY.x,transXY.y);
							} 
							else{
								if (layout){
									graphics.curveTo(
										((cx-layout.xMin)*layout.xMultiplier)+xOffset,
										((cy-layout.yMin)*layout.yMultiplier)+yOffset,
										((x1-layout.xMin)*layout.xMultiplier)+xOffset,
										((y1-layout.yMin)*layout.yMultiplier)+yOffset);
								}
								else{
									graphics.curveTo(cx,cy,x1,y1);
								}
								
							} 
							
	        				break;
	        				
	        			case CommandStackItem.DELEGATE_TO:
	        				item.delegate(graphics,rc,this);
	        				break;
	        			
	        			//recurse if required
	        			case CommandStackItem.COMMAND_STACK:
	        				renderCommandStack(graphics,rc,new DegrafaCursor(commandStack.source))
					}
    			}
    
        	}
		}
				
		/**
		* Updates the item with the correct previous and next reference
		**/
		private function updateItemRelations(item:CommandStackItem,index:int):void{
			
			item.previous = (index>0)? source[index-1]:null;
			
			if(item.previous){
				if(item.previous.type == CommandStackItem.COMMAND_STACK){
					item.previous = item.previous.commandStack.lastNonCommandStackItem;
				}
			
				item.previous.next = (item.type == CommandStackItem.COMMAND_STACK)? item.commandStack.firstNonCommandStackItem:item;
			}
			
		}
		
		/**
		* get the last none commandstack type (CommandStackItem.COMMAND_STACK)
		* item in this command stack.
		**/
		public function get lastNonCommandStackItem():CommandStackItem{
			var i:int = source.length-1;
			while(i>0){
				if(source[i].type != 4){
					return source[i];
				}
				else{
					return CommandStackItem(source[i]).commandStack.lastNonCommandStackItem;
				}
				i--
			}
			return source[0];
		}
		
		/**
		* Get the first none commandstack type (CommandStackItem.COMMAND_STACK)
		* item in this command stack.
		**/
		public function get firstNonCommandStackItem():CommandStackItem{
			
			var i:int = source.length-1;
			while(i<source.length-1){
				
				if(source[i].type != 4){
					return source[i];
				}
				else{
					return CommandStackItem(source[i]).commandStack.firstNonCommandStackItem;
				}
				
				i++
			}
			
			return null;
		}
		
		
		/**
		* Adds a new MOVE_TO type item to be processed.
		**/	
		public function addMoveTo(x:Number,y:Number):CommandStackItem{
			var itemIndex:int = source.push(new CommandStackItem(CommandStackItem.MOVE_TO,
			x,y,NaN,NaN,NaN,NaN))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new LINE_TO type item to be processed.
		**/	
		public function addLineTo(x:Number,y:Number):CommandStackItem{
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.LINE_TO,
			x,y,NaN,NaN,NaN,NaN))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			lengthIsValid = false;
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new CURVE_TO type item to be processed.
		**/	
		public function addCurveTo(cx:Number,cy:Number,x1:Number,y1:Number):CommandStackItem{
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			lengthIsValid = false;
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new DELEGATE_TO type item to be processed.
		**/	
		public function addDelegate(delegate:Function):CommandStackItem{
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new COMMAND_STACK type item to be processed.
		**/	
		public function addCommandStack(commandStack:CommandStack):CommandStackItem{
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.COMMAND_STACK,
			NaN,NaN,NaN,NaN,NaN,NaN,commandStack))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new command stack item to be processed.
		**/		
		public function addItem(value:CommandStackItem):CommandStackItem{
			
			var itemIndex:int =source.push(value)-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
						
			if(value.type != CommandStackItem.COMMAND_STACK){
				lengthIsValid = false;
			}
			
			return source[itemIndex];
			
		}
						
		private var _currentRenderPoint:Point;
		/**
		* Returns the current end point of the item being rendered.
		**/		
		public function get currentRenderPoint():Point{
			return _currentRenderPoint;
		}
				
		private var _cursor:DegrafaCursor;
		/**
		* Returns a working cursor for this command stack
		**/
		//TODO add a cursor dispose.
		public function get cursor():DegrafaCursor{
			if(!_cursor)
				_cursor = new DegrafaCursor(source);
				
			return _cursor;
		}
		
		/**
		* Retuirn the item at the given index
		**/
		public function getItem(index:int):CommandStackItem{
			return source[index];
		}
		
		/**
		* The current length of the internal array of command stack items. Setting 
		* the length to 0 will clear all items in the command stack.
		**/
		public function get length():int {
			return source.length;
		}
		public function set length(value:int):void{
			source.length = value;
		}
		
		private var _pathLength:Number=0;
		/**
		* Returns the length of the combined path elements.
		**/
		public function get pathLength():Number{
			if(!lengthIsValid){
				lengthIsValid = true;
				var item:CommandStackItem;
				
				for each (item in source){
					_pathLength += item.segmentLength;
				}
			}
			return _pathLength;
		}
		
		//walk from the start to get the first item with length
		public function get firstSegmentWithLength():CommandStackItem{
			
			var item:CommandStackItem;
			
			for each (item in source){
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
		
		//Based on code from Trevor McCauley, www.senocular.com
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
				
				with(item){
					if (type != 0){
						curLength += segmentLength;
					}
					else{
						continue;
					}
					if (tLength <= curLength){
						return segmentPointAt((tLength - lastLength)/segmentLength);
					}
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
				with(item){				
					if (type != 0){
						curLength += segmentLength;
					}
					else{
						continue;
					}
					
					if (tLength <= curLength){
						return segmentAngleAt((tLength - lastLength)/segmentLength);
					}
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