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
// Based on Adobe Code
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states
{
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Geometry;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("AddChild.png")]
	
	[DefaultProperty("target")]
	public class AddChild implements IOverride
	{
		public var relativeTo:IDegrafaStateClient;
		public var target:IDegrafaStateClient;
		
		public var position:String;
		
		private var _added:Boolean;
		
		public function AddChild(relativeTo:IDegrafaStateClient = null, target:IDegrafaStateClient = null, position:String = "lastChild")
		{
			this.relativeTo = relativeTo;
        	this.target = target;
        	this.position = position;
		}

		public function initialize():void {}
		
		public function apply(parent:IDegrafaStateClient):void
		{
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			_added = false;
			
			switch (position)
	        {
	            
	            case "before":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry,
	                    obj.geometryCollection.getItemIndex(obj as IGeometry));
	                break;
	            }
	
	            case "after":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry,
	                    obj.geometryCollection.getItemIndex(obj  as IGeometry) + 1);
	                break;
	            }
	
	            case "firstChild":
	            {
	                obj.geometryCollection.addItemAt(target as IGeometry, 0);
	                break;
	            }
	
	            case "lastChild":
	            default:
	            {
	                obj.geometryCollection.addItem(target as IGeometry);
	            }
	        }
	
	        _added = true;
	        	        
	        var tempGeometry:Array=[] 
	        tempGeometry = tempGeometry.concat(obj.geometryCollection.items);
	        obj.geometry = tempGeometry;
	        
	        
		}
		
		public function remove(parent:IDegrafaStateClient):void
		{
			var obj:IDegrafaStateClient = relativeTo ? relativeTo : parent;
			
			parent.geometryCollection.removeItem(target  as IGeometry);
		}
	}
}