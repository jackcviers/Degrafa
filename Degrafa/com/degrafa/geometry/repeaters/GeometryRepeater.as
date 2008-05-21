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
package com.degrafa.geometry.repeaters
{
	import com.degrafa.IGeometry;
	import com.degrafa.core.collections.RepeaterModifierCollection;
	import com.degrafa.core.utils.CloneUtil;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;

	//[DefaultProperty("sourceGeometry")]
	public class GeometryRepeater extends Geometry implements IGeometry{
		
		private var _sourceGeometry:Geometry;
		private var _bounds:Rectangle;  
		
		
		public function GeometryRepeater(x:Number=NaN,y:Number=NaN,width:Number=NaN,height:Number=NaN){
			super();
			this.x=x;
			this.y=y;
			this.width=width;
			this.height=height;
		}
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the regular rectangle. If not specified 
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
		* The y-axis coordinate of the upper left point of the regular rectangle. If not specified 
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
		* The width of the regular rectangle.
		**/
		public function get width():Number{
			if(!_width){return 0;}
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
		* The height of the regular rectangle.
		**/
		public function get height():Number{
			if(!_height){return 0;}
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
		
		/**
		* Principle geometry object that will be repeated
		* 
		**/
		public function set sourceGeometry(value:Geometry):void {
			_sourceGeometry=value;
			invalidated=true;
		}
		
		public function get sourceGeometry():Geometry  { return _sourceGeometry; }
		
		
		private var _count:int=1;
		
		public function set count(value:int):void {
			_count=value;
			invalidated=true;
		}
	
		/**
		* Denotes how many time object will be repeated
		* 
		**/
		public function get count():int { return _count; }	
		
		
		/*private var _modifiers:RepeaterModifierCollection;
		
		public function set modifiers(value:RepeaterModifierCollection):void {
			_modifiers=value;
			invalidated=true;
		}*/
		
		/**
		* Contains a collection of RepeaterModifiers that will be used to repeat instances of the repeaterObject;
		* 
		**/
		//public function get modifiers():RepeaterModifierCollection { return _modifiers; }
		
		
		private var _modifiers:RepeaterModifierCollection;
		[Inspectable(category="General", arrayType="com.degrafa.geometry.repeaters.IRepeaterModifier")]
		[ArrayElementType("com.degrafa.geometry.repeaters.IRepeaterModifier")]
		/**
		* Contains a collection of RepeaterModifiers that will be used to repeat instances of the repeaterObject;
		**/
		public function get modifiers():Array{
			initModifiersCollection();
			return _modifiers.items;
		}
		public function set modifiers(value:Array):void{			
			initModifiersCollection();
			_modifiers.items = value;
		}
		
		/**
		* Access to the Degrafa fill collection object for this graphic object.
		**/
		public function get modifierCollection():RepeaterModifierCollection{
			initModifiersCollection();
			return _modifiers;
		}
		
		/**
		* Initialize the collection by creating it and adding an event listener.
		**/
		private function initModifiersCollection():void{
			if(!_modifiers){
				_modifiers = new RepeaterModifierCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_modifiers.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Principle event handler for any property changes to a 
		* geometry object or it's child objects.
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			
			// getting here means a modifier has changed after treating the items that changed we need to dispatch
			// so that it works it's way up to start the draw cycle.
		}
		
		
		//DEV: How should we be calculating bounds (by the x/y width/height or dynamically based on the repeaters ??)
		override public function get bounds():Rectangle {
			return super.bounds;
		}
		
		
		
		override public function draw(graphics:Graphics, rc:Rectangle):void {
			this.suppressEventProcessing=true;
			//Clone source geometery to reset it
			//var tempSourceObject:Geometry=CloneUtil.clone(_sourceGeometry);
			
			//Create a loop that iterates through our modifiers at each stage and applies the modifications to the object
			for (var i:int=0; i<_count; i++) {
				
				//Apply our modifiers
				for each (var modifier:IRepeaterModifier in _modifiers.items) {
					if (i==0) modifier.beginModifier(geometryCollection);
					modifier.apply();
				}
				
				//Draw out our changed object
				super.draw(graphics,rc);
				
			}
			
			//not sure if we need this nor about the possible cleanup implications
			//_sourceGeometry.suppressEventProcessing=true	
			
			//End modifications (which returns the object to its original state
			for each (modifier in _modifiers.items) {
				modifier.end();
				modifier=null;
			}
			
			//super.draw(graphics,rc);
			
		}
		
	}
}