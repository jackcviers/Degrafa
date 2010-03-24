//
// Gauss.as - Gauss-Legendre Numerical Integration. 
//
// This code is derived from source bearing the following copyright notice,
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special
// incidental, or consequential damages, including, without limitation, lost
// revenues, lost profits, or loss of prospective economic advantage, resulting
// from the use or misuse of this software program.
//
// Programmed by:  Jim Armstrong, (http://algorithmist.wordpress.com)
// Ported to Degrafa with full consent of the author
//
/**
 * @version 1.0
 */
package com.degrafa.utilities.math
{
  import flash.events.EventDispatcher;
  import flash.events.Event;
  
  public class Gauss extends EventDispatcher
  {
    public static const MAX_POINTS:Number     = 8;
    public static const INVALID_PARAMS:String = "invalid_parameters";
    
    // core
    private var __abscissa:Array;         // abscissa table
    private var __weight:Array;           // weight table

    public function Gauss()
    { 
      __abscissa = new Array();
      __weight   = new Array();
      
      // N=2
      __abscissa.push(-0.5773502692);
      __abscissa.push( 0.5773502692);

      __weight.push(1);
      __weight.push(1);

      // N=3
      __abscissa.push(-0.7745966692);
      __abscissa.push( 0.7745966692);
      __abscissa.push(0);
    
      __weight.push(0.5555555556); 
      __weight.push(0.5555555556);
      __weight.push(0.8888888888);

      // N=4
      __abscissa.push(-0.8611363116);
      __abscissa.push( 0.8611363116);
      __abscissa.push(-0.3399810436);
      __abscissa.push( 0.3399810436);

      __weight.push(0.3478548451);
      __weight.push(0.3478548451);
      __weight.push(0.6521451549);
      __weight.push(0.6521451549);

      // N=5
      __abscissa.push(-0.9061798459);
      __abscissa.push( 0.9061798459);
      __abscissa.push(-0.5384693101);
      __abscissa.push( 0.5384693101);
      __abscissa.push( 0.0000000000);

      __weight.push(0.2369268851);
      __weight.push(0.2369268851);
      __weight.push(0.4786286705);
      __weight.push(0.4786286705);
      __weight.push(0.5688888888);
 
      // N=6
      __abscissa.push(-0.9324695142);
      __abscissa.push( 0.9324695142);
      __abscissa.push(-0.6612093865);
      __abscissa.push( 0.6612093865);
      __abscissa.push(-0.2386191861);
      __abscissa.push( 0.2386191861);

      __weight.push(0.1713244924);
      __weight.push(0.1713244924);
      __weight.push(0.3607615730);
      __weight.push(0.3607615730);
      __weight.push(0.4679139346);
      __weight.push(0.4679139346);
 
      // N=7
      __abscissa.push(-0.9491079123);
      __abscissa.push( 0.9491079123);
      __abscissa.push(-0.7415311856);
      __abscissa.push( 0.7415311856);
      __abscissa.push(-0.4058451514);
      __abscissa.push( 0.4058451514);
      __abscissa.push( 0.0000000000);

      __weight.push(0.1294849662);
      __weight.push(0.1294849662);
      __weight.push(0.2797053915);
      __weight.push(0.2797053915);
      __weight.push(0.3818300505);
      __weight.push(0.3818300505);
      __weight.push(0.4179591837);

      // N=8
      __abscissa.push(-0.9602898565); 
      __abscissa.push( 0.9602898565);
      __abscissa.push(-0.7966664774);
      __abscissa.push( 0.7966664774);
      __abscissa.push(-0.5255324099);
      __abscissa.push( 0.5255324099);
      __abscissa.push(-0.1834346425); 
      __abscissa.push( 0.1834346425);

      __weight.push(0.1012285363);
      __weight.push(0.1012285363);
      __weight.push(0.2223810345);
      __weight.push(0.2223810345);
      __weight.push(0.3137066459);
      __weight.push(0.3137066459);
      __weight.push(0.3626837834);
      __weight.push(0.3626837834);
    }

/**
* @param _f:Function - Reference to function to be integrated - must accept a numerical argument and return 
*                      the function value at that argument.
*
* @param _a:Number   - Left-hand value of interval.
* @param _b:Number   - Right-hand value of inteval.
* @param _n:Number   - Number of points -- must be between 2 and 8
*
* @return Number - approximate integral value over [_a, _b] or 0 if an error condition occured.  Assign a handler for the 
* 'invalid_parameters' event.  The three possible error conditions are 1) non-numeric values for the interval,  2) an invalid
* interval, 3) an invalid function reference, and 4) an invalid number of samples (must be between two and 8 
*
* @since 1.0
*
*/
    public function eval(_f:Function, _a:Number, _b:Number, _n:uint=5):Number
    {
      // evaluate the integral over the specified interval
      if( isNaN(_a) || isNaN(_b) )
      {
        dispatchEvent( new Event(INVALID_PARAMS) );
        return 0;
      } 

      if( _a >= _b )
      {
        dispatchEvent( new Event(INVALID_PARAMS) );
        return -0;
      }

      if( !(_f is Function) )
      {
        dispatchEvent( new Event(INVALID_PARAMS) );
        return 0;
      }
 
      if( isNaN(_n) || _n < 2 )
      {
        dispatchEvent( new Event(INVALID_PARAMS) );
        return 0;
      }

      var n:uint = Math.max(_n,2);
      n          = Math.min(n,MAX_POINTS);

      var l:uint     = (n==2) ? 0 : n*(n-1)/2 - 1;
      var sum:Number = 0;

      if( _a == -1 && _b == 1 )
      {
        for( var i:uint=0; i<n; ++i )
          sum += _f(__abscissa[l+i])*__weight[l+i];

        return sum;
      }
      else
      {
        // change of variable
        var mult:Number = 0.5*(_b-_a);
        var ab2:Number  = 0.5*(_a+_b);
        for( i=0; i<n; ++i )
          sum += _f(ab2 + mult*__abscissa[l+i])*__weight[l+i];

        return mult*sum;
      }
    }
  }
}