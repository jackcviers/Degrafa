package com.degrafa.utilities.external
{
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	//Simply an Event class for dispatching events from DegrafaObjects that do not trigger redraws in Degrafa
	//intended for use in transient states while data loading is not yet complete (e.g. ExternalBitmapData on a BitmapFill)
	/**
	* ...
	* @author Greg Dove
	*/
	public class  ExternalDataPropertyChangeEvent extends PropertyChangeEvent
	{   
		public static const EXTERNAL_DATA_PROPERTY_CHANGE:String = "externalDataPropertyChange";
		public function ExternalDataPropertyChangeEvent(type:String=ExternalDataPropertyChangeEvent.EXTERNAL_DATA_PROPERTY_CHANGE ,bubbles:Boolean=false,cancelable:Boolean=false,kind:String=PropertyChangeEventKind.UPDATE ,property:Object=null,newValue:Object=null,oldValue:Object=null,source:Object=null):void
		{
			super(type,bubbles,cancelable,kind,property,newValue,oldValue,source);
		}
	}
	
}