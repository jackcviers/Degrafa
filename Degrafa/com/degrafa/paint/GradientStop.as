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
package com.degrafa.paint{
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.Measure;
	import com.degrafa.core.utils.ColorUtil;
	import com.degrafa.paint.palette.PaletteEntry;
	
	import mx.events.PropertyChangeEvent;
	
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("GradientStop.png")]
	
	[Bindable(event="propertyChange")]  
	/**
	* The gradient stop class defines the objects that control 
	* a transition as part of a gradient fill.
	* 
	* @see mx.graphics.GradientEntry  
	**/
	public class GradientStop extends DegrafaObject {
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The solid stroke constructor accepts 3 optional arguments that define 
	 	* it's rendering color, alpha and weight.</p>
	 	* 
	 	* @param color A unit value indicating the stop color.
	 	* @param alpha A number indicating the alpha to be used for the stop.
	 	* @param ratio A number indicating where in the graphical element, as a percentage from 0.0 to 1.0, Flex starts the transition to the associated color.
	 	* @param ratioUnit A string indicating the unit of the ratio for the stop.  
	 	*/	
		public function GradientStop(color:Object=0x000000,alpha:Number=1,ratio:Number=-1,ratioUnit:String="ratio"){
			this.color = color;
			_alpha = alpha;
			_ratio.value = ratio;
			_ratio.unit = ratioUnit;
			
		}
	    
	    private var _alpha:Number = 1;
		[Inspectable(category="General", defaultValue="1")]
		/**
		* The transparency of a gradient fill.
		*
		* @see mx.graphics.GradientEntry
		**/
		public function get alpha():Number{
			return _alpha;
		}
		public function set alpha(value:Number):void{			
			if(_alpha != value){
				var oldValue:Number=_alpha;
			
				_alpha = value;
			
				//call local helper to dispatch event	
				initChange("alpha",oldValue,_alpha,this);
			}
			
		}
				
		private var _color:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
		* The color value for a gradient stop.
		*
		* @see mx.graphics.GradientEntry
		**/
		public function get color():Object{
			if(colorFunction !=null){
				return ColorUtil.resolveColor(colorFunction());
			}
			else if(!_color){
				return 0x000000;
			}
			return _color;
		}
		public function set color(value:Object):void{	
			
			//setup for a palette entry if one is passed
			if(value is PaletteEntry){
				paletteEntry = value as PaletteEntry;
			}
			else{
				paletteEntry=null;
			}
			
			value = ColorUtil.resolveColor(value);
			if(_color != value){
				var oldValue:uint =_color as uint;
				_color= value as uint;
				//call local helper to dispatch event	
				initChange("color",oldValue,_color,this);
			}
		}
		
		private var _paletteEntry:PaletteEntry;
		private function set paletteEntry(value:PaletteEntry):void{
			if(value){	
				if(_paletteEntry !== value){
					//remove old listener is required
					if(_paletteEntry){
						if(_paletteEntry.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE)){
							_paletteEntry.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPaletteEntryChange);
						}
					}
					//listen for changes	
					_paletteEntry = value
					if(_paletteEntry.enableEvents){
						_paletteEntry.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPaletteEntryChange);
					}
				}
			}
			else{
				//clean up
				if(_paletteEntry){
					if(_paletteEntry.hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE)){
						_paletteEntry.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPaletteEntryChange);
					}
					_paletteEntry=null;
				}
			}
		}
		
		//handle the change to the palette entry
		private function onPaletteEntryChange(event:PropertyChangeEvent):void{
			if(event.property=="value" && event.kind=="update"){
				color = event.source;
			}
		}
		
		protected var _colorFunction:Function;
		[Inspectable(category="General")]
		/**
		 * Function that sets the color of the fill. It is executed on
		 * every draw.
		 **/		
		public function get colorFunction():Function{
			return _colorFunction;
		}
		public function set colorFunction(value:Function):void{
			if(_colorFunction != value){ // value gets resolved first
				var oldValue:Function =_colorFunction as Function;
				_colorFunction= value as Function;
				//call local helper to dispatch event	
				initChange("colorFunction",oldValue,_colorFunction,this);
			}
		}
		
				    
		private var _ratio:Measure = new Measure(-1, Measure.RATIO);
		[Inspectable(category="General")]
		/**
		* Where in the graphical element, as a percentage from 0.0 to 1.0, 
		* Flex starts the transition to the associated color.
		*
		* @see mx.graphics.GradientEntry
		**/
		public function get ratio():Number{
			return _ratio.value;
		}
		public function set ratio(value:Number):void
		{		
			if(_ratio.value != value){
				var oldValue:Number=_ratio.value;
			
				_ratio.value = value;
			
				//call local helper to dispatch event	
				initChange("ratio",oldValue,_ratio.value,this);
			}
			
		}
		
		[Inspectable(category="General")]
		/**
		* Unit of measure for the ratio of the stop.
		**/
		public function get ratioUnit():String{
			return _ratio.unit;
		}
		public function set ratioUnit(value:String):void{		
			if(_ratio.unit != value){
				var oldValue:String=_ratio.unit;
			
				_ratio.unit = value;
			
				//call local helper to dispatch event	
				initChange("ratio",oldValue,_ratio.unit,this);
			}
			
		}
		
		/**
		* Returns the current ratio unit value.
		**/
		public function get measure():Measure{
			return _ratio;
		}
		
	}

}
