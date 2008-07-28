package com.degrafa.states{

import flash.events.EventDispatcher;

import mx.events.FlexEvent;
import mx.states.Transition;

[Event(name="enterState", type="mx.events.FlexEvent")]
[Event(name="exitState", type="mx.events.FlexEvent")]

[DefaultProperty("overrides")]

public class State extends EventDispatcher{

	public function State(){
		super();
	}
	 
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
