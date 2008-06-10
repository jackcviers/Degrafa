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
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.display.Graphics;
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
		* Makes sure that the object is set to 0,0 before any x or y offsets are applied.
		**/ 
		public var autoNormalizeData:Boolean=true;
		
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
		public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		public function set x(value:Number):void{
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
		public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		public function set y(value:Number):void{
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
		public function get width():Number{
			return _width;
		}
		public function set width(value:Number):void{
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
		public function get height():Number{
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
				
		private function loadLibraryItem():void{
			
			//normalize if needed
				
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
    	public function calculateRatios():void{
						
			var maxPointX:Number=0;
			var maxPointY:Number=0;
			
			var minPointX:Number=Number.POSITIVE_INFINITY;
			var minPointY:Number=Number.POSITIVE_INFINITY;
			
			//required to compute the tight bounds for a curve
			var lastX:Number=0;
			var lastY:Number=0;
			
			var bezierRect:Rectangle;
			
			//for nested command stacks
			var nestedItem:CommandStackItem;
			
			//get the max x or y and compute a ratio of the width and height and 
			//the min so we can offset to 0,0 if needed.
			var item:CommandStackItem;
			
			for each (item in commandStack.source){
				switch(item.type){
					case 0:
					case 1:
						maxPointX =Math.max(maxPointX,item.x);
						maxPointY =Math.max(maxPointY,item.y);
						
						minPointX =Math.min(minPointX,item.x);
						minPointY =Math.min(minPointY,item.y);
						
						//store for next iteration
						lastX=item.x;
						lastY=item.y;
						break;
					case 2:	
																	
						bezierRect = GeometryUtils.bezierBounds(lastX,lastY,
						item.cx,item.cy,item.x1,item.y1);
						
						if(isNaN(bezierRect.x) || isNaN(bezierRect.y)){
							//Dead curve. Not sure what to call it but the 
							//current algorithm hates when the cx and cy 
							//are the same and the x1 and y1 are the same
							//results in a NaN value.
						}
						else{
							//now take our bounds into account
							maxPointX =Math.max(maxPointX,bezierRect.x);
							maxPointY =Math.max(maxPointY,bezierRect.y);
							
							maxPointX =Math.max(maxPointX,bezierRect.x+bezierRect.width);
							maxPointY =Math.max(maxPointY,bezierRect.y+bezierRect.height);
							
							minPointX =Math.min(minPointX,bezierRect.x);
							minPointY =Math.min(minPointY,bezierRect.y);
							
							minPointX =Math.min(minPointX,bezierRect.x+bezierRect.width);
							minPointY =Math.min(minPointY,bezierRect.y+bezierRect.height);
						}
						
						//store for next iteration
						lastX=item.x1;
						lastY=item.y1;
						break;
						
					case 4:
					
						//nested command stack type
						for each (nestedItem in item.commandStack.source){
						
							bezierRect = GeometryUtils.bezierBounds(lastX,lastY,
							nestedItem.cx,nestedItem.cy,nestedItem.x1,nestedItem.y1);
							
							if(isNaN(bezierRect.x) || isNaN(bezierRect.y)){
								//Dead curve. Not sure what to call it but the 
								//current algorithm hates when the cx and cy 
								//are the same and the x1 and y1 are the same
								//results in a NaN value.
							}
							else{
								//now take our bounds into account
								maxPointX =Math.max(maxPointX,bezierRect.x);
								maxPointY =Math.max(maxPointY,bezierRect.y);
								
								maxPointX =Math.max(maxPointX,bezierRect.x+bezierRect.width);
								maxPointY =Math.max(maxPointY,bezierRect.y+bezierRect.height);
								
								minPointX =Math.min(minPointX,bezierRect.x);
								minPointY =Math.min(minPointY,bezierRect.y);
								
								minPointX =Math.min(minPointX,bezierRect.x+bezierRect.width);
								minPointY =Math.min(minPointY,bezierRect.y+bezierRect.height);
							}
							
							//store for next iteration
							lastX=nestedItem.x1;
							lastY=nestedItem.y1;
						}
						break;
				}
			}
			
			
			//get the percentage of the max points to width and height take into account 
			//the x,y 0,0 offset this should always provide a perfect tight fit no mater 
			//what the object.
			var xMultiplier:Number=width/(maxPointX-minPointX);
			var yMultiplier:Number=height/(maxPointY-minPointY);
			
			//multiply the axis by the difference
			for each (item in commandStack.source){
				switch(item.type){
					case 0:
					case 1:
						if(item.x!=0){
							item.x = (item.x-minPointX) * xMultiplier;
						}
						if(item.y!=0){
							item.y = (item.y-minPointY) * yMultiplier;
						}
						break;
					case 2:	
						if(item.cx!=0){
							item.cx = (item.cx-minPointX) * xMultiplier;
						} 
						if(item.cy!=0){
							item.cy = (item.cy-minPointY) * yMultiplier;
						}
						if(item.x1!=0){
							item.x1 = (item.x1-minPointX) * xMultiplier;
						}
						
						if(item.y1!=0){
							item.y1 = (item.y1-minPointY) * yMultiplier;
						}
						break;
					case 4:
						//nested command stack type
						for each (nestedItem in item.commandStack.source){
							if(nestedItem.cx!=0){
								nestedItem.cx = (nestedItem.cx-minPointX) * xMultiplier;
							} 
							if(nestedItem.cy!=0){
								nestedItem.cy = (nestedItem.cy-minPointY) * yMultiplier;
							}
							if(nestedItem.x1!=0){
								nestedItem.x1 = (nestedItem.x1-minPointX) * xMultiplier;
							}
							
							if(nestedItem.y1!=0){
								nestedItem.y1 = (nestedItem.y1-minPointY) * yMultiplier;
							}
						}
						
						break;
				}
			}
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return itemDataDictionary[type].originalBounds;	
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			
			if(!data){return}
			
			if(invalidated){
				
				//set the right command stack
				commandStack = itemDataDictionary[type].originalCommandStack;
				
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
		 	
			super.draw(graphics,(rc)? rc:new Rectangle(_x,_y,_width,_height));
	 	}
		
		
		
	}
}