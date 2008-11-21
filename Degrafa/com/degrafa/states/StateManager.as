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
	
	import com.degrafa.geometry.Geometry;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	public class StateManager{
		
		private var stateClient:IDegrafaStateClient;
		
		public function StateManager(stateClient:IDegrafaStateClient){
			
			this.stateClient = stateClient;
			
		}
		private var _currentState:String;
		private var requestedCurrentState:String;
		private var _currentStateChanged:Boolean;
		
		public function get currentState():String{
	        return _currentStateChanged ? requestedCurrentState : _currentState;
	    }
	    public function set currentState(value:String):void{
	        setCurrentState(value);
	    }
	     
		public function setCurrentState(stateName:String):void{
			 if (stateName != currentState && !(isBaseState(stateName) && isBaseState(currentState))){
	            requestedCurrentState = stateName;
	        
	            if (stateClient.isInitialized)
	            {
	                commitCurrentState();
	            }
	            else
	            {
	                _currentStateChanged = true;
	            }
	        }
		}
		public function isBaseState(stateName:String):Boolean{
	    	return !stateName || stateName == "";
    	}
    	
		public function commitCurrentState():void{
        
	        var commonBaseState:String = findCommonBaseState(_currentState, requestedCurrentState);
	        var event:StateChangeEvent;
	        var oldState:String = _currentState ? _currentState : "";
	        var destination:State = getState(requestedCurrentState);
	       
	        // Initialize the state we are going to.
	        initializeState(requestedCurrentState);
	        
	        // Dispatch currentStateChanging event
	        event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGING);
	        event.oldState = oldState;
	        event.newState = requestedCurrentState ? requestedCurrentState : "";
	        stateClient.dispatchEvent(event);
	
	        // If we're leaving the base state, send an exitState event
	        if (isBaseState(_currentState))
	            stateClient.dispatchEvent(new FlexEvent(FlexEvent.EXIT_STATE));
	
	        // Remove the existing state
	        removeState(_currentState, commonBaseState);
	        _currentState = requestedCurrentState;
	
	        // If we're going back to the base state, dispatch an
	        // enter state event, otherwise apply the state.
	        if (isBaseState(currentState))
	            stateClient.dispatchEvent(new FlexEvent(FlexEvent.ENTER_STATE));
	        else
	            applyState(_currentState, commonBaseState);
	
	        // Dispatch currentStateChange
	        event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGE);
	        event.oldState = oldState;
	        event.newState = _currentState ? _currentState : "";
	        stateClient.dispatchEvent(event);
	
	    }

	    public function getState(stateName:String):State{
	        if (!stateClient.states || isBaseState(stateName))
	            return null;
	
	        for (var i:int = 0; i < stateClient.states.length; i++)
	        {
	            if (stateClient.states[i].name == stateName)
	                return stateClient.states[i];
	        }
	        return null;
	    }
	
	    public function findCommonBaseState(state1:String, state2:String):String{
	        var firstState:State = getState(state1);
	        var secondState:State = getState(state2);
	
	        // Quick exit if either state is the base state
	        if (!firstState || !secondState)
	            return "";
	
	        // Quick exit if both states are not based on other states
	        if (isBaseState(firstState.basedOn) && isBaseState(secondState.basedOn))
	            return "";
	
	        // Get the base states for each state and walk from the top
	        // down until we find the deepest common base state.
	        var firstBaseStates:Array = getBaseStates(firstState);
	        var secondBaseStates:Array = getBaseStates(secondState);
	        var commonBase:String = "";
	        
	        while (firstBaseStates[firstBaseStates.length - 1] ==
	               secondBaseStates[secondBaseStates.length - 1])
	        {
	            commonBase = firstBaseStates.pop();
	            secondBaseStates.pop();
	
	            if (!firstBaseStates.length || !secondBaseStates.length)
	                break;
	        }
	
	        // Finally, check to see if one of the states is directly based on the other.
	        if (firstBaseStates.length && 
	            firstBaseStates[firstBaseStates.length - 1] == secondState.name)
	        {
	            commonBase = secondState.name;
	        }
	        else if (secondBaseStates.length && 
	                 secondBaseStates[secondBaseStates.length - 1] == firstState.name)
	        {
	            commonBase = firstState.name;
	        }
	        
	        return commonBase;
	    }
	
	    public function getBaseStates(state:State):Array{
	        var baseStates:Array = [];
	        
	        // Push each basedOn name
	        while (state && state.basedOn)
	        {
	            baseStates.push(state.basedOn);
	            state = getState(state.basedOn);
	        }
	
	        return baseStates;
	    }
	
	    public function removeState(stateName:String, lastState:String):void{
	        var state:State = getState(stateName);
	
	        if (stateName == lastState)
	            return;
	            
	        // Remove existing state overrides.
	        // This must be done in reverse order
	        if (state)
	        {
	            // Dispatch the "exitState" event
	            state.dispatchExitState();
	
	            var overrides:Array = state.overrides;
	
	            for (var i:int = overrides.length; i; i--)
	                overrides[i-1].remove(stateClient);
	
	            // Remove any basedOn deltas last
	            if (state.basedOn != lastState)
	                removeState(state.basedOn, lastState);
	        }
	    }

	    public function applyState(stateName:String, lastState:String):void{
	        var state:State = getState(stateName);
	
	        if (stateName == lastState)
	            return;
	            
	        if (state)
	        {
	            // Apply "basedOn" overrides first
	            if (state.basedOn != lastState)
	                applyState(state.basedOn, lastState);
	
	            // Apply new state overrides
	            var overrides:Array = state.overrides;
	
	            for (var i:int = 0; i < overrides.length; i++)
	                overrides[i].apply(stateClient);
	
	        }
	    }

    
	    public function initializeState(stateName:String):void{
	        var state:State = getState(stateName);
	        
	        while (state)
	        {
	            //state.initialize();
	            state = getState(state.basedOn);
	        }
	    }
	    
		
	}
}