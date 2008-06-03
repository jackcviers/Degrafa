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

package com.degrafa.transform{

	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;

	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	* TransformBase is a base transform class that other transforms extend off of.  
	**/
	[DefaultProperty("data")]	
	public class TransformBase extends DegrafaObject implements ITransform{
		
		private static var identity:Matrix = new Matrix();
		
		/**
		* Specifies whether this object's matrix is to be re calculated 
		* on the next request.
		**/
		public var invalidated:Boolean;
			
		private var _data:String;
		public function get data():String{
			return _data;
		}
		public function set data(value:String):void{
			_data=value;
		}
		
		//matrix transform properties that can be selectively exposed via getters/setters in sub-classes
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;
		protected var _skewY:Number = 0;
		protected var _skewX:Number = 0;
		protected var _angle:Number = 0;
		protected var _tx:Number = 0;
		protected var _ty:Number = 0;
		
		protected var _transformMatrix:Matrix=new Matrix();
		/**
		* The internal matrix calculated from the exposed transform properties.
		**/
		public function get transformMatrix():Matrix
		{
			if (!invalidated) return _transformMatrix;
			else {
				//recreate the matrix based on the transform properties
				//the sequence used here will result in a matrix that mimics the behavior exhibited by the Flash IDE
				//re-use the matrix instead of creating a new Matrix instance to begin from an identity matrix
				_transformMatrix.a = _transformMatrix.d = 1;
				_transformMatrix.b = _transformMatrix.c = _transformMatrix.tx = _transformMatrix.ty = 0;
				if (_scaleX || _scaleY) _transformMatrix.scale(_scaleX, _scaleY);
				
				if (_skewX || _skewY)
				{
					var skewMat:Matrix = new Matrix();
					skewMat.a =  Math.cos(_skewY*Math.PI/180);
					skewMat.b =  Math.sin(_skewY * Math.PI / 180);
					skewMat.c = - Math.sin(_skewX * Math.PI / 180);
					skewMat.d =  Math.cos(_skewX * Math.PI / 180);
					_transformMatrix.concat(skewMat);
				}
			 if (_angle) _transformMatrix.rotate(_angle*Math.PI/180);
		     if (_tx ||_ty)	_transformMatrix.translate(_tx, _ty);
			}
			invalidated = false;
			return _transformMatrix;
		}
		public function set transformMatrix(value:Matrix):void{
			_transformMatrix=value;
		}
		
		protected var _centerX:Number=0;
		/**
		* The center point of the transform along the x-axis.
		**/
		public function get centerX():Number{
			return _centerX;
		}
		public function set centerX(value:Number):void{
			
			if(_centerX != value){
				_centerX = value;
				invalidated = true;
			}
			
		}
		
		protected var _centerY:Number=0;
		/**
		* The center point of the transform along the y-axis.
		**/
		public function get centerY():Number{
			return _centerY;
		}
		public function set centerY(value:Number):void{
			if(_centerY != value){
				_centerY = value;
				invalidated = true;
			}
		}
		
		protected var _registrationPoint:String;
		[Inspectable(category="General", enumeration="topLeft,centerLeft,bottomLeft,centerTop,center,centerBottom,topRight,centerRight,bottomRight")]
		/**
		* A value defining one of 9 possible registration points. Takes priority over centerX,centerY.
		**/
		public function get registrationPoint():String{
			return _registrationPoint;
		}
		public function set registrationPoint(value:String):void{			
			if(_registrationPoint != value){
				var oldValue:String=_registrationPoint;
				_registrationPoint = value;
			}
		}
		
		
		
		/**
		* Calculates the translation offset based on the set registration point.
		**/
		protected function getRegistrationPoint(value:IGeometryComposition):Point{
			
			var regPoint:Point;
		
			switch(_registrationPoint){
				
				case "topLeft":
					regPoint = value.bounds.topLeft;
					break;
				case "centerLeft":
					regPoint = new Point(value.bounds.left,value.bounds.y+value.bounds.height/2);
					break;
				case "bottomLeft":
					regPoint = new Point(value.bounds.left,value.bounds.bottom);
					break;
				case "centerTop":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.y);
					break;
				case "center":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.y+value.bounds.height/2);
					break;
				case "centerBottom":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.bottom);
					break;
				case "topRight":
					regPoint = new Point(value.bounds.right,value.bounds.top);
					break;
				case "centerRight":
					regPoint = new Point(value.bounds.right,value.bounds.y+value.bounds.height/2);
					break;
				case "bottomRight":
					regPoint = value.bounds.bottomRight;
					break;
			}
			return regPoint;
			
		}
		/**
		 * Retrieves the adjusted matrix for the registration offset based on the Geometry target bounds, 
		 * if this transform is based on a registrationPoint, otherwise based on the centerX and centerY settings
		 * @param	value - the Geometry context for the transform
		 * @return
		 */
		public function getTransformFor(value:IGeometryComposition):Matrix
		{
			var offset:Point = (registrationPoint)? getRegistrationPoint(value):new Point(_centerX, _centerY);
			var retMatrix:Matrix = new Matrix();
		    retMatrix.translate( -offset.x, -offset.y);
			retMatrix.concat(transformMatrix);
			retMatrix.translate(offset.x, offset.y)
			return retMatrix;
		}
		/**
		 * Retreives the registration offset for the Geometry target
		 * @param	value
		 * @return
		 */
		public function getRegPoint(value:IGeometryComposition):Point
		{
			if (registrationPoint) return getRegistrationPoint(value);
			else return new Point(_centerX, _centerY);
		}
		/**
		 * Boolean value indicating whether this transform will have no effect on the coordinate space of a target
		 */
		public function get isIdentity():Boolean
		{
			//dev note: this may be useful to avoid the transform branch in commandstack rendering
			//need to check fastest way to compare to identity matrix, ie. like this or via toString()
			return (_transformMatrix.a == 1 && !_transformMatrix.b  && !_transformMatrix.c  && _transformMatrix.d == 1 && !_transformMatrix.tx && !_transformMatrix.ty);
		}
		

	}
}