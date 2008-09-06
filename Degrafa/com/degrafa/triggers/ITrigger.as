package com.degrafa.triggers
{
	import com.degrafa.states.IDegrafaStateClient;
	
	import flash.events.IEventDispatcher;
	
	public interface ITrigger
	{
		function get triggerParent():IDegrafaStateClient
		function set triggerParent(value:IDegrafaStateClient):void
		function get id():String
		function set id(value:String):void
		function get source():IEventDispatcher
		function set source(value:IEventDispatcher):void
	}
}