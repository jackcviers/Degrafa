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

	//[DefaultProperty("sourceGeometry")]
	public class GeometryRepeater extends Geometry implements IGeometry {
		
		private var _sourceGeometry:Geometry;
		private var _bounds:Rectangle;  
		private var _isDrawing:Boolean=false;
	
		[Inspectable]
		public var renderOnFinalIteration:Boolean=false;
	
		public function GeometryRepeater(){
			super();
		}
		
		/**
		* Denotes how many time object will be repeated
		* 
		**/
		private var _count:int=1;
		public function set count(value:int):void {
			var oldValue:int=_count;
			_count=value;
			invalidated=true;
			initChange("count",oldValue,_count,this);
		}
		public function get count():int { return _count; }	
		
		
		/**
		* Contains a collection of RepeaterModifiers that will be used to repeat instances of the repeaterObject;
		**/
		private var _modifiers:RepeaterModifierCollection;
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
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
		//	trace("Geometry Repeater: " + event.property + " has changed");
			if(_isDrawing || this.suppressEventProcessing==true) {
				this.invalidated=true;
				return;
			} 
			// getting here means a modifier has changed after treating the items that changed we need to dispatch
			// so that it works it's way up to start the draw cycle.
			if (!parent){
                dispatchEvent(event)
                draw(null,null);
            } 
            else{
                dispatchEvent(event)
            }
		}
		

		//DEV: How should we be calculating bounds (by the x/y width/height or dynamically based on the repeaters ??)
		override public function get bounds():Rectangle {
			return _bounds
		}
		
		
		override public function draw(graphics:Graphics, rc:Rectangle):void {
			
			if(!this.isInitialized){return;}
	//		trace("GeometryRepeater draw()");
			_isDrawing=true;
			
			
			//We need to do this before we reset our objects states
			calcBounds();
			
			
			var t:Number=getTimer();
			
			var isSuppressed:Boolean=suppressEventProcessing;
			
			suppressEventProcessing=true;
			//Clone source geometery to reset it
			//var tempSourceObject:Geometry=CloneUtil.clone(_sourceGeometry);

			
			//Create a loop that iterates through our modifiers at each stage and applies the modifications to the object

			for (var i:int=0; i<_count; i++) {
				
				//Apply our modifiers

				for each (var modifier:IRepeaterModifier in _modifiers.items) { 
					DegrafaObject(modifier).parent=this;
					DegrafaObject(modifier).suppressEventProcessing=true;
					if (i==0) modifier.beginModify(geometryCollection);
					modifier.apply();
				}

				//Draw out our changed object
				//super.draw(graphics,rc);
				
				if ((renderOnFinalIteration==true && (i==_count-1)) || !renderOnFinalIteration) {
				
					if(graphics){
	                    super.draw(graphics,rc);
	                   // super.endDraw(graphics);
	                }
	                else{
	                    
	                    if(graphicsTarget){
	                        for each (var targetItem:Object in graphicsTarget){
	                            if(targetItem){
	                            	 
	                                if(autoClearGraphicsTarget){
	                                    targetItem.graphics.clear();
	                                }
	                                super.draw(targetItem.graphics,rc);
	                               // super.endDraw(targetItem.graphics);
	                            }
	                        }
	                    }
	                    
	                }//
	  			 }
				
			}
			
		
			
			//End modifications (which returns the object to its original state
			for each (modifier in _modifiers.items) {
				modifier.end();
				DegrafaObject(modifier).suppressEventProcessing=false;
			}
			
			suppressEventProcessing=isSuppressed;
			
			_isDrawing=false;
			
			this.invalidated=false;

			//See if we have been invalidated while drawing
		//	if (this.invalidated) draw(graphics,rc);
			
		//	trace("elapsed draw time: " + String(getTimer()-t));
		}
		
		/**
		 * We need to override DegrafaObject here, because we don't want to trigger another change event 
		 * as it would put us in an endless loop with the draw function
		 */
	    override public function dispatchEvent(evt:Event):Boolean{
	//    	trace("GeometryRepeater: " + evt.type);
	    	if(suppressEventProcessing || _isDrawing){
	        	evt.stopImmediatePropagation();
	        	this.invalidated=true;
	     		return false;
	     	}
	     	
	     	return eventDispatcher.dispatchEvent(evt);
	     	
	    }

		
		private function calcBounds():void {
			_bounds=new Rectangle();
			_bounds.left=this.x;
			_bounds.top=this.y;
			_bounds.width=this.width;
			_bounds.height=this.height;
			
			//for (var i:int=0;i<geometry.length;i++) {
			//	 if (Geometry(geometry[i]).bounds!=null)  //This isn't going to work well for lines :) 
			//		_bounds.union(Geometry(geometry[i]).bounds);
			//}
			//trace("bounds.width: " + bounds.width + " bounds.height: " + bounds.height);
		}
		
	}
}