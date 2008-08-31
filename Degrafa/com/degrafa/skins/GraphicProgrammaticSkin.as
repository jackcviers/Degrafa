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
package com.degrafa.skins
{
	import com.degrafa.core.IGraphicSkin;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.collections.FillCollection;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.core.collections.StrokeCollection;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.states.IDegrafaStateClient;
	import com.degrafa.states.State;
	import com.degrafa.states.StateManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.skins.ProgrammaticSkin;
	
	[DefaultProperty("geometry")]
	[Exclude(name="graphicsData", kind="property")]		
	[Exclude(name="percentWidth", kind="property")]	
	[Exclude(name="percentHeight", kind="property")]	
	[Exclude(name="target", kind="property")]	
	
	[Bindable(event="propertyChange")] 	
		
	/**
	* GraphicProgrammaticSkin is an extension of ProgrammaticSkin for use declarativly.
	**/		
	public class GraphicProgrammaticSkin extends ProgrammaticSkin 
	implements IGraphicSkin, IDegrafaStateClient{
		
		public function GraphicProgrammaticSkin(){
			super();
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
				
		private var _stroke:IGraphicsStroke;
		/**
		* Defines the stroke object that will be used for 
		* rendering this geometry object.
		**/
		public function get stroke():IGraphicsStroke{
			return _stroke;
		}
		public function set stroke(value:IGraphicsStroke):void{
			_stroke = value;
			
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
			_fill=value;
			
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
			dispatchEvent(event);
			invalidateDisplayList();
			
		}
		
		//not required here but need for interface
		/**
		* @private
		**/
		public function get percentWidth():Number{return 0;}
	    public function set percentWidth(value:Number):void{}
	   	
	   	/**
		* @private
		**/
	    public function get percentHeight():Number{return 0;}
	    public function set percentHeight(value:Number):void{}	    			

		/**
		* @private
		**/
		public function get target():DisplayObjectContainer{return null;}
		public function set target(value:DisplayObjectContainer):void{}
		
		/**
		* @private
		**/
		public function set graphicsData(value:Array):void{}
		public function get graphicsData():Array{return null;}
		
		
		/**
		* Ends the draw phase for geometry objects.
		* 
		* @param graphics The current Graphics context being drawn to. 
		**/
		public function endDraw(graphics:Graphics):void{
			if (fill){     
	        	fill.end(this.graphics);  
			}
		}
		
		/**
		* Begins the draw phase for graphic objects. All graphic objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/	
		public function draw(graphics:Graphics,rc:Rectangle):void{
			if(!parent){return;}
			
			this.graphics.clear();
							
			if (geometry){
				for each (var geometryItem:Geometry in _geometry.items){
					if(geometryItem.state =="" || geometryItem.state ==null){
						
						if(states){
							prepareState();
						}
						
						geometryItem.draw(this.graphics,null);
					} 
					else {
						var possibleStates:Array=geometryItem.state.split(" ");
						if (possibleStates.length>0) {
							for (var i:int=0;i<possibleStates.length;i++) {
								if (name==possibleStates[i]) {
									geometryItem.draw(this.graphics,null);	
									break;
								}
							}
						}
						else if (geometryItem.state == name) {
							geometryItem.draw(this.graphics,null);	
						}
					}
				}			
			}
		}
	    
	    [Bindable]
	    public var skinWidth:Number=0;
	   
	    [Bindable]
	    public var skinHeight:Number=0;	    
	    
	    /**
		* Draws the object and/or sizes and positions its children.
		**/
	    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{	    	
	       	skinWidth =unscaledWidth;
	        skinHeight =unscaledHeight;
	        
	       	draw(null,null);
	    	endDraw(null);	
	    }
	    
	    /**********************************************************
  		* State related.
  		**********************************************************/
  		private var _currentState:String="";
	   
	    [Bindable("currentStateChange")]
	    public function get currentState():String
	    {
	        return stateManager.currentState;
	    }
	    public function set currentState(value:String):void
	    {
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
		
		//Only used in skin classes sets the matching current state 
		//based on the name
		private function prepareState():void{
			//see if the state exists
			for each (var state:State in states){
				if(state.name == name){
					currentState = name;
				}
			}
		}
		
	 	/**********************************************************
  		* END state related.
  		**********************************************************/
  		
	    	    
	    /**********************************************************
  		* event related.
  		**********************************************************/
		private var _enableEvents:Boolean=true;
		/**
 		* Enable events for this object.
 		**/
 		[Inspectable(category="General", enumeration="true,false")]
		public function get enableEvents():Boolean{
			return _enableEvents;
		}
		public function set enableEvents(value:Boolean):void{
			_enableEvents=value;
		}
		
		private var _surpressEventProcessing:Boolean=false;
		/**
 		* Temporarily suppress event processing for this object.
 		**/
 		[Inspectable(category="General", enumeration="true,false")]
		public function get surpressEventProcessing():Boolean{
			return _surpressEventProcessing;
		}
		public function set surpressEventProcessing(value:Boolean):void{
			
			if(_surpressEventProcessing==true && value==false){
				_surpressEventProcessing=value;
				initChange("surpressEventProcessing",false,true,this);
			}
			else{
				_surpressEventProcessing=value;	
			}
		}
		
		/**
		* Dispatches an event into the event flow.
		*
		* @see EventDispatcher
		**/
		override public function dispatchEvent(event:Event):Boolean{
			if(_surpressEventProcessing){return false;}
			
			return(super.dispatchEvent(event));
			
		}
		
		/**
		* Dispatches an property change event into the event flow.
		**/
		public function dispatchPropertyChange(bubbles:Boolean = false, 
		property:Object = null, oldValue:Object = null, 
		newValue:Object = null, source:Object = null):Boolean{
			return dispatchEvent(new PropertyChangeEvent("propertyChange",bubbles,false,PropertyChangeEventKind.UPDATE,property,oldValue,newValue,source));
		}
		
		/**
		* Helper function for dispatching property changes
		**/
		public function initChange(property:String,oldValue:Object,newValue:Object,source:Object):void{
			if(hasEventManager){
				dispatchPropertyChange(false,property,oldValue,newValue,source);
			}
		}
		
		/**
		* Tests to see if a EventDispatcher instance has been created for this object.
		**/ 
		public function get hasEventManager():Boolean{
			return true;
		}
		
		public function get isInitialized():Boolean{
			return super.initialized;
		}
		
	    /**********************************************************
  		* END event related.
  		**********************************************************/
	}
}