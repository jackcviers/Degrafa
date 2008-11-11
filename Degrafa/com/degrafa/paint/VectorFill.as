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
	
	import com.degrafa.core.collections.FilterCollection;
	import com.degrafa.core.ITransformablePaint;
	import com.degrafa.events.DegrafaEvent;
	import com.degrafa.GeometryGroup;
	import com.degrafa.transform.TransformBase;

	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IBlend;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.Measure;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.transform.ITransform;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
//	import flash.system.System;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	[DefaultProperty("source")]
	[Bindable(event="propertyChange")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("VectorFill.png")]
	
	
	/**
	 * Used to fill an area on screen with a bitmap or other DisplayObject.
	 */
	public class VectorFill extends DegrafaObject implements IGraphicsFill, IBlend, ITransformablePaint{
		
		// static constants
		public static const NONE:String = "none";
		public static const REPEAT:String = "repeat";
		public static const SPACE:String = "space";
		public static const STRETCH:String = "stretch";
			//targetSettings
		//scale to target bounds, without maintaining aspect ratio.
		public static const MATCH_BOUNDS:String = "matchTargetBounds";
		//scale the geometry fill to the target bounds, whilst maintaining aspect ratio. center horizontally and vertically
		public static const MATCH_BOUNDS_MAINTAIN_AR:String = "matchTargetBoundsMaintainAspectRatio";
		//draw without any scaling transforms to match the target bounds, but center on the fill bounds to the target's center of bounds
		public static const CENTER_TO_TARGET:String = "centerToTarget";
		private static var _targetSettings:Array = [NONE, MATCH_BOUNDS,MATCH_BOUNDS_MAINTAIN_AR,CENTER_TO_TARGET ];
		
		/**
		 * targetSetting options, avalailable as a convenience.
		 */
		public static function get targetSettingOptions():Array
		{
			return _targetSettings.concat();
		}
		
		// private variables
		private var shape:Shape;
		private var _source:IGeometryComposition;
		private var bitmapData:BitmapData;
		
		//flags
		private var _requiresPreRender:Boolean = true;
			
		//Dev note: disposeOnChange has implemented as a disposalQueue instead.
		//See the disposalQueueLimit property
		//	public var disposeOnChange:Boolean=true;

		
		public function VectorFill(source:IGeometryComposition = null){
			if (source) this.source = source;
			shape = new Shape();
		}
		
		private var _blendMode:String="normal";
		[Inspectable(category="General", enumeration="normal,layer,multiply,screen,lighten,darken,difference,add,subtract,invert,alpha,erase,overlay,hardlight", defaultValue="normal")]
		public function get blendMode():String { 
			return _blendMode; 
		}
		
		public function set blendMode(value:String):void {
			if(_blendMode != value){
				
				var oldValue:String=_blendMode;
				
				_blendMode = value;
			
				//call local helper to dispatch event	
				initChange("blendMode",oldValue,_blendMode,this);
				
			}
			
		}
		
		/**
		* The horizontal origin for the Geometry fill.
		* The Geometry fill is offset so that this point appears at the origin.
		* Scaling and rotation of the VectorFill are performed around this point.
		* @default 0
		*/
		private var _originX:Number = 0;
		public function get originX():Number { 
			return _originX; 
		}
		
		public function set originX(value:Number):void {
			
			if(_originX != value){
				
				var oldValue:Number=_originX;
				
				_originX = value;
				
				//call local helper to dispatch event	
				initChange("originX",oldValue,_originX,this);
				
			}
			
		}
		
		
		/**
		* The vertical origin for the Geometry fill.
		* The Geometry fill is offset so that this point appears at the origin.
		* Scaling and rotation of the rendered Geometry are performed around this point.
		* @default 0
		*/
		private var _originY:Number = 0;
		public function get originY():Number { 
			return _originY; 
		}
		public function set originY(value:Number):void {
			
			if(_originY != value){
				
				var oldValue:Number=_originY;
				
				_originY = value;
				
				//call local helper to dispatch event	
				initChange("originY",oldValue,_originY,this);
				
			}
			
		}
		
		
		/**
		* How far the Geometry is horizontally offset from the origin.
		* This adjustment is performed after rotation and scaling.
		* @default 0
		*/
		private var _offsetX:Measure = new Measure();
		public function get offsetX():Number { 
			return _offsetX.value; 
		}
		
		public function set offsetX(value:Number):void {
			
			if(_offsetX.value != value){
				
				var oldValue:Number=value;
				
				_offsetX.value = value;
				
				//call local helper to dispatch event	
				initChange("offsetX",oldValue,_offsetX,this);
				
			}
			
		}
		
		/**
		 * The unit of measure corresponding to offsetX.
		 */
		public function get offsetXUnit():String { return _offsetX.unit; }
		public function set offsetXUnit(value:String):void {
			if(_offsetX.unit != value) {
				initChange("offsetXUnit", _offsetX.unit, _offsetX.unit = value, this);
			}
		}
		
		
		/**
		 * How far the Geometry is vertically offset from the origin.
		 * This adjustment is performed after rotation and scaling.
		 * @default 0
		 */
		private var _offsetY:Measure = new Measure();
		public function get offsetY():Number { 
			return _offsetY.value; 
		}
		
		public function set offsetY(value:Number):void {
			
			if(_offsetY.value != value){
				
				var oldValue:Number=value;
				
				_offsetY.value = value;
				
				//call local helper to dispatch event	
				initChange("offsetY",oldValue,_offsetY,this);
				
			}
			
		}
		
		/**
		 * The unit of measure corresponding to offsetY.
		 */
		public function get offsetYUnit():String { return _offsetY.unit; }
		public function set offsetYUnit(value:String):void {
			if(_offsetY.unit != value) {
				initChange("offsetYUnit", _offsetY.unit, _offsetY.unit = value, this);
			}
		}
		
		/**
		 * How the Geometry repeats horizontally.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatX:String = "repeat";
		[Inspectable(category="General", enumeration="none,repeat,space,stretch")]
		
		public function get repeatX():String{ 
			return _repeatX;
		}
		
		public function set repeatX(value:String):void {
			if(_repeatX != value){
				
				var oldValue:String=value;
				//this setting will cause the underlying BitmapData to be recreated
				_requiresPreRender = true;
				//call local helper to dispatch event	
				initChange("repeatX",oldValue,_repeatX= value,this);
				
			}
			
		}
		
		
		/**
		 * How the Geometry repeats vertically.
		 * Valid values are "none", "repeat", "space", and "stretch".
		 * @default "repeat"
		 */
		private var _repeatY:String = "repeat";
		[Inspectable(category="General", enumeration="none,repeat,space,stretch")]
		public function get repeatY():String{ 
			return _repeatY; 
		}
		
		public function set repeatY(value:String):void {
			if(_repeatY != value){
				
				var oldValue:String=_repeatY;
				//this setting will cause the underlying BitmapData to be recreated
				_requiresPreRender = true;
				//call local helper to dispatch event	
				initChange("repeatY",oldValue,_repeatY= value,this);
				
			}
			
		}
		
		
		/**
		* The number of degrees to rotate the Geometry.
		* Valid values range from 0.0 to 360.0.
		* @default 0
		*/
		private var _rotation:Number = 0;
		
		public function get rotation():Number {
			return _rotation;
		}
		
		public function set rotation(value:Number):void {
			
			if(_rotation != value){
				
				var oldValue:Number=_rotation;
				
				
				//call local helper to dispatch event	
				initChange("rotation",oldValue,_rotation= value,this);
				
			}
			
		}
		
		
		/**
		 * The percent to horizontally scale the Geometry when filling, from 0.0 to 1.0.
		 * If 1.0, the Geometry is filled at its natural size.
		 * @default 1.0
		 */
	 	private var _scaleX:Number = 1;
		public function get scaleX():Number {
			return _scaleX; 
		}
		
		public function set scaleX(value:Number):void {
			
			if(_scaleX != value){
				
				var oldValue:Number=value;
				_scaleX = value;
				//call local helper to dispatch event	
				initChange("scaleX",oldValue,_scaleX,this);
			}
			
		}
		
		
		/**
		 * The percent to vertically scale the Geometry when filling, from 0.0 to 1.0.
		 * If 1.0, the Geometry is filled at its natural size.
		 * @default 1.0
		 */
		private var _scaleY:Number = 1;
		public function get scaleY():Number { 
			return _scaleY; 
		}
		
		public function set scaleY(value:Number):void {
			
			if(_scaleY != value){
				
				var oldValue:Number=value;
				
				_scaleY = value;
				
				//call local helper to dispatch event	
				initChange("scaleY",oldValue,_scaleY,this);
				
			}
		
		}
		
		
		/**
		 * A flag indicating whether to smooth the bitmap data when filling with it.
		 * @default true
		 */
		private var _smooth:Boolean = true; 
		[Inspectable(category="General", enumeration="true,false")]
		public function get smooth():Boolean{
			return _smooth; 
		}
		
		public function set smooth(value:Boolean):void {
			
			if(_smooth != value){
				
				var oldValue:Boolean=value;
				
				_smooth = value;
				//this setting will cause the underlying BitmapData to be recreated
				_requiresPreRender = true;
				//call local helper to dispatch event	
				initChange("smooth",oldValue,_smooth,this);
				
			}
			
		}
		
		/**
		 * A collection of filters to apply to the geometry source being used for the fill.
		 */
		//TODO: investigate event dispatching extended filters for Degrafa.
		private var _filters:FilterCollection;
		[Inspectable(category="General", arrayType="flash.filters.BitmapFilter")]
		[ArrayElementType("flash.filters.BitmapFilter")]
		public function get filters():Array{
			initFilterCollection();
			return _filters.items;
		}
		
		public function set filters(value:Array):void {
			initFilterCollection();
			if(_filters.items != value){
				
				var oldValue:Array=_filters.items;
			
				_filters.items = value;
				if (_enableFilters) shape.filters = _filters.items;
				else shape.filters = [];
				//call local helper to dispatch event	
				if (_enableFilters) initChange("filters",oldValue,_filters.items,this);
			}
		}
	
		/**
		* Initialize the filter collection by creating it and adding an event listener.
		**/
		private function initFilterCollection():void{
			if(!_filters){
				_filters = new FilterCollection();
				//add the parent so it can be managed by the collection
				_filters.parent = this;
				
				//add a listener to the collection
				if(enableEvents){
					_filters.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		 * Specifies whether to use enable any filters assigned to this Fill
		 */
		private var _enableFilters:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function get enableFilters():Boolean
		{
			return (_enableFilters == true);
		}
		public function set enableFilters(value:Boolean):void
		{
	
			if (value!=_enableFilters){
			_enableFilters = value;
		
			if (_filters) {
				_requiresRedraw = true;
				_requiresPreRender = true;
				if (_enableFilters) shape.filters = _filters.items;
				else shape.filters = [];
				initChange('enableFilters', !_enableFilters, _enableFilters, this);
			}
			}
		}
		
		
		/**
		 * Specifies whether to use the solidFillBackGround SolidFill (if set) when rendering
		 */
		private var _enableBackground:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function get enableBackground():Boolean
		{
			return (_enableBackground == true);
		}
		public function set enableBackground(value:Boolean):void
		{
			if (value!=_enableBackground){
			_enableBackground = value;
			
			//only trigger an update at this point if there is a solidFillBackground defined
			if (_solidFillBackground) {
				_requiresPreRender = true;
				initChange('enableBackground', !_enableBackground, _enableBackground, this);
			}
			}
		}
		/**
		 * A SolidFill instance to use when rendering 
		 */
		private var _solidFillBackground:SolidFill;
		public function get solidFillBackground():SolidFill
		{
			if (_solidFillBackground) return _solidFillBackground;
			else {
				// create a default a default instance on first request, but do not trigger a redraw until it has been manipulated
				_solidFillBackground = new SolidFill();
				_solidFillBackground.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE , BGListener);
				return _solidFillBackground;
			}
		}
		public function set solidFillBackground(value:SolidFill):void
		{
			if (value != _solidFillBackground) {
				var oldVal:SolidFill = _solidFillBackground;
				if (oldVal) oldVal.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE ,BGListener)
				_solidFillBackground = value;
				_solidFillBackground.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE , BGListener);
				//mark for recreation of the fill bitmapdata in begin method requests
				if (_enableBackground){
				_requiresPreRender = true;
				initChange("solidFillBackground", oldVal, _solidFillBackground , this);
				}
			}
		}
		
		private function BGListener(event:PropertyChangeEvent):void
		{
			if (_enableBackground){
			_requiresPreRender = true;
			initChange('solidFillBackground.'+event.property ,event.oldValue,event.newValue,this)
			}
		}
		
		/**
		 * whether the fillrendering bounds are determined by insetting from half the stroke width of the target or not.
		 * this setting only has effect when used to fill degrafa target geometry otherwise it is ignored.
		 */
		private var _insetFromStroke:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function get insetFromStroke():Boolean
		{
			return _insetFromStroke? _insetFromStroke:false;
		}
		public function set insetFromStroke(value:Boolean):void
		{
			if (value != _insetFromStroke) {
				_insetFromStroke = value;
				//_requiresRedraw = true;
				_requiresPreRender = true;
				initChange("insetFromStroke", !_insetFromStroke, _insetFromStroke, this);
			}
		}
		/**
		 * Specifies whether to use a the bounds of the clipSource Geometry object to clip the bounds of the fill
		 * from the rendered version of the source Geometry. If set to true and no clipSource has been assigned to this
		 * fill, then this setting is of no effect.
		 */
		private var _enableSourceClipping:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function get enableSourceClipping():Boolean
		{
			return (_enableSourceClipping == true);
		}
		public function set enableSourceClipping(value:Boolean):void
		{
			if (value!=_enableSourceClipping){
			_enableSourceClipping = value;
		
			if (_clipSource) {
				if (_enableSourceClipping) _clipSourceRect = _clipSource.bounds;
				_requiresPreRender = true;
				initChange('enableSourceClipping', !_enableSourceClipping, _enableSourceClipping, this);
			}
			}
		}
		
		
		private var _clipSource:Object;
		private var _clipSourceRect:Rectangle;
		/**
		 * Specifies a Geometry object to use as a clipping area for the fill's source geometry when determining the
		 * region to be used for the fill. Requires the enableSourceClipping setting to be enabled to have effect
		 */
		public function get clipSource():Object
		{
			if (!_clipSourceRect) {
				//default to an new RegularRectangle - might be useful from actionscript for easy clipSource settings
				_clipSource = new RegularRectangle();
				_clipSource.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE , clipSourceChange);
			}
			return _clipSource;
		}
		public function set clipSource(value:Object):void
		{
		//the only permitted clipSource items are GeometryGroup or Geometry
			
			if (value != _clipSource && value is Geometry || value is GeometryGroup)
			{
				if (_clipSource )
				{
					if (_clipSource is Geometry) (_clipSource as Geometry).removeEventListener(DegrafaEvent.RENDER , clipSourceChange);
					else (_clipSource as GeometryGroup).geometry.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE , clipSourceChange);
				}
				var oldVal:Object;
				if (value is Geometry) {
				//	value.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE , clipSourceChange);
					value.addEventListener(DegrafaEvent.RENDER , clipSourceChange);
					//force a boundsCalc if the clipSource Geometry is invalidated:
					value.preDraw();
					_clipSourceRect =value.bounds;
					_clipSourceRect = TransformBase.getRenderedBounds(value as IGeometryComposition);// .bounds;
					oldVal  = _clipSource;
				} else {
					//dev note: this is preliminary... an option to use a full GeometryGroup as the clipSource. Untested at this point.
					value.geometry.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE , clipSourceChange);
					_clipSourceRect = value.getBounds(value);
					oldVal = _clipSource;
				}
				 
				//assign it, but only dispatch a property change if enableSourceClipping is true
				_clipSource = value;
				if (enableSourceClipping) {
					_requiresPreRender = true;
					initChange('clipSource', oldVal, _clipSource = value, this);
				}
			}
		}
		
		/**
		 * respond to changes in the assigned source clipping object
		 * @param	event
		 */
		private function clipSourceChange(event:Event):void
		{
			//ignore any changes if enableSourceClipping is false
			if (!_enableSourceClipping) return;
			//track the bounds
			//ignore any changes here that don't affect the bounds
			var checkBounds:Rectangle
			if (event.target is Geometry){
				//get the transformed (render) bounds for the clipSource object:
				checkBounds = TransformBase.getRenderedBounds(event.target as IGeometryComposition );
			} else { //a displayObject is being used
				//dev note: this is preliminary... an option to use a full GeometryGroup as the clipSource. Untested at this point.
				checkBounds = event.target.getBounds(event.target);
			}
			if (!checkBounds.equals(_clipSourceRect))
			{
				_requiresPreRender=true
				initChange('clipSource', _clipSourceRect , _clipSourceRect=checkBounds, this);
			} 
		}
		
			
		
		/**
		 * A 'smart'/quick setting for matching fill rendering between source and target. Using this setting overrides - or more precisely, ignores -
		 * most of the manual settings applied to the fill. Using 'none' enables all the regular manual settings
		 */
		private var _targetSetting:uint = 0;
		[Inspectable(category="General", enumeration="none,matchTargetBounds,matchTargetBoundsMaintainAspectRatio,centerToTarget")]
		public function get targetSetting():String{
			return _targetSettings[_targetSetting]; 
		}
		
		public function set targetSetting(value:String):void {
			var valIndex:int = _targetSettings.indexOf(value);
			if (valIndex == -1) {
				valIndex = 0;
			}
			if (_targetSetting != valIndex)
			{
				var oldValue:uint = _targetSetting;
				_requiresPreRender = true;
				//call local helper to dispatch event	
				initChange("targetSetting",oldValue,_targetSetting=valIndex,this);
			}
		}
		
		
		/**
		 * listener to handle the property changes from the source geometry
		 * @param	event
		 */
		protected function geomListener(event:PropertyChangeEvent):void
		{
			_requiresRedraw = true;
			_requiresPreRender = true;
			initChange("source." + event.property , event.oldValue, event.newValue, this);
		
		}
		

		private var sourceBounds:Rectangle;
		private function redraw():void
		{
				//dev note: [optimization] at the moment, switching filters on/off also triggers a redraw below...this is not necessary if it is the only propertyChange
				// as a redraw is not required, just application or removal of the filters and adjustment of sourceBounds
				shape.graphics.clear();
				_source.draw(shape.graphics, _source.bounds);				
				sourceBounds = shape.getBounds(shape);

				//filters, if used, are not included in sourceBounds from the Shape. So we need to add the filter effects to the sourceBounds
				
				//dev note: this filter calculation is preliminary and (hopefully) may be able to be done in a more lightweight way:
				if (_enableFilters && _filters)
				{				
					var calcHelper:BitmapData; 
					for each(var filter:BitmapFilter in _filters.items)
						{
								calcHelper = new BitmapData(int(sourceBounds.width ), int(sourceBounds.height ));
								var check:Rectangle = calcHelper.generateFilterRect(calcHelper.rect, filter)
								check.offset(sourceBounds.x,sourceBounds.y)
								sourceBounds = sourceBounds.union(check);
								calcHelper.dispose();
						}
					var yround:Number;
					var xround:Number 
					xround= sourceBounds.x-Math.floor(sourceBounds.x);
					yround= sourceBounds.y-Math.floor(sourceBounds.y);
					sourceBounds.x=Math.floor(sourceBounds.x);
					sourceBounds.y=Math.floor(sourceBounds.y);
					sourceBounds.width = Math.ceil(sourceBounds.width);
					sourceBounds.height = Math.ceil(sourceBounds.height );
				}
				
				_requiresRedraw = false;
		}
		
		
		private var _disposalQueue:Array = [];
		/**
		 * A simple means by which to limit the amount of bitmapData this Fill generates.
		 * Any quantities of bitmapData older than this limit will be disposed.
		 * We may replace this at some point with a Degrafa bitmapData cache/manager
		 * or some other centralized way to manage the amount of/GC of bitmapData
		 */
		private var _disposalLimit:uint = 20;
		public function set disposalLimit(val:uint):void
		{
			_disposalLimit = val >= 0 ? val:0;
		}
		public function get disposalLimit():uint
		{
			return _disposalLimit;
		}
		
		protected function disposeBitmapData():void
		{
			while (_disposalQueue.length > _disposalLimit)
			{
				_disposalQueue.shift().dispose();			
			}
		}
		
		/**
		 * generate a prerendered bitmapData with padding by xoffset and yoffset, with a number of options
		 * @param	xoffset the number of pixels to pad left and right
		 * @param	yoffset the number of pixels to pad top and bottom
		 * @param	redrawSource force a refresh of the source (re-render the vectors)
		 * @param	targRect the target Rectangle for resizing into
		 * @param	clipSource an optional rectangle for the source space to clip to.
		 * @param   repX repeat count horizontally
		 * @param   repY repeat count vertically
		 */
		private function preRender(xoffset:uint=0,yoffset:uint=0,redrawSource:Boolean=true,targRect:Rectangle=null,clipperRect:Rectangle=null,repX:uint=1,repY:uint=1):void
		{
			if(_source )
			{
				//should only actually redraw if the source geometry has changed
				if (redrawSource)
				{
					redraw();
				}
				var workingBitmapData:BitmapData;
				var workingRect:Rectangle ;
				if (_enableSourceClipping && _clipSourceRect ) {
					workingRect = _clipSourceRect.clone();
				} else {
					workingRect = sourceBounds.clone();
				}
				if (!workingRect.isEmpty()) {
						var newWidth:uint ;
						var newHeight:uint;

					//move to the 'origin' of the fill capture
					var transMat:Matrix = new Matrix(1, 0, 0, 1, -(workingRect.x), -(workingRect.y))
					if (targRect)
					{
						if (targRect.isEmpty()) {
							//we have essentially scaled to zero
							if (bitmapData) _disposalQueue.push(bitmapData);
								bitmapData = null;
								return;
							}
					//handle scaling bitmapdata
						var xscaler:Number = targRect.width / workingRect.width;
						var yscaler:Number = targRect.height / workingRect.height;
				
						if (_targetSetting == 2) {
							//maintain aspect ratio
							var scale:Number = Math.min(xscaler, yscaler);
							transMat.scale(scale, scale);
						
							newWidth = Math.ceil(scale * workingRect.width) + xoffset * 2;
							newHeight = Math.ceil(scale * workingRect.height) + yoffset * 2;
							if (newWidth && newHeight) {
								workingBitmapData = new BitmapData(newWidth*repX, newHeight*repY, true, 0);
							}
							else {
								if (bitmapData) _disposalQueue.push(bitmapData);
								bitmapData = null;
								return;
							}
						
						} else {
	
							transMat.scale(xscaler, yscaler);
							newWidth = targRect.width+xoffset*2;
							newHeight = targRect.height + yoffset * 2;
	
							var xpadExtra:uint = (repX!=1 && repY==1)?1:0;
							var ypadExtra:uint = (repY!=1 && repX==1)?1:0;
							if (newWidth>0 && newHeight>0) {
								workingBitmapData = new BitmapData(newWidth*repX+xpadExtra*2, newHeight*repY+ypadExtra*2, true, 0);
							}
							else {
								if (bitmapData) _disposalQueue.push(bitmapData);
								bitmapData = null;
								return;
							}

						}
										
					} else { 

						workingBitmapData = new BitmapData((workingRect.width+xoffset*2)*repX, (workingRect.height+yoffset*2)*repY, true, 0);
		
					
					if (bitmapData) _disposalQueue.push(bitmapData);
					} 
					bitmapData = workingBitmapData;
				
					//dev note: move this background fill operation into the BitmapData instantiation
					if (_enableBackground && _solidFillBackground) {
						bitmapData.fillRect(bitmapData.rect, uint(_solidFillBackground.alpha * 255 * 0x1000000)+uint(_solidFillBackground.color));
					}

					var tempBmp:BitmapData;
					if (repX == 1 && repY == 1)
					{
		
						if (!_enableSourceClipping) { 
							//simple
							
							tempBmp = new BitmapData(workingRect.width*transMat.a + .5, workingRect.height*transMat.d + .5,true,0);
					        tempBmp.draw(shape, transMat, null, null, null, true );
							bitmapData.copyPixels(tempBmp,tempBmp.rect,new Point(xoffset,yoffset),null,null,true)
			
						} else 	{
							transMat.tx = -clipperRect.x * transMat.a;
							transMat.ty = -clipperRect.y * transMat.d;

							tempBmp = new BitmapData(clipperRect.width*transMat.a + .5, clipperRect.height*transMat.d + .5,true,0);
							tempBmp.draw(shape, transMat, null, null, null, true );
						
							bitmapData.copyPixels(tempBmp,tempBmp.rect,new Point(xoffset,yoffset),null,null,true)
						}
					}
					else {
						//repeat in one direction
						var i:uint;
						var j:uint;
						
						if (_enableSourceClipping) {
				
							transMat.tx = -clipperRect.x*transMat.a;
							transMat.ty = -clipperRect.y * transMat.d;
						   
							tempBmp = new BitmapData(clipperRect.width*transMat.a + .5, clipperRect.height*transMat.d + .5,true,0);
							tempBmp.draw(shape, transMat, null, null, null, true );

						} 

						transMat.translate(xoffset, yoffset);
						var orgty:Number = transMat.ty;
						var orgtx:Number = transMat.tx;

						for (i = 0; i < repX; i++)
						{
							if (repX!=1) {
							transMat.tx = i * (workingRect.width + xoffset * 2) + xoffset - workingRect.x;
							} else transMat.ty = orgtx;
							if (xpadExtra) {
								transMat.tx += xpadExtra;
							}

							for (j = 0; j < repY; j++)
							{	
							if (repY!=1) {
								transMat.ty =  j * (workingRect.height + yoffset * 2 ) + yoffset - workingRect.y;
								} else transMat.ty = orgty;
								if (ypadExtra) {
									transMat.ty += ypadExtra;

								}

							if (!tempBmp)	{
								bitmapData.draw(shape, transMat, null, _blendMode, null, true )
							} else {
								var tpoint:Point = new Point(xoffset+i*(workingRect.width+xoffset*2)+((xpadExtra)?xpadExtra:0), yoffset+j * (workingRect.height + yoffset*2 )+((ypadExtra)?ypadExtra:0));
								bitmapData.copyPixels(tempBmp, tempBmp.rect, tpoint,null,null,true);
							}
							
							}
						
						}
						
					}
					if (tempBmp) tempBmp.dispose();
					 
				} else {
					trace('empty working Rect')
				}
			}
		}
	

		/**
		 * The source used for the Geometry fill.
		 * An IGeometryComposition object
		 **/
		public function get source():IGeometryComposition { return _source; }
		public function set source(value:IGeometryComposition):void {

			//no change
			if (_source== value) return;
			//no value
			if (!value) {
				return;
			}	
			var oldValue:Object = bitmapData;
			//remove old listener
			if (_source) {
				(_source as DegrafaObject).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, geomListener);
			}
			_source = value;
			//add new listener
			(_source as DegrafaObject).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, geomListener);
			_requiresRedraw = true;
			_requiresPreRender = true;
			initChange("source", oldValue, bitmapData, this);

		}
		
		
		//reference to the requesting geometry
		private var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		
	
		private var matrix:Matrix = new Matrix();
		//flag to force a redraw of the source geometry
		private var _requiresRedraw:Boolean;
		//temporary working matrix
		private var tempmat:Matrix;
		//track difference in target bounds on subsequent requests
		private var _rectBuffer:Rectangle=new Rectangle();
		
		public function begin(graphics:Graphics, rectangle:Rectangle):void {

			if (rectangle && (rectangle.isEmpty() || rectangle.width*rectangle.height<1)) return; //no fill
			if (_enableSourceClipping && !_clipSourceRect) return ; // empty fill....as clipSource has not yet been assigned.

			if (_requiresRedraw) redraw();
			
			var template:BitmapData = bitmapData;
			var repeat:Boolean;
			var positionX:Number = 0; 
			var positionY:Number = 0;
			var regPoint:Point;
			matrix.identity();
			matrix.translate(rectangle.x, rectangle.y);
			
		
			if (_insetFromStroke && _requester && (_requester as Geometry).stroke){
				var strokeoffset:uint;
				strokeoffset = Math.ceil((_requester as Geometry).stroke.weight / 2);
				// for a zero weight stroke, give it a 1 pixel offset
				if (!strokeoffset) strokeoffset = 1;
				rectangle = rectangle.clone(); //don't mess with the original rectangle
				rectangle.inflate( -strokeoffset, -strokeoffset); //inset by strokeoffset - used for scaling if needed
				matrix.translate(strokeoffset, strokeoffset); //ditto for rendering
				_requiresPreRender = true;
			}
			if (rectangle && !_rectBuffer.equals(rectangle)) {
				//we have a different target to draw to. This may force a preRender if we need to.
				//todo: review targetSetting related conditions and add here if needed
				if ((_repeatX!=VectorFill.NONE || _repeatX!=VectorFill.REPEAT) && (_repeatY!=VectorFill.NONE || _repeatY!=VectorFill.REPEAT) ) _requiresPreRender = true;
				_rectBuffer.topLeft = rectangle.topLeft;
				_rectBuffer.bottomRight = rectangle.bottomRight;
			}
				
			repeat = false;
			if (_targetSetting) 
			{
			if (_requiresPreRender)
				if (_targetSetting!=3){

			
				{

						//first let's get some integer constraints on the fill target bounds.
						var targRect:Rectangle = rectangle.clone();
						targRect.width=Math.ceil(targRect.width+(targRect.x- (targRect.x=Math.floor(targRect.x))));
						targRect.height=Math.ceil(targRect.height+(targRect.y-(targRect.y=Math.floor(targRect.y))));
	
						 preRender(2, 2, false, targRect, _enableSourceClipping? _clipSourceRect:null);
						//if the bitmapdata was scaled to zero, then exit the fill
						if (bitmapData==null) return;
						template = bitmapData;
				
						
					}
				
				} 
				else 
				{ //centre to target
				
					if (_enableSourceClipping) preRender(2, 2, _requiresRedraw,null,_clipSourceRect);
					else preRender(2, 2, _requiresRedraw, null);
					//if the bitmapdata was scaled to zero in prendering, then exit the fill
					if (!bitmapData) return;
					template = bitmapData;
					
				}
				switch(_targetSetting)
				{
					case 2:
					//if match targetboundsmaintainaspectratio, then centre it to the target bounds
	
					matrix.translate(rectangle.width/2-bitmapData.width/2,rectangle.height/2-bitmapData.height/2)

					break;
					case 3 :
					matrix.translate(-2,-2)
					if (enableSourceClipping) 	matrix.translate(rectangle.width/2-_clipSourceRect.width/2, rectangle.height/2-_clipSourceRect.height/2);
					else matrix.translate(rectangle.width/2-sourceBounds.width/2, rectangle.height/2-sourceBounds.height/2);

					
					break;
					default:
					matrix.translate(-2,-2)
					
					break;
					
					
				}
					
			}
				
			else {  //there is no 'smart' setting for the target... use the regular BitmapFill approach
	
	
				var targetRect:Rectangle=  _enableSourceClipping ? _clipSourceRect.clone(): sourceBounds.clone();

				var padX:uint = 2;
				var padY:uint = 2;
				var repX:uint = 1;
				var repY:uint = 1;
				var renderingPadX:uint = 0;
				var renderingPadY:uint = 0;
				switch (_repeatX)
				{
					case VectorFill.STRETCH:
						targetRect.width = rectangle.width;
					break;
					case VectorFill.SPACE:
						renderingPadX = Math.round(Math.round((rectangle.width % targetRect.width) / int(rectangle.width/targetRect.width))  / 2);
						padX = 0;
						repX = int(rectangle.width / targetRect.width);
						repX = repX == 0?1:repX;
					break;
					case VectorFill.REPEAT :
						padX = 0;
						repX = int(rectangle.width / targetRect.width) + 1;
					break;
					case VectorFill.NONE:
					
					break;
				}
				switch (_repeatY)
				{
					case VectorFill.STRETCH:
						targetRect.height = rectangle.height;
					break;
					case VectorFill.SPACE:
						renderingPadY = Math.round(Math.round((rectangle.height % targetRect.height) / int(rectangle.height/targetRect.height))  / 2);
						padY = 0;
						repY = int(rectangle.height / targetRect.height);
						repY = repY == 0?1:repY;
					
					break;
					case VectorFill.REPEAT :
						padY = 0;
						repY = int(rectangle.height / targetRect.height) + 1
					break;
					case VectorFill.NONE:
						if (_repeatX==VectorFill.NONE) repeat = false;
					break;
				}
			
			if ((repX > 1 && repY > 1)  ) {
					//we have both x and y repeats, so just use the flash native bitmapfill's x&y repeat
					repX = 1;
					repY = 1;
					padX = 0;
					padY = 0;
					repeat = true;
				} 
				
			if (_requiresPreRender){
				preRender(padX+renderingPadX,padY+renderingPadY,_requiresRedraw,targetRect,_enableSourceClipping?_clipSourceRect:null,repX,repY)
				if (bitmapData==null) return;
				template = bitmapData;
				
			}
			repeat = (repeat || !(repeatX == VectorFill.NONE || repeatY == VectorFill.NONE));
	
			if(repeatX == VectorFill.NONE || repeatX == VectorFill.REPEAT) {
				positionX = _offsetX.relativeTo(rectangle.width-template.width)
			}

			if(repeatY == VectorFill.NONE || repeatY == VectorFill.REPEAT) {
				positionY = _offsetY.relativeTo(rectangle.height-template.height)
			}

			matrix.translate(-padX, -padY);
		
			}
			matrix.translate( -_originX, -_originY);

			matrix.scale(_scaleX, _scaleY);
			matrix.rotate(_rotation*(Math.PI/180));
			matrix.translate(positionX, positionY);
			var transformRequest:ITransform;
			var tempmat:Matrix;
			//handle layout transforms 
			if (_requester && (_requester as Geometry).hasLayout) {
				var geom:Geometry = _requester as Geometry;
				if (geom._layoutMatrix) matrix.concat( geom._layoutMatrix);
			}
			if (_transform && ! _transform.isIdentity) {
					tempmat= new Matrix();
					regPoint = _transform.getRegPointForRectangle(rectangle);
					tempmat.translate(-regPoint.x,-regPoint.y);
					tempmat.concat(_transform.transformMatrix);
					tempmat.translate( regPoint.x,regPoint.y);
					matrix.concat(tempmat);
				} 
			if (_requester && ((transformRequest  = (_requester as Geometry).transform) || (_requester as Geometry).transformContext)) {
				
				if (transformRequest) matrix.concat(transformRequest.getTransformFor(_requester));
				else matrix.concat((_requester as Geometry).transformContext);
				//remove the requester reference
				_requester = null;
			}
			graphics.beginBitmapFill(template, matrix, repeat,_smooth );
			//reset the forcePrerender flag
			_requiresPreRender  = false;
		}
		
		public function end(graphics:Graphics):void {
			graphics.endFill();
			disposeBitmapData();
		//testing code:	
		/*	graphics.lineStyle(0, 0xff0000, .1);
			var renderingRect:Rectangle = (_enableSourceClipping)? _clipSourceRect.clone():sourceBounds.clone();
			renderingRect.offset(_requester.bounds.x-renderingRect.x, _requester.bounds.y-renderingRect.y);

			graphics.drawRect(renderingRect.x,renderingRect.y, renderingRect.width,renderingRect.height);
		*/
			if (_requester) _requester = null;
		}
		
		private var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* altering this VectorFill object.
		**/
		public function get transform():ITransform{
			return _transform;
		}
		public function set transform(value:ITransform):void{
			
			if(_transform != value){
			
				var oldValue:Object=_transform;
			
				if(_transform){
					if(_transform.hasEventManager){
						_transform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
								
				_transform = value;
				
				if(enableEvents){
					_transform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				//call local helper to dispatch event
				initChange("transform", oldValue, _transform, this);
			}
			
		}
		
		private function propertyChangeHandler(event:PropertyChangeEvent):void
		{			
					
				if (event.source == _filters) _requiresPreRender = true;
					dispatchEvent(event);
		}
	}
}