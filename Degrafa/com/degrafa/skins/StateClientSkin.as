////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 The Degrafa Team : http://www.Degrafa.com/team
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
		import com.degrafa.IGeometry;
		import com.degrafa.IGraphic;
		import com.degrafa.core.IGraphicSkin;
		import com.degrafa.core.IGraphicsFill;
		import com.degrafa.core.IGraphicsStroke;
		import com.degrafa.core.collections.FillCollection;
		import com.degrafa.core.collections.GeometryCollection;
		import com.degrafa.core.collections.StrokeCollection;
		import com.degrafa.geometry.Geometry;
		import com.degrafa.states.State;
		import com.degrafa.states.StateManager;
		import com.degrafa.states.IDegrafaStateClient;
		import com.degrafa.triggers.ITrigger;
		
		import flash.display.DisplayObject;
		import flash.display.DisplayObjectContainer;
		import flash.display.Graphics;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.geom.Rectangle;
		
		import mx.core.IFlexDisplayObject;
		import mx.core.IInvalidating;
		import mx.core.IStateClient;
		import mx.core.UIComponentGlobals;
		import mx.core.mx_internal;
		import mx.events.PropertyChangeEvent;
		import mx.events.PropertyChangeEventKind;
		import mx.managers.ILayoutManagerClient;
		import mx.styles.ISimpleStyleClient;
		import mx.styles.IStyleClient;
		import mx.utils.NameUtil;

		use namespace mx_internal;
		
		/**
		 *  This class is the a state only base class for skin elements
		 *  which draw themselves programmatically.
		 *  Unlike skins based on ProgrammaticSkin it can exist as a single instance because 
		 *  it implements flex's IStateClient and does not implement IProgrammaticSkin (a requirement of some flex components)
		 */
		public class StateClientSkin extends Sprite
			implements IFlexDisplayObject, IInvalidating,
			ILayoutManagerClient, ISimpleStyleClient, IStateClient,IGraphic,IGraphicSkin,IDegrafaStateClient
		{
		//	include "../core/Version.as";
			

			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  Constructor.
			 */
			public function StateClientSkin()
			{
				super();
				addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			}
			
			//--------------------------------------------------------------------------
			//
			//  Variables
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  @private
			 */
			private var invalidateDisplayListFlag:Boolean = false;
			

			//--------------------------------------------------------------------------
			//
			//  Properties: ILayoutManagerClient 
			//
			//--------------------------------------------------------------------------
			
			//----------------------------------
			//  initialized
			//----------------------------------
			
			/**
			 *  @private
			 *  Storage for the initialized property.
			 */
			private var _initialized:Boolean = false;
			
			/**
			 *  @copy mx.core.UIComponent#initialized
			 */
			public function get initialized():Boolean
			{
				return _initialized;
			}
			
			/**
			 *  @private
			 */
			public function set initialized(value:Boolean):void
			{
				_initialized = value;
			}
			
			//----------------------------------
			//  nestLevel
			//----------------------------------
			
			/**
			 *  @private
			 *  Storage for the nestLevel property.
			 */
			private var _nestLevel:int = 0;
			
			/**
			 *  @copy mx.core.UIComponent#nestLevel
			 */
			public function get nestLevel():int
			{
				return _nestLevel;
			}
			
			/**
			 *  @private
			 */
			public function set nestLevel(value:int):void
			{
				_nestLevel = value;
				
				// After nestLevel is initialized, add this object to the
				// LayoutManager's queue, so that it is drawn at least once
				invalidateDisplayList();
			}
			
			//----------------------------------
			//  processedDescriptors
			//----------------------------------
			
			/**
			 *  @private
			 *  Storage for the processedDescriptors property.
			 */
			private var _processedDescriptors:Boolean = false;
			
			/**
			 *  @copy mx.core.UIComponent#processedDescriptors
			 */
			public function get processedDescriptors():Boolean
			{
				return _processedDescriptors;
			}
			
			/**
			 *  @private
			 */
			public function set processedDescriptors(value:Boolean):void
			{
				_processedDescriptors = value;
			}
			
			//----------------------------------
			//  updateCompletePendingFlag
			//----------------------------------
			
			/**
			 *  @private
			 *  Storage for the updateCompletePendingFlag property.
			 */
			private var _updateCompletePendingFlag:Boolean = true;
			
			/**
			 *  A flag that determines if an object has been through all three phases
			 *  of layout validation (provided that any were required).
			 */
			public function get updateCompletePendingFlag():Boolean
			{
				return _updateCompletePendingFlag;
			}
			
			/**
			 *  @private
			 */
			public function set updateCompletePendingFlag(value:Boolean):void
			{
				_updateCompletePendingFlag = value;
			}
			
			//--------------------------------------------------------------------------
			//
			//  Properties: ISimpleStyleClient
			//
			//--------------------------------------------------------------------------
			
			//----------------------------------
			//  styleName
			//----------------------------------
			
			/**
			 *  @private
			 *  Storage for the styleName property.
			 *  For skins, it is always a UIComponent.
			 */
			private var _styleName:IStyleClient;
			
			/**
			 *  A parent component used to obtain style values. This is typically set to the
			 *  component that created this skin.
			 */
			public function get styleName():Object
			{
				return _styleName;
			}
			
			/**
			 *  @private
			 */
			public function set styleName(value:Object):void
			{
				if (_styleName != value)
				{
					_styleName = value as IStyleClient;
					invalidateDisplayList();
				}
			}
			
			//--------------------------------------------------------------------------
			//
			//  Methods: IFlexDisplayObject
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  Moves this object to the specified x and y coordinates.
			 *
			 *  @param x The horizontal position, in pixels.
			 *
			 *  @param y The vertical position, in pixels.
			 */
			public function move(x:Number, y:Number):void
			{
				this.x = x;
				this.y = y;
			}
			
			/**
			 *  Sets the height and width of this object.
			 *
			 *  @param newWidth The width, in pixels, of this object.
			 *
			 *  @param newHeight The height, in pixels, of this object.
			 */
			public function setActualSize(newWidth:Number, newHeight:Number):void
			{
				var changed:Boolean = false;
				
				if (_width != newWidth)
				{
					_width = newWidth;
					changed = true;
				}
				
				if (_height != newHeight)
				{
					_height = newHeight;
					changed = true;
				}
				
				if (changed)
					invalidateDisplayList();
			}
			
			//--------------------------------------------------------------------------
			//
			//  Methods: ILayoutManagerClient 
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  This function is an empty stub so that ProgrammaticSkin
			 *  can implement the ILayoutManagerClient  interface.
			 *  Skins do not call <code>LayoutManager.invalidateProperties()</code>, 
			 *  which would normally trigger a call to this method.
			 */
			public function validateProperties():void
			{
			}
			
			/**
			 *  This function is an empty stub so that ProgrammaticSkin
			 *  can implement the ILayoutManagerClient  interface.
			 *  Skins do not call <code>LayoutManager.invalidateSize()</code>, 
			 *  which would normally trigger a call to this method.
			 *
			 *  @param recursive Determines whether children of this skin are validated. 
			 */
			public function validateSize(recursive:Boolean = false):void
			{
			}
			
			/**
			 *  This function is called by the LayoutManager
			 *  when it's time for this control to draw itself.
			 *  The actual drawing happens in the <code>updateDisplayList</code>
			 *  function, which is called by this function.
			 */
			public function validateDisplayList():void
			{
				invalidateDisplayListFlag = false;
				
				updateDisplayList(width, height);
			}
			
			//--------------------------------------------------------------------------
			//
			//  Methods: ISimpleStyleClient
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  Whenever any style changes, redraw this skin.
			 *  Subclasses can override this method
			 *  and perform a more specific test before calling invalidateDisplayList().
			 *
			 *  @param styleProp The name of the style property that changed, or null
			 *  if all styles have changed.
			 */
			public function styleChanged(styleProp:String):void
			{
				invalidateDisplayList();
			}
			
			//--------------------------------------------------------------------------
			//
			//  Methods: Other
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  @copy mx.core.UIComponent#invalidateDisplayList()
			 */
			public function invalidateDisplayList():void
			{
				// Don't try to add the object to the display list queue until we've
				// been assigned a nestLevel, or we'll get added at the wrong place in
				// the LayoutManager's priority queue.
				if (!invalidateDisplayListFlag && nestLevel > 0)
				{
					invalidateDisplayListFlag = true;
					UIComponentGlobals.layoutManager.invalidateDisplayList(this);
				}
			}
			
			
			/**
			 *  @inheritDoc
			 */
			public function invalidateSize():void
			{
			}
			
			/**
			 *  @inheritDoc
			 */
			public function invalidateProperties():void
			{
			}
			
			/**
			 *  Validate and update the properties and layout of this object
			 *  and redraw it, if necessary.
			 */
			public function validateNow():void
			{
				// Since we don't have commit/measure/layout phases,
				// all we need to do here is the draw phase
				if (invalidateDisplayListFlag)
					validateDisplayList();
			}
			
			/**
			 *  Returns the value of the specified style property.
			 *
			 *  @param styleProp Name of the style property.
			 *
			 *  @return The style value. This can be any type of object that style properties can be, such as 
			 *  int, Number, String, etc.
			 */
			public function getStyle(styleProp:String):*
			{
				return _styleName ? _styleName.getStyle(styleProp) : null;
			}
			

		
		[Bindable]
		public var skinWidth:Number=0;
		
		[Bindable]
		public var skinHeight:Number=0;     
		
		/**
		 * Draws the object and/or sizes and positions its children.
		 **/
		 protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{ 
	//		trace('updating bindable Dimensions')
			skinWidth =unscaledWidth;
			skinHeight =unscaledHeight;
	//		trace('finished udpated bindable Dimensions')
		//	draw(null,null);
		//	endDraw(null);
			invalidateDisplayListFlag=false;
			
		}
		
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
					trigger.triggerParent = com.degrafa.states.IDegrafaStateClient(this);
				}
			}
			
		}
		
		//because of the way skins have a deferred creation we need to 
		//set all the bindings for the triggers when the first item is created
		//this means that all triggers in all states are initialized otherwise we 
		//could never change state based on a trigger unless the state has been 
		//previously visited. This also ensures that the event listener is only added one time
		//but it will be triggered for each rule.
		private function onAddedToStage(event:Event):void{
			if(triggers.length !=0){
				if(!Object(this)._bindingsByDestination){
					return;
				}
				var bindings:Object  = Object(this)._bindingsByDestination;
				for each (var trigger:ITrigger in triggers){
					if(!trigger.source){
						if(bindings[trigger.id + ".source"]){
							bindings[trigger.id + ".source"].execute(trigger);
						}               
					}
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
			if (!stateManager) stateManager = new StateManager(IDegrafaStateClient(this));
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
					stateManager = new StateManager(IDegrafaStateClient(this))
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
		
	
	//	private var _state:String;
	//	/**
//		 * The state at which to draw this object
//		 **/
	/*		public function get state():String{
			return _state;
		}
		public function set state(value:String):void{
			_state = value;
		}
		
		*/

		
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
		
		
		/**
		 *  Returns a string indicating the location of this object
		 *  within the hierarchy of DisplayObjects in the Application.
		 *  This string, such as <code>"MyApp0.HBox5.FlexShape15"</code>,
		 *  is built by the <code>displayObjectToString()</code> method
		 *  of the mx.utils.NameUtils class from the <code>name</code>
		 *  property of the object and its ancestors.
		 *  
		 *  @return A String indicating the location of this object
		 *  within the DisplayObject hierarchy. 
		 *
		 *  @see flash.display.DisplayObject#name
		 *  @see mx.utils.NameUtil#displayObjectToString()
		 */
		override public function toString():String
		{
			return NameUtil.displayObjectToString(this);
		}
		

		/**********************************************************
		 * END state related.
		 **********************************************************/
	
		private var _geometry:GeometryCollection;
		[Inspectable(category="General", arrayType="com.degrafa.IGeometry")]
		[ArrayElementType("com.degrafa.IGeometry")]
		/**
		 * A array of IGeometry objects. Objects of type GraphicText, GraphicImage
		 * and GeometryGroup are added to the target display list.	
		 **/
		public function get geometry():Array{
			initGeometryCollection();
			return _geometry.items;
		}
		public function set geometry(value:Array):void
		{
			
			initGeometryCollection();
			
			_geometry.items = value;
			
			//add the children is required
			for each (var item:IGeometry in _geometry.items){
				if(item is IGraphic){
					addChild(DisplayObject(item));
				}
				
				//set the root geometry IGraphicParent
				if (item is Geometry){
					Geometry(item).IGraphicParent = this;
				}
			}
			
		}
		
		/**
		 * Access to the Degrafa geometry collection object for this graphic object.
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
			draw(null,null);
		}
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
		
		private var _suppressEventProcessing:Boolean=false;
		/**
		 * Temporarily suppress event processing for this object.
		 **/
		[Inspectable(category="General", enumeration="true,false")]
		public function get suppressEventProcessing():Boolean{
			return _suppressEventProcessing;
		}
		public function set suppressEventProcessing(value:Boolean):void{
			
			if(_suppressEventProcessing==true && value==false){
				_suppressEventProcessing=value;
				initChange("suppressEventProcessing",false,true,this);
			}
			else{
				_suppressEventProcessing=value;	
			}
		}
		
		/**
		 * Dispatches an event into the event flow.
		 *
		 * @see EventDispatcher
		 **/ 
		override public function dispatchEvent(event:Event):Boolean{
			if(_suppressEventProcessing){return false;}
			
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
		/**
		 * Begins the draw phase for graphic objects. All graphic objects 
		 * override this to do their specific rendering.
		 * 
		 * @param graphics The current context to draw to.
		 * @param rc A Rectangle object used for fill bounds. 
		 **/							
		public function draw(graphics:Graphics,rc:Rectangle):void{			
			if (!parent){return;}
			if(percentWidth || percentHeight)
			{
				//calculate based on the parent
				if (percentWidth)	_width = (parent.width/100)*_percentHeight;
				if (percentHeight)	_height = (parent.height/100)*_percentHeight;
			}
			
			
			this.graphics.clear(); 
			var rect:Rectangle;
			if(!rc){
				rect = new Rectangle(0,0,width,height);
			} else rect=rc;
			
			if (stroke)
			{
			//	if(!rc){
			//		stroke.apply(this.graphics,null);
				//}
			//	else{
					stroke.apply(this.graphics,rect);	
				//}
				
			}
			else
			{
				this.graphics.lineStyle();
			}
			
			
			if (fill){   
				
			//	if(!rc){
					fill.begin(this.graphics, rect);
			//	}
			//	else{
			//		fill.begin(this.graphics, rc);
				//}
				
			}
			
			
			if (_geometry){
				for each (var geometryItem:IGeometry in _geometry.items){
					
					if(geometryItem is IGraphic){
						//a IGraphic is a sprite and does not draw to 
						//this graphics object
						geometryItem.draw(null,null);
					}
					else{
						geometryItem.draw(this.graphics,null);
					}
				}
			}
			
			endDraw(null);
			
		}
		
		/**
		 * Data is required for the IGeometry interface and has no effect here.
		 * @private  
		 **/		
		public function get data():Object{return null;}
		public function set data(value:Object):void{}
		
		//Graphic
		
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
		 * Number that specifies the vertical position, in pixels, within the target.
		 **/
		override public function get y():Number{
			return super.y;
		}
		override public function set y(value:Number):void{
			super.y = value;
		}
		
		/**
		 * Number that specifies the horizontal position, in pixels, within the target.
		 **/
		override public function get x():Number{
			return super.x;
		}
		override public function set x(value:Number):void{
			super.x = value;
		}
		
		private var _width:Number=0;
		[PercentProxy("percentWidth")]
		/**
		 * Number that specifies the width, in pixels, in the target's coordinates.
		 **/
		override public function get width():Number{
			return _width;
		}
		override public function set width(value:Number):void{
			_width = value;
		//	draw(null,null);
			invalidateDisplayList();
			dispatchEvent(new Event("change"));
		}
		
		
		
		private var _height:Number=0;
		[PercentProxy("percentHeight")]
		/**
		 * Number that specifies the height, in pixels, in the target's coordinates.
		 **/
		override public function get height():Number{
			return _height;
		}
		override public function set height(value:Number):void{
			_height = value;
			//draw(null,null);
			invalidateDisplayList();
			dispatchEvent(new Event("change"));
		}
		
		/**
		 * The default height, in pixels.
		 **/
		public function get measuredHeight():Number{
			return _height;
		}
		
		/**
		 * The default width, in pixels.
		 **/
		public function get measuredWidth():Number{
			return _width;
		}
		
		private var _percentWidth:Number;
		[Inspectable(environment="none")]
		/**
		 * Number that specifies the width as a percentage of the target.
		 **/
		public function get percentWidth():Number{
			return _percentWidth;
		}
		public function set percentWidth(value:Number):void{
			if (_percentWidth == value){return};
			_percentWidth = value;
			
		}
		
		
		private var _percentHeight:Number;
		[Inspectable(environment="none")]
		/**
		 * Number that specifies the height as a percentage of the target.
		 **/
		public function get percentHeight():Number{
			return _percentHeight;
		}
		public function set percentHeight(value:Number):void{
			if (_percentHeight == value){return;}
			_percentHeight = value;
			
		}
		
		
		private var _target:DisplayObjectContainer;
		/**
		 * A target DisplayObjectContainer that this graphic object should be added or drawn to.
		 **/
		public function get target():DisplayObjectContainer{
			return _target;
		}
		public function set target(value:DisplayObjectContainer):void{
			
			if (!value){return;}
			
			//reparent if nessesary
			if (_target != value && _target!=null)
			{
				//remove this obejct from previous parent
				_target.removeChild(this);	
			}
			
			_target = value;
			_target.addChild(this);	
			
			//draw the obejct
			draw(null,null);
			endDraw(null);
			
			
		}
		
		
		private var _stroke:IGraphicsStroke;
		/**
		 * Defines the stroke object that will be used for 
		 * rendering this graphic object.
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
		 * rendering this graphic object.
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
		 * Initialize the fills collection by creating it and adding an event listener.
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
		 * Initialize the strokes collection by creating it and adding an event listener.
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
		
		public function get isInitialized():Boolean{
			return true;
		}
		
	}
}