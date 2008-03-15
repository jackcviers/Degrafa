////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki 
// and Pavan Podila.
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

package com.degrafa.transform{
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.collections.GeometryCollection;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	* Transform is a base abstract transform class. Objects passed to data can include sprite, 
	* shape, geometry, grahic, segment.
	* 
	* Coming Soon.
	**/
	[DefaultProperty("geometry")]	
	public class Transform extends DegrafaObject implements ITransform{
			
		private var _data:String;
		public function get data():String{
			return _data;
		}
		public function set data(value:String):void{
			_data=value;
		}
		
		private var _geometry:GeometryCollection;
		[Inspectable(category="General", arrayType="com.degrafa.IGeometryComposition")]
		[ArrayElementType("com.degrafa.IGeometryComposition")]
		/**
		* A array of IGeometryComposition objects. 	
		**/
		public function get geometry():Array{
			initGeometryCollection();
			return _geometry.items;
		}
		public function set geometry(value:Array):void{
			
			initGeometryCollection();
			_geometry.items = value;
		}
		
		/**
		* Access to the Degrafa geometry collection object for this geometry object.
		**/
		public function get geometryCollection():GeometryCollection{
			initGeometryCollection();
			return _geometry;
		}
		
		/**
		* Initialize the geometry collection by creating it and adding an event listener.
		**/
		private function initGeometryCollection():void{
			if(!_geometry){
				_geometry = new GeometryCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_geometry.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Principle event handler for any property changes to a 
		* graphic object or it's child objects.
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			dispatchEvent(event)
		}
		
		/**
		* Ends the draw phase for geometry objects.
		* 
		* @param graphics The current Graphics context being drawn to. 
		**/		
		public function endDraw(graphics:Graphics):void{
		    //do stuff
	    }	
	    
	    private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		public function get bounds():Rectangle{
			//do stuff
			
			return null;
				
		}
		
		/**
		* Calculates the bounds for this element. 
		**/
		public function calcBounds():void{
			//do stuff
		}		
		
	    /**
		* @inheritDoc 
		**/
		public function preDraw():void{
			//do stuff
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		public function draw(graphics:Graphics,rc:Rectangle):void{
			//do stuff
		}
	}
}