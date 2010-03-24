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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net) and 
// ported by the Degrafa team.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.utilities.math{
	
	/**
	* Helper class for advanced math used in various spline Geometry.
	**/ 
	public class Consts{
  		public static const ZERO_TOL:Number = 0.0001; // zero tolerance
    
    	public static const PI_2:Number       = 0.5*Math.PI;
    	public static const PI_4:Number       = 0.25*Math.PI;
	    public static const PI_8:Number       = 0.125*Math.PI;
	    public static const PI_16:Number      = 0.0625*Math.PI; 
	    public static const TWO_PI:Number     = 2.0*Math.PI;
	    public static const THREE_PI_2:Number = 1.5*Math.PI;
	    public static const ONE_THIRD:Number  = 1.0/3.0;
	    public static const TWO_THIRDS:Number = ONE_THIRD + ONE_THIRD;
	    public static const ONE_SIXTH:Number  = 1.0/6.0;
	    public static const DEG_TO_RAD:Number = Math.PI/180;
	    public static const RAD_TO_DEG:Number = 180/Math.PI;
    
	    public static const CIRCLE_ALPHA:Number = 4*(Math.sqrt(2)-1)/3.0;
	    
	    public static const ON:Boolean  = true;
	    public static const OFF:Boolean = false;
	    
	    public static const AUTO:String         = "A";
	    public static const DUPLICATE:String    = "D";
	    public static const EXPLICIT:String     = "E";
	    public static const CHORD_LENGTH:String = "C";
	    public static const ARC_LENGTH:String   = "AL";
	    public static const UNIFORM:String      = "U";
	    public static const FIRST:String        = "F"; 
	    public static const LAST:String         = "L";
	    public static const POLAR:String        = "P";
    
	    // Machine-dependent
	    private var _epsilon:Number;
	    	
	    public function Consts(){
	    	// Machine epsilon ala Eispack
	      	var _fourThirds:Number = 4.0/3.0;
	      	var _third:Number = _fourThirds - 1.0;
	      	var _one:Number = _third + _third + _third;
	      	_epsilon = Math.abs(1.0 - _one);
	    }
	
	    public function get EPSILON():Number { 
	    	return _epsilon; 
	    }
	}
}