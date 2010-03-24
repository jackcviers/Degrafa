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
// Credit to Mr. Bourke see link for details. 
// http://local.wasp.uwa.edu.au/~pbourke/geometry/supershape/ 
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry{
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	/**
 	*  The SuperShape2D element draws a shape using the specified parameters.
 	*  
 	*  Credit to Mr. Bourke with a stellar algorithm. 
 	*  @see http://local.wasp.uwa.edu.au/~pbourke/geometry/supershape/   
 	*  
 	*  Also Jim Has elaborated on the algorithm with some helpful links.
 	*  @see http://algorithmist.wordpress.com/2009/06/10/supershapes-in-degrafa/
 	*  
 	**/
	public class SuperShape2D extends Geometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The SuperShape2D constructor accepts 6 optional arguments that define it's 
	 	* properties.</p>
	 	* 
	 	* @param n1 A number indicating the n1 value.
	 	* @param n2 A number indicating the n2 value.
	 	* @param n3 A number indicating the n3 value.
	 	* @param m A number indicating the m value.
	 	* @param detail A number indicating the level of detail.
	 	* @param range A number indicating the range.
	 	*/		
		public function SuperShape2D(n1:Number=NaN,n2:Number=NaN,n3:Number=NaN
		,m:Number=NaN,detail:int=-1,range:int=-1){
			super();
			
			if (n1) this.n1=n1;
			if (n2) this.n2=n2;
			if (n3) this.n3=n3;
			if (m) this.m=m;
			if (detail!=-1) this.detail=detail;
			if (range!=-1) this.range=range;
			
		}
		
		/**
		* SuperShape2D short hand data value.
		* 
		* <p>The SuperShape2D data property expects exactly 6 values n1, 
		* n2,n3,m,detail and range separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:Object):void{
			if(super.data != value){

				//parse the string
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 6)
				{	
					super.data = value;
					n1=	tempArray[0];
					n2=	tempArray[1];
					n3= tempArray[2];
					m= tempArray[3];
					detail=	tempArray[4];
					range =	tempArray[5];
					invalidated = true;
				}	
			}
		} 
		
		private var _n1:Number=1;
		/**
		* The n1 paramater of the super shape.
		**/
		public function get n1():Number{
			return _n1;
		}
		public function set n1(value:Number):void{
			if(_n1 != value){
				_n1 = value;
				invalidated = true;
			}
		}
		
		private var _n2:Number=1;
		/**
		* The n2 paramater of the super shape.
		**/
		public function get n2():Number{
			return _n2;
		}
		public function set n2(value:Number):void{
			if(_n2 != value){
				_n2 = value;
				invalidated = true;
			}
		}
		
		private var _n3:Number=1;
		/**
		* The n3 paramater of the super shape.
		**/
		public function get n3():Number{
			return _n3;
		}
		public function set n3(value:Number):void{
			if(_n3 != value){
				_n3 = value;
				invalidated = true;
			}
		}
				
		private var _m:Number=4;
		/**
		* The m paramater of the super shape.
		**/
		public function get m():Number{
			return _m;
		}
		public function set m(value:Number):void{
			if(_m != value){
				_m = value;
				invalidated = true;
			}
		}
		
		private var _detail:int=4;
		/**
		* The detail of the super shape. The number of points to be used.
		**/
		public function get detail():int{
			return _detail;
		}
		public function set detail(value:int):void{
			if(_detail != value){
				_detail = value;
				invalidated = true;
			}
		}
		
		private var _range:int=2;
		/**
		* The range of the super shape.
		**/
		public function get range():int{
			return _range;
		}
		public function set range(value:int):void{
			if(_range != value){
				_range = value;
				invalidated = true;
			}
		}
		
		/**
		* The core of the formula. Full credits to Mr. bourke.
		* 
		* @see http://local.wasp.uwa.edu.au/~pbourke/geometry/supershape/  
		**/
		private function eval(phi:Number,isLine:Boolean=true):void{
			
			var a:Number = 1; 
			var b:Number = 1;
			
			var t1:Number = Math.cos(_m * phi / 4) / a;
			t1 = Math.abs(t1);
			t1 = Math.pow(t1, _n2);

			var t2:Number = Math.sin(_m * phi / 4) / b;
			t2 = Math.abs(t2);
			t2 = Math.pow(t2, _n3);

			var r:Number = Math.pow(t1 + t2, 1 / _n1);
			
			if (Math.abs(r) != 0) {
				r = 1 / r;
				
				if(isLine){
					commandStack.addLineTo(r * Math.cos(phi),r * Math.sin(phi))
				}	
				else{//move to
					commandStack.addMoveTo(r * Math.cos(phi),r * Math.sin(phi))	
				}			
			}
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				commandStack.source.length = 0;
				
				eval(0,false);
				
				var i:int = 0;
				
				while (++i <= _detail) {
					eval(range * Math.PI * (i / _detail),true);
				}
				
				invalidated = false;
			}
		}
		
		
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					//default to bounds if no width or height is set
					//and we have layout
					if(isNaN(_layoutConstraint.width)){
						tempLayoutRect.width = bounds.width;
					}
					 
					if(isNaN(_layoutConstraint.height)){
						tempLayoutRect.height = bounds.height;
					}
										
					super.calculateLayout(tempLayoutRect);
						
					_layoutRectangle = _layoutConstraint.layoutRectangle;

				}
			}
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics,rc:Rectangle):void{
			
			//re init if required
		 	if (invalidated) preDraw(); 
			
			//init the layout in this case done after predraw.
			if (_layoutConstraint) calculateLayout();
			
			super.draw(graphics,(rc)? rc:bounds);
	 	}
	}
}
