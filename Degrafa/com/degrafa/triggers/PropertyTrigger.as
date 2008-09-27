package com.degrafa.triggers
{
	import flash.events.Event;
	
	import mx.binding.utils.ChangeWatcher;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("PropertyTrigger.png")]

	public class PropertyTrigger extends Trigger implements ITrigger
	{
		public function PropertyTrigger()
		{
			super();
		}
		
		private var _property:String;
		/**
		* The event on the target we are listening for
		**/
		public function get property():String{
			return _property;
		}
		public function set property(value:String):void{
			_property = value;
			
			initTrigger();
		}
		
		private var _autoRestoreState:Boolean=true;
		//if true (default) will set the state to the old state
		//when rule test is false
		public function get autoRestoreState():Boolean{
			return _autoRestoreState;
		}
		public function set autoRestoreState(value:Boolean):void{
			_autoRestoreState = value;
		}
		
		private var _propertyValue:String;
		//property value is used as an initial rule and is optional
		//when set the value being set on the target property must be equal
		//to this value before the trigger will occure. If not set this 
		//test is ignored
		public function get propertyValue():String{
			return _propertyValue;
		}
		public function set propertyValue(value:String):void{
			_propertyValue = value;
			
			initTrigger();
		}
		
		
		private var changeWatcher:ChangeWatcher; 
		
		//setup the listener uses a weak reff
		override protected function initTrigger():void{
			if(!source || !property){return;}
			
			if(Object(source).hasOwnProperty(property)){
				
				//setup the watcher is we can
				if(ChangeWatcher.canWatch(source,property)){
					changeWatcher = ChangeWatcher.watch(source,property,executeTrigger);
				}
								
			}
			
		}
		
		//clear the listener
		override protected function clearTrigger():void{
			if(changeWatcher){
				changeWatcher.unwatch();
			}
		}
		
		//store the old state for a false value
		private var oldState:String="";
		
		private function executeTrigger(event:Event):void{
			
			var result:Boolean=true;
			
			if(propertyValue){
				if(Object(source)[property]!=propertyValue){
					if(autoRestoreState){triggerParent.currentState =oldState;}
					return;
				}
			}
			
			//if there are rules then they must all evaluate 
			//to true before this state change will take place
			if(ruleFunction != null){
				if(!ruleFunction.call(this,property,this)){
					if(autoRestoreState){triggerParent.currentState =oldState;}
					return;
				}
			}
								
			if(result){
				if(setState){
					//store the old state
					oldState = triggerParent.currentState;
					//set the new state
					triggerParent.currentState =setState; 
				}
			}
		}
		
		
	}
}