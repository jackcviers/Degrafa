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
}

}
