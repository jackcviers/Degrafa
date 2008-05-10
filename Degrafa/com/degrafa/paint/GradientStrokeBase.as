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
package com.degrafa.paint {
	
	import com.degrafa.core.IGraphicsStroke;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
		
	[DefaultProperty("gradientStops")]
	[Exclude(name="color", kind="property")]
	[Exclude(name="alpha", kind="property")]
		
	[Bindable(event="propertyChange")]
	
	
	/**
	* The gradient stroke class lets you specify a gradient filled stroke. 
	* This is the base class for other gradient stroke types.
	* 
	* @see http://degrafa.com/samples/LinearGradientStroke.html  
	**/
	public class GradientStrokeBase extends GradientFillBase implements IGraphicsStroke {
		
		public function GradientStrokeBase(){
			super();
			registerClassAlias("com.degrafa.paint.GradientStrokeBase", GradientStrokeBase);
		}
		
		
		protected var _weight:Number;
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
				
		protected var _scaleMode:String;
		[Inspectable(category="General", enumeration="normal,vertical,horizontal,none", defaultValue="normal")]
		/**
 		* Specifies how to scale a stroke.
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
			
		protected var _pixelHinting:Boolean = false;
		[Inspectable(category="General", enumeration="true,false")]
		/**
 		* Specifies whether to hint strokes to full pixels.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get pixelHinting():Boolean {
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
						
		protected var _miterLimit:Number;
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
				
		protected var _joints:String;
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
		
		protected var _caps:String;
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
		
		/**
 		* Applies the properties to the specified Graphics object.
 		* 
 		* @see mx.graphics.LinearGradientStroke
 		* 
 		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for stroke bounds. 
 		**/
		public function apply(graphics:Graphics,rc:Rectangle):void{
			
			//ensure that all defaults are in fact set these are temp until fully tested
			if(!_caps){_caps="round";}
			if(!_joints){_joints="round";}
			if(!_miterLimit){_miterLimit=3;}
			if(!_scaleMode){_scaleMode="normal";}
			if(!_weight){_weight=1;}
			
			
			var matrix:Matrix;
			if (rc) {
				matrix=new Matrix();
				matrix.createGradientBox(rc.width+weight, rc.height+weight,
				(angle/180)*Math.PI, rc.x-weight, rc.y-weight);
				var xp:Number = (angle % 90)/90;
				var yp:Number = 1 - xp;
				processEntries((rc.width+weight)*xp + (rc.height+weight)*yp);
			} else {
				matrix=null;
			}
			
			graphics.lineStyle(weight,0,1, pixelHinting,scaleMode,caps, joints, miterLimit);
			graphics.lineGradientStyle(gradientType, _colors, _alphas, _ratios, matrix, spreadMethod, interpolationMethod,focalPointRatio);
			
		}
	
		
	}
}