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
	
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.utils.ColorUtil;
	import com.degrafa.paint.palette.PaletteEntry;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	
	[Bindable(event="propertyChange")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("SolidFill.png")]
	
	/**
	* Solid fill defines a fill color to be applied to a graphics contex.
	* @see http://samples.degrafa.com/SolidFill/SolidFill.html  
	**/
	public class SolidFill extends DegrafaObject implements IGraphicsFill{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The solid fill constructor accepts 2 optional arguments that define 
	 	* it's rendering color and alpha.</p>
	 	* 
	 	* @param color A unit or String value indicating the stroke color.
	 	* @param alpha A number indicating the alpha to be used for the fill.
	 	*/
		public function SolidFill(color:Object=null, alpha:Number=NaN){
			this.alpha = alpha;
			this.color = color;
		}
		
		protected var _alpha:Number;
		[Inspectable(category="General")]
		/**
 		* The transparency of a fill.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get alpha():Number{
			if(isNaN(_alpha)){return 1;}
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
				
		protected var _color:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
 		 * The fill color.
 		 * This property accepts uint, hexadecimal (including shorthand), 
 		 * and color keys as well as comma seperated rgb or cmyk values.
 		 * 
 		**/
		public function get color():Object {
			if(colorFunction!=null){
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
			
			if(_color != value){ // value gets resolved first
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
		

		//reference to the requesting geometry
		private var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void{
			_requester = value;
		}
		 
		
		private var _lastRect:Rectangle;
		/**
		 * Provides access to the last rectangle that was relevant for this fill.
		 */
		public function get lastRectangle():Rectangle {
			return _lastRect.clone();
		}
		private var _lastContext:Graphics;
		private var _lastArgs:Array = [];
		
		/**
		 * Provide access to the lastArgs array
		 */
		public function get lastArgs():Array {
			return _lastArgs;
		}
		
		/**
		 * Provides access to a cached function for restarting the last used fill either it the same context, or , if context is provided as an argument,
		 * then to an alternate context. If no
		 */
		public function get restartFunction():Function {
			var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
		if (!_lastContext) return function(alternate:Graphics = null):void { 
				if (alternate) alternate.beginFill(copy[0], copy[1]);
			}
		else {
			return function(alternate:Graphics = null):void {
					if (alternate) alternate.beginFill(copy[0], copy[1]);
					else last.beginFill(copy[0], copy[1]);
				}
			}
		}
		/**
		* Begins the fill for the graphics context.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void{
			
			//ensure that all defaults are in fact set these are temp until fully tested
			if (isNaN(_alpha)) { _alpha = 1; }
			
			//handle alpha modification
			var csAlpha:Number = CommandStack.currentAlpha;
			var alpha:Number = this.alpha;
			if (csAlpha != 1) { alpha *= csAlpha;	}
			

			_lastArgs.length = 0;
			_lastArgs[0] = color as uint;
			_lastArgs[1] = alpha;
			_lastContext = graphics;
			_lastRect = rc;
			graphics.beginFill(color as uint,alpha);						
		}
		
		/**
		* Ends the fill for the graphics context.
		* 
		* @param graphics The current context being drawn to.
		**/
		public function end(graphics:Graphics):void{
			graphics.endFill();
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:SolidFill):void{
			
			if (!_color){_color = uint(value.color);}
			if (isNaN(_alpha)){_alpha = value.alpha;}
		}
	}
}