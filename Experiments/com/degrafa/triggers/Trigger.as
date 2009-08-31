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
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.states.IDegrafaStateClient;
	
	import flash.events.IEventDispatcher;
	/**
	* Trigger is the base class that other triggers extend from.  
	**/
	public class Trigger extends DegrafaObject{
		
		/**
		* Constructor.
		**/
		public function Trigger(){}

		private var _triggerParent:IDegrafaStateClient;
		/**
		* The parent for this trigger. A valide IDegrafaStateClient.
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
		* The source of the property or event we want to be notified about. 
		* Any valid IEventDispatcher.
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
		
		/**
		* Inits the trigger overrideen by subclasses.
		**/
		protected function initTrigger():void{
			//overridden
		}
		
		/**
		* Clears the trigger overrideen by subclasses.
		**/
		protected function clearTrigger():void{
			//overridden
		}
	}
}