package stencils {
	
	import com.degrafa.geometry.stencil.Stencil;
	
	public class AssortedShapesStencil extends Stencil{
		
		public function AssortedShapesStencil(item:String="CROSS_MALTESE"){
			super();
			
			//add each item to the dictionary
			addItem("CROSS_MALTESE",Stencil.POLYGON,"7,6 7.5,5 7,4 9,5 8,3 9,3.5 10,3 9,5 11,4 10.5,5 11,6 9,5 10,7 9,6.5 8,7 9,5");
			addItem("CROSS_SWISS",Stencil.POLYGON,"2.55,3.05 2.55,2.55 3.05,2.55 3.05,2.05 3.55,2.05 3.55,2.55 4.05,2.55 4.05,3.05 3.55,3.05 3.55,3.55 3.05,3.55 3.05,3.05");
			addItem("DIAMOND",Stencil.POLYGON,"1,0 2,1 1,2 0,1");
			addItem("HEPTAGON",Stencil.POLYGON,"0,6 0.5,2 5,0 9.5,2 10,6 7.5,9.5 2.5,9.5");
			addItem("HEXAGON",Stencil.POLYGON,"1.5,1 3,1 4,2.5 3,4 1.5,4 0.5,2.5");
			addItem("OCTAGON",Stencil.POLYGON,"3.55,2.05 5.05,2.05 6.05,3.05 6.05,4.55 5.05,5.55 3.55,5.55 2.55,4.55 2.55,3.05");
			addItem("PARALLELOGRAM_HORIZONTAL",Stencil.POLYGON,"1,0 2,0 1,1 0,1");
			addItem("PARALLELOGRAM_VERTICAL",Stencil.POLYGON, "0,1 1,0 1,1 0,2");
			addItem("PENTAGON",Stencil.POLYGON,"0,1.5 2,0 4,1.5 3,3.5 1,3.5");
			addItem("STAR_4",Stencil.POLYGON,"0,2.5 1.5,2 2,0.5 2.5,2 4,2.5 2.5,3 2,4.5 1.5,3");
			addItem("STAR_5",Stencil.POLYGON,"0,4.5 5,4.5 7,0 9,4.5 14,4.5 10,7.5 12,12.5 7,9 2,12.5 4,7.5"); 
			addItem("STAR_6",Stencil.POLYGON,"0,1 1,1 1.5,0 2,1 3,1 2.5,2 3,3 2,3 1.5,4 1,3 0,3 0.5,2");
			addItem("STAR_7",Stencil.POLYGON,"5,0 6.5,2 9,2 8.5,4.5 10,6.5 8,7 7.5,9.5 5,8 2.5,9.5 2,7 0,6.5 1.5,4.5 1,2 3.5,2"); 
			addItem("STAR_8",Stencil.POLYGON,"0,3.5 1,2.5 1,1 2.5,1 3.5,0 4.5,1 6,1 6,2.5 7,3.5 6,4.5 6,6 4.5,6 3.5,7 2.5,6 1,6 1,4.5");
			addItem("STAR_8_SHARP",Stencil.POLYGON,"0,7.5 5,6.5 2.5,2.5 6.5,5 7.5,0 8.5,5 12.5,2.5 10,6.5 15,7.5 10,8.5 12.5,12.5 8.5,10 7.5,15 6.5,10 2.5,12.5 5,8.5");
			addItem("TRAPEZOID",Stencil.POLYGON,"1,0 3,0 4,2 0,2");
			addItem("TRIANGLE_ISOCELES",Stencil.POLYGON,"5.5,4 6.5,6 4.5,6");
			addItem("TRIANGLE_RIGHTANGLE",Stencil.POLYGON,"0,2 2,2 0,0");
			addItem("CIRCLE_QUARTER",Stencil.PATH,"M 0 0 C 0.5,0 1,0.5 1,1 C 1,1 0,1 0,1 C 0,1 0,0 0,0z");
			addItem("HEART",Stencil.PATH,"M 9 9 C 5,4 13,2 13,8 C 13,8 13,8 13,8 C 13,2 21,4 17,9 C 17,9 13,14 13,14 C 13,14 9,9 9,9z");
			addItem("MOON_QUARTER",Stencil.PATH,"M 4 0 C 4,0 2,0 2,4 C 2,8 4,8 4,8 C 4,8 0,8 0,4 C 0,0 4,0 4,0z");
			addItem("STAR_4_CURVED",Stencil.PATH,"M 4.5 2 C 4.5,3 5.5,4 6.5,4 C 5.5,4 4.5,5 4.5,6 C 4.5,5 3.5,4 2.5,4 C 3.5,4 4.5,3 4.5,2z");
			addItem("STAR_8_CURVED",Stencil.PATH,"M 2 0 C 2,1 3,1 3.5,0.5 C 3,1 3,2 4,2 C 3,2 3,3 3.5,3.5 C 3,3 2,3 2,4 C 2,3 1,3 0.5,3.5 C 1,3 1,2 0,2 C 1,2 1,1 0.5,0.5 C 1,1 2,1 2,0z");
		}
				
		[Inspectable(category="General", 
		enumeration="CROSS_MALTESE,CROSS_SWISS,DIAMOND,HEPTAGON,HEXAGON,OCTAGON,PARALLELOGRAM_HORIZONTAL,PARALLELOGRAM_VERTICAL,PENTAGON,STAR_4,STAR_5,STAR_6,STAR_7,STAR_8,STAR_8_SHARP,TRAPEZOID,TRIANGLE_ISOCELES,TRIANGLE_RIGHTANGLE,CIRCLE_QUARTER,HEART,MOON_QUARTER,STAR_4_CURVED,STAR_8_CURVED",				
		defaultValue="CROSS_MALTESE")]
		override public function set type(value:String):void{
			super.type=value;
		}
	}
}