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
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.utils.ColorUtil;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.display.IDisplayObjectProxy;
	import com.degrafa.geometry.text.DegrafaTextFormat;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.PropertyChangeEvent;
	
	[Exclude(name = "data", kind = "property")]

		 
	[Bindable(event = "propertyChange")]
	
	/**
 	*  The RasterText element permits rendering Text as part of a composition or drawing to an arbitrary
	*  graphics target.
 	* 
 	*  <p>RasterText represents a bitmap copy of text content that can be part of a geometry composition
	*  with behavior similar to a regular geometry object. It provides a simple way to include Text based
	*  content within compositions rendered to an arbitrary graphics context.</p>   
 	**/
	public class RasterTextPlus extends Geometry implements IDisplayObjectProxy{
		
		//Store the textField internally so that properties are proxied
		protected var textField:TextField = new TextField();
		
		protected var sprite:Sprite = new Sprite();
		protected var internalMaskee:Shape;
		protected var internalbackground:Shape=new Shape();
		
		static public const ADJUST:String = "adjust";
		static public const SCALE:String = "scale";
		
		protected var _embedded:Boolean;
		/**
		 * <p>The RasterText constructor has no arguments . RasterText does not inherit stroke by default unlike other Geometry items.</p>
		 */
		public function RasterTextPlus(){
			super();
			//by default do not inherit stroke. 
			inheritStroke = false;
			inheritFill = false;
			//this is a dynamic only type text Field non 
			//editable and no mouse events as it is just 
			//rendered only and not added to the dispaly list.
			
			textField.selectable = false;
			textField.mouseEnabled = false;
			//though heavy handed this is required to get around 
			//a bug when copying the bitmapdata.
			sprite.addChild(internalbackground);
			sprite.addChild(textField);
		}
		
		/**
		* Data is required for the IGeometry interface and has no effect here.
		* @private 
		**/	
		override public function get data():Object{return null;}
		override public function set data(value:Object):void{}
		
		/**
		 * Internal function to update the textfield based on settings
		 * @private 
		 */
		private function updateTextField():void {
	
			if (fill is SolidFill) { 
				textField.textColor = uint(SolidFill(fill).color);
			}
			else 
				{
				textField.textColor = 0;
			}
			
			//simple for now: re-apply any formatting changes to the whole text content
			textField.text = textField.text;

			if(autoSizeField){
				textField.width = textField.textWidth + 4;
				textField.height = textField.textHeight + 4;
				_width = textField.width;
				_height = textField.height;
				realign();
			}
		}
		
		
		private var _autoSizeField:Boolean=true;
		/**
		* Autosize the text field to text size. When set to true the 
		* TextField object will size to fit the height and width of 
		* the text. If layout is active on this object and its layoutMode is set to "adjust", then this
		* setting will be overridden by the layout constraints. If layoutMode is set to "scale" then layout scaling will be applied after
		* the textfield has been autosized to its contents.
		**/

		[Inspectable(category="General", enumeration="true,false")]
		public function get autoSizeField():Boolean{
			return _autoSizeField;
		}
		public function set autoSizeField(value:Boolean):void {
			if (value!=_autoSizeField){
				_autoSizeField = value;
				invalidated = true;
				initChange('autoSizeField', !_autoSizeField, _autoSizeField, this);
			}
		}
		private static var _fontList:Array;
		/**
		 * Utility function for checking fonts
		 */
		public static function get availableEmbeddedFonts():Array {
			if (!_fontList) _fontList = [];
			_fontList = Font.enumerateFonts();
			for (var i:uint = 0; i < _fontList.length; i++) _fontList[i] = _fontList[i].fontName;
			_fontList.sort();
			return _fontList;			
		}
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the text element. If not specified 
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
		* The y-axis coordinate of the upper left point of the text element. If not specified 
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
		* The width of the text element. This may change depending on autoSizeField settings (true) and/or layoutMode settings (adjust).
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
		* The height of the text element. This may change depending on autoSizeField settings (true) and/or layoutMode settings (adjust).
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
		* Initialise the stroke/border for this RasterText object. Typically only called by draw 
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		override public function initStroke(graphics:Graphics, rc:Rectangle):void {
				
			if (border) {
				super.initStroke(graphics, rc);
			}
			else{
				graphics.lineStyle();
			}
		}
		
		/**
		* Initialise the fill for RasterText. This overrides Geometry to implement a specific combination
		* for RasterText.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		override public function initFill(graphics:Graphics, rc:Rectangle):void {
			if (background && _backgroundFill ) {
				internalbackground.graphics.clear();
	TARGET::FLEX3  {_backgroundFill.begin(internalbackground.graphics, rc);}
	TARGET::FLEX4  {_backgroundFill.begin(internalbackground.graphics,rc,zeroOrigin);}
				internalbackground.graphics.drawRect(rc.x, rc.y, rc.width, rc.height);
			}
			if (!(_fill is SolidFill)) {
				if (!internalMaskee) {
					internalMaskee = new Shape();
					sprite.addChild(internalMaskee)
				}
				internalMaskee.graphics.clear();
				super.initFill(internalMaskee.graphics, rc);
				var cacheLayout:Matrix = CommandStack.currentLayoutMatrix.clone();
				var cacheTrans:Matrix = CommandStack.currentTransformMatrix.clone();
				commandStack.simpleRender(internalMaskee.graphics, rc);

				if (CommandStack.currentTransformMatrix) {
					cacheTrans.invert()
					internalMaskee.transform.matrix = cacheTrans;
				}
				else internalMaskee.transform.matrix.identity();// = new Matrix();
				internalMaskee.cacheAsBitmap = true;
				//dev note: consider applying a slight blur to device fonts for 'Antialiasing'
			//	if (availableEmbeddedFonts.indexOf(_fontFamily) == -1) {
			///		textField.filters = [new BlurFilter(2,2,3)];
			//	}
				textField.cacheAsBitmap = true;
				internalMaskee.mask = textField;
			} else {
				if (internalMaskee) {
					internalMaskee.graphics.clear();
					textField.cacheAsBitmap = false;
					internalMaskee.cacheAsBitmap = false;
					internalMaskee.mask = null;
				}
			
			}
	
		}
		
		/**
		* Returns this objects bitmapdata.
		**/
		public function get displayObject():DisplayObject{
			
			if (!textField.textWidth || !textField.textHeight){
				return null;
			} 

			//for now just return the textField
			return sprite;

		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle {
			return commandStack.bounds;
		}
		
		private var _layoutinited:Boolean;
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used or the most appropriate size is calculated. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated) {
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
				
					if(_width){
			 			tempLayoutRect.width = _width;
			 		}
			 		else{
			 			tempLayoutRect.width = textField.width?textField.width:1;
			 		}
					
					if(_height){
			 			tempLayoutRect.height = _height;
			 		}
			 		else{
			 			tempLayoutRect.height = textField.height?textField.height:1;
			 		}
			 		
			 		if(_x){
			 			tempLayoutRect.x = _x;
			 		}
			 		
			 		if(_y){
			 			tempLayoutRect.y = _y;
			 		}

			 		super.calculateLayout(tempLayoutRect);	
			 		_layoutRectangle = _layoutConstraint.layoutRectangle;
					
						
					if (isNaN(_width) || isNaN(_height) || layoutMode == "adjust") {
						
						_x=textField.x=layoutRectangle.x ;
						_y=textField.y=layoutRectangle.y ;
						_width=textField.width=layoutRectangle.width;
						_height=textField.height=layoutRectangle.height ;
					
						if (!_transformBeforeRender) {
						//make commandstack outline at layoutrectangle pixelbounds
							_width = _layoutRectangle.width=Math.ceil(_layoutRectangle.width+(_layoutRectangle.x-(_x = _layoutRectangle.x=Math.floor(_layoutRectangle.x))));
							_height = _layoutRectangle.height=Math.ceil(_layoutRectangle.height+(_layoutRectangle.y-(_y = _layoutRectangle.y=Math.floor(_layoutRectangle.y))));
						} 
					}else {
						if (layoutMode == "scale" ) {
							_width = _layoutRectangle.width=Math.ceil(_layoutRectangle.width+(_layoutRectangle.x-(_x = _layoutRectangle.x=Math.floor(_layoutRectangle.x))));
							_height = _layoutRectangle.height=Math.ceil(_layoutRectangle.height+(_layoutRectangle.y-(_y = _layoutRectangle.y=Math.floor(_layoutRectangle.y))));
				
						//dev note: under development
						}
			 	}
					invalidated = true;
		
				}
			} else {
					//size into regular settings
					_transformBeforeRender = false;
					if (isNaN(_width)) {
						updateTextField();
						_width = textField.width }
					else {
						//fixed width setting
					if (!_autoSizeField && !_layoutinited )	{
						textField.width = width;
					}

					}
					if (isNaN(_height)) {
						updateTextField();
						_height = textField.height;
					} else {
						if (!_autoSizeField && !_layoutinited)	textField.height = height;
					}
					textField.x = x;
					textField.y = y
				
					invalidated = true;	
					_layoutinited = true;
				}
		}
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void {
				if(invalidated){
				
				commandStack.length=0;
				//frame it in a rectangle to permit transforms via 
				//commandStack (whether this is used or not will 
				//depend on the transformBeforeRender setting
				commandStack.addMoveTo(x, y);
				commandStack.addLineTo(x+width, y);
				commandStack.addLineTo(x+width, y+height);
				commandStack.addLineTo(x, y + height);
				commandStack.addLineTo(x, y);
				invalidated = false;
			}
		}
		
		private var _layoutMode:String = "adjust";

		/**
		 * The layout mode associated with this RasterText. Currently fixed at 'adjust' which means
		 * that layout adjusts the size of the text field instead of scaling it. A 'scale' option will be available
		 * in a future release.
		 */
		[Inspectable(category="General", enumeration="adjust,scale")]
		public function get layoutMode():String {
			return _layoutMode;
		}
		public function set layoutMode(value:String):void {
			if (_layoutMode != value && (['adjust','scale']).indexOf(value)!=-1) {
				initChange('layoutMode',_layoutMode,_layoutMode=value,this)
			}
		}

		private var _transformBeforeRender:Boolean;

		/**
		 * A setting to determine at what point transforms are performed when capturing the bitmap representation of this object internally
		 * before final rendering. This is currently fixed as false for RasterText. A true option may be made available in a future release.
		 */
		public function get transformBeforeRender():Boolean {
			return Boolean(_transformBeforeRender);
		}
		
		/**
		* Begins the draw phase for geometry/IDisplayObjectProxy objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
    	override public function draw(graphics:Graphics, rc:Rectangle):void {
	
			if (invalidated) updateTextField();
    		calculateLayout();
			preDraw()
			super.draw(graphics, (rc)? rc:bounds);		
    	}
    			
    	
    	/** NOTE :: Need to add the complete list or format properties.
		* Below are the TextField text Format proxied properties. Any changes here 
		* will update the public textFormat and set the textfield defaultTextFormat 
		* to the textformat. 
		*/ 
		
		/**
		* Text format.
		* 
		* @see flash.text.TextFormat
		**/
		private var _textFormat:DegrafaTextFormat;
		public function get textFormat():DegrafaTextFormat {
			if(!_textFormat){
				textFormat = new DegrafaTextFormat();
			}
			return _textFormat;
		}
		
		public function set textFormat(value:DegrafaTextFormat):void {
			if (_textFormat != value) {
				
			if(_textFormat){
					if(_textFormat.hasEventManager){
						_textFormat.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
			if(enableEvents){	
				value.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler, false, 0, true);
			}
				textField.defaultTextFormat = value.textFormat;
				invalidated = true;
				initChange('textFormat',_textFormat,_textFormat = value,this)
			}
		}

		
		override protected function propertyChangeHandler(event:PropertyChangeEvent):void{

		if (_textFormat)	textField.defaultTextFormat = _textFormat.textFormat;	
	
			invalidated = true;
			//carry on to the super.
			super.propertyChangeHandler(event);
			
		}
		
		/**
		* The name of the font for text in this text format, as a string. If the font is a registered embedded font, then embedFonts is 
		* automatically set to true, otherwise to false.
		* 
		* @see flash.text.TextFormat 
		**/
		private var _fontFamily:String="_sans";
		public function set fontFamily(value:String):void {
			if (textFormat.font!=_fontFamily){
				
				if (availableEmbeddedFonts.indexOf(value)!=-1) {
					textField.embedFonts = true;
				}
				else {
					textField.embedFonts = false;
				}
				_embedded = textField.embedFonts;
				_fontFamily = value;
				textFormat.font = _fontFamily;
				textField.defaultTextFormat = _textFormat.textFormat;
			//	invalidated = true;
			}
			
		}
		
		public function get fontFamily():String{
			return _fontFamily;
		}
		
	
		
		
		private var _fontSize:Number;  
    	/**
		* The point size of text in this text format.
		* 
		* @see flash.text.TextFormat
		**/
		public function set fontSize(value:Number):void{
			_fontSize = value;
			textFormat.size = _fontSize;
			//Adobe recommendations in livedocs:
			textField.antiAliasType = (_fontSize > 48)? AntiAliasType.NORMAL:AntiAliasType.ADVANCED;

			if (textField.antiAliasType == AntiAliasType.ADVANCED) textField.gridFitType = GridFitType.PIXEL;
						
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get fontSize():Number{
			return _fontSize;
		}
		
		/**
		* Specifies whether the text is normal or boldface.
		* 
		* @see flash.text.TextFormat
		**/
		private var _fontWeight:String="normal";
		[Inspectable(category="General", enumeration="normal,bold", defaultValue="normal")]
		public function set fontWeight(value:String):void{
			_fontWeight = value;
			textFormat.bold = _bold = (_fontWeight == "bold") ? true: false;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get fontWeight():String{
			return _fontWeight;
		}
		
		
		/**
		* Indicates the alignment of the paragraph. Valid values are TextFormatAlign constants.
		* 
		* @see flash.text.TextFormat
		**/
		private var _align:String="left";
		[Inspectable(category="General", enumeration="center,justify,left,right", defaultValue="left")]
		public function set align(value:String):void{
			_align = value;
			textFormat.align = _align;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get align():String{
			return _align;
		}
		
		/**
		* Indicates the block indentation in pixels.
		* 
		* @see flash.text.TextFormat
		**/
		private var _blockIndent:Object;
		public function set blockIndent(value:Object):void{
			_blockIndent = value;
			textFormat.blockIndent = _blockIndent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get blockIndent():Object{
			return _blockIndent;
		}
		
		/**
		* Specifies whether the text is boldface.
		* 
		* @see flash.text.TextFormat
		**/
		private var _bold:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function set bold(value:Boolean):void{
			_bold = value;
			textFormat.bold = _bold;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get bold():Boolean{
			return _bold;
		}
		
		/**
		* Indicates that the text is part of a bulleted list.
		* 
		* @see flash.text.TextFormat
		**/
		private var _bullet:Object;
		public function set bullet(value:Object):void{
			_bullet = value;
			textFormat.bullet = _bullet;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get bullet():Object{
			return _bullet;
		}
		
		/**
		* Indicates the indentation from the left margin to the first character in the paragraph.
		* 
		* @see flash.text.TextFormat
		**/
		private var _indent:Object;
		public function set indent(value:Object):void {
			_indent = value;
			textFormat.indent = _indent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get indent():Object{
			return _indent;
		}

		/**
		* Indicates whether text in this text format is italicized.
		* 
		* @see flash.text.TextFormat
		**/
		private var _italic:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function set italic(value:Boolean):void{
			_italic = value;
			textFormat.italic = _italic;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get italic():Boolean{
			return _italic;
		}
		
		/**
		* A Boolean value that indicates whether kerning is enabled (true) or disabled (false). 
		* 
		* @see flash.text.TextFormat
		**/
		private var _kerning:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function set kerning(value:Boolean):void{
			_kerning = value;
			textFormat.kerning = _indent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get kerning():Boolean{
			return _kerning;
		}
		
		/**
		* An integer representing the amount of vertical space (called leading) between lines. 
		* 
		* @see flash.text.TextFormat
		**/
		private var _leading:int;
		public function set leading(value:int):void{
			_leading = value;
			textFormat.leading = _leading;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get leading():int{
			return _leading;
		}
		
		/**
		* The left margin of the paragraph, in pixels. 
		* 
		* @see flash.text.TextFormat
		**/
		private var _leftMargin:Number;
		public function set leftMargin(value:Number):void{
			_leftMargin = value;
			textFormat.leftMargin = _leftMargin;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get leftMargin():Number{
			return _leftMargin;
		}
		
		/**
		* A number representing the amount of space that is uniformly distributed between all characters.
		* 
		* @see flash.text.TextFormat
		**/
		private var _letterSpacing:Number;
		public function set letterSpacing(value:Number):void{
			_letterSpacing = value;
			textFormat.letterSpacing = _letterSpacing;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get letterSpacing():Number{
			return _letterSpacing;
		}
		
		/**
		* The right margin of the paragraph, in pixels. 
		* 
		* @see flash.text.TextFormat
		**/
		private var _rightMargin:Number;
		public function set rightMargin(value:Number):void{
			_rightMargin = value;
			textFormat.rightMargin = _rightMargin;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get rightMargin():Number{
			return _rightMargin;
		}
		
		
		/**
		* The point size of text in this text format. 
		* 
		* @see flash.text.TextFormat
		**/
		private var _size:Number;
		public function set size(value:Number):void {
			if (textFormat.size!=value){
			textFormat.size = _fontSize = value;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
			_size = value;
			}
		}
		public function get size():Number{
			return _size;
		}
		
		
		/**
		* Specifies custom tab stops as an array of non-negative integers. 
		* 
		* @see flash.text.TextFormat
		**/
		private var _tabStops:Array;
		public function set tabStops(value:Array):void{
			_tabStops = value;
			textFormat.tabStops = _tabStops;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get tabStops():Array{
			return _tabStops;
		}
		
		/**
		* Indicates whether the text that uses this text format is underlined (true) or not (false). 
		* 
		* @see flash.text.TextFormat
		**/
		private var _underline:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function set underline(value:Boolean):void{
			_underline = value;
			textFormat.underline = _underline;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidated = true;
		}
		public function get underline():Boolean{
			return _underline;
		}
		
		
		/**
		* accessibilityProperties property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get accessibilityProperties():AccessibilityProperties {
			return textField.accessibilityProperties;
		}
		public function set accessibilityProperties(value:AccessibilityProperties):void {
			if (value!=textField.accessibilityProperties)
			initChange("accessibilityProperties", textField.accessibilityProperties, textField.accessibilityProperties = value, this);
		}
		/**
		* alpha property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		override public function get alpha():Number{
			return textField.alpha;
		} 
    	override public function set alpha(value:Number):void {
			if (value!=textField.alpha)
			initChange("alpha", textField.alpha, textField.alpha = value, this);
    	}
    	/**
		* antiAliasType property for the textField. 
		* 
		* @see flash.text.TextField
		**/
    	[Inspectable(category="General", enumeration="normal,advanced", defaultValue="normal")]
		public function get antiAliasType():String {
			return textField.antiAliasType;
		}
   	 	public function set antiAliasType(value:String):void {
			if (value!=textField.antiAliasType)
			initChange("antiAliasType", textField.antiAliasType, textField.antiAliasType = value, this);
   	 	} 
    	/**
		* autoSize property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="none,left,right,center", defaultValue="none")]
		public function get autoSize():String{
			return textField.autoSize;
		} 
    	public function set autoSize(value:String):void {
			if (value!=textField.autoSize)
			initChange("autoSize", textField.autoSize, textField.autoSize = value, this);
    	}
		
		
		
		private var _backgroundFill:IGraphicsFill;
		/**
		* A Degrafa Fill used in the background of this RasterText area.
		* 
		**/
		public function get backgroundFill():IGraphicsFill{
			return _backgroundFill;
		} 
    	public function set backgroundFill(value:IGraphicsFill):void {
			if (value != _backgroundFill) {
				if (_backgroundFill) _backgroundFill.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler);
				value.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler);
				initChange("backgroundFill", _backgroundFill, _backgroundFill = value, this);
			}
    	} 
		
		private var _background:Boolean;
		/**
		* background property for the textField. Activates the backgroundFill.
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get background():Boolean{
			return _background;
		} 
    	public function set background(value:Boolean):void {
			if (value!=_background)
			initChange("background", _background, _background = value, this);
    	} 
		
		/**
		* Similar to backgroundColor property for the textField. A shortcut setting for backgroundFill's color property. If used, and a non-SolidFill (e.g gradientFill) is currently being
		* used as a backgroundFill, then this will force creation of a new SolidFill in its place.
		* 
		* @see flash.text.TextField
		**/
		public function get backgroundColor():Object{
			return (_backgroundFill is SolidFill)? (_backgroundFill as SolidFill).color:null;
		} 
   		public function set backgroundColor(value:Object):void {
			if (_backgroundFill is SolidFill) (_backgroundFill as SolidFill).color = value;
			else { backgroundFill = new SolidFill(value, 1) };
	
   		} 
		
		
		private var _border:Boolean;
		/**
		* border property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get border():Boolean{
			return _border;
		} 
	    public function set border(value:Boolean):void {
			if (value!=_border)
			initChange("border", _border, _border = value, this);
	    }
		/**
		* borderColor property for the textField. This property has additional support for extended Degrafa color specifications, for example "red" as a color key.
		* 
		* @see flash.text.TextField
		**/
		public function get borderColor():Object{
			return textField.borderColor;
		} 
    	public function set borderColor(value:Object):void {
			
			var newval:uint = ColorUtil.resolveColor(value);
			if (stroke is SolidStroke) SolidStroke(stroke).color = value;
			else stroke = new SolidStroke(value, 1, 0);
			
		//	if (newval!=textField.borderColor)
		//	initChange("borderColor", textField.borderColor, textField.borderColor = newval, this);
    	}
		/**
		* condenseWhite property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get condenseWhite():Boolean{
			return textField.condenseWhite;
		} 
	    public function set condenseWhite(value:Boolean):void {
			if (value!=textField.condenseWhite)
			initChange("condenseWhite", textField.condenseWhite, textField.condenseWhite = value, this);
	    } 
		
		//either made private and the formazt options moved to this class(align etc.. or 
		//create a textFormat class that is bindable.
		private function get defaultTextFormat():TextFormat{
			return textField.defaultTextFormat
		} 
    	private function set defaultTextFormat(value:TextFormat):void {
			if (value!=textField.defaultTextFormat)
			initChange("defaultTextFormat", textField.defaultTextFormat, textField.defaultTextFormat = value, this);
    	}
    	/**
		* embedFonts property for the textField. setting the fontFamily can also change this setting in RasterText.
		* 
		* @see flash.text.TextField
		**/
    	[Inspectable(category="General", enumeration="true,false")]
    	public function get embedFonts():Boolean{
    		return textField.embedFonts;
    	}
    	public function set embedFonts(value:Boolean):void {
			if (value!=textField.embedFonts)
			initChange("embedFonts", textField.embedFonts, textField.embedFonts = value, this);
    	}
        /**
		* gridFitType property for the textField. 
		* 
		* @see flash.text.TextField
		**/
    	[Inspectable(category="General", enumeration="none,pixel,subpixel", defaultValue="none")]
	    public function get gridFitType():String{
	    	return textField.gridFitType;
	    } 
    	public function set gridFitType(value:String):void {
			if (value!=textField.gridFitType)
			initChange("gridFitType", textField.gridFitType, textField.gridFitType = value, this);
    	} 
        /**
		* htmlText property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get htmlText():String{
			return textField.htmlText;
		} 
    	public function set htmlText(value:String):void {
			if (value!=textField.htmlText)
			initChange("htmlText", textField.htmlText, textField.htmlText = value, this);
    	}
        /**
		* length property for the textField. 
		* 
		* @see flash.text.TextField
		**/   
		public function get length():int{
			return textField.length;
		} 
		/**
		* multiline property for the textField. 
		* 
		* @see flash.text.TextField
		**/   
		[Inspectable(category="General", enumeration="true,false")]
    	public function get multiline():Boolean{
    		return textField.multiline;
    	} 
    	public function set multiline(value:Boolean):void {
			if (value!=textField.multiline)
			initChange("multiline", textField.multiline, textField.multiline = value, this);
    	} 
		/**
		* numLines property for the textField. 
		* 
		* @see flash.text.TextField
		**/  
		public function get numLines():int{
			return textField.numLines;
		} 
		/**
		* sharpness property for the textField. 
		* 
		* @see flash.text.TextField
		**/  
		public function get sharpness():Number{
			return textField.sharpness;
		} 
    	public function set sharpness(value:Number):void {
			if (value!=textField.sharpness)
			initChange("sharpness", textField.sharpness, textField.sharpness = value, this);
    	} 
		/**
		* styleSheet property for the textField. 
		* 
		* @see flash.text.TextField
		**/  
		public function get styleSheet():StyleSheet{
			return textField.styleSheet;
		} 
    	public function set styleSheet(value:StyleSheet):void {
			if (value != textField.styleSheet) {
				var oldSS:StyleSheet = textField.styleSheet;
				textField.styleSheet = value;
				invalidated = true;
				initChange("styleSheet", oldSS, textField.styleSheet, this);
			}
    	}
    	/**
		* text property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 
		public function get text():String{
			return textField.text;
		} 
   		public function set text(value:String):void {
			if (value != textField.text) {
				var oldVal:String = textField.text;
				textField.text = value;	
				invalidated = true;
				initChange("text",oldVal, textField.text, this);
			}
   		} 

    	/**
		* textColor property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 		
		public function get textColor():uint{
			return (_fill is SolidFill) ? uint((_fill as SolidFill).color):null;// textField.textColor;
		} 
    	public function set textColor(value:uint):void{
			if (!(_fill is SolidFill) || value != uint((_fill as SolidFill).color)) {
				if (_fill is SolidFill) (_fill as SolidFill).color = value;
				else fill = new SolidFill(value, 1);
			//initChange("textColor", textField.textColor, textField.textColor = value, this);
			}
    	} 
    	/**
		* textHeight property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 	
		public function get textWidth():Number{
			return textField.textWidth;
		} 
    	/**
		* thickness property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 		
		public function get thickness():Number{
			return textField.thickness;
		} 
	    public function set thickness(value:Number):void {
			if (value!=textField.thickness && value>=-200 && value<=200)
			initChange("thickness", textField.thickness, textField.thickness = value, this);
	    } 
    	/**
		* wordWrap property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 			
		[Inspectable(category="General", enumeration="true,false")]
		public function get wordWrap():Boolean{
			return textField.wordWrap;
		} 
    	public function set wordWrap(value:Boolean):void {
			if (value!=textField.wordWrap)
			initChange("wordWrap", textField.wordWrap, textField.wordWrap = value, this);
    	} 
    		
		/**
		* Indicates the horizontal alignment of the anchored text object. Valid values are center, left, and right.
		* 
		* @see flash.text.TextFormat
		**/
		private var _halign:String="left";
		[Inspectable(category="General", enumeration="left,center,right", defaultValue="left")]
		public function set halign(value:String):void{
			_halign = value;
			realign();
		}
		public function get halign():String{
			return _halign;
		}
		
		/**
		* Indicates the vertical alignment of the anchored text object. Valid values are center, left, and right.
		* 
		* @see flash.text.TextFormat
		**/
		private var _valign:String="top";
		[Inspectable(category="General", enumeration="top,middle,bottom", defaultValue="top")]
		public function set valign(value:String):void{
			_valign = value;
			realign();
		}
		public function get valign():String{
			return _valign;
		}
						
		/**
		* An integer representing the horizontal anchor point 
		* 
		* @see flash.text.TextFormat
		**/
		private var _anchorx:Number;
		public function set anchorx(value:Number):void{
			_anchorx = value;
			realign();
		}
		public function get anchorx():Number{
			return _anchorx;
		}

		/**
		* An integer representing the vertical anchor point 
		* 
		* @see flash.text.TextFormat
		**/
		private var _anchory:Number;
		public function set anchory(value:Number):void{
			_anchory = value;
			realign();
		}
		public function get anchory():Number{
			return _anchory;
		}

	     public function realign() : void {
        	if(isNaN(anchorx))
        		this.anchorx = x;
        		
        	if(isNaN(anchory))
        		this.anchory = y;
        		
        	if(halign == "left") {
        		this.x = this.anchorx;
        	}
        	if(halign == "center") {
        		this.x = this.anchorx - (this.width / 2);
        	}
        	if(halign == "right") {
        		this.x = this.anchorx - this.width;
        	}
        	if(valign == "top") {
        		this.y = this.anchory;
        	}
        	if(valign == "middle") {
        		this.y = this.anchory - (this.height/ 2);
        	}
        	if(valign == "bottom") {
        		this.y = this.anchory - this.height;
        	}
        } 
	}
}
