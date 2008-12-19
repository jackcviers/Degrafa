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
	import flash.events.IEventDispatcher;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EventTrigger.png")]
	/**
	* EventTrigger will listen to the specified event on the source
	* and set the specified state when that event occurs.
	**/
	public class EventTrigger extends Trigger implements ITrigger{
		
		/**
		* Constructor.
		**/
		public function EventTrigger(source:IEventDispatcher=null,event:String="",ruleFunction:Function=null){
			super();
			
			super.source = source;
			_event= event;
			super.ruleFunction= ruleFunction;
			
		}
		
		private var _event:String;
		/**
		* The event on the source we are listening for
		**/
		public function get event():String{
			return _event;
		}
		public function set event(value:String):void{
			_event = value;
			
			initTrigger();
		}
						
		/**
		* Sets the listener on the event specified.
		**/
		override protected function initTrigger():void{
			if(!source || !event){return;}
			source.addEventListener(event,onEventTriggered,false,0,true);
		}
		
		/**
		* Clears the listener setup by this trigger.
		**/
		override protected function clearTrigger():void{
			if(source){
				source.removeEventListener(event,onEventTriggered);
			}
		}
		
		/**
		* Executes the rule.
		**/
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