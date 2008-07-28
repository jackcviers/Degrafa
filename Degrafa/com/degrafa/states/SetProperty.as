package com.degrafa.states{

import com.degrafa.geometry.Geometry;

public class SetProperty implements IOverride{

    public function SetProperty(target:Object = null, name:String = null,value:* = undefined){
        this.target = target;
        this.name = name;
        this.value = value;
    }

    private var oldValue:Object;
    private var oldRelatedValues:Array;

    public var name:String;

    public var target:Object;

    public var value:*;

    public function initialize():void{}
    
    public function apply(parent:Geometry):void{
        var obj:Object = target ? target : parent;
        var propName:String = name;
        var newValue:* = value;

        // Remember the current value so it can be restored
        oldValue = obj[propName];
        
        // Set new value
        setPropertyValue(obj, propName, newValue, oldValue);
    }

    public function remove(parent:Geometry):void{
        var obj:Object = target ? target : parent;
        
        var propName:String = name;
        
        // Restore the old value
        setPropertyValue(obj, propName, oldValue, oldValue);
    }

    private function setPropertyValue(obj:Object, name:String, value:*,valueForType:Object):void{
        if (valueForType is Number)
            obj[name] = Number(value);
        else if (valueForType is Boolean)
            obj[name] = toBoolean(value);
        else
            obj[name] = value;
    }

    private function toBoolean(value:Object):Boolean{
        if (value is String)
            return value.toLowerCase() == "true";

        return value != false;
    }
}

}
