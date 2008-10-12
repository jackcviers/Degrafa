package stencils {
	import com.degrafa.geometry.stencil.Stencil;
	
	[Bindable]	
	
	public class ArrowsStencil extends Stencil{
						
		public function ArrowsStencil(){
			super();
								
			//add each item to the dictionary
			addItem("ARROW_CHEVRON",Stencil.POLYGON,"0,0 2,0 3,1 2,2 0,2 1,1");
			addItem("ARROW_DOWN",Stencil.POLYGON,"1,0 1,2 0,2 2,4 4,2 3,2 3,0");
			addItem("ARROW_LEFT_NOTCHED",Stencil.POLYGON,"4,1 2,1 2,0 0,2 2,4 2,3 4,3 3,2");
			addItem("ARROW_LEFT_RIGHT",Stencil.POLYGON,"6,1 2,1 2,0 0,2 2,4 2,3 6,3 6,4 8,2 6,0");
			addItem("ARROW_LEFT_RIGHT_UP",Stencil.POLYGON,"8,4 6,4 6,2 7,2 5,0 3,2 4,2 4,4 2,4 2,3 0,5 2,7 2,6 8,6 8,7 10,5 8,3");
			addItem("ARROW_LEFT_UP",Stencil.POLYGON,"6,2 7,2 5,0 3,2 4,2 4,4 2,4 2,3 0,5 2,7 2,6 6,6");
			addItem("ARROW_PENTAGON",Stencil.POLYGON,"0,0 2,0 3,1 2,2 0,2");
		
		}
				
		[Inspectable(category="General", 
		enumeration="ARROW_CHEVRON,ARROW_DOWN,ARROW_LEFT_NOTCHED,ARROW_LEFT_RIGHT,ARROW_LEFT_RIGHT_UP,ARROW_LEFT_UP,ARROW_PENTAGON",				
		defaultValue="ARROW_CHEVRON")]
		override public function set type(value:String):void{
			super.type=value;
		}
	}
}