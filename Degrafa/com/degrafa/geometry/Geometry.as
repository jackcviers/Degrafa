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
package com.degrafa.geometry{
	
	import com.degrafa.IGeometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IDegrafaObject;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.collections.DisplayObjectCollection;
	import com.degrafa.core.collections.GeometryCollection;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	[DefaultProperty("geometry")]
	[Bindable(event="propertyChange")]
		
	/**
 	*  A geometry object is a type of Degrafa object that enables 
 	*  rendering to a graphics context. Degrafa provides a number of 
 	*  ready-to-use geometry objects. All geometry objects inherit 
 	*  from the Geometry class. All geometry objects have a default data
 	*  property that can be used for short hand property setting.
 	**/	
	public class Geometry extends DegrafaObject implements IDegrafaObject, IGeometryComposition {
		
		/**
		* Specifies whether this object is to be re calculated 
		* on the next cycle.
		**/
		protected var invalidated:Boolean;
		public function get isInvalidated():Boolean{
			
			return invalidated;
			
		} 
				
		private var _data:String;
		/**
		* Allows a short hand property setting that is 
		* specific to and parsed by each geometry object. 
		* Look at the various geometry objects to learn what 
		* this setting requires.
		**/	
		public function get data():String{
			return _data;
		}
		public function set data(value:String):void{
			_data=value;
		}
		
		private var _autoClearGraphicsTarget:Boolean=true;
		/**
		* When using a graphicsTarget and if this property is set to true 
		* the draw phase will clear the graphics context before drawing.
		**/	
		[Inspectable(category="General", enumeration="true,false")]
		public function get autoClearGraphicsTarget():Boolean{
			return _autoClearGraphicsTarget;
		}
		public function set autoClearGraphicsTarget(value:Boolean):void{
			_autoClearGraphicsTarget=value;
		}
		
		private var _graphicsTarget:DisplayObjectCollection;
		[Inspectable(category="General", arrayType="flash.display.DisplayObject")]
		[ArrayElementType("flash.display.DisplayObject")]
		/**
		* One or more display object's that this Geometry is to be drawn to. 
		* During the drawing phase this is tested first. If items have been defined 
		* the drawing of the geometry is done on each item(s) graphics context. 
		**/
		public function get graphicsTarget():Array{
			initGraphicsTargetCollection();
			return _graphicsTarget.items;
		}
		public function set graphicsTarget(value:Array):void{
			
			if(!value){return;}
			
			for each (var item:Object in value){
				if (!item){return;} 
			}
			
			//make sure we don't set anything until all target creation is 
			//complete otherwise we will be getting null items since flex
			//has not finished creation of the target items.
			initGraphicsTargetCollection();
			_graphicsTarget.items = value;
			
			
			
		}
		/**
		* Access to the Degrafa target collection object for this geometry object.
		**/
		public function get graphicsTargetCollection():DisplayObjectCollection{
			initGraphicsTargetCollection();
			return _graphicsTarget;
		}
		
		/**
		* Initialize the target graphics collection by creating it and adding an event listener.
		**/
		private function initGraphicsTargetCollection():void{
			if(!_graphicsTarget){
				_graphicsTarget = new DisplayObjectCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_graphicsTarget.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		private var _state:String;
		/**
		* The state at which to draw this object
		**/
		public function get state():String{
			return _state;
		}
		public function set state(value:String):void{
			_state = value;
		}
		
		private var _stateEvent:String;
		/**
		* The state event at which to draw this object
		**/
		public function get stateEvent():String{
			return _stateEvent;
		}
		public function set stateEvent(value:String):void{
			_stateEvent = value;
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
				
				//add the parent so it can be managed by the collection
				_geometry.parent = this;
				
				//add a listener to the collection
				if(enableEvents){
					_geometry.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
				
		private var _stroke:IGraphicsStroke;
		/**
		* Defines the stroke object that will be used for 
		* rendering this geometry object.
		**/
		public function get stroke():IGraphicsStroke{
			return _stroke;
		}
		public function set stroke(value:IGraphicsStroke):void{
			if(_stroke != value){
				
				var oldValue:Object=_stroke;
				
				
				if(_stroke){
					if(_stroke.hasEventManager){
						_stroke.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
				
				_stroke = value;
				
				if(enableEvents){	
					_stroke.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				
				//call local helper to dispatch event
				initChange("stroke",oldValue,_stroke,this);
				
			}	
		}
		
		private var _fill:IGraphicsFill;
		/**
		* Defines the fill object that will be used for 
		* rendering this geometry object.
		**/
		public function get fill():IGraphicsFill{
			return _fill;
		}
		public function set fill(value:IGraphicsFill):void{
						
			if(_fill != value){
				
				
				var oldValue:Object=_fill;
				
				if(_fill){
					if(_fill.hasEventManager){
						_fill.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
								
				_fill = value;
				
				if(enableEvents){	
					_fill.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
												
				//call local helper to dispatch event
				initChange("fill",oldValue,_fill,this);
				
			}	
			
		}
				
		/**
		* Principle event handler for any property changes to a 
		* geometry object or it's child objects.
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			if (!parent){
				dispatchEvent(event);
				drawToTargets();	
			}
			else{
				dispatchEvent(event)
				//drawToTargets();
			}
		}
		
		
		//draws to each target
		private  function drawToTargets():void{
			
			if(_graphicsTarget){
				for each (var targetItem:Object in _graphicsTarget.items){
					if(targetItem){
						if(autoClearGraphicsTarget){
							targetItem.graphics.clear();
						}
						draw(targetItem.graphics,null);
					}
				}
			}
			
		}
			
		public function get bounds():Rectangle{
			//to be overriden
			return null;	
		}
		
		/**
		* Ends the draw phase for geometry objects.
		* 
		* @param graphics The current Graphics context being drawn to. 
		**/		
		public function endDraw(graphics:Graphics):void {
			if (fill) {  
				//force a null stroke before closing the fill - prevents a 'closepath' stroke for unclosed paths
				graphics.lineStyle.apply(graphics, null);  
	        	fill.end(graphics);  
	        }
	        
	        //draw children
	        if (geometry){
				for each (var geometryItem:IGeometry in geometry){
					geometryItem.draw(graphics,null);
				}
			}

	    }		
		
		
		private var _inheritStroke:Boolean=true;
		/**
		* If set to true and no stroke is defined and there is a parent object
		* then this object will walk up through the parents to retrive a stroke 
		* object. 
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get inheritStroke():Boolean{
			return _inheritStroke;
		} 
		public function set inheritStroke(value:Boolean):void{
			_inheritStroke=value;
		}
		
		private var _inheritFill:Boolean=true;
		/**
		* If set to true and no fill is defined and there is a parent object
		* then this object will walk up through the parents to retrive a fill 
		* object. 
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get inheritFill():Boolean{
			return _inheritFill;
		} 
		public function set inheritFill(value:Boolean):void{
			_inheritFill=value;
		}
		
		
		
		public function initStroke(graphics:Graphics,rc:Rectangle):void{
			
			//this will only be done one time unless no stroke is found
			if(inheritStroke && !_stroke && parent){
				var currparent:IGeometry = parent as IGeometry;  
				while (!_stroke && currparent){
					
					if(currparent.stroke){
						_stroke = currparent.stroke;
					}
					else{
						if(parent.parent){
							currparent = parent.parent as IGeometry;
						}
						else{
							currparent = null;
						}
					}
					
				}
			}
			
			//setup the stroke
			if (_stroke){
	        	_stroke.apply(graphics,(rc)? rc:null);
	        }
			else {
				//force a null stroke
				graphics.lineStyle.apply(graphics,null); 
			}
			
		}
		
		public function initFill(graphics:Graphics,rc:Rectangle):void{
			
			//this will only be done one time unless no fill is found
			if(inheritFill && !_fill && parent){
								
				var currparent:IGeometry = parent as IGeometry;  
				while (!_fill && currparent){
					if(currparent.fill){
						_fill = currparent.fill;
					}
					else{
						if(parent.parent){
							currparent = parent.parent as IGeometry;
						}
						else{
							currparent = null;
						}
					}
				}
				
			}
				
			//setup the fill
	        if (_fill){   
	        	_fill.begin(graphics, (rc) ? rc:null);	
	        }
	        
		}
		
		/**
		* Performs any pre calculation that is required to successfully render 
		* this element. Including bounds calculations and lower level drawing 
		* command storage. Each geometry object overrides this 
		* and is responsible for it's own pre calculation cycle.
		**/
		public function preDraw():void{
			//overridden
		}
		
		/**
		* An Array of flash rendering commands that make up this element. 
		**/
		private var _commandStack:Array=[];
		public function get commandStack():Array{
			return _commandStack;
		}	
		public function set commandStack(value:Array):void{
			_commandStack=value;
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		public function draw(graphics:Graphics,rc:Rectangle):void{			
			
			//exit if no command stack
			if(commandStack.length==0){return;}
						
			//setup the stroke
			initStroke(graphics,rc);
			
			//setup the fill
			initFill(graphics,rc);
			
			var item:Object;
			for each (item in commandStack){
				switch(item.type){
        			
        			case "l":
        				graphics.lineTo(item.x,item.y);
        				break;
        		
        			case "m":
        				graphics.moveTo(item.x,item.y);
        				break;
        		
        			case "c":
        				graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
        				break;
        		}
			}
			
        	endDraw(graphics);
        		       
	  	
		}
		
	}
}