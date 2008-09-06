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
package com.degrafa.geometry{
	
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IDegrafaObject;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.collections.DisplayObjectCollection;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.decorators.IGlobalDecorator;
	import com.degrafa.events.DegrafaEvent;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.layout.ILayout;
	import com.degrafa.states.IDegrafaStateClient;
	import com.degrafa.states.State;
	import com.degrafa.states.StateManager;
	import com.degrafa.transform.ITransform;
	import com.degrafa.triggers.ITrigger;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	import mx.styles.ISimpleStyleClient;
	
	[DefaultProperty("geometry")]
	[Bindable(event="propertyChange")]
		
	/**
 	*  A geometry object is a type of Degrafa object that enables 
 	*  rendering to a graphics context. Degrafa provides a number of 
 	*  ready-to-use geometry objects. All geometry objects inherit 
 	*  from the Geometry class. All geometry objects have a default data
 	*  property that can be used for short hand property setting.
 	**/	
	public class Geometry extends DegrafaObject implements IDegrafaObject, 
	IGeometryComposition, IDegrafaStateClient, ISimpleStyleClient {
		
		/**
		* Specifies whether this object is to be re calculated 
		* on the next cycle. Only property updates which affect the 
		* computation of this object set this property
		**/
		private var _invalidated:Boolean;
		public function get invalidated():Boolean{
			return _invalidated;
		}
		public function set invalidated(value:Boolean):void{
			_invalidated = value;
		}
		
		public function get isInvalidated():Boolean{
			return _invalidated;
		} 
		
		/**
		* Specifies whether the bounds of this object is to be re calculated 
		* on the next cycle.
		**/
		private var _boundsInvalidated:Boolean;
		public function get boundsInvalidated():Boolean{
			return _boundsInvalidated;
		}
		public function set boundsInvalidated(value:Boolean):void{
			_boundsInvalidated = true;
		}
		
		public function get isBoundsInvalidated():Boolean{
			return _boundsInvalidated;
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
		
		private var _visible:Boolean=true;
		/**
		* Controls the visibility of this geometry object. If true, the geometry is visible.
		*
		* When set to false this geometry object will be pre computed but not drawn.
		**/	
		[Inspectable(category="General", enumeration="true,false")]
		public function get visible():Boolean{
			return _visible;
		}
		public function set visible(value:Boolean):void{
			if(_visible != value){
				
				var oldValue:Boolean=_visible;
				_visible=value;
				
				invalidated = true;
				
				//call local helper to dispatch event
				initChange("visible",oldValue,_visible,this);
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
				
				if(enableEvents && _stroke){	
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
				//force a null stroke before closing the fill - 
				//prevents a 'closepath' stroke for unclosed paths
				graphics.lineStyle.apply(graphics, null);  
	        	fill.end(graphics);  
	        } 
			
			//append a null moveTo following a stroke without a  fill 
			//forces a break in continuity with moveTo before the next 
			//path - if we have the last point coords we could use them 
			//instead of null, null or perhaps any value
			if (stroke && !fill) graphics.moveTo.call(graphics, null, null); 

	        //draw children
	        if (geometry){
				for each (var geometryItem:IGeometryComposition in geometry){
					geometryItem.draw(graphics,null);
				}
			}
			dispatchEvent(new DegrafaEvent(DegrafaEvent.RENDER));
		}		
		
		/**
		* Initialise the stroke for this geometry object. Typically only called by draw 
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function initStroke(graphics:Graphics,rc:Rectangle):void{
			
			//this will only be done one time unless no stroke is found
			if(parent){
				if(inheritStroke && !_stroke && parent is Geometry){
					_stroke = Geometry(parent).stroke;
				}
			}
			
			//setup the stroke
			if (_stroke){
	        	_stroke.apply(graphics,(rc)? rc:null);
	        }
			else{
				graphics.lineStyle();
			}
			
		}
		
		/**
		* Initialise the fill for this geometry object. Typically only called by draw 
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function initFill(graphics:Graphics,rc:Rectangle):void{
			
			//this will only be done one time unless no fill is found
			if(parent){
				if(inheritFill && !_fill && parent is Geometry){
					_fill = Geometry(parent).fill;
				}
			}
				
			//setup the fill
	        if (_fill)
	        {   
				//this is a quick fix because we can't pass it in the method signature with IFill
				_fill.requester = this;
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
			//overriden by subclasses
		}
		
		/**
		* An Array of flash rendering commands that make up this element. 
		**/
		private var _commandStack:CommandStack;
		public function get commandStack():CommandStack{
			
			if(!_commandStack)
				_commandStack = new CommandStack(this);
			
			return _commandStack;
		}	
		public function set commandStack(value:CommandStack):void{
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
			
			//always do layout regardless
			initLayout();
		
			//don't draw unless visible
			if(!visible){return;}
			
			commandStack.draw(graphics,(layout)? layout.layoutRectangle:rc);
         	endDraw(graphics);
         
  		}		
  		
  		/**********************************************************
  		* Decoration related.
  		**********************************************************/
  		private var _decorators:Array=[];
		/**
		* An Array of decorators that modify this Geometry.  IGlobalDecorator
		* are executed and cleaned up here. 
		**/
		public function get decorators():Array{
			return _decorators;
		}	
		public function set decorators(value:Array):void{
			
			if(_decorators != value)
			{
				var oldValue:Object = _decorators;
				
				if(_decorators){
					if(_decorators.hasEventManager){
						_decorators.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
				
				if(_decorators)
				{
					for each(var decorator:Object in _decorators)
					{
						if(decorator is IGlobalDecorator && _decorators.indexOf(decorator) != -1)
						{
							IGlobalDecorator(decorator).cleanup();
						}
					}			
				}
				
				_decorators=value;
				
				if(enableEvents){	
					_decorators.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				
				initChange("decorators",oldValue,_decorators,this);
				
				for each(decorator in _decorators)
				{
					if(decorator is IGlobalDecorator)
					{
						decorator.execute(this);
					}
				}
				
				invalidated = true;
			}
		}
		/**********************************************************
  		* END Decoration related.
  		**********************************************************/
  		
  		/**********************************************************
  		* Transform related.
  		**********************************************************/
  		/**
		 * A reference to the transformation matrix context within which local transforms will be applied.
		 * Similar in concept to the concatenatedMatrix on a flash DisplayObjects transform property.
		 */
		private var _transformContext:Matrix;
		public function get transformContext():Matrix
		{
			return _transformContext;
		}
		public function set transformContext(value:Matrix):void
		{
			_transformContext = value;
		}
		private var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* rendering this geometry object.
		**/
		public function get transform():ITransform{
			return _transform;
		}
		public function set transform(value:ITransform):void
		{
			//get a reference to the transform hierachy
			if (parent && (parent as Geometry).transform)
			{
				_transformContext = (parent as Geometry).transform.getTransformFor(parent as Geometry);
			} 
			if(_transform != value){
			
				var oldValue:Object=_transform;
			
				if(_transform){
					if(_transform.hasEventManager){
						_transform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
								
				_transform = value;
				
				if(enableEvents){	
					_transform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				//call local helper to dispatch event
				initChange("transform",oldValue,_transform,this);
			}
			
		}
		/**********************************************************
  		* END Transform related.
  		**********************************************************/
  		
  		
  		/**********************************************************
  		* Layout related.
  		**********************************************************/
  		
  		private var _layout:ILayout;
		/**
		* Defines the layout that will be used for 
		* positioning this geometry object.
		**/
		public function get layout():ILayout{
			return _layout;
		}
		public function set layout(value:ILayout):void{
			if(_layout != value){
				var oldValue:Object=_layout;
				
				if(_layout){
					if(_layout.hasEventManager){
						_layout.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
								
				_layout = value;
				
				if(enableEvents){	
					_layout.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
												
				//call local helper to dispatch event
				initChange("layout",oldValue,_layout,this);
				
			}	
			
		}
		
		//read only accessor for the layout rectangle
		public function get layoutRectangle():Rectangle{
			return (layout)? layout.layoutRectangle:bounds;
		}
		
		//does the layout calculation		
		public function initLayout():void{
			if(parent && layout){
				layout.computeLayoutRectangle(bounds,Geometry(parent).layoutRectangle);
			}
		}		
		/**********************************************************
  		* END Layout related.
  		**********************************************************/
  		
  		/**********************************************************
  		* Trigger related.
  		**********************************************************/
  		
  		private var _triggers:Array= [];
	    [Inspectable(arrayType="com.degrafa.triggers.ITrigger")]
	    [ArrayElementType("com.degrafa.triggers.ITrigger")]
	    public function get triggers():Array{
	    	return _triggers;
	    }
	    public function set triggers(items:Array):void{
	    	_triggers = items;
	    	
	    	if(_triggers){
		    	//make sure each item knows about it's manager
	    		for each (var trigger:ITrigger in _triggers){
	    			trigger.triggerParent = this;
	    		}
	    	}
	    	
	    }
	    
    	/**********************************************************
  		* End Trigger related.
  		**********************************************************/
  		
  		/**********************************************************
  		* State related.
  		**********************************************************/
  		private var _currentState:String="";
	   
	    [Bindable("currentStateChange")]
	    public function get currentState():String{
	        return (stateManager) ? stateManager.currentState:"";
	    }
	    
	    public function set currentState(value:String):void{
	        stateManager.currentState = value;
	    }
		
		private var stateManager:StateManager;
		
		private var _states:Array= [];
	    [Inspectable(arrayType="com.degrafa.states.State")]
	    [ArrayElementType("com.degrafa.states.State")]
	    public function get states():Array{
	    	return _states;
	    }
	    public function set states(items:Array):void{
	    	
	    	_states = items;
	    	
	    	if(items){
	    		if(!stateManager){
	    			stateManager = new StateManager(this)
	    			
	    			//make sure each item knows about it's manager
		    		for each (var state:State in _states){
		    			state.stateManager = stateManager;
		    		}
		    	
	    		}
	    	}
	    	else{
	    		stateManager = null;	
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
		
	 	/**********************************************************
  		* END state related.
  		**********************************************************/
   	
   		/**********************************************************
  		* Style related.
  		**********************************************************/
  		private var _styleName:Object;
  		public function get styleName():Object{
  			return _styleName;
  		} 
   		public function set styleName(value:Object):void{
   			_styleName=value;
   		} 

		public function styleChanged(styleProp:String):void{
			//handle change
		} 
  		/**********************************************************
  		* END Style related.
  		**********************************************************/
   	
  	}
}