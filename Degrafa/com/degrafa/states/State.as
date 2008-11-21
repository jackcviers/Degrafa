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
//
// Based on Adobe Code
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states{

import flash.events.EventDispatcher;

import mx.events.FlexEvent;

//--------------------------------------
//  Other metadata
//--------------------------------------
	
	[IconFile("State.png")]

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
