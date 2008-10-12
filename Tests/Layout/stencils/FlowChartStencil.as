package stencils {
	import com.degrafa.geometry.stencil.Stencil;
	
	
	[Bindable]	
	
	public class FlowChartStencil extends Stencil{
				
		public function FlowChartStencil(){
			super();
								
			//add each item to the dictionary
			addItem("PROCESS",Stencil.PATH,"M 0,0 H 60 V40 H 0 Z");
			addItem("DECISION",Stencil.PATH,"M 0,20 L 30 0 L 60,20 L 30,40 Z");
			addItem("DOCUMENT",Stencil.PATH,"M 0,0 H 60 V 40 C 30,30 30,50 0,40 Z");
			addItem("DATA",Stencil.PATH,"M 10,0 L 60 0 L 50,40 L 0,40 Z");
			addItem("START",Stencil.PATH,"M 10,20 A 20,20 0 1 1 50,20 A 20,20 0 1 1 10,20");
			addItem("PREDEFINED",Stencil.PATH,"M 50,0 V 40 M 10,0 V 40 M 0 0 H 60 V 40 H 0 Z");
			addItem("STOREDDATA",Stencil.PATH,"M 5,0 H 60 A 40,40 0 0 0 60,40 H 5 A 40,40 0 0 1 5,0 Z");
			addItem("INTERNALSTORAGE",Stencil.PATH,"M 0,10 H 60 M 10,0 V 40 M 0,0 H 60 V 40 H 0 Z");
			addItem("SEQUENTIALDATA",Stencil.PATH,"M 30,40 A 20,20 0 1 1 30,0 A 20,20 0 0 1 43,35 H 50 L 50,40 Z");
			addItem("DIRECTDATA",Stencil.PATH,"M 57,40 H 3 A 4,20 0 1 1 3,0 H 57 A 4,20.1 0 1 1 56,0 Z ");
			addItem("MANUALINPUT",Stencil.PATH,"M 0 10 L 60,0 V 40 H 0 Z");
			addItem("CARD",Stencil.PATH,"M 0 10 L 10,0 H 60 V 40 H 0 Z");
			addItem("PAPERTAPE",Stencil.PATH,"M 0,3 C 30,-7 30,13 60,3 V 37 C 30,47 30,27 0,37 Z");
			addItem("DELAY",Stencil.PATH,"M 0,0 H 40 A 20,20 0 0 1 40,40 H 0 Z");
			addItem("TERMINATOR",Stencil.PATH,"M 20,40 A 20,20 1 0 1 20,0 H 40 A 20,20 0 0 1 40,40 Z");
			addItem("DISPLAY",Stencil.PATH,"M 0,20 A 40,40 0 0 1 15,0 H 55 A 60,60 0 0 1 55,40 H 15 A 40,40, 0 0 1 0,20 Z");
			addItem("LOOPLIMIT",Stencil.PATH,"M 0 10 L 10,0 H 50 L 60,10 V 40 H 0 Z");
			addItem("PREPARATION",Stencil.PATH,"M 0,20 L 10,0  H 50 L 60,20 L 50,40 H10 Z");
			addItem("MANUALOPERATION",Stencil.PATH,"M 0 0 H 60 L 50 40 H 10 Z");
			addItem("OFFPAGEREFERENCE",Stencil.PATH,"M 0 0 H 60 V 20 L 30,40 L 0,20 Z");
			
		}
					
		[Inspectable(category="General", 
		enumeration="PROCESS,DECISION,SEQUENTIALDATA,INTERNALSTORAGE,STOREDDATA,PREDEFINED,START,PREDEFINED,STOREDDATA,INTERNALSTORAGE,SEQUENTIALDATA,DIRECTDATA,MANUALINPUT,CARD,PAPERTAPE,DELAY,TERMINATOR,DISPLAY,LOOPLIMIT,PREPARATION,MANUALOPERATION,OFFPAGEREFERENCE,PUZZLE_001",
		defaultValue="PROCESS")]
		override public function set type(value:String):void{
			super.type=value;
		}
	}
}