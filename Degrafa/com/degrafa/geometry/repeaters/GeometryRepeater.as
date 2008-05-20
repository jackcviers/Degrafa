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

	public class GeometryRepeater extends Geometry implements IGeometry
	{
		
		
		private var _sourceGeometry:Geometry;
		private var _bounds:Rectangle;  
		
		
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
		
		
		private var _modifiers:RepeaterModifierCollection;
		
		public function set modifiers(value:RepeaterModifierCollection):void {
			_modifiers=value;
			invalidated=true;
		}
		
		/**
		* Contains a collection of RepeaterModifiers that will be used to repeat instances of the repeaterObject;
		* 
		**/
		public function get modifiers():RepeaterModifierCollection { return _modifiers; }
		
		//DEV: How should we be calculating bounds (by the x/y width/height or dynamically based on the repeaters ??)
		override public function get bounds():Rectangle {
			return super.bounds;
		}
		
		public function GeometryRepeater(x:Number=NaN,y:Number=NaN,width:Number=NaN,height:Number=NaN)
		{
			super();
			this.x=x;
			this.y=y;
			this.width=width;
			this.height=height;
		}
		
		override public function draw(graphics:Graphics, rc:Rectangle):void {
			super.draw(graphics,rc);
			
			//We will need to keep track of our bounds as we do this
			//DEV - Do we want our bounds to be deterministic based on the repeaters OR fixed per width/height ?
			var minX:Number=0;
			var minY:Number=0;
			var maxX:Number=0;
			var maxY:Number=0;
			
			//Clone source geometery to reset it
			var tempSourceObject:Geometry=CloneUtil.clone(_sourceGeometry);
			
			//Create a loop that iterates through our modifiers at each stage and applies the modifications to the object
			for (var i:int=0; i<_count; i++) {
				
				for each (var modifier:IRepeaterModifier in _modifiers.items) {
					_sourceGeometry=modifier.apply(_sourceGeometry,i);
				}
			
				_sourceGeometry.draw(graphics,rc);
				
			}
			
			//Set our source object back to its original state			
			_sourceGeometry=tempSourceObject;
		}
		
	}
}