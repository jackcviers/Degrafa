////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.triggers{
	
	import flash.events.Event;
	
	import mx.binding.utils.ChangeWatcher;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("PropertyTrigger.png")]

	public class PropertyTrigger extends Trigger implements ITrigger{
		
		/**
		* Constructor.
		**/
		public function PropertyTrigger(){
			super();
		}
		
		private var _property:String;
		/**
		* The property on the source to be watched for changes.
		**/
		public function get property():String{
			return _property;
		}
		public function set property(value:String):void{
			_property = value;
			
			initTrigger();
		}
		
		private var _autoRestoreState:Boolean=true;
		/**
		* If true will set the state to the old state
		* when rule test is false.
		**/
		public function get autoRestoreState():Boolean{
			return _autoRestoreState;
		}
		public function set autoRestoreState(value:Boolean):void{
			_autoRestoreState = value;
		}
		
		private var _propertyValue:String;
		/**
		* Property value is used as an initial rule and is optional
		* when set the value being set on the target property must be equal
		* to this value before the trigger will occure. If not set this
		* test is ignored.
		**/
		public function get propertyValue():String{
			return _propertyValue;
		}
		public function set propertyValue(value:String):void{
			_propertyValue = value;
			
			initTrigger();
		}
		
		//internal change watcher
		private var changeWatcher:ChangeWatcher; 
		
		/**
		* Sets up a ChangeWatcher for the property on the source specified.
		**/
		override protected function initTrigger():void{
			if(!source || !property){return;}
			
			if(Object(source).hasOwnProperty(property)){
				
				//setup the watcher is we can
				if(ChangeWatcher.canWatch(source,property)){
					changeWatcher = ChangeWatcher.watch(source,property,executeTrigger);
				}
								
			}
			
		}
		
		/**
		* Clears the ChangeWatcher for the property on the source specified.
		**/
		override protected function clearTrigger():void{
			if(changeWatcher){
				changeWatcher.unwatch();
			}
		}
		
		//store the old state for a false value
		private var oldState:String="";
		
		//executes the trigger when a change takes place.
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