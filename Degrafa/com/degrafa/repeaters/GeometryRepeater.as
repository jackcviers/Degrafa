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
package com.degrafa.repeaters
{
	import com.degrafa.IGeometry;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.collections.RepeaterModifierCollection;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.events.PropertyChangeEvent;
		
	[IconFile("GeometryRepeater.png")]
	
	/**
	* The GeometryRepeater repeates geometry objects. For each item 
	* repeated values can be modified through an array of PropertyModifiers.
	**/		
	[Event(name="iterationChanged", type="flash.events.Event")]
	public class GeometryRepeater extends Geometry implements IGeometry {
		
		private var _sourceGeometry:Geometry;
		private var _bounds:Rectangle;  
		private var _isDrawing:Boolean=false;
	
		[Inspectable]
		public var renderOnFinalIteration:Boolean=false;
		
		/**
		* GeometryRepeater constructor takes no arguments.
		**/
		public function GeometryRepeater(){
			super();
		}
		
		
		private var _count:int=1;
		/**
		* Denotes how many times object will be repeated.
		**/
		public function set count(value:int):void {
			var oldValue:int=_count;
			_count=value;
			invalidated=true;
			initChange("count",oldValue,_count,this);
		}
		public function get count():int { return _count; }	
		
		
		/**
		 * Returns current iteration for a draw cycle
		 * -1 if not currently drawing
		 */
		 [Bindable(event="iterationChanged")]
		 public function get iteration():int {
		 	return _curIteration;
		 }
		
		private var _curIteration:int=-1;
		
		private var _modifiers:RepeaterModifierCollection;
		/**
		* Contains a collection of RepeaterModifiers that will be used to 
		* repeat instances of the repeaterObject.
		**/
		[Inspectable(category="General", arrayType="com.degrafa.repeaters.IRepeaterModifier")]
		[ArrayElementType("com.degrafa.repeaters.IRepeaterModifier")]
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
		override protected function propertyChangeHandler(event:PropertyChangeEvent):void{
			if(_isDrawing || this.suppressEventProcessing==true) {
				this.invalidated=true;
				return;
			} 
		   super.propertyChangeHandler(event);
		}
		
		//TODO
		//DEV: How should we be calculating bounds 
		//(by the x/y width/height or dynamically based on the repeaters ??)
		/**
		* The tight bounds of this element as represented by a Rectangle.
		* The value does not include children. 
		**/
		override public function get bounds():Rectangle {
			return _bounds
		}
		
		override public function preDraw():void {
			if (invalidated) commandStack.length=0;
			super.preDraw();
		}
		
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics, rc:Rectangle):void {
			
			preDraw();
			
			if(!this.isInitialized){return;}
			_isDrawing=true;
			
			var t:Number=getTimer();
			
			//We need to do this before we reset our objects states
			calcBounds();
			
			var isSuppressed:Boolean=suppressEventProcessing;
			
			suppressEventProcessing=true;
						
			//Create a loop that iterates through our modifiers at each stage and applies the modifications to the object
			for (var i:int=0; i<_count; i++) {
				
				_curIteration=i;
				
				dispatchEvent(new Event("iterationChanged"));
				
				//Apply our modifiers
				if (_modifiers) {
					for each (var modifier:IRepeaterModifier in _modifiers.items) { 
						DegrafaObject(modifier).parent=this;
						DegrafaObject(modifier).suppressEventProcessing=true;
						if (i==0) modifier.beginModify(geometryCollection);
						modifier.apply();
					}
				}
				//Draw out our changed object
				if ((renderOnFinalIteration==true && (i==_count-1)) || !renderOnFinalIteration) {
				
					if(graphics){
						//t=getTimer();
	                    super.draw(graphics,rc);   
	                    //trace("GeometeryRepeater.inner Draw = " + (getTimer()-t) + "ms");
	                }
	                else{     
	                    if(graphicsTarget){
	                        for each (var targetItem:Object in graphicsTarget){
	                            if(targetItem){
	                            	 
	                                if(autoClearGraphicsTarget){
	                                    targetItem.graphics.clear();
	                                }
	                                super.draw(targetItem.graphics,rc);
	                            }
	                        }
	                    }
	                }
	  			 }
			}
				
			//End modifications (which returns the object to its original state
			if (_modifiers) {
				for each (modifier in _modifiers.items) {
					modifier.end();
					DegrafaObject(modifier).suppressEventProcessing=false;
				}
			}
			
			suppressEventProcessing=isSuppressed;
			
			_isDrawing=false;
			
			_curIteration=-1;
			
			
			this.invalidated=false;

			//super.endDraw(graphics);
			//trace("GeometeryRepeater.draw() = " + (getTimer()-t) + "ms");
		}
		
		/**
		 * We need to override DegrafaObject here, because we don't want to trigger another change event 
		 * as it would put us in an endless loop with the draw function
		 */
	    override public function dispatchEvent(evt:Event):Boolean{
	    	
	    	if (evt.type=="iterationChanged") return eventDispatcher.dispatchEvent(evt);
	    	
	    	if(suppressEventProcessing || _isDrawing) {
	        	evt.stopImmediatePropagation();
	        	this.invalidated=true;
	     		return false;
	     	}
	     	
	     	return eventDispatcher.dispatchEvent(evt);
	     	
	    }

		
		private function calcBounds():void {
			_bounds=new Rectangle();
			_bounds.x=x;
			_bounds.y=y;
			_bounds.width=width;
			_bounds.height=height;
		}
		
		//*******
		//temporary until bounds for this is figured out
		private var _x:Number;
		
		/**
		* The x-axis coordinate of the upper left point of the regular rectangle. If not specified 
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
		* The y-axis coordinate of the upper left point of the regular rectangle. If not specified 
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
		* The width of the regular rectangle.
		**/
		[PercentProxy("percentWidth")]
		override public function get width():Number{
			if(!_width){return 0;}
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
		* The height of the regular rectangle.
		**/
		[PercentProxy("percentHeight")]
		override public function get height():Number{
			if(!_height){return 0;}
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
	}
}