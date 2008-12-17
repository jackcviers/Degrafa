//
// Bisect.as - A simple implementation of bisection to identify intervals of a function in which there is a sign change.
// This is a generic implementation, unlike the version inside the Bezier classes that is embedded for a bit extra
// performance.
//
// This code is derived from source bearing the following copyright notice
//
// copyright (c) 2006-2008, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Programmed by Jim Armstrong, (http://algorithmist.wordpress.com)
// Ported to Degrafa with full consent of author
//
/**
 * @version 1.0
 */
 
package com.degrafa.utilities.math
{  
  public class Bisect
  {
    private static const BISECT_LIMIT:Number = 0.05;  // will probably make this changeable in the future
  
    public function Bisect()
    {
      // Empty
    }

/**
* @param _f:Function function whose root(s) are desired
* @param _left:Number leftmost x-coordinate of interval to be bisected
* @param _right:Number rightmost x-coordinate of interval to be bisected
*
* @return Object 'left' property contains the leftmost x-coordinate of the interval and 'right' property contains the rightmost x-coordinate of the interval.
* returns null if the right interval value is less than the left value or the interval has been reduced to below the bisection limit with no sign change.
*
* @since 1.0
*
*/
    public static function bisection(_f:Function, _left:Number, _right:Number):Object
    {
      if( _right < _left )
      {
        return null;
      }
      
      if( Math.abs(_right-_left) <= BISECT_LIMIT )
      {
        return null;
      }
      
      var middle:Number = 0.5*(_left+_right);
      if( _f(_left)*_f(_right) <= 0 )
      {
        return {left:_left, right:_right};
      }
      else
      {
        var leftInterval:Object  = bisection(_f, _left, middle);
        if( leftInterval != null )
          return leftInterval;
          
        var rightInterval:Object = bisection(_f, middle, _right);
        if( rightInterval != null )
          return rightInterval;
      }
      
      return null;
    }
  }
}