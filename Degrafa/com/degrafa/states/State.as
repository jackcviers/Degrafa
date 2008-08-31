////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states{

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.events.FlexEvent;

[Event(name="enterState", type="mx.events.FlexEvent")]
[Event(name="exitState", type="mx.events.FlexEvent")]

[DefaultProperty("overrides")]

public class State extends EventDispatcher{

	public function State(){
		super();
				
	}
	
	public var stateManager:StateManager;
	 
	private var initialized:Boolean = false;

	[Inspectable(category="General")]
	public var basedOn:String;

	[Inspectable(category="General")]
	public var name:String;

	[ArrayElementType("com.degrafa.states.IOverride")]
	[Inspectable(category="General")]
	public var overrides:Array = [];

    /**
     *  @private
     *  Initialize this state and all of its overrides.
     */
    public function initialize():void{
    	if (!initialized){
    		initialized = true;
    		for (var i:int = 0; i < overrides.length; i++){
    			overrides[i].initialize();
    		}
    	}
    }

    /**
     *  @private
     *  Dispatches the "enterState" event.
     */
	public function dispatchEnterState():void{
		dispatchEvent(new FlexEvent(FlexEvent.ENTER_STATE));
	}

    /**
     *  @private
     *  Dispatches the "exitState" event.
     */
	public function dispatchExitState():void{
		dispatchEvent(new FlexEvent(FlexEvent.EXIT_STATE));
	}
	
	/**
	* Trigger based code
	**/
	
	private var _triggers:Array= [];
    [Inspectable(arrayType="com.degrafa.states.Trigger")]
    [ArrayElementType("com.degrafa.states.Trigger")]
    public function get triggers():Array{
    	return _triggers;
    }
    public function set triggers(items:Array):void{
    	_triggers = items;
    	
    	//make sure each item knows about it's manager
		for each (var trigger:Trigger in _triggers){
			trigger.parentState = this;
		}
		
    }
	
	//setup all the listeners
	internal function initTriggers():void{
		
		if(!triggers){return;}
		
		for each (var itemTrigger:Trigger in triggers){
			if(itemTrigger.source && itemTrigger.event){
				if(!itemTrigger.source.hasEventListener(itemTrigger.event)){
					itemTrigger.source.addEventListener(itemTrigger.event,
					onEventTriggered,false,0,true);
				}
			}
		}
		
	}
	private function clearTriggers():void{
		if(!triggers){return;}
		
		for each (var itemTrigger:Trigger in triggers){
			if(itemTrigger.source && itemTrigger.event){
				if(!itemTrigger.source.hasEventListener(itemTrigger.event)){
					itemTrigger.source.removeEventListener(itemTrigger.event,onEventTriggered);
				}
			}
		}
	}
	
	private function onEventTriggered(event:Event):void{
		
		var result:Boolean=true;
		
		//if there are rules then they must all evaluate 
		//to true before this state change will take place
		for each (var itemTrigger:Trigger in triggers){
			if(itemTrigger.ruleFunction != null){
				if(!itemTrigger.ruleFunction.call(this,event,itemTrigger)){
					return;
				}
			}
				
		}
		
		if(result){
			stateManager.currentState = name;
		}
	}
	
	
}

}
