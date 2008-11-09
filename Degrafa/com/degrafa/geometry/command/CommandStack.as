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
//
//
// Some algorithms based on code from Trevor McCauley, www.senocular.com
////////////////////////////////////////////////////////////////////////////////

package com.degrafa.geometry.command{
	
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.degrafa.transform.Transform;
	import com.degrafa.transform.TransformBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	public class CommandStack{
		
		//TODO this has to be made private now and all access controlled through the command
		//stack otherwise we can lose previous and next references
		public var source:Array = [];
		
		public var lengthIsValid:Boolean;
		
		public var transMatrix:Matrix;
		
		
		private	static var transXY:Point=new Point();
		private	static var transCP:Point=new Point();
						
		public var owner:Geometry;
		
		//filter stuff
		private var hasFilters:Boolean
		
		private var _fxShape:Shape;
		private var _maskRender:Shape;
		private static var isRegistered:Boolean = false;
		
		public function CommandStack(geometry:Geometry = null){
			super();
			this.owner = geometry;
			if(geometry){
				hasFilters = (geometry.filters.length>0);
			}
			
			if (!isRegistered) {
				registerClassAlias("com.degrafa.geometry.command.CommandStack", CommandStack);
				isRegistered = true;
			}
		}
		
		
		
		/**
		* Setups the layout and transforms
		**/
		private function predraw():void{
			
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
			
			var layout:Boolean=owner.hasLayout;
					
			//setup a layout transform
			if (layout){
				//[Greg] to be verified.
				var temp:Matrix = new Matrix();
				var tempRect:Rectangle = owner.originalBounds ? owner.originalBounds: owner.bounds;
				tempRect = owner.bounds;
				
				temp.translate( -tempRect.x, -tempRect.y)
				temp.scale(owner.layoutRectangle.width/tempRect.width,owner.layoutRectangle.height/tempRect.height);
				temp.translate(owner.layoutRectangle.x, owner.layoutRectangle.y);
				owner._layoutMatrix = temp;
				transMatrix = owner._layoutMatrix.clone();
			}
			
			var trans:Boolean = (owner.transformContext || (owner.transform && !owner.transform.isIdentity));
			
			//combine the layout and transform into one matrix
			if (trans){	
				if (!layout){
					transMatrix = (owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext;	
				} 
				else{
					transMatrix.concat((owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext)
				}
			}
			else{
				if (!layout) transMatrix = null;
			}
		}
		
		/**
		* Initiates the render phase.
		**/
		public function draw(graphics:Graphics,rc:Rectangle):void{

			//exit if no command stack
			if(source.length==0){return;}
			
			//setup requirements before the render
			predraw()
					
			//setup a cursor for the path data interation
			_cursor=new DegrafaCursor(source)
			
			//setup the temporary shape to draw to in place 
			//of the passsed graphics context
			var hasmask:Boolean = (owner.mask!=null);
			if(hasFilters || hasmask){
				if (!_fxShape) _fxShape = new Shape();
				if (hasmask) {
					//dev note: need to change this mask is only redrawn when necessary
					if (!_maskRender) _maskRender = new Shape();
					_maskRender.graphics.clear();
					_fxShape.mask = _maskRender;
					owner.mask.draw(_maskRender.graphics, owner.mask.bounds)
				} else if (_fxShape.mask) _fxShape.mask = null;
				
				/*if(owner.blendMode){
					_fxShape.blendMode = owner.blendMode;
				}*/
				
				_fxShape.graphics.clear();
											
				//setup the stroke
				owner.initStroke(_fxShape.graphics,rc);
				
				//setup the fill
				owner.initFill(_fxShape.graphics,rc);
				
				renderCommandStack(_fxShape.graphics,rc,_cursor);
				
				//apply the filters
			//	if(owner.mask ||(owner.filters.length!=0 && owner.filters[0] !=null)){
					if (owner.filters[0]) _fxShape.filters = owner.filters;
				
					//blit the data to the destination context
					renderBitmapDatatoContext(_fxShape,graphics)
			//	}
				
			}
			else {
				//setup the stroke
				owner.initStroke(graphics,rc);
				
				//setup the fill
				owner.initFill(graphics,rc);
				
				renderCommandStack(graphics,rc,_cursor);
			}
			
		}
		
		
		
		private function renderBitmapDatatoContext(source:DisplayObject,context:Graphics):void{
									
			var sourceRect:Rectangle = source.getBounds(source);
			if (owner.mask) sourceRect = sourceRect.intersection(_maskRender.getBounds(_maskRender));
			if(sourceRect.isEmpty()){return;}
			
			var filteredRect:Rectangle = sourceRect.clone();
			filteredRect.x = filteredRect.y = 0;
			filteredRect.width = Math.ceil(filteredRect.width);
			filteredRect.height = Math.ceil(filteredRect.height);
			filteredRect = updateToFilterRectangle(filteredRect,source);
			filteredRect.offset(sourceRect.x, sourceRect.y);
						
			var bitmapData:BitmapData;
			
			//var blendMode:String= (owner.blendMode)? owner.blendMode:null; 
			
			var clipTo:Rectangle = (owner.clippingRectangle)? owner.clippingRectangle:null;
			
			if(filteredRect.width<1 || filteredRect.height<1){
				return;
			} 
			
			bitmapData = new BitmapData(filteredRect.width , filteredRect.height , true, 0);
			var mat:Matrix=new Matrix(1,0,0,1,-filteredRect.x,-filteredRect.y)
			bitmapData.draw(source, mat, null, null, clipTo,true);
			mat.invert()
			context.beginBitmapFill(bitmapData, mat, false);
		//dev note: debug outline
		//	context.lineStyle(0,0x00ff00)
			context.drawRect(filteredRect.x,filteredRect.y, filteredRect.width, filteredRect.height);
			context.endFill();
			
		}
		
		private function updateToFilterRectangle(filterRect:Rectangle,source:DisplayObject):Rectangle{
			
			//iterate the filters to calculte the desired rect
			var bitmapData:BitmapData = new BitmapData(filterRect.width, filterRect.height, true, 0);
			
			//compute the combined filter rectangle
			for each (var filter:BitmapFilter in owner.filters){
				filterRect = filterRect.union(bitmapData.generateFilterRect(filterRect,filter));
			}
			return filterRect;
			
		}
				
		/**
		* Principle render loop. Use delgates to override specific items
		* while the render loop is processing.
		**/
		private function renderCommandStack(graphics:Graphics,rc:Rectangle,cursor:DegrafaCursor=null):void{
			
			var item:CommandStackItem;
			while(cursor.moveNext()){	   			
	   			
				item = cursor.current;				
				
				//deffer to the start delegate if one found
				if (item.renderDelegateStart !=null){
					item=item.renderDelegateStart(this,item,graphics);
				}
				
				with(item){	
					switch(type){
						case CommandStackItem.MOVE_TO:
						    if (transMatrix){
								transXY.x = x; 
								transXY.y = y;
								transXY = transMatrix.transformPoint(transXY);
								graphics.moveTo(transXY.x, transXY.y);
							}
							else{
								graphics.moveTo(x,y);
							}
							break;
	        			case CommandStackItem.LINE_TO:
	        				if (transMatrix){
								transXY.x = x; 
								transXY.y = y;
								transXY = transMatrix.transformPoint(transXY);
								graphics.lineTo(transXY.x, transXY.y);
							} 
							else{
								graphics.lineTo(x,y);
							}
							break;
	        			case CommandStackItem.CURVE_TO:
	        				if (transMatrix){
								transXY.x = x1; 
								transXY.y = y1;
								transCP.x = cx; 
								transCP.y = cy;
								transXY = transMatrix.transformPoint(transXY);
								transCP = transMatrix.transformPoint(transCP);
								graphics.curveTo(transCP.x,transCP.y,transXY.x,transXY.y);
							} 
							else{
								graphics.curveTo(cx,cy,x1,y1);
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
    			
    			//deffer to the end delegate if one found
				if (item.renderDelegateEnd !=null){
					item=item.renderDelegateEnd(this,item,graphics);
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
		
		public function get transformBounds():Rectangle{
			var tempBounds:Rectangle = TransformBase.transformBounds(_bounds.clone(),transMatrix);
			return tempBounds;
		}
		
		/**
		* The calculated bounds for this object.
		*/		
		private var _bounds:Rectangle;
		public function get bounds():Rectangle{
			return _bounds;
		}
		
		private function addBounds(item:CommandStackItem):void{
			
			if(item){
				item.calcBounds();
			}
			
			if(!_bounds || _bounds.isEmpty()){
				_bounds = item.bounds;
			}
			else{
				_bounds = _bounds.union(item.bounds);
			}
			
		}
		
		public function resetBounds():void{
			if(_bounds){
				_bounds.setEmpty();
			}
		}
		
		/**
		* Adds a new MOVE_TO type item to be processed.
		**/	
		public function addMoveTo(x:Number,y:Number):CommandStackItem{
			var itemIndex:int = source.push(new CommandStackItem(CommandStackItem.MOVE_TO,
			x,y,NaN,NaN,NaN,NaN))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			addBounds(source[itemIndex]);
			
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
			
			addBounds(source[itemIndex]);
			
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
			
			addBounds(source[itemIndex]);
			
			lengthIsValid = false;
			
			return source[itemIndex];
		}
		
		/**
		* Accepts a cubic bezier and adds the CURVE_TO type items requiered to render it.
		* And returns the array of added CURVE_TO objects.
		**/	
		public function addCubicBezierTo(x0:Number,y0:Number,cx:Number,cy:Number,cx1:Number,cy1:Number,x1:Number,y1:Number,tolerance:int=1):Array{
			
			lengthIsValid = false;
			
			return GeometryUtils.cubicToQuadratic(x0,y0,cx,cy,cx1,cy1,x1,y1,1,this);
			
		}
		
		/**
		* Adds a new DELEGATE_TO type item to be processed.
		**/	
		public function addDelegate(delegate:Function):CommandStackItem{
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO))-1;
			source[itemIndex].delegate = delegate;

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
			
			addBounds(source[itemIndex]);
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new command stack item to be processed.
		**/		
		public function addItem(value:CommandStackItem):CommandStackItem{
			
			var itemIndex:int =source.push(value)-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			
			addBounds(source[itemIndex]);
						
			if(value.type != CommandStackItem.COMMAND_STACK){
				lengthIsValid = false;
			}
			
			return source[itemIndex];
			
		}
						
		private var _cursor:DegrafaCursor;
		/**
		* Returns a working cursor for this command stack
		**/
		public function get cursor():DegrafaCursor{
			if(!_cursor)
				_cursor = new DegrafaCursor(source);
				
			return _cursor;
		}
		
		/**
		* Return the item at the given index
		**/
		public function getItem(index:int):CommandStackItem{
			return source[index];
		}
		
		/**
		* The current length(count) of the internal array of command stack items. Setting 
		* the length to 0 will clear all items in the command stack.
		**/
		public function get length():int {
			return source.length;
		}
		public function set length(value:int):void{
			source.length = value;
		}
		
		/**
		* Applies the current layout and transform to a point.
		**/
		public function adjustPointToLayoutAndTransform(point:Point):Point{
			if(!owner){return point;}
			if (transMatrix){
				return transMatrix.transformPoint(point)
			}else{
				return point;	
			}
		}
		
		private var _pathLength:Number=0;
		/**
		* Returns the length of the combined path elements.
		**/
		public function get pathLength():Number{
			if(!lengthIsValid){
				lengthIsValid = true;
				
				//clear prev length
				_pathLength=0;
				
				var item:CommandStackItem;
				
				for each (item in source){
					_pathLength += item.segmentLength;
				}
			}
			return _pathLength;
		}
		
		/**
		* Returns the first commandStackItem objetc that has length
		**/
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
		
		/**
		* Returns the last commandStackItem objetc that has length
		**/
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
				return adjustPointToLayoutAndTransform(firstSegment.segmentPointAt(t));
			}
			else if (t == 1){
				return adjustPointToLayoutAndTransform(lastSegmentWithLength.segmentPointAt(t));
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
						return adjustPointToLayoutAndTransform(segmentPointAt((tLength - lastLength)/segmentLength));
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