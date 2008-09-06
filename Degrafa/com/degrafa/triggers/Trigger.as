package com.degrafa.triggers
{
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.states.IDegrafaStateClient;
	
	import flash.events.IEventDispatcher;
	
	public class Trigger extends DegrafaObject
	{
		public function Trigger()
		{
		}

		private var _triggerParent:IDegrafaStateClient;
		/**
		* The parent for this trigger. At the moment a geometry object or a skin.
		**/
		public function get triggerParent():IDegrafaStateClient{
			return _triggerParent;
		}
		public function set triggerParent(value:IDegrafaStateClient):void{
			_triggerParent = value;
			
			if(!value){
				clearTrigger();
			}
			
		}
		
		private var _source:IEventDispatcher;
		/**
		* The target we are listening to
		**/
		public function get source():IEventDispatcher{
			return _source;
		}
		public function set source(value:IEventDispatcher):void{
			_source = value;
			
			if(value){
				initTrigger();
			}
			else{
				clearTrigger();
			}
		}
		
		protected var _ruleFunction:Function;
		/**
		* Function that gets evaluated on the event trigger and 
		* if true the state change will take place. The default 
		* for any evaluation if no rules exist is true 
		* The arguments passed to the function call are: 
		* 1 : the event the trigger received.
		* 2 : the trigger.
		* 
		**/		
		public function get ruleFunction():Function{
			return _ruleFunction;
		}
		public function set ruleFunction(value:Function):void{
			if(_ruleFunction != value){
				_ruleFunction= value as Function;
			}
		}
		
		private var _setState:String;
		/**
		* The state should the rule result be true (default) that will be set on the 
		* triggerParent.
		**/
		public function get setState():String{
			return _setState;
		}
		public function set setState(value:String):void{
			_setState = value;
		}
		
		protected function initTrigger():void{
			//overridden
		}
		protected function clearTrigger():void{
			//overridden
		}
	}
}