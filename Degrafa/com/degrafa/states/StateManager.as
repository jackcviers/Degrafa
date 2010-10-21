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
// Based on the Adobe Flex 2 and 3 state implementation and modified for use in 
// Degrafa.
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa
package com.degrafa.states{
	
	
	import com.degrafa.core.IDegrafaObject;
	import com.degrafa.core.IGraphicSkin;
	import com.degrafa.core.collections.GeometryCollection;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	/**
	* The StateManager manages states for a IDegrafaStateClients. 
	* This object is not intended to be accessed directly.
	* 
	* Degrafa states work very much like Flex 2 or 3 built in states. 
	* For further details reffer to the Flex 2 or 3 documentation. 
	**/
	public class StateManager{
		
		private var stateClient:IDegrafaStateClient;
		
		/**
		* Constructor.
		**/
		public function StateManager(stateClient:IDegrafaStateClient){
			
			this.stateClient = stateClient;
			
		}
		
		private var requestedCurrentState:String;
		private var _currentStateChanged:Boolean;
		
		private var _currentState:String;
		/**
		* The current view state.
		**/
		public function get currentState():String{
	        return _currentStateChanged ? requestedCurrentState : _currentState;
	    }
	    public function set currentState(value:String):void{
	        setCurrentState(value);
	    }
	    
	    /**
	    * Sets the current state for this view.
	    **/ 
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
		
		/**
		* Returns true if the passed state is the base state.
		**/
		public function isBaseState(stateName:String):Boolean{
	    	return !stateName || stateName == "";
    	}
    	
    	/**
    	* Commits the current state making it the active state.
    	**/
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
		
		/**
		* Return the state object with the given name.
		**/
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
		
		/**
		* Returns the name of the common base state shared between state1 and state2.
		**/
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
		
		/**
		* Returns an array of base states
		**/
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
		
		/**
		* Removes the passed state from the collection of states.
		**/
	    public function removeState(stateName:String, lastState:String):void{
	        var state:State = getState(stateName);
	
	        if (stateName == lastState)
	            return;
			var firstCall:Boolean;     
	        // Remove existing state overrides.
	        // This must be done in reverse order
	        if (state)
	        {
				
				if (!isSuppressing) {
					isSuppressing=firstCall=true;
				}
				
	            // Dispatch the "exitState" event
	            state.dispatchExitState();
	
	            var overrides:Array = state.overrides;
				getSuppressions(overrides);
	            for (var i:int = overrides.length; i; i--)
	                overrides[i-1].remove(stateClient);
	
	            // Remove any basedOn deltas last
	            if (state.basedOn != lastState)
	                removeState(state.basedOn, lastState);
				
				
				if (firstCall) {
					removeSuppressions();
					suppressions.length=0;
					isSuppressing=false;
		//			trace('suppressions removed')
				}
	        }
	    }
		
		private function getParentObject(from:IDegrafaObject):IDegrafaObject{
			var obj:IDegrafaObject=from;
			while (obj.parent){
				obj=obj.parent;
			}
			
			return obj;
			
			
		}
		
		
		private function getSuppressions(overrides:Array):Array{
			
			//var suppressions:Array=[];
		//	var overrides:Array = state.overrides;
//			trace('getting Suppressions')
		
			if (stateClient is IGraphicSkin && suppressions.indexOf(stateClient)==-1) {
				suppressions.push(stateClient);
				Object(stateClient).suppressEventProcessing=true;	
				var geomCollection:GeometryCollection = GeometryCollection(Object(stateClient).geometryCollection);
				suppressions.push(geomCollection);
				geomCollection.suppressEventProcessing=true;	
	//			trace('suppressed '+stateClient)
			}
				
				for (var i:int = 0; i < overrides.length; i++){
					var check:Object=IOverride(overrides[i]).targetRef(stateClient);
					if (check is Array) for each(var item:Object in check) {
						var upperItem:IDegrafaObject
						if (item is IDegrafaObject)
						{	 
						upperItem = getParentObject(IDegrafaObject(item))
						if (suppressions.indexOf(upperItem)==-1){
								suppressions.push(upperItem);
								IDegrafaObject(upperItem).suppressEventProcessing=true;
							}
						}
					} else if (check is IDegrafaObject && suppressions.indexOf(check)==-1){
						suppressions.push(check);
						IDegrafaObject(check).suppressEventProcessing=true;
	//					trace('suppressed '+check.id)
					}
					
			
				
			}
	//		trace('suppressed '+suppressions)
			return suppressions;
		}
		
		private function removeSuppressions():void{
			
			
		//	if (!value) return;
			var l:int=suppressions.length;
			
			while(l) {
				l--;
				Object(suppressions[l]).suppressEventProcessing=false;
	//			trace('unsuppressed '+suppressions[l])
			}
		}
		
		private  var suppressions:Array=[];
		private  var isSuppressing:Boolean;
		
		/**
		* Applys the passed state. Making it the current state.
		**/
	    public function applyState(stateName:String, lastState:String):void{
	        var state:State = getState(stateName);
	
	        if (stateName == lastState)
	            return;
	          var firstCall:Boolean;
	        if (state)
	        {
				
				if (!isSuppressing) {
					isSuppressing=firstCall=true;
				}
	            // Apply "basedOn" overrides first
	            if (state.basedOn != lastState) 		
					 applyState(state.basedOn, lastState);

	               
	
	            // Apply new state overrides
	            var overrides:Array = state.overrides;
	           getSuppressions(overrides);
	            for (var i:int = 0; i < overrides.length; i++)
	                overrides[i].apply(stateClient);
				
				if (firstCall) {
					removeSuppressions();
					suppressions.length=0;
					isSuppressing=false;
	//				trace('suppressions removed')
				}
				state.dispatchEnterState();
	        }
			
			
	    }

    	/**
    	* Initializes the passed state.
    	**/
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