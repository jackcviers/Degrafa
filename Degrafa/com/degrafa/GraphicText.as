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

package com.degrafa
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.collections.FillCollection;
	import com.degrafa.core.collections.StrokeCollection;
	import com.degrafa.paint.SolidFill;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.NameUtil;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("GraphicText.png")]
	
	/**
	* some of these will be added back at a later date
	**/
	
	[Exclude(name="percentHeight", kind="property")]
	[Exclude(name="percentWidth", kind="property")]
	[Exclude(name="measuredWidth", kind="property")]
	[Exclude(name="measuredHeight", kind="property")]
	[Exclude(name="target", kind="property")]
	[Exclude(name="stroke", kind="property")]
	[Exclude(name="fills", kind="property")]
	[Exclude(name="strokes", kind="property")]
	
	[Bindable(event="propertyChange")]
	
	/**
	* GraphicText extends TextField and enables support for text fields 
	* to be added to compositions.
	* 
	* @see flash.text.TextField
	**/
	public class GraphicText extends TextField implements IGraphic, IGeometry, IMXMLObject 
	{
		public function GraphicText()
		{
			super();
			defaultTextFormat = _textFormat;
		}
		
		/**
		* Data is required for the IGeometry interface and has no effect here.
		* @private 
		**/	
		public function get data():String{return "";}
		public function set data(value:String):void{}
		
		
		/**
		* Text format.
		* 
		* @see flash.text.TextFormat
		**/
		private var _textFormat:TextFormat=new TextFormat();
		public function get textFormat():TextFormat{
			return _textFormat;
		}
		public function set textFormat(value:TextFormat):void{
			_textFormat = value;
			defaultTextFormat = _textFormat;
		}
		
						
		/**
		* Controls automatic sizing and alignment of text fields.
		* 
		* @see flash.text.TextField
		**/
		private var _autoSize:String="none";
		[Inspectable(category="General", enumeration="none,left,center", defaultValue="none")]
		override public function get autoSize():String{
			return _autoSize;
		}
		override public function set autoSize(value:String):void{
			_autoSize = value;
			super.autoSize =_autoSize;
		}
		
		
		/**
		* Autosize the text field to text size. When set to true the 
		* GraphicText object will size to fit the height and width of 
		* the text.
		**/
		private var _autoSizeField:Boolean=true;
		[Inspectable(category="General", enumeration="true,false")]
		public function get autoSizeField():Boolean{
			return _autoSizeField;
		}
		public function set autoSizeField(value:Boolean):void{
			_autoSizeField = value;
			
			//NOTE: added the 4px offset as the left and bottom was 
			//being cut off requires investigation.  Was changed
			//from 5px to 4px to address the "walking text" issue
			
			if(text != ""){
				width = textWidth + 4;
				height = textHeight + 4;
			}
			
		}
		
		/**
		* A string that is the current text in the text field.
		**/
		override public function set text(value:String):void{
			
			super.text = value;
			
			//NOTE: added the 4px offset as the left and bottom was 
			//being cut off requires investigation.  Was changed
			//from 5px to 4px to address the "walking text" issue
			
			if(_autoSizeField){
				width = textWidth + 4;
				height = textHeight + 4;
			}
			
		}
		
		
		/**
		* Indicates the color of the text.
		* 
		* @see flash.text.TextFormat 
		**/
		private var _color:uint;
		public function set color(value:uint):void{
			_color = value;
			_textFormat.color = _color;
			defaultTextFormat = _textFormat;
		}
		public function get color():uint{
			return _color;
		}
		
		/**
		* The name of the font for text in this text format, as a string.
		* 
		* @see flash.text.TextFormat 
		**/
		private var _fontFamily:String;
		public function set fontFamily(value:String):void{
			_fontFamily = value;
			_textFormat.font = _fontFamily;
			defaultTextFormat = _textFormat;
		}
		public function get fontFamily():String{
			return _fontFamily;
		}
		
		/**
		* The point size of text in this text format.
		* 
		* @see flash.text.TextFormat
		**/
		private var _fontSize:Number;
		public function set fontSize(value:Number):void{
			_fontSize = value;
			_textFormat.size = _fontSize;
			defaultTextFormat = _textFormat;
		}
		public function get fontSize():Number{
			return _fontSize;
		}
		
		/**
		* Specifies whether the text is normal or boldface.
		* 
		* @see flash.text.TextFormat
		**/
		private var _fontWeight:String="normal";
		[Inspectable(category="General", enumeration="normal,bold", defaultValue="normal")]
		public function set fontWeight(value:String):void{
			_fontWeight = value;
			_textFormat.bold = (_fontWeight == "bold") ? true: false;
			defaultTextFormat = _textFormat;
		}
		public function get fontWeight():String{
			return _fontWeight;
		}
		
		/**
		* A number representing the amount of space that is uniformly distributed between all characters.
		* 
		* @see flash.text.TextFormat
		**/
		private var _letterSpacing:int;
		public function set letterSpacing(value:int):void{
			_letterSpacing = value;
			_textFormat.letterSpacing = _letterSpacing;
			defaultTextFormat = _textFormat;
		}
		public function get letterSpacing():int{
			return _letterSpacing;
		}
		
		private var _stroke:IGraphicsStroke;
		/**
		* Defines the stroke object that will be used for 
		* rendering this geometry object. Coming soon has no effect here.
		*
		* @private 
		**/
		public function get stroke():IGraphicsStroke{
			return _stroke;
		}
		public function set stroke(value:IGraphicsStroke):void{
			if(_stroke != value){
				
				if(_stroke){
					if(_stroke.hasEventManager){
						_stroke.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
				
				_stroke = value;
				
				if(enableEvents){	
					_stroke.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
			}	
		}
		
		/**
		* Defines the fill object that will be used for 
		* rendering this geometry object. Coming soon has no effect here.
		*
		* @private
		**/
		private var _fill:IGraphicsFill;
		public function get fill():IGraphicsFill{
			return _fill;
		}
		public function set fill(value:IGraphicsFill):void{
			_fill=value;
			
			if (_fill is SolidFill){
				color = uint(SolidFill(_fill).color);
			}
			else{
				//gradient fill need to do runtime mask
				
			}
			
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
		
		/**
		* Principle event handler for any property changes to a 
		* graphic object or it's child objects.
		*
		* @private 
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			draw(null,null);
		}
		
		/**
		* draw is required for the IGeometry interface and has no effect here.
		* @private  
		**/	
		
		public function draw(graphics:Graphics,rc:Rectangle):void{}
		
		/**
		* endDraw is required for the IGeometry interface and has no effect here.
		* @private 
		**/
		public function endDraw(graphics:Graphics):void{}
		
		
		
		/**
		* the below are all excluded for now
		**/
		
		/**
		* @private  
		**/		
		public function get percentHeight():Number{return 0;}
		public function set percentHeight(value:Number):void{}
		
		/**
		* @private  
		**/	
		public function get percentWidth():Number{return 0;}
		public function set percentWidth(value:Number):void{}
		
		/**
		* @private  
		**/	
		public function get measuredWidth():Number{return 0;} 
		
		/**
		* @private  
		**/
		public function get measuredHeight():Number{return 0;}
		
		/**
		* @private  
		**/	
		public function get target():DisplayObjectContainer{return null;}
		public function set target(value:DisplayObjectContainer):void{}
		 
				
				
		//event related stuff
		
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
		
		//specific identity code
		
		private var _id:String;
		/**
		* The identifier used by document to refer to this object.
		**/
		public function get id():String{
			
			if(_id){
				return _id;	
			}
			else{
				_id =NameUtil.createUniqueName(this);
				name=_id;
				return _id;
			}
		}
		public function set id(value:String):void{
			_id = value;
			name=_id;
		}
				
		private var _document:Object;
		/**
		*  The MXML document that created this object.
		**/
		public function get document():Object{
			return _document;
		}
		
		/**
		* Called after the implementing object has been created and all component properties specified on the MXML tag have been initialized.
		* 
		* @param document The MXML document that created this object.
		* @param id The identifier used by document to refer to this object.  
		**/
    	public function initialized(document:Object, id:String):void {
	    	
	    	//if the id has not been set (through as perhaps)
	        if(!_id){    	        
		        if(id){
		        	_id = id;
		        }
		        else{
		        	//if no id specified create one
		        	_id = NameUtil.createUniqueName(this);
		        }
	        }
	        
	        //sprit has a name property and it is set 
	        //to the instance value. Make sure it is the 
	        //same as the id
	        name=_id;
	        
	        _document=document;
	        
	        if(enableEvents && !suppressEventProcessing){
	        	dispatchEvent(new FlexEvent(FlexEvent.INITIALIZE));
	        }
	        
        } 
	}
}