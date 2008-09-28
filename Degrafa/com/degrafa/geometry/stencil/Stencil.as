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
				commandStack =  itemDataDictionary[type].originalCommandStack;
				commandStack.owner = this;
								
				invalidated = false;
			}
			
		}
				
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			
			if(_layoutConstraint){
				
				super.calculateLayout();
				
				_layoutConstraint.xMax=bounds.bottomRight.x;
				_layoutConstraint.yMax=bounds.bottomRight.y;
				
				_layoutConstraint.xMin=bounds.x;
				_layoutConstraint.yMin=bounds.y;
				
				_layoutConstraint.xOffset = layoutRectangle.x;
				_layoutConstraint.yOffset = layoutRectangle.y;
				
				_layoutConstraint.xMultiplier=layoutRectangle.width/(_layoutConstraint.xMax-bounds.x);
				_layoutConstraint.yMultiplier=layoutRectangle.height/(_layoutConstraint.yMax-bounds.y);
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
			
			//re init if required
		 	preDraw();
		 	
		 	//init the layout in this case done after predraw.
			calculateLayout();
			
			super.draw(graphics,(rc)? rc:bounds);
	 	}
		
		
		
	}
}