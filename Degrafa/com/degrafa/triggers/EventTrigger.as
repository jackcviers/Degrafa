package com.degrafa.triggers
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EventTrigger.png")]

	public class EventTrigger extends Trigger implements ITrigger
	{
		public function EventTrigger(source:IEventDispatcher=null,event:String="",ruleFunction:Function=null)
		{
			super();
			
			super.source = source;
			_event= event;
			super.ruleFunction= ruleFunction;
			
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
			
			initTrigger();
		}
						
		//setup the listener uses a weak reff
		override protected function initTrigger():void{
			if(!source || !event){return;}
			source.addEventListener(event,onEventTriggered,false,0,true);
		}
		
		//clear the listener
		override protected function clearTrigger():void{
			if(source){
				source.removeEventListener(event,onEventTriggered);
			}
		}
		
		private function onEventTriggered(event:Event):void{
		
			var result:Boolean=true;
			
			//if there are rules then they must all evaluate 
			//to true before this state change will take place
			if(ruleFunction != null){
				if(!ruleFunction.call(this,event,this)){
					return;
				}
			}
								
			if(result){
				if(setState){
					triggerParent.currentState =setState; 
				}
			}
		}
		
	}
}