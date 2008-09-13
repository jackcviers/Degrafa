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
package com.degrafa.geometry.stencil{
	
	import com.degrafa.IGeometry;
	import com.degrafa.core.utils.CloneUtil;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	[Exclude(name="data", kind="property")] 
	
	[Bindable]
	public class Stencil extends Geometry implements IGeometry{
		
		public static const POLYGON:int=0;
		public static const PATH:int=1;
		
		public var itemDataDictionary:Dictionary = new Dictionary();
		
		public function Stencil(){
			super();
		}
		
		/**
		* adds a new item to the library
		**/
		public function addItem(key:String,type:int,data:String):void{
			
			_shapeList.push(key);
			itemDataDictionary[key] = {id:_shapeList.length,type:type,data:data,originalCommandStack:null,originalBounds:null};
		}
		
		private var _selectedItem:String;
		/**
		* the currently loaded item
		**/
		public function get selectedItem():String{
			return _selectedItem
		}
		
		private var _selectedIndex:String;
		/**
		* the currently loaded item
		**/
		public function get selectedIndex():String{
			return _selectedIndex
		}
		
		protected var _shapeList:Array = [];
		/**
		* Stores a string array of item keys.
		**/
		public function get shapeList():Array{
			return _shapeList;
		}
		
		private var _type:String;
		/**
		* Sets the type of object to be rendered.
		**/
		public function get type():String{
			return _type;
		}
		public function set type(value:String):void{
			if(_type != value){
				_type = value;
				
				loadLibraryItem();
				
				invalidated = true;
			}
		}
		
		private var _x:Number;
		/**
		* The x-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		
		private var _y:Number;
		/**
		* The y-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
		private var _width:Number;
		/**
		* The width of the object. If not specified 
		* a default value of 0 is used.
		**/
		override public function get width():Number{
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated = true;
			}
		}
		
		private var _height:Number;
		/**
		* The height of the object. If not specified 
		* a default value of 0 is used.
		**/
		override public function get height():Number{
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
				
		private function loadLibraryItem():void{
							
			//set the data
			data = itemDataDictionary[type].data;
			
			//process if command data not already loaded and in the dictionary
			if(!itemDataDictionary[type].originalCommandStack){
				//use a switch for later types
				switch(itemDataDictionary[type].type){
					case Stencil.POLYGON:
						//in the case of poygon we need to split the points into an array
						//so explicitly set the data after creation
						var tempPolyGon:Polygon = new Polygon();
						tempPolyGon.data = data;
						
						tempPolyGon.commandStack = new CommandStack(this);
						
						//Calculate
						tempPolyGon.preDraw();
						
						//store the processed result so we only have to do it one time
						itemDataDictionary[type].originalCommandStack = tempPolyGon.commandStack;
						itemDataDictionary[type].originalBounds = tempPolyGon.bounds;
						
						//clean up
						tempPolyGon.points = null;
						tempPolyGon = null;
						break;
						
					case Stencil.PATH:
						//create new path to aid us in calculation	
						var tempPath:Path = new Path(data);
						
						tempPath.commandStack = new CommandStack(this);
												
						//Calculate
						tempPath.preDraw();
						//store the processed result so we only have to do it one time
						itemDataDictionary[type].originalCommandStack = tempPath.commandStack;
						itemDataDictionary[type].originalBounds = tempPath.bounds;
						
						//clean up
						tempPath.segments = null;
						tempPath = null;	
						break;
				}
			}
		}
		
		/**
		* Proportionally sizes each point in the command array to the given width and height
		* taking into account any additional x or y offset that the command data may have. 
		* This ensures that rendering is always started at point(0,0) and that the maximum
		* allotted spaced is used for both width and height.  
		**/
    	private function calculateRatios():void{
			
			var minPoint:Point = new Point(Number.POSITIVE_INFINITY,Number.POSITIVE_INFINITY);
			var maxPoint:Point = new Point(0,0);
			
			var lastX:Number=0;
			var lastY:Number=0;
			
			getCommandStackMinMax(commandStack,maxPoint,minPoint,lastX,lastY);
						
			//apply the offset
			applyOffsetToCommandStack(commandStack,
			width/(maxPoint.x-minPoint.x),
			height/(maxPoint.y-minPoint.y),
			minPoint);
			
		}
		
		//loops through the given command stack and calculates the min and max points
		private function getCommandStackMinMax(commandStack:CommandStack,maxPoint:Point,minPoint:Point,lastX:Number,lastY:Number):void{
						
			var bezierRect:Rectangle;
			
			var item:CommandStackItem;
			
			for each (item in commandStack.source){
				switch(item.type){
					case CommandStackItem.MOVE_TO:
					case CommandStackItem.LINE_TO:
						maxPoint.x =Math.max(maxPoint.x,item.x);
						maxPoint.y =Math.max(maxPoint.y,item.y);
						
						minPoint.x =Math.min(minPoint.x,item.x);
						minPoint.y =Math.min(minPoint.y,item.y);
						
						//store for next iteration
						lastX=item.x;
						lastY=item.y;
						break;
					case CommandStackItem.CURVE_TO:	
																	
						bezierRect = GeometryUtils.bezierBounds(lastX,lastY,
						item.cx,item.cy,item.x1,item.y1);
												
						//now take our bounds into account
						maxPoint.x =Math.max(maxPoint.x,bezierRect.x);
						maxPoint.y =Math.max(maxPoint.y,bezierRect.y);
						
						maxPoint.x =Math.max(maxPoint.x,bezierRect.x+bezierRect.width);
						maxPoint.y =Math.max(maxPoint.y,bezierRect.y+bezierRect.height);
						
						minPoint.x =Math.min(minPoint.x,bezierRect.x);
						minPoint.y =Math.min(minPoint.y,bezierRect.y);
						
						minPoint.x =Math.min(minPoint.x,bezierRect.x+bezierRect.width);
						minPoint.y =Math.min(minPoint.y,bezierRect.y+bezierRect.height);
												
						//store for next iteration
						lastX=item.x1;
						lastY=item.y1;
						break;
						
					case CommandStackItem.COMMAND_STACK:
						//recurse
						getCommandStackMinMax(item.commandStack,maxPoint,minPoint,lastX,lastY);
						break;
				}
			}
					
		}
		
		
		//loops through the given command stack applying the offset
		private function applyOffsetToCommandStack(commandStack:CommandStack,xMultiplier:Number,yMultiplier:Number,minPoint:Point,lastPoint:Point=null):void{
			
			var item:CommandStackItem;
			
			//keep last point for recursion and setting the origin
			if(!lastPoint){
				lastPoint=minPoint.clone();
			}
			
			//multiply the axis by the difference
			for each (item in commandStack.source){
				switch(item.type){
					case CommandStackItem.MOVE_TO:
					case CommandStackItem.LINE_TO:
						if(item.x!=0){
							item.x = (item.x-minPoint.x) * xMultiplier;
						}
						if(item.y!=0){
							item.y = (item.y-minPoint.y) * yMultiplier;
						}
						
						//offset according to x and y
						item.x += x;
						item.y += y;
						
						lastPoint.x=item.x;
						lastPoint.y=item.y;
						
						break;
					case CommandStackItem.CURVE_TO:	
						if(item.cx!=0){
							item.cx = (item.cx-minPoint.x) * xMultiplier;
						} 
						if(item.cy!=0){
							item.cy = (item.cy-minPoint.y) * yMultiplier;
						}
						if(item.x1!=0){
							item.x1 = (item.x1-minPoint.x) * xMultiplier;
						}
						
						if(item.y1!=0){
							item.y1 = (item.y1-minPoint.y) * yMultiplier;
						}
						
						//offset according to x and y
						item.cx += x;
						item.cy += y;
						item.x1 += x;
						item.y1 += y;
						
						lastPoint.x=item.x1;
						lastPoint.y=item.y1;
						
						break;
					case CommandStackItem.COMMAND_STACK:
						//recurse
						applyOffsetToCommandStack(item.commandStack,xMultiplier,yMultiplier,minPoint,lastPoint);
						break;	
				}
							
			}
		}
		
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return _bounds;	
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			
			if(!data){return}
			
			if(invalidated){
				
				_bounds = new Rectangle(x,y,width,height);
												
				//set the right command stack
				commandStack =  CloneUtil.clone(CommandStack(itemDataDictionary[type].originalCommandStack),com.degrafa.geometry.command.CommandStack);
				commandStack.owner = this;
				
				//resize
				calculateRatios();
				
				invalidated = false;
			}
			
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics,rc:Rectangle):void{
			//make sure either width or height are not 0
			if(!width || !height){return;}
			
			//re init if required
		 	preDraw();
		 			 	
			super.draw(graphics,(rc)? rc:_bounds);
	 	}
		
		
		
	}
}