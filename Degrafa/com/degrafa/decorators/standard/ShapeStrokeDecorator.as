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
package com.degrafa.decorators.standard{
	
	import com.degrafa.GeometryComposition;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.transform.RotateTransform;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	/**
	* ShapeStrokeDecorator is intended as an example wrapper type decoration.
	* Given a source object the ShapeStrokeDecorator will repeat that object 
	* along the wrapped geometry. ShapeStrokeDecorator is based on GeometryComposition,
	* so all contained geometry will be decorated.   
	**/
	public class ShapeStrokeDecorator extends GeometryComposition{
		
		private var coords:Array=[]; //stores coordinates and angles along the path
						
		public function ShapeStrokeDecorator(){
			super();
			invalidated = true;
		}
		
		private var _sourceGeometry:GeometryCollection;
		[Inspectable(category="General", arrayType="com.degrafa.IGeometryComposition")]
		[ArrayElementType("com.degrafa.IGeometryComposition")]
		/**
		* A array of IGeometryComposition objects. For ShapeStrokeDecorator
		* at this time only one is allowed. 
		**/
		public function get sourceGeometry():Array{
			initSourceGeometryCollection();
			return _sourceGeometry.items;
		}
		public function set sourceGeometry(value:Array):void{
			initSourceGeometryCollection();
			_sourceGeometry.items = value;
		}
		
		/**
		* Access to the Degrafa geometry collection object for this geometry object.
		**/
		public function get sourceGeometryCollection():GeometryCollection{
			initSourceGeometryCollection();
			return _sourceGeometry;
		}
		
		/**
		* Initialize the geometry collection by creating it and adding an event listener.
		**/
		private function initSourceGeometryCollection():void{
			if(!_sourceGeometry){
				_sourceGeometry = new GeometryCollection();
				
				//add the parent so it can be managed by the collection
				_sourceGeometry.parent = this;
				
				//add a listener to the collection
				if(enableEvents){
					_sourceGeometry.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}				
		
		private var _explicitRepeatCount:int=-1;
		/**
 		* Use an explicit count. If not specified the optimal will be calculated.
 		**/
 		public function get explicitRepeatCount():int{
			return _explicitRepeatCount;
		}
		public function set explicitRepeatCount(value:int):void{
			_explicitRepeatCount=value;
			invalidated =true;
		}
				
		private var _gap:Number=0;
		/**
 		* The gap of empty space between repeated items. Only applicable 
 		* when explicitRepeatCount is not set.
 		**/
 		public function get gap():Number{
			return _gap;
		}
		public function set gap(value:Number):void{
			_gap=value;
			invalidated =true;
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			
			if(invalidated){
				
				for each (var geom:Geometry in geometry){
					geom.preDraw();
					geom.calculateLayout();
					geom.commandStack.lengthInvalidated =true;
				}
				invalidated =false;
			}
		}
		
		/**
		* Ends the draw phase for geometry objects.
		* 
		* @param graphics The current Graphics context being drawn to. 
		**/
		override public function endDraw(graphics:Graphics):void {
			super.endDraw(graphics);
			
			//we have drawn our object that we will be repeating around, predrawn the source 
			//object to repeat and stored the angles and points on our geometry that are required. 
			executeStroke(graphics);
				
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/				
		override public function draw(graphics:Graphics, rc:Rectangle):void{
			
			//init the layout in this case done before predraw.
			calculateLayout();
			
		 	//re init if required
		 	preDraw();
		 				
			super.draw(graphics, (rc)? rc:bounds);		
		}
		
		/**
 		* Calculates the values required for distribution.
 		**/
		private function calcValues(geom:Geometry):void{
			
			var repeateCount:int;
			if(_explicitRepeatCount==-1){
				//calculate optimal based on geometric length
				var optimalDivisor:Number = Math.min(Geometry(sourceGeometry[0]).bounds.height,Geometry(sourceGeometry[0]).bounds.width);
				repeateCount = (geom.commandStack.transformedPathLength / (optimalDivisor+_gap));
			}
			else{
				//use explicit count setting
				repeateCount=_explicitRepeatCount;	
			}
				
			for (var i:int=0;i<(repeateCount+1);i++){ 
				coords.push({point:geom.pointAt(i/repeateCount),angle:geom.angleAt(i/repeateCount)*(180/Math.PI)})
			}
			
			//add item at t:1
			coords.push({point:geom.pointAt(1),angle:geom.angleAt(1)*(180/Math.PI)})
			
		}
		
		/**
 		* Executes the distribution.
 		**/
		private function executeStroke(graphics:Graphics):void{
			
			if(sourceGeometry.length==0){return;}
			
			coords.length=0;
									
			var trans:RotateTransform = new RotateTransform();
			trans.angle = 0;
			trans.registrationPoint = "center";
			
			trans.enableEvents = false;
			
			var geom:Geometry;
			for each (geom in sourceGeometry){
				geom.suppressEventProcessing = true;
				geom.transform = trans;
				geom.preDraw();
			}
			
			//get the angles and points 
			for each (geom in geometry){
				calcValues(geom);
			}
			
			var xOffset:Number=0;
			var yOffset:Number=0;
			var sourceRect:Rectangle;
			
			var sourcelength:int=sourceGeometry.length;
			var sourceIndex:int=0
			
			for (var i:int=0;i<coords.length-1;i++){
				
				if(sourceIndex==sourcelength){
					sourceIndex=0;
				}
				
				sourceRect=sourceGeometry[sourceIndex].bounds;
				
				xOffset = sourceRect.width/2;
				yOffset = sourceRect.height/2;
				
				trans.angle=coords[i].angle;
				
				sourceGeometry[sourceIndex].x = coords[i].point.x-xOffset;
				sourceGeometry[sourceIndex].y = coords[i].point.y-yOffset;
				
				sourceGeometry[sourceIndex].draw(graphics,null);
				sourceIndex +=1;
				
			}
		}
	}
}