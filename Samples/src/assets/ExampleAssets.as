package assets
{
	public class ExampleAssets
	{
		
		[Embed("retro.gif")]
		public static const RETRO:Class;
		
		[Embed("kitchen.gif")]
		public static const KITCHEN:Class;
		
		[Embed("grunge.png",
		scaleGridTop="120", scaleGridBottom="140", 
		scaleGridLeft="257", scaleGridRight="267")]
		public static const GRUNGE:Class;

	}
}