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

package com.degrafa
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	* GraphicText extends TextField and enables support for text fields 
	* to be added to compositions.
	* 
	* @see flash.text.TextField
	**/
	public class GraphicTextPlus extends GraphicText 
	{
		public function GraphicTextPlus()
		{
			super();
			addEventListener(Event.RENDER, renderHandler);
			addEventListener(Event.INIT, initHandler);
		}

		/**
		* The render handler is used to enable runtime resizing/alignment
		* @private 
		**/	
		private function renderHandler(event:Event):void {
	        realign();
	    }
	    
		/**
		* The init handler is used to enable runtime resizing/alignment
		* @private 
		**/	
		private function initHandler(event:Event):void {
	        realign();
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

		/**
		* draw is required for the IGeometry interface and has no effect here.
		* @private  
		**/	
		
		public override function draw(graphics:Graphics,rc:Rectangle):void{
			realign();
			super.draw(graphics,rc);
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