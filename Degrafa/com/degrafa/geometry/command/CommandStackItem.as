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
package com.degrafa.geometry.command{
	
	import flash.net.registerClassAlias;
	
	public class CommandStackItem{
		
		public static const MOVE_TO:String="m";
		public static const LINE_TO:String="l";
		public static const CURVE_TO:String="c";
		public static const DELEGATE_TO:String="d";
		
		public function CommandStackItem(type:String="",x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN,cx:Number=NaN,cy:Number=NaN,ox:Number=NaN,oy:Number=NaN){
			this.type = type;
			
			this.x=x;
			this.y=y;
			this.x1=x1;
			this.y1=y1;
			this.cx=cx;
			this.cy=cy;
			this.ox=ox;
			this.oy=oy;
			
			registerClassAlias("com.degrafa.geometry.command.CommandStackItem", CommandStackItem);
			
		}
				
		public var type:String;
		public var id:String;
		public var reference:String;
		
		//Line or move to
		public var x:Number;
		public var y:Number;
		
		//curve only
		public var x1:Number;
		public var y1:Number;
		public var cx:Number;
		public var cy:Number;
		
		// Origin points 
		public var ox:Number;
		public var oy:Number;
		
		// Funciton used in a DELEGATE_TO command
		public var delegate:Function;
	}
}