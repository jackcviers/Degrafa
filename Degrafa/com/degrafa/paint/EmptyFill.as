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
	

	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IGraphicsFill;

	import flash.display.Graphics;
	import flash.geom.Rectangle;
	

	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EmptyFill.png")]
	
	/**
 	* The EmptyFill class provides a class for explicitly setting an empty Fill. In situations, e.g. where 'derive' is used and you require
	* that the local Geometry class does not derive the fill from the derive target, then you must set an EmptyFill explicitly.
 	* 
 	**/ 
	public class EmptyFill extends DegrafaObject implements IGraphicsFill{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The EmptyFill constructor accepts no arguments</p>
	 	* 
	 	* @param color A unit or String value indicating the stroke color.
	 	* @param alpha A number indicating the alpha to be used for the fill.
	 	*/
		public function EmptyFill(){

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
		 * then to an alternate context.
		 */
		public function get restartFunction():Function {
			//var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
			return function(alternate:Graphics = null):void {
				if (alternate) alternate.beginFill(0xffffffff);
				else if (last) last.beginFill(0xffffffff);
			}
		}
		/**
		* Begins the fill for the graphics context.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void{
			
			//basically do nothing: force the fill to be empty
			_lastContext = graphics;
			_lastRect = rc;
			if (graphics) graphics.beginFill(0xffffffff);
								
		}
		
		/**
		* Ends the fill for the graphics context.
		* 
		* @param graphics The current context being drawn to.
		**/
		public function end(graphics:Graphics):void{
			//basically do nothing
		}
		

	}
}