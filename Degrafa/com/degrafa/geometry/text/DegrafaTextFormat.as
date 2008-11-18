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
package com.degrafa.geometry.text{
	
	import com.degrafa.core.DegrafaObject;
	
	import flash.text.TextFormat;
	
	[Bindable]
	/**
	* DegrafaTextFormat is a convenience object for defining reusable textformat data
	* for use with RasterText. It can be defined in mxml and bound to.
	**/
	public class DegrafaTextFormat extends DegrafaObject{
		
		public var textFormat:TextFormat;
		
		public function DegrafaTextFormat(){
			textFormat = new TextFormat();
		}
		
		/**
		* The name of the font for text in this text format, as a string.
		* 
		* @see flash.text.TextFormat 
		**/
		public function set font(value:String):void {
			if (textFormat.font != value) {
				textFormat.font=value;
			}
		}
		public function get font():String{
			return textFormat.font;
		}
		
		
		/**
		* Indicates the color of the text. If a fill is assigned, then it will override this setting.
		* 
		* @see flash.text.TextFormat 
		**/
		public function set color(value:uint):void {
			if (textFormat.color != value) {
				textFormat.color = value;
			}
		}
		public  function get color():uint{
			return textFormat.color as uint;
		}
		
		/**
		* Indicates the alignment of the paragraph. Valid values are TextFormatAlign constants.
		* 
		* @see flash.text.TextFormat
		**/
		[Inspectable(category="General", enumeration="center,justify,left,right", defaultValue="left")]
		public function set align(value:String):void{
			textFormat.align = value;
		}
		public function get align():String{
			return textFormat.align;
		}
		
		/**
		* Indicates the block indentation in pixels.
		* 
		* @see flash.text.TextFormat
		**/
		public function set blockIndent(value:Object):void{
			textFormat.blockIndent = value;
		}
		public function get blockIndent():Object{
			return textFormat.blockIndent;
		}
		
		/**
		* Specifies whether the text is boldface.
		* 
		* @see flash.text.TextFormat
		**/
		private var _bold:Boolean;
		[Inspectable(category="General", enumeration="true,false")]
		public function set bold(value:Boolean):void{
			textFormat.bold = value;
		}
		public function get bold():Boolean{
			return textFormat.bold;
		}
		
		/**
		* Indicates that the text is part of a bulleted list.
		* 
		* @see flash.text.TextFormat
		**/
		public function set bullet(value:Object):void{
			textFormat.bullet = value;
		}
		public function get bullet():Object{
			return textFormat.bullet;
		}
		
		/**
		* Indicates the indentation from the left margin to the first character in the paragraph.
		* 
		* @see flash.text.TextFormat
		**/
		public function set indent(value:Object):void{
			textFormat.indent = value;
		}
		public function get indent():Object{
			return textFormat.indent;
		}

		/**
		* Indicates whether text in this text format is italicized.
		* 
		* @see flash.text.TextFormat
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function set italic(value:Boolean):void{
			textFormat.italic = value;
		}
		public function get italic():Boolean{
			return textFormat.italic;
		}
		
		/**
		* A Boolean value that indicates whether kerning is enabled (true) or disabled (false). 
		* 
		* @see flash.text.TextFormat
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function set kerning(value:Boolean):void{
			textFormat.kerning = value;
		}
		public function get kerning():Boolean{
			return textFormat.kerning;
		}
		
		/**
		* An integer representing the amount of vertical space (called leading) between lines. 
		* 
		* @see flash.text.TextFormat
		**/
		public function set leading(value:Object):void{
			textFormat.leading = value;
		}
		public function get leading():Object{
			return textFormat.leading;
		}
		
		/**
		* The left margin of the paragraph, in pixels. 
		* 
		* @see flash.text.TextFormat
		**/
		public function set leftMargin(value:Object):void{
			textFormat.leftMargin = value;
		}
		public function get leftMargin():Object{
			return textFormat.leftMargin;
		}
		
		/**
		* A number representing the amount of space that is uniformly distributed between all characters.
		* 
		* @see flash.text.TextFormat
		**/
		public function set letterSpacing(value:Object):void{
			textFormat.letterSpacing = value;
		}
		public function get letterSpacing():Object{
			return textFormat.letterSpacing;
		}
		
		/**
		* The right margin of the paragraph, in pixels. 
		* 
		* @see flash.text.TextFormat
		**/
		public function set rightMargin(value:Object):void{
			textFormat.rightMargin = value;
		}
		public function get rightMargin():Object{
			return textFormat.rightMargin;
		}
		
		
		/**
		* The point size of text in this text format. 
		* 
		* @see flash.text.TextFormat
		**/
		public function set size(value:Object):void{
			textFormat.size = value;
		}
		public function get size():Object{
			return textFormat.size;
		}
		
		
		/**
		* Specifies custom tab stops as an array of non-negative integers. 
		* 
		* @see flash.text.TextFormat
		**/
		public function set tabStops(value:Array):void{
			textFormat.tabStops = value;
		}
		public function get tabStops():Array{
			return textFormat.tabStops;
		}
		
		/**
		* Indicates whether the text that uses this text format is underlined (true) or not (false). 
		* 
		* @see flash.text.TextFormat
		**/
		[Inspectable(category="General", enumeration="true,false")]
		public function set underline(value:Boolean):void{
			textFormat.underline = value;
		}
		public function get underline():Boolean{
			return textFormat.underline;
		}
		
	}
}