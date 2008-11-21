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
	import com.degrafa.geometry.display.IDisplayObjectProxy;
	import com.degrafa.geometry.text.DegrafaTextFormat;
	
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
	[Exclude(name="fill", kind="property")]
		 
	[Bindable(event = "propertyChange")]
	
	/**
 	*  The RasterText element permits rendering Text as part of a composition or drawing to an arbitrary
	*  graphics target.
 	* 
 	*  <p>RasterText represents a bitmap copy of text content that can be part of a geometry composition
	*  with behavior similar to a regular geometry object. It provides a simple way to include Text based
	*  content within compositions rendered to an arbitrary graphics context.</p>   
 	**/
	public class RasterText extends Geometry implements IDisplayObjectProxy{
		
		//Store the textField internally so that properties are proxied
		public var textField:TextField = new TextField()
		
		public var sprite:Sprite = new Sprite();
		
		protected var _embedded:Boolean;
		/**
		 * <p>The RasterText constructor has no arguments . RasterText does not inherit stroke by default unlike other Geometry items.</p>
		 */
		public function RasterText(){
			super();
			//by default do not inherit stroke. 
			inheritStroke = false;
			inheritFill = false;
			//this is a dynamic only type text Field non 
			//editable and no mouse events as it is just 
			//rendered only and not added to the dispaly list.
			
			//Note:: might be worth keeping the old text object as well .. after all and depending.
			
			textField.selectable = false;
			textField.mouseEnabled = false;
			//though heavy handed this is required to get around 
			//a bug when copying the bitmapdata.
			sprite.addChild(textField);
		}
		
		/**
		* Data is required for the IGeometry interface and has no effect here.
		* @private 
		**/	
		override public function get data():String{return "";}
		override public function set data(value:String):void{}
		
		
		/**
		 * This item has no regular fill
		 */
		override public function get fill():IGraphicsFill {	return null };
		override public function set fill(value:IGraphicsFill):void { };
		
		
		/**
		 * Internal function to update the textfield based on settings
		 */
		private function invalidate():void {
			
			//simple for now: re-apply any formatting changes to the whole text content
			textField.text = textField.text;
			if(autoSizeField){
				textField.width = textField.textWidth +4;
				textField.height = textField.textHeight +4;
			}
			invalidated = true;
		}
		
		/**
		* Autosize the text field to text size. When set to true the 
		* TextField object will size to fit the height and width of 
		* the text.
		**/
		private var _autoSizeField:Boolean=true;
		[Inspectable(category="General", enumeration="true,false")]
		public function get autoSizeField():Boolean{
			return _autoSizeField;
		}
		public function set autoSizeField(value:Boolean):void {
			if (value!=_autoSizeField){
				_autoSizeField = value;
				invalidate();
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
		* The width of the text element.
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
		* The height of the text element.
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

		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used or the most appropriate size is calculated. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			invalidate()
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
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

						//dev note: under development
						}
			 	}
					invalidated = true;
		
				}
			} else {
					//size into regular settings
					_transformBeforeRender = false;
					if (isNaN(_width)) {
						invalidate();
						_width = textField.width }
					else {
						//fixed width setting
						textField.width = width;
						_autoSizeField = false;
					}
					if (isNaN(_height)) {
						invalidate();
						_height = textField.height;
					} else {
						textField.height = height;
						_autoSizeField = false;
					}
					textField.x = x;
					textField.y = y

					invalidated = true;
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
		public function get layoutMode():String {
			return _layoutMode;
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
    	override public function draw(graphics:Graphics,rc:Rectangle):void{

    		calculateLayout();
			preDraw()
			super.draw(graphics, rc);
			
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
		private var _textFormat:DegrafaTextFormat=new DegrafaTextFormat();
		public function get textFormat():DegrafaTextFormat{
			return _textFormat;
		}
		public function set textFormat(value:DegrafaTextFormat):void{
			_textFormat = value;
			
			_textFormat.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
						
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
		}
		
		
		
		override protected function propertyChangeHandler(event:PropertyChangeEvent):void{
			
			//update locally
			textField.defaultTextFormat = _textFormat.textFormat;	
			invalidate();		
			
			//carry on to the super.
			super.propertyChangeHandler(event);
			
		}
		
		/**
		* The name of the font for text in this text format, as a string.
		* 
		* @see flash.text.TextFormat 
		**/
		private var _fontFamily:String;
		public function set fontFamily(value:String):void {
			var oldval:String = _fontFamily;
			_fontFamily = value;
			_textFormat.font = _fontFamily;
			if (availableEmbeddedFonts.indexOf(value)!=-1) {
				textField.embedFonts = true;
			}
			else {
				textField.embedFonts = false;
			}
			
			_embedded = textField.embedFonts;
			textField.defaultTextFormat = _textFormat.textFormat;

			invalidate();
		}
		public function get fontFamily():String{
			return _fontFamily;
		}
		
		
		/**
		* Indicates the color of the text. 
		* 
		* @see flash.text.TextFormat 
		**/
		private var _color:uint;
		public function set color(value:uint):void {
			if (_color != value) {
				var oldval:uint = _color;
				_color = value;
				_textFormat.color = _color;
				textField.defaultTextFormat = _textFormat.textFormat;
				invalidate();
			}
		}
		public  function get color():uint{
			return _color;
		}
		  
    	/**
		* The point size of text in this text format.
		* 
		* @see flash.text.TextFormat
		**/
		private var _fontSize:Number;
		public function set fontSize(value:Number):void{
			_fontSize = value;
			_textFormat.size = _fontSize;
			//Adobe recommendations in livedocs:
			textField.antiAliasType = (_fontSize > 48)? AntiAliasType.NORMAL:AntiAliasType.ADVANCED;
			//not sure yet if this helps?
			if (textField.antiAliasType == AntiAliasType.ADVANCED) textField.gridFitType = GridFitType.PIXEL;
						
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.bold = _bold = (_fontWeight == "bold") ? true: false;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.align = _align;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.blockIndent = _blockIndent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.bold = _bold;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.bullet = _bullet;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
		public function set indent(value:Object):void{
			_indent = value;
			_textFormat.indent = _indent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.italic = _italic;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.kerning = _indent;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.leading = _leading;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.leftMargin = _leftMargin;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.letterSpacing = _letterSpacing;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.rightMargin = _rightMargin;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
		public function set size(value:Number):void{
			_size = value;
			_textFormat.size = _fontSize = _size;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.tabStops = _tabStops;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
			_textFormat.underline = _underline;
			textField.defaultTextFormat = _textFormat.textFormat;
			invalidate();
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
		public function set accessibilityProperties(value:AccessibilityProperties):void{
			textField.accessibilityProperties = value;
		}
		/**
		* alpha property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get alpha():Number{
			return textField.alpha;
		} 
    	public function set alpha(value:Number):void{
    		textField.alpha = value;
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
   	 	public function set antiAliasType(value:String):void{
   	 		textField.antiAliasType = value;
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
    	public function set autoSize(value:String):void{
    		textField.autoSize=value;
    	}
		/**
		* background property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get background():Boolean{
			return textField.background;
		} 
    	public function set background(value:Boolean):void{
    		textField.background=value;
    	} 
		
		/**
		* backgroundColor property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get backgroundColor():uint{
			return textField.backgroundColor;
		} 
   		public function set backgroundColor(value:uint):void{
   			textField.backgroundColor = value;
   		} 
		/**
		* border property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function get border():Boolean{
			return textField.border;
		} 
	    public function set border(value:Boolean):void{
	    	textField.border = value;
	    }
		/**
		* borderColor property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get borderColor():uint{
			return textField.borderColor;
		} 
    	public function set borderColor(value:uint):void{
    		textField.borderColor = value;
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
	    public function set condenseWhite(value:Boolean):void{
	    	textField.condenseWhite = value;
	    } 
		
		//either made private and the formazt options moved to this class(align etc.. or 
		//create a textFormat class that is bindable.
		private function get defaultTextFormat():TextFormat{
			return textField.defaultTextFormat
		} 
    	private function set defaultTextFormat(value:TextFormat):void{
    		textField.defaultTextFormat = value;
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
    	public function set embedFonts(value:Boolean):void{
    		textField.embedFonts = value;
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
    	public function set gridFitType(value:String):void{
    		textField.gridFitType = value;
    	} 
        /**
		* htmlText property for the textField. 
		* 
		* @see flash.text.TextField
		**/
		public function get htmlText():String{
			return textField.htmlText;
		} 
    	public function set htmlText(value:String):void{
    		textField.htmlText = value;
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
    	public function set multiline(value:Boolean):void{
    		textField.multiline = true;
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
    	public function set sharpness(value:Number):void{
    		textField.sharpness =value;
    	} 
		/**
		* styleSheet property for the textField. 
		* 
		* @see flash.text.TextField
		**/  
		public function get styleSheet():StyleSheet{
			return textField.styleSheet;
		} 
    	public function set styleSheet(value:StyleSheet):void{
    		textField.styleSheet = value;
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
   			textField.text=value;
   			invalidate();
		
			}
   		} 

    	/**
		* textColor property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 		
		public function get textColor():uint{
			return textField.textColor;
		} 
    	public function set textColor(value:uint):void{
    		textField.textColor = value;
    	} 
    	/**
		* textHeight property for the textField. 
		* 
		* @see flash.text.TextField
		**/ 	
		public function get textHeight():Number{
			return textField.textHeight;
		}	
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
	    public function set thickness(value:Number):void{
	    	textField.thickness = value;
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
    	public function set wordWrap(value:Boolean):void{
    		textField.wordWrap = value;
    	} 
    		
	}
}