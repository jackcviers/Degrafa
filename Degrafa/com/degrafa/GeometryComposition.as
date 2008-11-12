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
package com.degrafa{
	
	import com.degrafa.core.collections.FillCollection;
	import com.degrafa.core.collections.StrokeCollection;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	[DefaultProperty("geometry")]
	
		
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("GeometryComposition.png")]
	
	/**
	* GeometryComposition allows composing only objects that 
	* extend Geometry. This is not Sprite based like GeometryGroup and as such
	* can be used in situations where a sprite is not allowed, for example skins.
	* 
	* If you just want to draw to a arbitrary graphics context like Canvas, this 
	* object is recommended for the opening tag of your composition.  
	**/		
	public class GeometryComposition extends Geometry implements IGeometry{
		
		public function GeometryComposition(){
			super();
		}
		
		private var _fills:FillCollection;
		[Inspectable(category="General", arrayType="com.degrafa.core.IGraphicsFill")]
		[ArrayElementType("com.degrafa.core.IGraphicsFill")]
		/**
		* A array of IGraphicsFill objects.
		**/
		public function get fills():Array{
			initFillsCollection();
			return _fills.items;
		}
		public function set fills(value:Array):void{			
			initFillsCollection();
			_fills.items = value;
		}
		
		/**
		* Access to the Degrafa fill collection object for this graphic object.
		**/
		public function get fillCollection():FillCollection{
			initFillsCollection();
			return _fills;
		}
		
		/**
		* Initialize the collection by creating it and adding an event listener.
		**/
		private function initFillsCollection():void{
			if(!_fills){
				_fills = new FillCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_fills.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		private var _strokes:StrokeCollection;
		[Inspectable(category="General", arrayType="com.degrafa.core.IGraphicsStroke")]
		[ArrayElementType("com.degrafa.core.IGraphicsStroke")]
		/**
		* A array of IStroke objects.
		**/
		public function get strokes():Array{
			initSrokesCollection();
			return _strokes.items;
		}
		public function set strokes(value:Array):void{	
			initSrokesCollection();
			_strokes.items = value;
			
		}
		
		/**
		* Access to the Degrafa stroke collection object for this graphic object.
		**/
		public function get strokeCollection():StrokeCollection{
			initSrokesCollection();
			return _strokes;
		}
		
		/**
		* Initialize the collection by creating it and adding an event listener.
		**/
		private function initSrokesCollection():void{
			if(!_strokes){
				_strokes = new StrokeCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_strokes.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Returns the bounds for this objects children 
		* not including this object.
		**/
		public function get childBounds():Rectangle{
			var tempRect:Rectangle;
			for each (var item:Geometry in geometry){
				if(!tempRect || tempRect.isEmpty()){
					tempRect = item.bounds;
				}
				else{
					tempRect=tempRect.union(item.bounds);
				}
			}
			
			return tempRect;
		}
		
				
		
	    private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return _bounds;	
		}
		
		/**
		* Calculates the bounds for this element. 
		**/
		public function calcBounds():void{
			
			if(_layoutConstraint){
				super.calculateLayout();
				_bounds = layoutRectangle; 
			}
			else if(parent && parent is Geometry){
				_bounds=Geometry(parent).bounds;
			}
			else if (_currentGraphicsTarget){
				
				_bounds= _currentGraphicsTarget.getRect(_currentGraphicsTarget)
				
			}		
			else{
				_bounds= new Rectangle();
			}
		}		
	
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			//in the case of geom comp the predraw only sets up the bounds
			calcBounds();
		}
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
				
					super.calculateLayout(tempLayoutRect);	
					_layoutRectangle = _layoutConstraint.layoutRectangle;
				}
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
		 	
		 	//init the layout in this case done before predraw.
			calculateLayout();
			
		 	//re init if required
		 	preDraw();
		 				
			super.draw(graphics, (rc)? rc:_bounds);
												
        }
        
			
	}
}