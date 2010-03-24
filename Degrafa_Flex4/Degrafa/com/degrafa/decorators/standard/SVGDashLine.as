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
//
//
// Some algorithms based on code from Trevor McCauley, www.senocular.com
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.decorators.standard{
	
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.decorators.RenderDecoratorBase;
	import com.degrafa.geometry.command.CommandStack;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	public class SVGDashLine extends RenderDecoratorBase{
		/**
		* A value representing the accuracy used in determining the length
		* of curveTo curves.
		*/
		public var _curveaccuracy:Number =6;
			
		private var isLine:Boolean = true;
		private var overflow:Number = 0;
		private var _penx:Number = 0;
		private var _peny:Number = 0;
		
		private var _dashArray:Array; //same as SVG's dasharray
		private var _dashIndex:uint = 0; //where are we in the _dashArray currently
		private var _dashVal:Number = 0; //offset from beginning of current dash
		private var _dashoffset:Number = 0; //dash offset
		private var _alternateStroke:IGraphicsStroke; //an optional alternate stroke to use instead of unstroked gaps
		private static var DEFAULT_DASH_PATTERN:Array = [10, 10];
		
		
		public function SVGDashLine(){
			super();
		}
		

		/**
		* Allows a short hand property setting that is 
		* similar to the stroke-dasharray setting in SVG. Populates dashArray from a comma-delimited list of values.
		* @see dashArray
		**/	
		public function get data():String{
			return dashArray.join(",");
		}
		public function set data(value:String):void{
			var temp:Array = value.split(",");
			if (temp[temp.length-1]=="") temp.pop();
			//avoid unnecesary updates:
			if ((temp.join(",")+(temp.length&1?","+temp.join(","):""))!=dashArray.join(",")){
				dashArray = temp;
			} 
		}
		//is this Decorator valid
		//with a default dash pattern this decorator is now initialized as valid:
		private var _isValid:Boolean=true;
		override public function get isValid():Boolean {
			return _isValid;
		}
		
		/**
		 * Sets new lengths for dash sizes. Follows SVG rules for dasharray stroke style.
		 * The contents specify a list of on and off dash lengths similar to SVG's dasharray setting. 
		 * If the array assigned contains an odd number of elements, then it is duplicated to
		 * create an even number of elements.
		 * Unlike SVG, only pixel units are supported here. Any non-numeric or negative numeric values are in error.
		 * @see http://www.w3.org/TR/SVG/painting.html#StrokeProperties
		 */
		public function set dashArray(value:Array):void {
			if (value == _dashArray ) return;
			//check for errors
			for (var i:uint = 0; i < value.length;i++) {
				if (isNaN(value[i] = Number(value[i])) || value[i]<0) return; //error
			}
			//if its an odd length, make it even by doubling it
			if (value.length &1) {
				value = value.concat(value);
			} 
			_totalLength = 0;
			for each(var v:Number in value) _totalLength += v;
			if (_totalLength) {
			_isValid = true;
			} else _isValid = false;
			initChange("dashArray", _dashArray, _dashArray = value, this);
		}
		/**
		 * Gets the current lengths for dash sizes
		 * @return Array containing the onLength and offLength values
		 * respectively in that order
		 */
		public function get dashArray():Array {
			if (_dashArray) return _dashArray;
			var defaultArr:Array = DEFAULT_DASH_PATTERN.concat();
			if (isNaN(_totalLength)) {
				_totalLength = 0;
				for each(var v:Number in defaultArr) _totalLength += v;
				_isValid = (_totalLength > 0);
			}
			return defaultArr;
		}
		
		/**
		 * Gets the total length of the dash sequence for dash on/dash-off combinations
		 * @return length of the total dash sequence
		 */
		public function get totalLength():Number {
			if (isNaN(_totalLength)) {
				var defaultArr:Array = DEFAULT_DASH_PATTERN.concat();
				_totalLength = 0;
				for each(var v:Number in defaultArr) _totalLength += v;
				_isValid = (_totalLength > 0);
			}
			return _totalLength;
		}
		
	
		/**
		* Specifies the distance into the stroke to start the dash pattern
		* similar to the stroke-dashoffset setting in SVG. Negative values are permitted.
		* @see http://www.w3.org/TR/SVG/painting.html#StrokeProperties
		**/	
		public function get dashOffset():Number{
			return _dashoffset;
		}
		public function set dashOffset(value:Number):void {
			if (value != _dashoffset) {
				initChange("dashOffset", _dashoffset, _dashoffset = value, this);
			}
		}
		
		
		/**
		* alternateStroke permits an alternate stroke to be used instead of unstroked gaps (this is a degrafa extension, not part of SVG 1.1)
		*  
		**/	
		public function get alternateStroke():IGraphicsStroke{
			return _alternateStroke;
		}
		public function set alternateStroke(value:IGraphicsStroke):void {
			if (value != _alternateStroke) {
				if (_alternateStroke) _alternateStroke.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler);
				var oldVal:IGraphicsStroke = _alternateStroke;
				_alternateStroke = value;
				if (_alternateStroke) _alternateStroke.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler,false,0,true);
				initChange("alternateStroke", oldVal, _alternateStroke, this);
			}
		}
		
		
		private var _matchCommonStrokeSettings:Boolean = true;
		/**
		* when an alternateStroke is in use, this setting, if true (the default), matches weight, pixelHinting, caps, joints, scaleMode and miterLimit
		* with those of the primary stroke on the original geometry being decorated, otherwise the alternateStroke's own settings for these properties will be used
		**/	
		public function get matchCommonStrokeSettings():Boolean{
			return _matchCommonStrokeSettings;
		}
		public function set matchCommonStrokeSettings(value:Boolean):void {
			if (value != _matchCommonStrokeSettings) {
				_matchCommonStrokeSettings = value;
				initChange("matchCommonStrokeSettings", !_matchCommonStrokeSettings, _matchCommonStrokeSettings, this);
			}
		}
		
		private var _disableAlternateStroke:Boolean;
		/**
		* when an alternateStroke is in use, this setting, if true (it defaults to false), will disable the alternate stroke, rendering the dash pattern
		* with unstroked gaps as per SVG's standard dash strokes.
		**/	
		public function get disableAlternateStroke():Boolean{
			return _disableAlternateStroke;
		}
		public function set disableAlternateStroke(value:Boolean):void {
			if (value != _disableAlternateStroke) {
				_disableAlternateStroke = value;
				initChange("disableAlternateStroke", !_disableAlternateStroke, _disableAlternateStroke, this);
			}
		}
		
		
		
		/**
		* @private local handler for referenced external objects
		**/
		protected function propertyChangeHandler(event:PropertyChangeEvent):void {
			//ignore changes from the alternate stroke if it's disabled
			if (_disableAlternateStroke && _alternateStroke && event.source == _alternateStroke ) return;
			//for now:
			dispatchEvent(event);
			//so far just alternateStroke:
			//initChange("alternateStroke." + event.property, event.oldValue, event.newValue, this);
		}
		
		
		
		private var _totalLength:Number;
		private var _currentStrokeArgs:Array;
		private var _currentRectangle:Rectangle;
		private var _altStrokeArgs:Array;
		
		/**
		 * initialize override, to set up local reStroking support and adjust for dashoffset, nothing else is required at this point.
		 * If no stroke was originally set on the decorated geometry, no original stroke will be drawn.
		 * @param	stack
		 */
		override public function initialize(stack:CommandStack):void {
			var i:uint;
			_reStrokeActive = true;
			if (CommandStack.currentStroke) {
				_currentRectangle = CommandStack.currentStroke.lastRectangle;
				_currentStrokeArgs = CommandStack.currentStroke.lastArgs;
				var restroke:Function = CommandStack.currentStroke.reApplyFunction;
				_reStroke = function(graphics:Graphics):void {
					restroke(graphics,_currentStrokeArgs);
					_reStrokeActive = true;
				}
				if (_alternateStroke && !_disableAlternateStroke) {
					_alternateStroke.apply(null, _currentRectangle);
					_altStrokeArgs = _alternateStroke.lastArgs.concat();
					if (_matchCommonStrokeSettings) {
						var targ:Array = (_altStrokeArgs[0] is Array)?_altStrokeArgs[0]:_altStrokeArgs;
						var copyFrom:Array= (_currentStrokeArgs[0] is Array)? _currentStrokeArgs[0]:_currentStrokeArgs;
						targ[0] = copyFrom[0];//weight
						targ[3] = copyFrom[3];//pixelhinting
						targ[4] = copyFrom[4];//scaling
						targ[5] = copyFrom[5];//caps
						targ[6] = copyFrom[6];//joints
						targ[7] = copyFrom[7];//miterlimit
					}
					var destroke:Function = _alternateStroke.reApplyFunction;
					_deStroke = function(graphics:Graphics):void {
						destroke(graphics,_altStrokeArgs);
				
					} 
				} else if (_deStroke!=null) _deStroke = null;
			} else {
				_isValid = false;
				return;
			}
			isLine = true;
			overflow = 0;
			var dashcalc:Number = Math.abs(_dashoffset) % _totalLength;

			if (dashcalc) {
				var dir:int = (_dashoffset < 0)? -1:1;
				isLine=(dir==1)
				for (i = (dir == -1)? _dashArray.length - 1:0; i > -1 && i < _dashArray.length; i += dir) {
				  if (dashcalc < _dashArray[i]) {
					  _dashIndex = i;
					  _dashVal = (dir == -1)? _dashArray[i] - dashcalc:dashcalc;
					  dashcalc = 0;
					  break;
				} else {
					dashcalc -= _dashArray[i];
					isLine = !isLine;
				}
			}
			} else {
				_dashIndex = 0;
				_dashVal = 0;
			}	
			if (_dashArray) {
				var len:uint = _dashArray.length;
			} else _dashArray = DEFAULT_DASH_PATTERN.concat();
			
		}
		
		
		/**
		* Moves the current drawing position in graphics to (x, y).
		*/
		override public function moveTo(x:Number, y:Number,graphics:Graphics):void {
			graphics.moveTo(x, y);
			_penx = x;_peny=y
		}
		
		/**
		* Draws a dashed line in graphics from the current drawing position
		* to (x, y).
		*/
		override public function lineTo(x:Number, y:Number, graphics:Graphics):void {
			var dx:Number = x-_penx
			var dy:Number = y-_peny;
			var a:Number = Math.atan2(dy, dx);
			var ca:Number 
			var sa:Number ;
			var segLength:Number = lineLength(dx, dy);

			if (overflow) {
				if (overflow > segLength) {
					//then we won't advance to the next index in dashArray with this lineTo
					if (isLine) doLineTo(x,y,graphics);
					else doAltLineTo(x,y,graphics);
					overflow -= segLength;
					_dashVal += segLength;
					return;
				}
				//otherwise we're dealing with a switch inside this lineto following an overflow:
				ca = Math.cos(a);
				sa = Math.sin(a);
				if (isLine) doLineTo(_penx + ca*overflow, _peny + sa*overflow,graphics);
				else doAltLineTo(_penx + ca*overflow, _peny + sa*overflow,graphics);
				segLength -= overflow;
				overflow = 0;
				_dashVal = 0;
				_dashIndex++
				if (_dashIndex == _dashArray.length)_dashIndex = 0; 
				isLine = !isLine;
				if (!segLength) return;
			} else {
				ca = Math.cos(a);
				sa = Math.sin(a);
			}
			while ((_dashVal + segLength) > _dashArray[_dashIndex]) {
				var remaining:Number = _dashArray[_dashIndex] - _dashVal;
					if (segLength > remaining) {
						if (isLine) 	doLineTo(_penx + ca * (remaining), _peny + sa * (remaining), graphics);
						else doAltLineTo(_penx + ca * (remaining), _peny + sa * (remaining), graphics);
					   _dashVal = 0;
					   //reduce the length of this segment
					   segLength -= remaining;
					   //advance to next dash value
					   _dashIndex++
					   if (_dashIndex == _dashArray.length)_dashIndex = 0; 
					    //flip dash state
						isLine = !isLine;
					}else {
						if (isLine) 	doLineTo(x, y, graphics);
						else doAltLineTo(x, y, graphics);
						if (segLength == remaining){
							overflow = 0;
							_dashVal = 0;
							segLength-=remaining;
							 _dashIndex++
					   if (_dashIndex == _dashArray.length)_dashIndex = 0; 
							isLine = !isLine;
						}else{
							overflow = remaining - segLength;
							_dashVal += segLength;
						if (isLine)	 doLineTo(x, y,graphics);
						else doAltLineTo(x, y,graphics);
						}
					}
			}

				if (_dashVal+segLength <= _dashArray[_dashIndex]) {
				
				_dashVal += segLength;
				overflow = _dashArray[_dashIndex] - _dashVal;
				if (isLine) {
					doLineTo(_penx+ca*(_dashArray[_dashIndex]-overflow), _peny+sa*(_dashArray[_dashIndex]-overflow),graphics);
					
				} else {
					doAltLineTo(_penx+ca*(_dashArray[_dashIndex]-overflow), _peny+sa*(_dashArray[_dashIndex]-overflow),graphics);
				}
			}
		}
		
		/**
		* Draws a dashed curve in graphics using the current from the current drawing position to
		* (x, y) using the control point specified by (cx, cy).
		*/
		override public function curveTo(cx:Number, cy:Number, x:Number, y:Number, graphics:Graphics):void {
			var sx:Number = _penx;
			var sy:Number = _peny;
			var segLength:Number = curveLength(sx, sy, cx, cy, x, y,_curveaccuracy);
			var t:Number = 0;
			var t2:Number = 0;
			var c:Array;
			var d:Array;
			if (overflow) {
				if (overflow > segLength){
					if (isLine) doCurveTo(cx, cy, x, y,graphics);
					else doAltCurveTo(cx, cy, x, y, graphics);
					overflow -= segLength;
					_dashVal += segLength;
					return;
				}
				t = overflow/segLength;
				c = curveSliceUpTo(sx, sy, cx, cy, x, y, t);
				d = curveSliceFrom(sx, sy, cx, cy, x, y, t);
				if (isLine) doCurveTo(c[2], c[3], c[4], c[5],graphics);
				else doAltCurveTo(c[2], c[3], c[4], c[5], graphics);
				segLength -= overflow;
				overflow = 0;
				_dashVal = 0;
				_dashIndex++
				if (_dashIndex == _dashArray.length)_dashIndex = 0; 
				isLine = !isLine;
				if (!segLength) return;
				sx = d[0]; sy = d[1];
				cx = d[2]; cy = d[3];
			}

			while ((_dashVal + segLength) > _dashArray[_dashIndex]) {

				var remaining:Number = _dashArray[_dashIndex] - _dashVal;
					if (segLength > remaining) {
						t = remaining / segLength;
						c = curveSliceUpTo(sx, sy, cx, cy, x, y, t);
						d = curveSliceFrom(sx, sy, cx, cy, x, y, t);

						if (isLine) doCurveTo(c[2], c[3], c[4], c[5], graphics);
						else doAltCurveTo(c[2], c[3], c[4], c[5], graphics);
					   _dashVal = 0;
					   //reduce the length of this segment
					   segLength -= remaining;
					   //advance to next dash value
					   _dashIndex++
					   if (_dashIndex == _dashArray.length)_dashIndex = 0; 
					    //flip dash state
						isLine = !isLine;
						sx = d[0]; sy = d[1];
						cx = d[2]; cy = d[3];
					}else {
						if (isLine) doCurveTo(cx, cy, x, y, graphics);
						else doAltCurveTo(cx, cy, x, y, graphics);
						if (segLength == remaining) {
							overflow = 0;
							_dashVal = 0;
							segLength-=remaining;
							 _dashIndex++
					   if (_dashIndex == _dashArray.length)_dashIndex = 0; 
							isLine = !isLine;
						}else{
							overflow = remaining - segLength;
							_dashVal += segLength;
							if (isLine)	 doCurveTo(cx, cy, x, y, graphics);
							else doAltCurveTo(cx, cy, x, y, graphics);
							return;
						}
					}
			}
			if (_dashVal+segLength <= _dashArray[_dashIndex]) {
				_dashVal += segLength;
				overflow = _dashArray[_dashIndex] - _dashVal;
				if (isLine) {
					doCurveTo(cx, cy, x, y, graphics);
				} else {
					doAltCurveTo(cx, cy, x, y, graphics);
				}
			}
		}
		
		private var _reStrokeActive:Boolean;
		private var _restrokeArgs:Array;
		private var _reStroke:Function; 
		private var _deStroke:Function; 
		private var _destrokeArgs:Array;
		
		private var deStroke:Function = function (graphics:Graphics):void {
			//use the alternate stroke if one is specified
			if (_deStroke!=null) _deStroke(graphics)
			else graphics.lineStyle();
			_reStrokeActive = false;
		}
		
		private function doAltLineTo(x:Number, y:Number, graphics:Graphics):void {
			if (x == _penx && y == _peny) return;
			_penx = x; _peny = y;
			if (_reStrokeActive) deStroke(graphics);
			graphics.lineTo(x, y);
		}
		
		private function doLineTo(x:Number, y:Number, graphics:Graphics):void {
			if (x == _penx && y == _peny) return;
			_penx = x; _peny = y;
			if (!_reStrokeActive)_reStroke(graphics);
			graphics.lineTo(x, y);
		}
		private function doCurveTo(cx:Number, cy:Number, x:Number, y:Number, graphics:Graphics):void {
			if (cx == x && cy == y && x == _penx && y == _peny) return;
			_penx = x; _peny = y;
			if (!_reStrokeActive) _reStroke(graphics);
			graphics.curveTo(cx, cy, x, y);
		}
		
		private function doAltCurveTo(cx:Number, cy:Number, x:Number, y:Number, graphics:Graphics):void {
			if (cx == x && cy == y && x == _penx && y == _peny) return;
			_penx = x; _peny = y;
			if (_reStrokeActive) deStroke(graphics);
			graphics.curveTo(cx, cy, x, y);
		}
		//the below to be moved into a shared class.
								
		// private methods
		private function lineLength(sx:Number, sy:Number, ex:Number=0, ey:Number=0):Number {
			if (arguments.length == 2) return Math.sqrt(sx*sx + sy*sy);
			var dx:Number = ex - sx;
			var dy:Number = ey - sy;
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		private function curveLength(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, accuracy:Number):Number {
			var total:Number = 0;
			var tx:Number = sx;
			var ty:Number = sy;
			var px:Number, py:Number, t:Number, it:Number, a:Number, b:Number, c:Number;
			var n:Number = (accuracy) ? accuracy : _curveaccuracy;
			for (var i:Number = 1; i<=n; i++){
				t = i/n;
				it = 1-t;
				a = it*it; b = 2*t*it; c = t*t;
				px = a*sx + b*cx + c*ex;
				py = a*sy + b*cy + c*ey;
				total += lineLength(tx, ty, px, py);
				tx = px;
				ty = py;
			}
			return total;
		}
		
		private function curveSlice(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, t1:Number, t2:Number):Array {
			if (t1 == 0) return curveSliceUpTo(sx, sy, cx, cy, ex, ey, t2);
			else if (t2 == 1) return curveSliceFrom(sx, sy, cx, cy, ex, ey, t1);
			var c:Array = curveSliceUpTo(sx, sy, cx, cy, ex, ey, t2);
			c.push(t1/t2);
			return curveSliceFrom.apply(this, c);
		}
		
		private function curveSliceUpTo(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, t:Number):Array {
			if (isNaN(t)) t = 1;
			if (t != 1) {
				var midx:Number = cx + (ex-cx)*t;
				var midy:Number = cy + (ey-cy)*t;
				cx = sx + (cx-sx)*t;
				cy = sy + (cy-sy)*t;
				ex = cx + (midx-cx)*t;
				ey = cy + (midy-cy)*t;
			}
			return [sx, sy, cx, cy, ex, ey];
		}
		
		private function curveSliceFrom(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, t:Number):Array {
			if (isNaN(t)) t = 1;
			if (t != 1) {
				var midx:Number = sx + (cx-sx)*t;
				var midy:Number = sy + (cy-sy)*t;
				cx = cx + (ex-cx)*t;
				cy = cy + (ey-cy)*t;
				sx = midx + (cx-midx)*t;
				sy = midy + (cy-midy)*t;
			}
			return [sx, sy, cx, cy, ex, ey];
		}
		
		
	}
}