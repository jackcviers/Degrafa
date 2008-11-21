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
	import com.degrafa.decorators.IDecorator;
	import com.degrafa.decorators.IRenderDecorator;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.display.IDisplayObjectProxy;
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.degrafa.transform.TransformBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	/**
	* The CommandStack manages and stores the render process. All geometry goes 
	* through this process at draw time. The command stack provides convenient access 
	* to all commands that make up the drawing of the Geometry and helper methods.
	**/
	public class CommandStack{
	
		static public const IS_REGISTERED:Boolean = !registerClassAlias("com.degrafa.geometry.command.CommandStack", CommandStack);	
		
		static public var transMatrix:Matrix=new Matrix();
		static public var currentLayoutMatrix:Matrix=new Matrix();
		static public var currentTransformMatrix:Matrix = new Matrix();
		
		//single references to point objects used for internal calculations:
		static private var transXY:Point=new Point();
		static private var transCP:Point=new Point();
			
		//TODO this has to be made private eventually otherwise we can lose 
		//previous and next references
		public var source:Array = [];
				
		public var owner:Geometry;
		public var parent:CommandStackItem;
				
		private var _fxShape:Shape;
		private var _maskRender:Shape;

		
		public function CommandStack(geometry:Geometry = null){
			super();
			this.owner = geometry;
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
			
			var layout:Boolean = owner.hasLayout;
			transMatrix=null;
			currentLayoutMatrix.identity();

			//setup a layout transform
			if (layout){
				//give DisplayObjectProxies the ability to define their own bounds
				var tempRect:Rectangle = (owner is IDisplayObjectProxy)?owner.bounds:bounds;

				if (!tempRect.equals(owner.layoutRectangle) ) {	
						currentLayoutMatrix.translate( -tempRect.x, -tempRect.y)
						currentLayoutMatrix.scale(owner.layoutRectangle.width/tempRect.width,owner.layoutRectangle.height/tempRect.height);
						currentLayoutMatrix.translate(owner.layoutRectangle.x, owner.layoutRectangle.y);

						owner._layoutMatrix = currentLayoutMatrix.clone();
						transMatrix = currentLayoutMatrix.clone();
	
					} else {

						layout = false;
						owner._layoutMatrix = null;
						currentLayoutMatrix.identity();
				}
			} 
			else {
				if (owner._layoutMatrix){  
					owner._layoutMatrix = null;
				}
			}
		

			var trans:Boolean = (owner.transformContext || (owner.transform && !owner.transform.isIdentity));
			
			//combine the layout and transform into one matrix
			if (trans) {	
				currentTransformMatrix = (owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext;
				if (!layout){
					transMatrix = (owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext;	
				} 
				else{
					transMatrix.concat((owner.transform)? owner.transform.getTransformFor(owner): owner.transformContext)
				}
			}
			else {
				currentTransformMatrix.identity();
				if (!layout) transMatrix = null;
			}

		}
		
		/**
		* Initiates the render phase.
		**/
		public function draw(graphics:Graphics,rc:Rectangle):void{

			//exit if no command stack
			if(source.length==0 && !(owner is IDisplayObjectProxy)){return;}
			
			//init the decorations if required
			if(owner.hasDecorators){
				for each (var item:IDecorator in owner.decorators){
					
					item.initialize(this);
					
					if(item is IRenderDecorator){
						hasRenderDecoration = true;
					}
				}
			}

			//setup requirements before the render
			predraw()
			
			if((owner is IDisplayObjectProxy)){
				if(!IDisplayObjectProxy(owner).displayObject){
					return;
				}
				
				
				var displayObject:DisplayObject = IDisplayObjectProxy(owner).displayObject;
				//apply the filters
				if(owner.hasFilters){
					displayObject.filters = owner.filters;
				}
					
				if (transMatrix && (IDisplayObjectProxy(owner).transformBeforeRender || (owner._layoutMatrix && IDisplayObjectProxy(owner).layoutMode == 'scale'))) {
					var transObject:DisplayObject;
					//always expect a single child of this displayobject
					if(Sprite(displayObject).numChildren!=0){
						transObject = Sprite(displayObject).getChildAt(0);
						if (!IDisplayObjectProxy(owner).transformBeforeRender) {
							//scale layoutmode only, without a pretransformed capture: scale before capture to bitmapData:
							transObject.transform.matrix = CommandStack.currentLayoutMatrix;
	
				
						} else {

							if (IDisplayObjectProxy(owner).layoutMode == 'scale') {
						
								transObject.transform.matrix = CommandStack.transMatrix;
							}
						    else {
								if (owner._layoutMatrix) {
									var tempMat:Matrix = owner._layoutMatrix.clone();
									tempMat.a = 1; tempMat.d = 1;
									tempMat.concat(CommandStack.currentTransformMatrix);
									transObject.transform.matrix = tempMat;
								} else transObject.transform.matrix = CommandStack.currentTransformMatrix;
							}
							/**/
						}
					} 
				}
			
				//	maybe there's a stroke on some owners at this point:
				owner.initStroke(graphics, rc);
				renderBitmapDatatoContext(IDisplayObjectProxy(owner).displayObject, graphics,!IDisplayObjectProxy(owner).transformBeforeRender,rc);	
		
			}
			else{
					
				//setup a cursor for the path data interation
				_cursor=new DegrafaCursor(source)
				
				//setup the temporary shape to draw to in place 
				//of the passsed graphics context
				var hasmask:Boolean = (owner.mask!=null);
				if(owner.hasFilters || hasmask){
					if (!_fxShape){
						_fxShape = new Shape();
					}
					else{
						_fxShape.graphics.clear();
					}
					
					if (hasmask) {
						//dev note: need to change this mask is only redrawn when necessary
						if (!_maskRender) _maskRender = new Shape();
						_maskRender.graphics.clear();
						//cache the current settings as rendering the mask will alter them
						var cacheLayout:Matrix = currentLayoutMatrix.clone();
						var cacheTransform:Matrix = currentTransformMatrix.clone();
						var cacheCombo:Matrix = transMatrix.clone();
						owner.mask.draw(_maskRender.graphics, owner.mask.bounds);
						//restore cached settings
						currentLayoutMatrix = cacheLayout;
						currentTransformMatrix = cacheTransform;
						transMatrix = cacheCombo;
						_fxShape.mask = _maskRender;
					} else if (_fxShape.mask) _fxShape.mask = null;
																						
					//setup the stroke
					owner.initStroke(_fxShape.graphics,rc);
					
					//setup the fill
					owner.initFill(_fxShape.graphics,rc);
					
					renderCommandStack(_fxShape.graphics,rc,_cursor);
					

					//blit the data to the destination context
					renderBitmapDatatoContext(_fxShape,graphics)
				
				}
				else {
					//setup the stroke
					owner.initStroke(graphics,rc);
					
					//setup the fill
					owner.initFill(graphics,rc);
					
					renderCommandStack(graphics,rc,_cursor);
				}
			}
		}
		
		
		private function renderBitmapDatatoContext(source:DisplayObject,context:Graphics, viaCommandStack:Boolean=false, rc:Rectangle=null):void{
			
			if(!source){return;}
									
			var sourceRect:Rectangle=source.getBounds(source);
			
			if (owner.mask) sourceRect = sourceRect.intersection(_maskRender.getBounds(_maskRender));

			if(sourceRect.isEmpty()){return;}
			var filteredRect:Rectangle = sourceRect.clone();


			if (owner.hasFilters) {
				source.filters = owner.filters;
				filteredRect.x = filteredRect.y = 0;
				filteredRect.width = Math.ceil(filteredRect.width);
				filteredRect.height = Math.ceil(filteredRect.height);
				if (!filteredRect.width || !filteredRect.height) return; //nothing to draw
				filteredRect = updateToFilterRectangle(filteredRect,source);
				filteredRect.offset(sourceRect.x, sourceRect.y);
			} 	

			var bitmapData:BitmapData;
						
			var clipTo:Rectangle = (owner.clippingRectangle)? owner.clippingRectangle:null;
			
			if(filteredRect.width<1 || filteredRect.height<1){
				return;

			} else {
				//adjust to pixelbounds:
				filteredRect.y = Math.floor(filteredRect.y );
				filteredRect.width = Math.ceil(filteredRect.width +(filteredRect.x -(filteredRect.x = Math.floor(filteredRect.x ))));
				filteredRect.height = Math.ceil(filteredRect.height +(filteredRect.y-(filteredRect.y = Math.floor(filteredRect.y ))));
				if (filteredRect.width > 2880 || filteredRect.height > 2880) {
					//trace('DEBUG:oversize bitmap : '+owner.id)
					return;
				}
			}


			var mat:Matrix
			if (owner is IDisplayObjectProxy){
				//padding with transparent pixel border
				bitmapData = new BitmapData(filteredRect.width+4 , filteredRect.height+4,true,0);
				mat = new Matrix(1, 0, 0, 1, 2 - filteredRect.x, 2 - filteredRect.y)
				
			} else {
				
				bitmapData = new BitmapData(filteredRect.width , filteredRect.height,true,0);
				mat = new Matrix(1, 0, 0, 1, - filteredRect.x,  - filteredRect.y)
			}
			bitmapData.draw(source, mat, null, null, clipTo, true);
			mat.invert();

			if (!viaCommandStack) {
				var tempMat:Matrix 
				if (owner.hasFilters &&!sourceRect.equals(filteredRect) && owner is IDisplayObjectProxy ) {
					//adjust for scale- downscale to fit filters in the same bounds:
	
					mat= new Matrix(sourceRect.width/filteredRect.width,0,0,sourceRect.height/filteredRect.height,mat.tx,mat.ty)
					context.beginBitmapFill(bitmapData, mat,false,true);
					context.drawRect(Math.floor(sourceRect.x),Math.floor(sourceRect.y), Math.ceil(sourceRect.width), Math.ceil(sourceRect.height));
					context.endFill();
				} else {
					//draw at filtered size
	
					context.beginBitmapFill(bitmapData, mat,false,true);
					context.drawRect(filteredRect.x,filteredRect.y, filteredRect.width, filteredRect.height);
					context.endFill();
				}
			} else {
				if (transMatrix) {
					var temp:Matrix
					if (owner is IDisplayObjectProxy ) {
						if (owner._layoutMatrix && IDisplayObjectProxy(owner).layoutMode=="scale") {
							mat.concat(CommandStack.currentTransformMatrix)
	
						} else {
	
							mat.concat( currentTransformMatrix);
							transMatrix = currentTransformMatrix;
						}
					} else mat.concat(transMatrix);
			}
				context.beginBitmapFill(bitmapData, mat, false, true);
				renderCommandStack(context, rc, new DegrafaCursor(this.source))
			}
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
		
		private var hasRenderDecoration:Boolean;
		//called from render loop if the geometry has an IRenderDecorator
		private function delegateGraphicsCall(methodName:String,graphics:Graphics,x:Number=0,y:Number=0,cx:Number=0,cy:Number=0,x1:Number=0,y1:Number=0):*{
			//permit each decoration to do work on the current segment			
			for each (var item:IRenderDecorator in owner.decorators){
				switch(methodName){
					case "moveTo":
						return item.moveTo(x,y,graphics);
						break;
					case "lineTo":
						return item.lineTo(x,y,graphics);
						break;
					case "curveTo":
						return item.curveTo(cx,cy,x1,y1,graphics);
						break;		
				}
			}
		}
		
		//calls each delegate in order
		private function processDelegateArray(delegates:Array,item:CommandStackItem,graphics:Graphics,currentIndex:int):CommandStackItem{
						
			for each (var delegate:Function in delegates){
				item = delegate(this,item,graphics,currentIndex);
			}
			
			return item;
			
		}
		
		/**
		* Array of delegate functions to be called during the render loop when 
		* each item is about to be rendered. Individual item 
		* delegates take precedence if both are set
		*/		
		private var _globalRenderDelegateStart:Array=[];
		public function get globalRenderDelegateStart():Array{
			return _globalRenderDelegateStart;
		}
		public function set globalRenderDelegateStart(value:Array):void{
			if(_globalRenderDelegateStart != value){
				_globalRenderDelegateStart = value;
				invalidated = true;
			}
		}
		
		/**
		* Function to be called during the render loop when 
		* each item has just been rendered. Individual item 
		* delegates take precedence if both are set
		*/	
		private var _globalRenderDelegateEnd:Array=[];
		public function get globalRenderDelegateEnd():Array{
			return _globalRenderDelegateEnd;
		}
		public function set globalRenderDelegateEnd(value:Array):void{
			if(_globalRenderDelegateEnd != value){
				_globalRenderDelegateEnd = value;
				invalidated = true;
			}
		}
				
		/**
		* Principle render loop. Use delgates to override specific items
		* while the render loop is processing.
		**/
		private function renderCommandStack(graphics:Graphics,rc:Rectangle,cursor:DegrafaCursor=null):void{
			
			var item:CommandStackItem;
			while(cursor.moveNext()){	   			
	   			
				item = cursor.current;				
												
				//defer to the start delegate if one found
				if (item.renderDelegateStart.length !=0){
					item=processDelegateArray(item.renderDelegateStart,item,graphics,cursor.currentIndex);
				}
				
				//process any global type items
				if (_globalRenderDelegateStart.length !=0){
					item=processDelegateArray(_globalRenderDelegateStart,item,graphics,cursor.currentIndex);
				}
				
				if(item.skip){continue;}
				
				with(item){	
					switch(type){
						case CommandStackItem.MOVE_TO:
						    if (transMatrix){
								transXY.x = x; 
								transXY.y = y;
								transXY = transMatrix.transformPoint(transXY);
								
								if(hasRenderDecoration){
									delegateGraphicsCall("moveTo",graphics,transXY.x, transXY.y);
								}
								else{
									graphics.moveTo(transXY.x, transXY.y);
								}
							}
							else{
								if(hasRenderDecoration){
									delegateGraphicsCall("moveTo",graphics,x, y);
								}
								else{
									graphics.moveTo(x,y);
								}
							}
							break;
	        			case CommandStackItem.LINE_TO:
	        				if (transMatrix){
								transXY.x = x; 
								transXY.y = y;
								transXY = transMatrix.transformPoint(transXY);
								
								if(hasRenderDecoration){
									delegateGraphicsCall("lineTo",graphics,transXY.x, transXY.y);
								}
								else{
									graphics.lineTo(transXY.x, transXY.y);
								}
								
							} 
							else{
								if(hasRenderDecoration){
									delegateGraphicsCall("lineTo",graphics,x, y);
								}
								else{
									graphics.lineTo(x,y);
								}
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
								
								if(hasRenderDecoration){
									delegateGraphicsCall("curveTo",graphics,0,0,transCP.x,transCP.y,transXY.x,transXY.y);
								}
								else{
									graphics.curveTo(transCP.x,transCP.y,transXY.x,transXY.y);
								}
								
							} 
							else{
								if(hasRenderDecoration){
									delegateGraphicsCall("curveTo",graphics,0,0,cx,cy,x1,y1);
								}
								else{
									graphics.curveTo(cx,cy,x1,y1);
								}
							}
							break;
	        			case CommandStackItem.DELEGATE_TO:
	        				item.delegate(this,item,graphics,cursor.currentIndex);
	        				break;
	        			
	        			//recurse if required
	        			case CommandStackItem.COMMAND_STACK:
	        				renderCommandStack(graphics,rc,new DegrafaCursor(commandStack.source))
	        				break;
	        			        				
					}
    			}
    			    							
				//defer to the end delegate if one found
				if (item.renderDelegateEnd.length !=0){
					item=processDelegateArray(item.renderDelegateEnd,item,graphics,cursor.currentIndex);
				}
				
				//process any global type items
				if (_globalRenderDelegateEnd.length !=0){
					item=processDelegateArray(_globalRenderDelegateEnd,item,graphics,cursor.currentIndex);
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
		public function get lastNonCommandStackItem():CommandStackItem {
			var i:int = source.length-1;
			while (i > 0) {
				if(source[i].type != CommandStackItem.COMMAND_STACK){
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
				if(source[i].type != CommandStackItem.COMMAND_STACK){
					return source[i];
				}
				else{
					return CommandStackItem(source[i]).commandStack.firstNonCommandStackItem;
				}
				
				i++
			}
			
			return null;
		}
		
		private var _invalidated:Boolean = true;
		/**
		* Specifies whether bounds for this object is to be re calculated.
		* It will only get recalculated when bounds is requested. 
		**/
		public function get invalidated():Boolean{
			return _invalidated;
		}
		public function set invalidated(value:Boolean):void{
			if(_invalidated !=value){
				_invalidated = value;
				
				if(_invalidated){
					lengthInvalidated =true;
				}
			}
		}
		
		private var _lengthInvalidated:Boolean = true;
		/**
		* Specifies whether the path length for this object is to be re calculated.
		* It will only get recalculated when pathLength is requested. 
		**/
		public function get lengthInvalidated():Boolean{
			return _lengthInvalidated;
		}
		public function set lengthInvalidated(value:Boolean):void{
			if(_lengthInvalidated !=value){
				_lengthInvalidated = value;
			}
		} 
		
		/**
		* Returns a transformed version of this objects bounds. If no transform 
		* is specified bounds is returned.
		**/
		public function get transformBounds():Rectangle{
			if(transMatrix){
				return TransformBase.transformBounds(_bounds.clone(),transMatrix);
			}
			return _bounds;
		}
		
		/**
		* The calculated non transformed bounds for this object.
		*/		
		private var _bounds:Rectangle=new Rectangle();
		
		public function get bounds():Rectangle {

			if (!invalidated) return _bounds
			else {
				_bounds.setEmpty();
				for each(var item:CommandStackItem in source) {
					if(item.bounds){
						_bounds = _bounds.union(item.bounds);
					}
				}
				invalidated = false;
				if (_bounds.height!=0.0001) _bounds.height = Number(_bounds.height.toPrecision(3));
				if (_bounds.width != 0.0001) _bounds.width = Number(_bounds.width.toPrecision(3));

				if (_bounds.isEmpty()) invalidated = true;
			}
			return _bounds;
		}
		
		/**
		* Resets the bounds for this command stack.
		**/
		public function resetBounds():void{
			if(_bounds){
				_bounds.setEmpty();
				invalidated = true;
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
			source[itemIndex].indexInParent = itemIndex;
		
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
			
			source[itemIndex].indexInParent = itemIndex;
			source[itemIndex].parent = this;
			
			invalidated = true;
			
			return source[itemIndex];
		}
		
		/**
		* Adds a new CURVE_TO type item to be processed.
		**/	
		public function addCurveTo(cx:Number, cy:Number, x1:Number, y1:Number):CommandStackItem {
			var itemIndex:int =source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy))-1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			source[itemIndex].indexInParent = itemIndex;
			source[itemIndex].parent = this;
			
			invalidated = true;
			
			return source[itemIndex];
		}
		
		/**
		* Accepts a cubic bezier and adds the CURVE_TO type items requiered to render it.
		* And returns the array of added CURVE_TO objects.
		**/	
		public function addCubicBezierTo(x0:Number,y0:Number,cx:Number,cy:Number,cx1:Number,cy1:Number,x1:Number,y1:Number,tolerance:int=1):Array{
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
			source[itemIndex].indexInParent = itemIndex;
			source[itemIndex].parent = this;
			
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
			source[itemIndex].indexInParent = itemIndex;
			source[itemIndex].parent = this;
			
			invalidated = true;
						
			return source[itemIndex];
		}
		
		/**
		* Adds a new command stack item to be processed.
		**/		
		public function addItem(value:CommandStackItem):CommandStackItem{
			
			var itemIndex:int = source.push(value) - 1;
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			value.indexInParent = itemIndex;
			value.parent = this;
									
			invalidated = true;
			
			return source[itemIndex];
			
		}
		
		/**
		* Addes a commandStackItem at the specific location in the source.
		* if index is not specified then the item is appended to the end. 
		**/		
		public function addItemAt(value:CommandStackItem,index:int=-1):CommandStackItem{
			
			
			var itemIndex:int = index; 
			
			if(itemIndex==-1){
				itemIndex = source.push(value) - 1;
			}
			else{
				
				source.splice(itemIndex,0,value);
				itemIndex +=-1;
			}
			
			//update the related items (previous and next)
			updateItemRelations(source[itemIndex],itemIndex);
			value.indexInParent = itemIndex;
			value.parent = this;
									
			invalidated = true;
			
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
			invalidated = true;
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
			if(lengthInvalidated){
				lengthInvalidated = false;
				
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
			
			if(!source.length){return new Point(0,0);}
			
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
			
			if(!source.length){return 0;}
			
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