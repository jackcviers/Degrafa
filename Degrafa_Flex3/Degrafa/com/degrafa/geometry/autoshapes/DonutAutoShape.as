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
package com.degrafa.geometry.autoshapes{
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.command.CommandStack;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	[Bindable]
	
	/**
 	* The DonutAutoShape element draws a donut using the specified centre point 
 	* and radius with a cut out hole defined by the innerRadius.
 	*
 	* User Tip: Adjust accuracy for other results.  
 	**/
	public class DonutAutoShape extends AutoShape implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The DonutAutoShape constructor accepts 4 optional arguments that define it's 
	 	* center point and radius.</p>
	 	* 
	 	* @param centerX A number indicating the center x-axis coordinate.
	 	* @param centerY A number indicating the center y-axis coordinate.
	 	* @param radius A number indicating the radius of the circle. 
	 	* @param innerRadius A number indicating the radius of the inner cut out circle.
	 	*/	
		public function DonutAutoShape(centerX:Number=NaN,centerY:Number=NaN,radius:Number=NaN,innerRadius:Number=NaN){
			super();
			
			if (centerX) this.centerX=centerX;
			if (centerY) this.centerY=centerY;
			if (radius)  this.radius=radius;
			if (innerRadius)  this.innerRadius=innerRadius;
		}
		
		/**
		* DonutAutoShape short hand data value.
		* 
		* <p>The DonutAutoShape data property expects exactly 4 values centerX, 
		* centerY, radius and innerRadius separated by spaces.</p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:Object):void{
			if(super.data != value){

				//parse the string
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 4)
				{	
					super.data = value;
					_centerX=	tempArray[0];
					_centerY=	tempArray[1];
					_radius =	tempArray[2];
					_innerRadius = tempArray[4];
					invalidated = true;
				}	
			}
		} 
		
		private var _centerX:Number;
		/**
		* The x-axis coordinate of the center of the DonutAutoShape. If not specified 
		* a default value of 0 is used.
		**/
		public function get centerX():Number{
			if(!_centerX){return (hasLayout)? 0.5:0;}
			return _centerX;
		}
		public function set centerX(value:Number):void{
			if (_centerX != value) {
				_centerX = value;
				invalidated = true;
			}
		}
				
		private var _centerY:Number;
		/**
		* The y-axis coordinate of the center of the DonutAutoShape. If not specified 
		* a default value of 0 is used.
		**/
		public function get centerY():Number{
			if(!_centerY){return (hasLayout)? 0.5:0;}
			return _centerY;
		}
		public function set centerY(value:Number):void{
			if(_centerY != value){
				_centerY = value;
				invalidated = true;
			}
			
		}		
		
		private var _radius:Number;
		/**
		* The radius of the DonutAutoShape. If not specified a default value of 0 
		* is used.
		**/
		public function get radius():Number{
			if(!_radius){return (hasLayout)? .5:0;}
			return _radius;
		}
		public function set radius(value:Number):void{
			if(_radius != value){
				_radius = value;
				invalidated = true;
			}
		}
		
		private var _innerRadius:Number;
		/**
		* The inner radius of the DonutAutoShape. If not specified a default value of 0 
		* is used. Percent values (50%) are accepted.
		**/
		[PercentProxy("innerRadiusPercent")]
		public function get innerRadius():Number{
			if(!_innerRadius){return (hasLayout)? 0:0;}
			return _innerRadius;
		}
		
		public function set innerRadius(value:Number):void{
			if(_innerRadius != value){
				_innerRadius = value;
				_innerRadiusPercent = NaN;
				invalidated = true;
			}
		}
				
		private var _innerRadiusPercent:Number;
		/**
		* The percent inner radius of the DonutAutoShape. If not specified a default value of 0 
		* is used. Expects a value between 0 and 100. 
		* Note: Percent values between 0 and 1 are not yet supported.
		**/
		public function get innerRadiusPercent():Number{
			if(!_innerRadiusPercent){return NaN;}
			return _innerRadiusPercent;
		}
		
		public function set innerRadiusPercent(value:Number):void{
			if(_innerRadiusPercent != value){
				_innerRadiusPercent = value;
				invalidated = true;
			}
		}
		
		private var _accuracy:Number;
		/**
		* The accuracy of the circles that make up the DonutAutoShape. 
		* If not specified a default value of 8 is used.
		**/
		public function get accuracy():Number{
			if(!_accuracy){return 8;}
			return _accuracy;
		}
		public function set accuracy(value:Number):void{
			if(_accuracy != value){
				_accuracy = value;
				invalidated = true;
			}
		}
		
		/**
		* Draw the objects part(s) based on passed parameters.
		*/
		private function preDrawPart(item:int,commandStackForItem:CommandStack):void{
			
			var itemRadius:Number;
			
			if(item==0){
				itemRadius = radius;
			}
			else{
				if(_innerRadiusPercent){
					itemRadius = (innerRadiusPercent/100)*radius;
				} else itemRadius = innerRadius;
			}
			
			
			//item 0 = outer, 1 = inner
			var span:Number = Math.PI/accuracy;
			var controlRadius:Number = itemRadius/Math.cos(span);
			var anchorAngle:Number=0
			var controlAngle:Number=0;
			    
		   	//add the move to the command stack
		    commandStackForItem.addMoveTo(
		    centerX+Math.cos(anchorAngle)*itemRadius,
		    centerY+Math.sin(anchorAngle)*itemRadius);
				
		    var i:int=0;
		    
		    //loop through and add the curve commands
		    for (i; i<accuracy; ++i) {
		        controlAngle = anchorAngle+span;
		        anchorAngle = controlAngle+span;
		    
		        commandStackForItem.addCurveTo(
		        centerX + Math.cos(controlAngle)*controlRadius,
		        centerY + Math.sin(controlAngle)*controlRadius,
		        centerX + Math.cos(anchorAngle)*itemRadius,
		        centerY + Math.sin(anchorAngle)*itemRadius)
			};
			
			
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				commandStack.source.length = 0;
				
				//add outer circle
				preDrawPart(0,commandStack);
			
				if(innerRadius || innerRadiusPercent){				
				    var commandStackInnerItem:CommandStack = new CommandStack(this);
				    preDrawPart(1,commandStackInnerItem);
					//add nested donut hole
					commandStack.addCommandStack(commandStackInnerItem);
				}
				
				invalidated = false;
			}
			
		}
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used or the most appropriate size is calculated. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					if(_radius){
			 			tempLayoutRect.width = tempLayoutRect.height = radius*2;
			 		}
			 		
			 		if(_centerX){
						tempLayoutRect.x = _centerX-(_radius? _radius:0);
					}
	
					if(_centerY){
						tempLayoutRect.y = _centerY - (_radius? _radius:0);	
					}

			 		super.calculateLayout(tempLayoutRect);	
					_layoutRectangle = _layoutConstraint.layoutRectangle;
					
					//Dev Note: layout needs testing and verification. 
					//Seems we are getting a bunch of duplicated code for 
					//this may want to seperate this out. 
					
					if (isNaN(_radius)) {
						//handle layout defined startup values:
						_radius = _layoutRectangle.width / 2;
						
						if (isNaN(_centerX)){
							_centerX = layoutRectangle.width / 2 + layoutRectangle.x;
						}
						else{
							_layoutRectangle.x -= _radius;
						} 
						
						if (isNaN(_centerY)){
							_centerY = layoutRectangle.height / 2  + layoutRectangle.y;
						} 	
						else{
							_layoutRectangle.y -= _radius;
						} 
						
						invalidated = true;
					}

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
			
		 	//init the layout in this case done before predraw.
			if (hasLayout) calculateLayout();
			
			//re init if required
			if (invalidated) preDraw();
						
			//apply the fill retangle for the draw
			super.draw(graphics,(rc)? rc:bounds);
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:DonutAutoShape):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			
			if (!_centerX){_centerX = value.centerX}
			if (!_centerY){_centerY = value.centerY}
			if (!_radius){_radius = value.radius}
			if (!_innerRadius){_innerRadius = value.innerRadius}
			if (!_accuracy){_accuracy = value.accuracy;}
			
		}
		
	}
}