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
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.core.utils.ColorUtil;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.paint.palette.PaletteEntry;
	import flash.geom.Point;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import mx.events.PropertyChangeEvent;
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("SolidStroke.png")]
		
	[Bindable(event="propertyChange")]
	
	/**
 	* The Stroke class defines the properties for a line. You can define a 
 	* Stroke object in MXML, but you must attach that Stroke to another object 
 	* for it to appear in your application.
 	* 
 	* @see mx.graphics.Stroke
 	* @see http://samples.degrafa.com/SolidStroke/SolidStroke.html  
 	**/ 
	public class SolidStroke extends DegrafaObject implements IGraphicsStroke {
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The solid stroke constructor accepts 3 optional arguments that define 
	 	* it's rendering color, alpha and weight.</p>
	 	* 
	 	* @param color A unit value indicating the stroke color.
	 	* @param alpha A number indicating the alpha to be used for the stoke.
	 	* @param weight A number indicating the weight of the line for the stroke. 
	 	*/		
		public function SolidStroke(color:Object=null, alpha:Number=NaN,weight:Number=NaN){
			this.color = color;
			this.alpha = alpha;
			this.weight = weight;
			
			
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
				var oldValue:uint=_color as uint;
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
				
		private var _weight:Number;
		[Inspectable(category="General", defaultValue=1)]
		/**
 		* The line weight, in pixels.
 		* 
 		* @see mx.graphics.Stroke
 		**/ 
		public function get weight():Number{
			if(!_weight){return 1;}
			return _weight;
		}
		public function set weight(value:Number):void{
			if(_weight != value){
				var oldValue:Number=_weight;
			
				_weight = value;
			
				//call local helper to dispatch event	
				initChange("weight",oldValue,_weight,this);
			}
			
		}
				
		protected var _degrafaScaling:int;
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		/**
 		* Determines whether Degrafa transforms will perform additional stroke weight transforms in accordance with the scaleMode setting on this stroke (or not) to scale a stroke.
		* Default is false in which case degrafa transforms do not affect this stroke's weight.
 		* 
 		* @see scaleMode
 		**/
		public function get degrafaScaling():Boolean {
			return (_degrafaScaling<1)
		}
		public function set degrafaScaling(value:Boolean):void{			
			if((_degrafaScaling>0) != value){
				_degrafaScaling = value?1: -1;
				//call local helper to dispatch event	
				initChange("degrafaScaling",!value,value,this);
			}
		}
		
		protected var _scaleMode:String;
		[Inspectable(category="General", enumeration="normal,vertical,horizontal,none", defaultValue="normal")]
		/**
 		* Specifies how to scale a stroke. Strokes inside filtered or masked Degrafa geometry objects do not respect this setting for scaling in the native flash renderer 
		* as they are rasterized before being rendered by Degrafa.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get scaleMode():String{
			if(!_scaleMode){return "normal";}
			return _scaleMode;
		}
		public function set scaleMode(value:String):void{			
			if(_scaleMode != value){
				var oldValue:String=_scaleMode;
			
				_scaleMode = value;
			
				//call local helper to dispatch event	
				initChange("scaleMode",oldValue,_scaleMode,this);
			}
		}
		
		
		private var _pixelHinting:Boolean = false;
		[Inspectable(category="General", enumeration="true,false")]
		/**
 		* Specifies whether to hint strokes to full pixels.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get pixelHinting():Boolean{
			return _pixelHinting;
		}
		public function set pixelHinting(value:Boolean):void{						
			if(_pixelHinting != value){
				var oldValue:Boolean=_pixelHinting;
			
				_pixelHinting = value;
			
				//call local helper to dispatch event	
				initChange("pixelHinting",oldValue,_pixelHinting,this);
			}			
		}
						
		private var _miterLimit:Number;
		[Inspectable(category="General")]
		/**
 		* Indicates the limit at which a miter is cut off.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get miterLimit():Number{
			if(!_miterLimit){return 3;}
			return _miterLimit;
		}
		public function set miterLimit(value:Number):void{			
			if(_miterLimit != value){
				var oldValue:Number=_miterLimit;
			
				_miterLimit = value;
			
				//call local helper to dispatch event	
				initChange("miterLimit",oldValue,_miterLimit,this);
			}
			
		}
				
		private var _joints:String;
		[Inspectable(category="General", enumeration="round,bevel,miter", defaultValue="round")]
		/**
 		* Specifies the type of joint appearance used at angles.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get joints():String{
			if(!_joints){return "round";}
			return _joints;
		}
		public function set joints(value:String):void{
			
			if(_joints != value){
				var oldValue:String=_joints;
			
				_joints = value;
			
				//call local helper to dispatch event	
				initChange("joints",oldValue,_joints,this);
			}
			
		}
		
		private var _caps:String;
		[Inspectable(category="General", enumeration="round,square,none", defaultValue="round")]
		/**
 		* Specifies the type of caps at the end of lines.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get caps():String{
			if(!_caps){return "round";}
			return _caps;
		}
		public function set caps(value:String):void{
			if(_caps != value){
				var oldValue:String=_caps;
			
				_caps = value;
			
				//call local helper to dispatch event	
				initChange("caps",oldValue,_caps,this);
			}
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
		 * Provides access to a cached function for reapplying the last used stroke either in the same context, or , if context is provided as an argument,
		 * to an alternate context.
		 */
		public function get reApplyFunction():Function {
			var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
			return function(alternate:Graphics = null, altArgs:Array = null):void {
					var local:Array = altArgs?altArgs:copy;
					if (alternate) alternate.lineStyle.apply(alternate, local);
					else if (last) last.lineStyle.apply(last, local);
				}
		}
		
		/**
 		* Applies the properties to the specified Graphics object.
 		* 
 		* @see mx.graphics.Stroke
 		* 
 		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for stroke bounds. 
 		**/
		public function apply(graphics:Graphics,rc:Rectangle):void{
			
			//ensure that all defaults are in fact set these are temp until fully tested
			if(isNaN(_alpha)){_alpha=1;}
			if(!_caps){_caps="round";}
			if(!_joints){_joints="round";}
			if(!_miterLimit){_miterLimit=3;}
			if(!_scaleMode){_scaleMode="normal";}
			if(isNaN(_weight)){_weight=1;}
			var weight:Number = this.weight;
			if (_degrafaScaling > 0 && scaleMode != "none") {
				var m:Matrix = CommandStack.transMatrix;
				if (m) {
					var s:Number
					switch(_scaleMode) {
						case "normal":
						//discriminant seems to make sense here
						s = Math.sqrt(Math.abs(m.a * m.d - m.b * m.c));
						break;
						case "vertical":
						//this seems to provide the same behaviour as the flash native vertical stroke scaling. Not sure if it makes sense with rotation, but best to keep consistent
						s = m.b + m.d;
						break;
						case "horizontal":
						//this seems to provide the same behaviour as the flash native horizontal stroke scaling. Not sure if it makes sense with rotation, but best to keep consistent
						s = m.a + m.c;
						break;
					}
					weight *= s;
				}
			}
			
			//handle alpha modification
			var csAlpha:Number = CommandStack.currentAlpha;
			var alpha:Number = this.alpha;
			if (csAlpha != 1) { alpha *= csAlpha;	}
			
			//performance gain by not setting the last 3 arguments if 
			//they are already the default flash values
			if(caps=="round" && joints=="round" && miterLimit==3){
				if (graphics) graphics.lineStyle(weight, uint(color), alpha, pixelHinting, scaleMode);
				_lastArgs.length = 0;
				_lastArgs[0] = weight;
				_lastArgs[1] = color as uint;
				_lastArgs[2] = alpha;
				_lastArgs[3] = pixelHinting;
				_lastArgs[4] = scaleMode;
				_lastContext = graphics;
				_lastRect = rc;
			}
			else{
				if (graphics) graphics.lineStyle(weight,uint(color),alpha,pixelHinting,
					scaleMode, caps, joints, miterLimit);
				_lastArgs.length = 0;
				_lastArgs[0] = weight;
				_lastArgs[1] = color as uint;
				_lastArgs[2] = alpha;
				_lastArgs[3] = pixelHinting;
				_lastArgs[4] = scaleMode;
				_lastArgs[5] = caps;
				_lastArgs[6] = joints;
				_lastArgs[7] = miterLimit;
				_lastContext = graphics;
				_lastRect = rc;
			}				
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:SolidStroke):void{
						
			if (isNaN(_alpha)) { _alpha = value.alpha }
			if (!_caps){_caps = value.caps;}
			if (!_color){_color = uint(value.color);}
			if (!_joints){_joints = value.joints;}
			if (!_miterLimit){_miterLimit = value.miterLimit;}
			if (!_pixelHinting){_pixelHinting = value.pixelHinting}
			if (!_scaleMode){_scaleMode = value.scaleMode}
			if (!_weight) { _weight = value.weight }
			if (!_degrafaScaling) {_degrafaScaling = value.degrafaScaling?1:-1}
			
		}
		
		
	}
}