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
package com.degrafa.geometry{
	
	import com.degrafa.geometry.display.IDisplayObjectProxy;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import com.degrafa.core.IGraphicsFill;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import com.degrafa.utilities.external.ExternalBitmapData;
	import com.degrafa.utilities.external.ExternalDataAsset;
	import com.degrafa.utilities.external.LoadingLocation;
	import com.degrafa.utilities.external.ExternalDataPropertyChangeEvent;
	import flash.utils.setTimeout;
	import mx.events.PropertyChangeEvent;
	
	
	[Exclude(name="data", kind="property")]
	[Exclude(name="fill", kind="property")]
	[Bindable(event = "propertyChange")]
	
	/**
 	*  The RasterImage element draws a Bitmap Rectangle to the 
	*  drawing target.
 	* 
 	*  <p>RasterImage represents a bitmap image that can be part of a geometry composition
	*  with behavior similar to a regular geometry object. The source of the image mirrors the
	*  flexibility provided by the paint BitmapFill object, including the possibility of externally
	*  loaded iamges.</p>   
 	* 
 	* 
 	**/
	public class RasterImage extends Geometry implements IDisplayObjectProxy{
		

		
		public var sprite:Sprite = new Sprite();
		private var _externalBitmapData:ExternalBitmapData;
		private var _loadingLocation:LoadingLocation;
		private var _contentWidth:Number;
		private var _contentHeight:Number;
		
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The RasterImage constructor has no arguments . RasterImage does not inherit stroke by default unlike other Geometry items.</p>
	 	* 
	 	*/	
		public function RasterImage(){
			super();
			//default to false for images on stroke inheritance
			inheritStroke = false;
			inheritFill = false;
		}
		
		/**
		* Excluded Items
		**/	
		/**
		* Data is required for the IGeometry interface and has no effect here.
		* @private 
		**/	
		override public function get data():Object{return null;}
		override public function set data(value:Object):void{}
		
		/**
		 * This item currently has no regular fill. We may add this to behave as a background fill (visible through transparent pixels in the image) in the future.
		 */
		override public function get fill():IGraphicsFill {	return null };
		override public function set fill(value:IGraphicsFill):void { };
		
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the regular rectangle. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		
		private var _y:Number;
		/**
		* The y-axis coordinate of the upper left point of the regular rectangle. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
		private var _width:Number;
		/**
		* The width of the regular rectangle.
		**/
		[PercentProxy("percentWidth")]
		override public function get width():Number{
			if(!_width){return (hasLayout)? 1:0;}
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated = true;
			}
		}
		
		
		private var _height:Number;
		/**
		* The height of the regular rectangle.
		**/
		[PercentProxy("percentHeight")]
		override public function get height():Number{
			if(!_height){return (hasLayout)? 1:0;}
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated = true;
			}
		}
		
		
		/**
		* Returns this objects displayObject.
		**/
		public function get displayObject():DisplayObject{
			if (sprite.numChildren == 0) return null;
			//provide the container object
			return sprite;
		}

		
		
		/**
		 * A support property for binding to in the event of an external loading wait.
		 * permits a simple binding to indicate that the wait is over
		 */
		private var _waiting:Boolean;
		[Bindable("externalDataPropertyChange")] 
		public function get waiting():Boolean
		{
			return (_waiting==true);
		}
		public function set waiting(val:Boolean):void
		{
		  if (val != _waiting  )
		  {
			_waiting = val; 
			//support binding, but don't use propertyChange to avoid Degrafa redraws for no good reason
			dispatchEvent(new ExternalDataPropertyChangeEvent(ExternalDataPropertyChangeEvent.EXTERNAL_DATA_PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE , "waiting", !_waiting, _waiting, this))
		  }
		}
		
		
		private var _internalDO:DisplayObject;
		/**
		 * handles the ready state for an ExternalBitmapData as the source of a RasterImage
		 * @param	evt an ExternalDataAsset.STATUS_READY event
		 */
		private function externalBitmapHandler(evt:Event):void {
			switch(evt.type)
			{
			case ExternalDataAsset.STATUS_READY:
				var oldValue:Object = (sprite.numChildren) ? sprite.removeChildAt(0) : null;
				var bitmapData:BitmapData = evt.target.content;
				swapInContent(new Bitmap(bitmapData, "auto", true));
				invalidated = true;
				initChange("source", oldValue, _internalDO, this);
				waiting = false;
			break;
			}
		}
		
		private function swapInContent(dobj :DisplayObject):void {
			if (sprite.numChildren) sprite.removeChildAt(0);
			_internalDO = dobj;
			sprite.addChild(dobj);
			//cache original values:
			_contentWidth = sprite.width;
			_contentHeight = sprite.height;
			//if there were no explicit assigned width and height, use the content's width and height
				if (isNaN(_width)) _width = _contentWidth;
				if (isNaN(_height)) _height = _contentHeight;
			invalidated = true;
		}
		
		/**
		 * Optional loadingLocation reference. Only relevant when a subsequent source assignment is made as 
		 * a url string. Using a LoadingLocation simplifies management of loading from external domains
		 * and is required if a crossdomain policy file is not in the default location (web root) and with the default name (crossdomain.xml)
		 * In actionscript, a loadingLocation assignment MUST precede a change in the url assigned to the source property
		 * If a LoadingLocation is being used, the url assigned to the source property MUST be relative to the base path
		 * defined in the LoadingLocation, otherwise loading will fail.
		 * If a LoadingLocation is NOT used and the source property assignment is an external domain url, then the crossdomain permissions
		 * must exist in the default location and with the default name crossdomain.xml, otherwise loading will fail.
		*/
		public function get loadingLocation():LoadingLocation { return _loadingLocation; }
		
		public function set loadingLocation(value:LoadingLocation):void 
		{
			if (value) 	_loadingLocation = value;
		} 
		
		private var target:DisplayObject;
		//used in actionscript when a remote load is done
		private var instantiationTimer:uint=5;
		public function set source(value:Object):void {
			var oldValue:Object = _internalDO;
			
			target = null;
			
			if (_externalBitmapData) {
				_externalBitmapData.removeEventListener(ExternalDataAsset.STATUS_READY, externalBitmapHandler);
				_externalBitmapData = null;
			}
			
			if (!value) {
				_internalDO  = null;
				if (sprite.numChildren) sprite.removeChildAt(0);
				if (oldValue!=null)	initChange("source", oldValue, null, this);
				return;
			}
			
			if (value is ExternalBitmapData) {
				_externalBitmapData = value as ExternalBitmapData;
				if (value.content) {		
					value = value.content;
				} else {
					value.addEventListener(ExternalDataAsset.STATUS_READY, externalBitmapHandler)
					waiting = true;
				return;
				}
			}
			
			if (value is BitmapData)
			{
				swapInContent( new Bitmap(value as BitmapData,"auto",true));
				initChange("source", oldValue, _internalDO, this);
				return;
			}
			if (value is Class)
			{
				target= new value() as DisplayObject;
	
			}
			else if (value is Bitmap)
			{
				
				target = value as Bitmap;
			}
			else if (value is DisplayObject)
			{
				target = value as DisplayObject;
			}
			else if (value is String)
			{
				//is it a class name or an external url?
				try {
					var cls:Class = Class(getDefinitionByName(value as String));	
				} catch (e:Error)
				{
					//if its not a class name, assume url string for an ExternalBitmapData
					//and wait for isInitialized to check/access loadingLocation mxml assignment
					//if not isInitialized after 5 ms, assume actionscript instantiation and not mxml
					if (!isInitialized && instantiationTimer) {
							instantiationTimer--;
						setTimeout(
							function():void
							{source = value }, 1);
					} else {
						source = ExternalBitmapData.getUniqueInstance(value as String, _loadingLocation);
					}
					return;
				}
				target = new cls();
			}
			else
			{
				_internalDO  = null;
				if (sprite.numChildren) sprite.removeChildAt(0);
				invalidated = true;
				if (oldValue!=null)	initChange("source", oldValue, null, this);
				return;
			}
		
			if( target != null)
			{
				swapInContent(target as DisplayObject)
				invalidated = true;
				initChange("source", oldValue, _internalDO, this);
			}
		
		
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle {
			return commandStack.bounds;
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
					if (isNaN(_width)) _width = _contentWidth;
					if (isNaN(_height)) _height = _contentHeight;
					

						tempLayoutRect.width = _width 
						tempLayoutRect.height = _height
						tempLayoutRect.x =_x?_x: _x=0;
						tempLayoutRect.y =_y?_y: _y=0;;


			 		super.calculateLayout(tempLayoutRect);	
			 		
			 		_layoutRectangle = _layoutConstraint.layoutRectangle.isEmpty()? tempLayoutRect: _layoutConstraint.layoutRectangle;
					_layoutMode = "scale";

					invalidated = true;

					}
			 	} else {
					//size into regular settings
					_transformBeforeRender = false;
					if (isNaN(_width)) _width = _contentWidth;
					if (isNaN(_height)) _height = _contentHeight;
					_internalDO.x = x;
					_internalDO.y = y

					if (_width !=_contentWidth) _internalDO.scaleX = _width / _contentWidth;
					if (_height != _contentHeight) _internalDO.scaleY = _height / _contentHeight;

					invalidated = true;
				}
	
		}
		
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void {

				if(invalidated){
				
				commandStack.length=0;
				//frame it in a rectangle to permit transforms 
				//(whether this is used or not will depend on the 
				//transformBeforeRender setting
				commandStack.addMoveTo(x, y);
				commandStack.addLineTo(x+_width, y);
				commandStack.addLineTo(x+_width, y+_height);
				commandStack.addLineTo(x, y + _height);
				commandStack.addLineTo(x, y);
				invalidated = false;
			}
           


		}
		
		
		private var _layoutMode:String = "scale";

		/**
		 * The layout mode associated with this IDisplayObjectProxy. For an image this is always scale only.
		 */
		public function get layoutMode():String {
			return _layoutMode;
		}
		
		
		private var _transformBeforeRender:Boolean;
		/**
		 * A setting to determine at what point transforms are performed when capturing the bitmap representation of this object internally
		 * before final rendering. Unless otherwise needed, the default setting of false uses less memory.
		 */
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		public function get transformBeforeRender():Boolean {
			return Boolean(_transformBeforeRender);
		}
		public function set transformBeforeRender(value:Boolean):void {
			if (_transformBeforeRender != value) {
				_transformBeforeRender = value;
			}
		}
		
		/**
		* Begins the draw phase for geometry/IDisplayObjectProxy objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
    	override public function draw(graphics:Graphics, rc:Rectangle):void {
			if (!_internalDO || _internalDO.getBounds(_internalDO).isEmpty()) return;
			//init the layout in this case done after predraw.
			 calculateLayout();
			
			if (invalidated) preDraw();
	
			super.draw(graphics, rc?rc:bounds);

    	}
    			
    	
    	
    		
	}
}