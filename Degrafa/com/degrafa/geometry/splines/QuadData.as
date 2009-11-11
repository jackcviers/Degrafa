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
// Programmed by:  Jim Armstrong, (www.algorithmist.net)
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines
{
	/**
 	* QuadData is a holder class for the minimial number of parameters to define a quadratic Bezier curve.
 	* It serves as a cache for the creation parameters.
 	**/
  public class QuadData
  {
		  // properties
		  public var x0:Number;
		  public var y0:Number;
		  public var cx:Number;
		  public var cy:Number;
		  public var x1:Number;
		  public var y1:Number;
		  
		/**
		* @description 	Method: QuadData() - Construct a new QuadData instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function QuadData(_x0:Number=0, _y0:Number=0, _cx:Number=0, _cy:Number=0, _x1:Number=0, _y1:Number=0)
	   {
	    	x0 = _x0;
		    y0 = _y0;
		    cx = _cx;
		    cy = _cy;
		    x1 = _x1;
		    y1 = _y1;
	   }
	 }
}