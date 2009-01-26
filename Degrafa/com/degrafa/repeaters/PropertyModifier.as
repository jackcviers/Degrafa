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
package com.degrafa.repeaters{
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.geometry.Geometry;
	
	import flash.geom.Rectangle;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("PropertyModifier.png")]
	
	/**
	* PropertyModifier is used to specify changes that should 
	* occur on the geometry or subsequent objects being repeated.
	**/
	public class PropertyModifier extends DegrafaObject implements IRepeaterModifier{
		
		/**
		 * The source object we will apply mods to.
		 */
		private var _sourceObject:Object;
		
		/**
		 * the actual objects that gets modified (could be a child of the source object)
		 */
		private var _targetObjects:Array;
		
		/**
		 * the related properties of the targetObjects that gets its value changed
		 */
		private var _targetProperties:Array;
		
		/**
		 * the original values of the target objects property
		 */
		 private var _originalValues:Array;
		
		private var _iteration:Number=0;
		private var _modifyInProgress:Boolean=false;
		
		/**
		* The PropertyModifier constructor.
		*/
		public function PropertyModifier(){
			super();
		}		
		
		/**
		* The current iteration of an active modification.
		*/
	   	public function get iteration():Number { return _iteration; }
				 
		private var _targets:Array
		/**
		* An array of targets.
		*/
		public function set targets(value:Array):void {
			_targets=value;
		}
		public function get targets():Array { return _targets }
		
		
		private var _property:String;
		/**
		* This is the property we intend to modify when we iterate.
		*/ 
		public function set property(value:String):void {
			_property=value;
		}
		public function get property():String { return _property }
	
		private var _modifier:Object;
		/**
		* This represents how we will be modifierting the property.
		*/ 
		public function set modifier(value:Object):void {
			var oldValue:Object=_modifier;
			_modifier=value;
			initChange("modifier",oldValue,_modifier,this);
		}
		public function get modifier():Object { return _modifier };
		
		public static var MODIFIER_ADD:String="add";
		public static var MODIFIER_NONE:String="none";
		public static var MODIFIER_SUBTRACT:String="subtract";
		public static var MODIFIER_MULTIPLY:String="multiply";
		public static var MODIFIER_DIVIDE:String="divide";
		
		private var _modifierOperator:String="add";
		/**
		* How to apply the modifier for each iteration.
		*/
		[Inspectable(category="General", enumeration="add,subtract,multiply,divide,none" )]
		public function set modifierOperator(value:String):void {
			_modifierOperator=value;
		}
		public function get modifierOperator():String { return _modifierOperator; }
		
		/**
		* This tells the modifier that it will be doing iterations and 
		* modifying the source object.
		*/
		public function beginModify(sourceObject:Object):void {
			//Expects a geometry array
			
			if (_modifyInProgress) return;
			_sourceObject=sourceObject;
			setTargetProperty(_sourceObject);
			_iteration=0;
			_modifyInProgress=true;
			this.suppressEventProcessing=true;
		}
		
		/**
		* This ends the modification loop and we need to set 
		* back our modified property to its original state.
		*/
		public function end():void {
			if (!_modifyInProgress) return;
			var i:uint;
			for (i=0;i<_targetObjects.length;i++) {
				_targetObjects[i][_targetProperties[i]]=_originalValues[i];
			}
			
			for (i=0;i<targets.length;i++) {
				if (targets[i] is Geometry) Geometry(targets[i]).suppressEventProcessing=false;
			}
			_iteration=0;
			_modifyInProgress=false;
			this.suppressEventProcessing=false;
		}
		
		/**
		* This applies our numeric modifier or array of modifiers to 
		* the property of our geometryObject.
		*/
		public function apply():void {
			
		//	trace("applying modifier");
			var tempModifier:Object;
			
			var bounds:Rectangle=new Rectangle();    
			
			if (_modifier is Array) {
				tempModifier = modifier[_iteration % modifier.length];
				//trace(tempmodifier);
			}
			else if (_modifier is Function ) {
				tempModifier=_modifier(_iteration,_targetObjects[i][_targetProperties[i]] );
			}
			else {
				tempModifier=Number(_modifier);
			}

			if (_modifier!=null) {
				for (var i:int=0;i<_targetObjects.length;i++) {
					if (_modifierOperator==PropertyModifier.MODIFIER_ADD && _iteration>0)  
						_targetObjects[i][_targetProperties[i]]+=Number(tempModifier);
					else if (_modifierOperator==PropertyModifier.MODIFIER_SUBTRACT && _iteration>0)
						_targetObjects[i][_targetProperties[i]]-=Number(tempModifier);
					else if (_modifierOperator==PropertyModifier.MODIFIER_MULTIPLY && _iteration>0)
						_targetObjects[i][_targetProperties[i]]*=Number(tempModifier);
					else if (_modifierOperator==PropertyModifier.MODIFIER_DIVIDE && _iteration>0)
						_targetObjects[i][_targetProperties[i]]/=Number(tempModifier);
					else if (_modifierOperator != PropertyModifier.MODIFIER_ADD && _modifierOperator != PropertyModifier.MODIFIER_SUBTRACT && _modifierOperator != PropertyModifier.MODIFIER_MULTIPLY && _modifierOperator != PropertyModifier.MODIFIER_DIVIDE)
						_targetObjects[i][_targetProperties[i]]=tempModifier;
				}
			}
			
			_iteration++;

			
		}
		
		/**
		* We want to find the property we are modifying and cache the property.
		* If the sourceObject has changed then we need to find the property again
		* We store the object in _targetObject
		* And the property name in _targetProperty
		* This is an easy way to keep a reference versus trying to cast one.
		*/
		private function setTargetProperty(sourceObject:Object):void { 

			//Clear our targets
			_targetObjects=new Array();
			_targetProperties=new Array();
			_originalValues=new Array();
			
			if (_targets==null) _targets=new Array();
			
			//Set our initial source object
			if (sourceObject is GeometryCollection) {
				if (_targets.length==0)
					_targets.push(Geometry(GeometryCollection(sourceObject).items[0]));
				}
			else {
				_targets.push(sourceObject);
			}

			//Go through our source objects and find the correct objects.
			for (var i:int=0;i<_targets.length;i++) {
					
				var targetObject:Object=_targets[i];
				var targetProperty:String;
				
				if (targetObject is Geometry) {
					//We want to make sure we are part of the source object so we dont update properties of other objects
					if (Geometry(targetObject).parent && Geometry(targetObject).parent!=this.parent) continue;
					Geometry(targetObject).suppressEventProcessing=true;
				}
				else if (targetObject==null) continue;
			
				if (_property.indexOf(".") < 0) {
					if (_property.indexOf("[")<0)
					targetProperty = _property;
					else {
						targetProperty = _property.substring(_property.indexOf("[") + 1, _property.indexOf("]") );
						targetObject = targetObject[_property.substr(0, _property.indexOf("[") )];
					}
				} 
				else {
					//We must have a property chain lets use it
					var propChain:Array=_property.split(/[\.\[]/);

					for (var y:int = 0; y < propChain.length - 1; y++) {
						if (propChain[y].indexOf("]") != -1) propChain[y] = propChain[y].substr(0, propChain[y].indexOf("]") );
						targetObject = targetObject[propChain[y]];
					}
					if (propChain[y].indexOf("]") != -1) propChain[y] = propChain[y].substr(0, propChain[y].indexOf("]") );
					targetProperty=propChain[y];
				}					
				_targetObjects.push(targetObject);
				_targetProperties.push(targetProperty);
				_originalValues.push(targetObject[targetProperty]);
			}

		}
		
	}
}