package com.degrafa.skins
{	
	
	import mx.core.EdgeMetrics;
	import mx.core.IBorder;
	
	/**
	 *  The StateClientBorder class is an abstract base class for various classes that
	 *  draw borders, either rectangular or non-rectangular, around UIComponents.
	 *  This class does not do any actual drawing itself.
	 * 
	 *  it handles its state internally performs updates via degrafa states
	 *
	 *  <p>If you create a new non-rectangular border class, you should extend
	 *  this class.
	 *  If you create a new rectangular border class, you should extend the
	 *  abstract subclass StateClientRectangularBorder.</p>
	 *
	 */
	public class StateClientBorder extends StateClientSkin implements IBorder
	{

		


			
			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  Constructor.
			 */
		public function StateClientBorder()
		{
			super();
		}
			
			//--------------------------------------------------------------------------
			//
			//  Properties
			//
			//--------------------------------------------------------------------------
			
			//----------------------------------
			//  borderMetrics
			//----------------------------------
			
			/**
			 *  The thickness of the border edges.
			 *
			 *  @return EdgeMetrics with left, top, right, bottom thickness in pixels
			 */
			public function get borderMetrics():EdgeMetrics
			{
				return EdgeMetrics.EMPTY;
			}
	
		
		
		
		
	}
}