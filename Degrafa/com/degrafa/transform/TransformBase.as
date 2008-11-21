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

	import com.degrafa.core.IDegrafaObject;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import flash.geom.Rectangle;
	import mx.core.IMXMLObject;

	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	* TransformBase is a base transform class that other transforms extend off of.  
	**/
	public class TransformBase extends DegrafaObject implements ITransform{
		
		private static var identity:Matrix = new Matrix();
		

		/**
		 * Helper method to get the bounds after a transform has been applied
		 * @param	target
		 * @return  a rendered bounds rectangle
		 */
		public static function getRenderedBounds(target:IGeometryComposition):Rectangle
		{
			var requester:Geometry = (target as Geometry);

			if (requester.transform)
			{
				return (requester.transform as TransformBase).getTransformedBoundsFor(target);

			} else {
			var context:Matrix = requester.transformContext;

			if (!context)
			{
				//check the parent hierachy for the closest ancestor with a transform
				while (requester.parent)
				{
					requester = (requester.parent as Geometry);
					if (requester.transform) {
						context = requester.transform.getTransformFor(requester);
						break;
					}
				}
			}
			if (context)
			{
				return transformBounds(requester.bounds, context);
			} else return requester.bounds.clone();
			
			}
		}
		
		/**
		 * Helper method to apply a matrix to a bounds Rectangle and return a transformed bounds Rectangle
		 * @param	rect the bounds rectangle to be transformed
		 * @param	trans the transformation Matrix to be applied
		 * @return  the transformed bounds rectangle
		 */
		public static function transformBounds(rect:Rectangle, trans:Matrix):Rectangle
		{
			var tempBounds:Rectangle = rect.clone();
			var tl:Point = tempBounds.topLeft;
			var br:Point = tempBounds.bottomRight;
			var tr:Point;
			var bl:Point;
			( tr =tl.clone()).offset(br.x - tl.x, 0);
			( bl = tl.clone()).offset(0, br.y - tl.y);
				
			var points:Array = [trans.transformPoint(tl),trans.transformPoint(br),trans.transformPoint(tr),trans.transformPoint(bl)];
			tempBounds.setEmpty();
			tempBounds.topLeft = trans.transformPoint(tl);
			for each(var p:Point in points)
			{
				if (tempBounds.right < p.x) tempBounds.right = p.x;
				if (tempBounds.top > p.y) tempBounds.top = p.y;
				if (tempBounds.left > p.x) tempBounds.left = p.x;
				if (tempBounds.bottom < p.y) tempBounds.bottom = p.y;
			}
			return tempBounds;
		}
		
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
		
		//matrix transform properties that can be selectively exposed via setters in sub-classes
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
				//the sequence used here will result in a matrix that appears to mimic the behavior exhibited by the Flash IDE
				//re-use the matrix instead of creating a new Matrix instance to begin from an identity matrix
				_transformMatrix.identity();
			
			if (_scaleX!=1 || _scaleY!=1) _transformMatrix.scale(_scaleX, _scaleY);
			if (_skewX || _skewY)
				{
					var skewMat:Matrix = new Matrix();
					skewMat.a =  Math.cos(_skewY*Math.PI/180);
					skewMat.b =  Math.sin(_skewY * Math.PI / 180);
					skewMat.c = - Math.sin(_skewX * Math.PI / 180);
					skewMat.d =  Math.cos(_skewX * Math.PI / 180);
					_transformMatrix.concat(skewMat);
				}
			 if (_angle) _transformMatrix.rotate(_angle * Math.PI / 180);
		
		     if (_tx ||_ty)	_transformMatrix.translate(_tx, _ty);
			}
			invalidated = false;
			return _transformMatrix;
		}
		public function set transformMatrix(value:Matrix):void{
			_transformMatrix=value;
		}
		
		protected var _centerX:Number=NaN;
		/**
		* The center point of the transform along the x-axis.
		**/
		public function get centerX():Number{
			return isNaN(_centerX)? 0:_centerX;
		}
		public function set centerX(value:Number):void{
			
			if(_centerX != value){
				_centerX = value;
				invalidated = true;
			}
			
		}
		
		protected var _centerY:Number=NaN;
		/**
		* The center point of the transform along the y-axis.
		**/
		public function get centerY():Number {
			return isNaN(_centerY)? 0:_centerY;
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
		 * A check to determine if the center of transfomation has been explicitly set. Required for TransformGroup
		 * @return boolean true if this Transform object has an explicit setting for it's registration point
		 */
		public function hasExplicitSetting():Boolean {
			return (_registrationPoint || !(isNaN(_centerX) || isNaN(_centerY)));
		}
		
		/**
		 * Detetermines the transformation registration point based on this transform's settings for an arbitrary Rectangle. Exposed primarily for
		 * use in Fills. This method returns a point where 0,0 as centerX,centerY (default for a Transform) is the center of the rectangle, because Fill transforms default to the center
		 * of the Fill target's bounds for their registration Point.
		 * @param	rectangle
		 * @return  a Point representing the registration point settings for this transform, expressed in the context of the rectangle argument
		 */
		public function getRegPointForRectangle(rectangle:Rectangle):Point
		{
			var fillRegPoint:Point;
			if (_registrationPoint) fillRegPoint= getRegistrationPoint(null, rectangle);
			else
			{
				//use the centerpoint of the rectangle as the 'origin' in this case (best for fills)
				fillRegPoint = new Point(rectangle.x+rectangle.width/2+centerX ,rectangle.y+rectangle.height/2+ centerY);
			}
			return fillRegPoint;
		}
		
		
		/**
		* Calculates the translation offset based on the set registration point.
		**/
		protected function getRegistrationPoint(value:IGeometryComposition,rectangle:Rectangle=null):Point{
			
			var regPoint:Point;
			
			if (value) rectangle = (value as Geometry).hasLayout? Geometry(value).layoutRectangle: Geometry(value).bounds;
			
			switch(_registrationPoint){
				
				case "topLeft":
					regPoint = rectangle.topLeft;
					break;
				case "centerLeft":
					regPoint = new Point(rectangle.left,rectangle.y+rectangle.height/2);
					break;
				case "bottomLeft":
					regPoint = new Point(rectangle.left,rectangle.bottom);
					break;
				case "centerTop":
					regPoint = new Point(rectangle.x+rectangle.width/2,rectangle.y);
					break;
				case "center":
					regPoint = new Point(rectangle.x+rectangle.width/2,rectangle.y+rectangle.height/2);
					break;
				case "centerBottom":
					regPoint = new Point(rectangle.x+rectangle.width/2,rectangle.bottom);
					break;
				case "topRight":
					regPoint = new Point(rectangle.right,rectangle.top);
					break;
				case "centerRight":
					regPoint = new Point(rectangle.right,rectangle.y+rectangle.height/2);
					break;
				case "bottomRight":
					regPoint = rectangle.bottomRight;
					break;
			}
			return regPoint;
			
		}
		
		/**
		 * Utility function used internally for accessing the bounds of a transformed object
		 * @param	value - the Geometry object for which the transformed bounds are required
		 * @return  a Rectangle representing the transformed bounds of the Geometry
		 */
		public function getTransformedBoundsFor(value:IGeometryComposition):Rectangle
		{
			var requester:Geometry = (value as Geometry);
			var trans:Matrix = getTransformFor(value);
			return transformBounds(requester.bounds, trans);
		
		}
		
		/**
		 * Retrieves the adjusted matrix for the registration offset based on the Geometry target bounds, 
		 * if this transform is based on a registrationPoint, otherwise based on the centerX and centerY settings
		 * @param	value - the Geometry context for the transform
		 * @return	a flash Matrix representing the transform for the Geometry argument
		 */
		public function getTransformFor(value:IGeometryComposition):Matrix
		{
			var offset:Point = (_registrationPoint)? getRegistrationPoint(value):new Point(centerX, centerY);
			//first check for a transform history...
			//this relies on the nested update sequence from parent to children to work in 
			//a stable way.

			var requester:Geometry = (value as Geometry);
			var context:Matrix = requester.transformContext;

			if (!context)
			{
				//check the parent hierachy for the closest ancestor with a transform
				while (requester.parent)
				{
					requester = (requester.parent as Geometry);
					if (requester.transform) {
						context = requester.transform.getTransformFor(requester);
						break;
					}
				}
			}
		
			var transMat:Matrix = new Matrix();
			transMat.translate( -offset.x, -offset.y);
			transMat.concat(transformMatrix);
			transMat.translate(offset.x, offset.y)
			
			//TODO: Something is not working as it should here:
			if (context) {
				transMat.concat(context);
			}
			return transMat;
			
		}
		/**
		 * Retrieves the registration offset for the Geometry target. If the registrationPoint property is set,
		 * this will return the registrationPoint calculated from the geometry target bounds, otherwise it will
		 * return the centerX and centerY settings for this Transform.
		 * @param	value
		 * @return
		 */
		public function getRegPoint(value:IGeometryComposition):Point
		{
			if (_registrationPoint) return getRegistrationPoint(value);
			else return new Point(centerX, centerY);
		}
		/**
		 * Boolean value indicating whether this transform will have no effect on the coordinate space of a target
		 */
		public function get isIdentity():Boolean
		{
			// make sure we're checking a validated transform
			if (invalidated) var forceupdate:Matrix = transformMatrix; 
			//dev note: this may be useful to avoid the transform conditional branch in commandstack rendering
			//need to check fastest way to compare to identity matrix, ie. like this or via toString()
			return (_transformMatrix.a == 1 && !_transformMatrix.b  && !_transformMatrix.c  && _transformMatrix.d == 1 && !_transformMatrix.tx && !_transformMatrix.ty);
		}
		
		//getters are always available from the base class
		public function get y():Number
		{
			return _ty;
		}
		
		public function get x():Number
		{
			return _tx;
		}
		
		public function get angle():Number
		{
			return _angle;
		}
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function get skewX():Number
		{
			return _skewX;
		}
		
		public function get skewY():Number
		{
			return _skewY;
		}

	}
}