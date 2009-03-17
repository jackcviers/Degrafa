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
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;

	import mx.events.PropertyChangeEvent;
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EmptyStroke.png")]
		
	[Bindable(event="propertyChange")]
	
	/**
 	* The EmptyStroke class provides a class for explicitly setting an empty stroke. In situations, e.g. where 'derive' is used and you require
	* that the local Geometry class does not derive the stroke from the derive target, then you must set an EmptyStroke explicitly.
 	* 
 	**/ 
	public class EmptyStroke extends DegrafaObject implements IGraphicsStroke {
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The Emptry stroke constructor takes no arguments.</p>
	 	* 
	 	*/		
		public function EmptyStroke(){

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
		public function get reApplyFunction():Function {
			var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
			if (!_lastContext) return function(alternate:Graphics = null,altArgs:Array=null):void { 

				}
			else {
			return function(alternate:Graphics = null, altArgs:Array = null):void {
					//if (alternate) alternate.lineStyle.apply(alternate, null);
					//else last.lineStyle.apply(last, null);
				}
			}
		}
		/**
 		* In this case, does nothing because there is no stroke.
 		* 
 		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for stroke bounds. 
 		**/
		public function apply(graphics:Graphics,rc:Rectangle):void{
			
			_lastContext = graphics;
			_lastRect = rc;
			//graphics.lineStyle.apply(graphics,null);

							
		}
		
		/* INTERFACE com.degrafa.core.IGraphicsStroke */
		
		public function get weight():Number
		{
			return NaN;
		}
		
		public function set weight(value:Number):void
		{
			
		}
		
		public function get scaleMode():String
		{
			return null;
		}
		
		public function set scaleMode(value:String):void
		{
			
		}
		
		public function get pixelHinting():Boolean
		{
			return false;
		}
		
		public function set pixelHinting(value:Boolean):void
		{
			
		}
		
		public function get miterLimit():Number
		{
			return NaN;
		}
		
		public function set miterLimit(value:Number):void
		{
			
		}
		
		public function get joints():String
		{
			return null;
		}
		
		public function set joints(value:String):void
		{
			
		}
		
		public function get caps():String
		{
			return null;
		}
		
		public function set caps(value:String):void
		{
			
		}
		

		
		
	}
}