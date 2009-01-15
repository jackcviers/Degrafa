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
package  com.degrafa.geometry
{
	import com.degrafa.IGeometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.ITransformablePaint;
	import com.degrafa.events.DegrafaEvent;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;

	/**
	 * Unions child geometries into one large closed path
	 * Note: Child geometries fill and strokes will be ignored
	 */
	public class GeometryUnion extends Geometry implements IGeometry
	{
		public function GeometryUnion()
		{
			super();
		}
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					var tempLayoutRect:Rectangle = new Rectangle(x,y,width,height);
				
					super.calculateLayout(tempLayoutRect);	
					_layoutRectangle = _layoutConstraint.layoutRectangle;
				}
			}
		//	this._layoutRectangle=this.commandStack.bounds;
		}
		
	
		/**
		* Principle event handler for any property changes to a 
		* geometry object or it's child objects.
		**/
		override protected function propertyChangeHandler(event:PropertyChangeEvent):void{
			super.propertyChangeHandler(event);
			invalidated=true;
		}
								
		//override to combine geometry
		override public function preDraw():void{
			
			//predraw each child and grab the command stack adding it to 
			//this command stack one item at time
			//Remove any move to operations that would leave the path open and not filled.
			
			commandStack.source=new Array();
			
			var i:int=0;
			for each (var item:IGeometryComposition in geometry){
				item.preDraw();
				for each (var cmd:CommandStackItem in item.commandStack.source) {
					if (cmd.type !=CommandStackItem.MOVE_TO || i==0) {
						commandStack.addItem(cmd);
					}
					else if (cmd.type==CommandStackItem.MOVE_TO && i > 0) {
						cmd.type=CommandStackItem.LINE_TO;
						commandStack.addItem(cmd);
					}
					i++;
				}

			}
			this.commandStack.invalidated=true;
			var t:Rectangle=this.commandStack.bounds; //Force calc on bounds

		}
		
		
		//may need to do stuff here for the fill side
		override public function initFill(graphics:Graphics,rc:Rectangle):void{
			if (_fill)
	        {   
				//we can't pass a reference to the requesting Geometry in the method signature with IFill - its required for transform inheritance by some fills
				if (_fill is ITransformablePaint) (_fill as ITransformablePaint).requester = this;
	        	_fill.begin(graphics, (rc) ? rc:null);	
				CommandStack.currentFill = _fill;
	        } else 
	        	CommandStack.currentFill = null;
		}
						
		//override for now
		override public function draw(graphics:Graphics, rc:Rectangle):void{
			//re init if required
			calculateLayout();
		 	preDraw();
			super.draw(graphics, (rc)? rc:bounds);
		
			
		}
		
		
		override public function endDraw(graphics:Graphics):void {
			if (fill) {  
	        	fill.end(graphics);  
	        } 
			//append a null moveTo following a stroke without a  fill 
			//forces a break in continuity with moveTo before the next 
			//path - if we have the last point coords we could use them 
			//instead of null, null or perhaps any value
			if (stroke && !fill) graphics.moveTo.call(graphics, null, null); 


			dispatchEvent(new DegrafaEvent(DegrafaEvent.RENDER));
		}
		
		
	}
}