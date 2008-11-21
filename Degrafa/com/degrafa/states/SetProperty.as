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

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("SetProperty.png")]

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
    
    public function apply(parent:IDegrafaStateClient):void{
        var obj:Object = target ? target : parent;
        var propName:String = name;
        var newValue:* = value;

        // Remember the current value so it can be restored
        oldValue = obj[propName];
        
        // Set new value
        setPropertyValue(obj, propName, newValue, oldValue);
    }

    public function remove(parent:IDegrafaStateClient):void{
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
