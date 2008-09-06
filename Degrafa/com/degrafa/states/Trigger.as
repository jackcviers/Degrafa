package com.degrafa.states
{
	import flash.events.IEventDispatcher;
	
	public class Trigger
	{
		public function Trigger(){}
				
		//the parent state this trigger belongs to.
		public var parentState:State;
		
		private var _source:IEventDispatcher;
		/**
		* The target we are listening to
		**/
		public function get source():IEventDispatcher{
			return _source;
		}
		public function set source(value:IEventDispatcher):void{
			_source = value;
			
			//initTriggers();
		}
	
		private var _event:String;
		/**
		* The event on the target we are listening for
		**/
		public function get event():String{
			return _event;
		}
		public function set event(value:String):void{
			_event = value;
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
		
	}
}