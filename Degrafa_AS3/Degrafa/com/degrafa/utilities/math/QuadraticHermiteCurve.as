/**
/* QuadHermiteCurve.as - Construct a quadratic Hermite curve given two interpolation points and a start tangent.
*
* This code is derived from source bearing the following copyright notice,
*
* Copyright (c) 2009, Jim Armstrong.  All rights reserved.
*
* This software program is supplied 'as is' without any warranty, express, 
* implied, or otherwise, including without limitation all warranties of 
* merchantability or fitness for a particular purpose.  Jim Armstrong shall not 
* be liable for any special incidental, or consequential damages, including, 
* witout limitation, lost revenues, lost profits, or loss of prospective 
* economic advantage, resulting from the use or misuse of this software program.
*
* Programmed by  Jim Armstrong, (http://algorithmist.wordpress.com)
* Ported to Degrafa with full permission of author
**/

package com.degrafa.utilities.math
{
  public class QuadraticHermiteCurve
  {
    // first and last points
    private var __p0X:Number;
    private var __p0Y:Number;
    private var __p1X:Number;
    private var __p1Y:Number;
    
    // tangent
    private var __tX:Number;
    private var __tY:Number;
    
    // your friendly neighborhood quad. coefficients
    private var __c0X:Number;
    private var __c0Y:Number;
    private var __c1X:Number;
    private var __c1Y:Number;
    private var __c2X:Number;
    private var __c2Y:Number;
    
    private var __invalidated:Boolean;
    
/**
 * <code>QuadraticHermitCurve</code> Construct a new QuadraticHeriteCurve instance.
 *
 * @param _x0:Number x-coordinate of first interpolation point 
 * @default 0
 * 
 * @param _y0:Number y-coordinate of first interpolation point
 * @default 0
 * 
 * @param _x1:Number x-coordinate of second inpterolation point
 * @default 0
 * 
 * @param _y1:Number y-coordinate of second interpolation point
 * @default 0
 * 
 * @param _tx:Number x-coordinate of start tangent (tangent to first interpolation point)
 * @default 0
 * 
 * @param _ty:Number y-coordinate of start tangent (tangent to first interpolation point)
 * @since 1.0
 *
 * @return Nothing.  Make sure to enter the endpoints of the tangent vector in the parent coordinate system.
 */
    public function QuadraticHermiteCurve(_x0:Number=0, _y0:Number=0, _x1:Number=0, _y1:Number=0, _tx:Number=0, _ty:Number=0)
    {
      __p0X = _x0;
      __p0Y = _y0;
      __p1X = _x1;
      __p1Y = _y1;
      __tX  = _tx;
      __tY  = _ty;
      __c0X = 0;
      __c0Y = 0;
      __c1X = 0;
      __c1Y = 0;
      __c2X = 0;
      __c2Y = 0;
      
      __invalidated = true;
    }

    public function getCoef():Object
    {
      return {c0X:__c0X, c0Y:__c0Y, c1X:__c1X, c1Y:__c1Y, c2X:__c2X, c2Y:__c2Y};
    }
/**
* <code>[set] x0</code> Assign x-coordinate of first interpolation point
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set x0(_n:Number):void 
    {
      __p0X         = _n; 
      __invalidated = true;
    }
    
/**
* <code>[set] y0</code> Assign y-coordinate of first interpolation point
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set y0(_n:Number):void 
    {
      __p0Y         = _n; 
      __invalidated = true;
    }
    
/**
* <code>[set] x1</code> Assign x-coordinate of second interpolation point
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set x1(_n:Number):void 
    {
      __p1X         = _n; 
      __invalidated = true;
    }
    
/**
* <code>[set] y1</code> Assign y-coordinate of second interpolation point
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set y1(_n:Number):void 
    {
      __p1Y         = _n; 
      __invalidated = true;
    }
    
/**
* <code>[set] tx</code> Assign x-coordinate of start tangent
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set tx(_n:Number):void 
    {
      __tX         = _n; 
      __invalidated = true;
    }
    
/**
* <code>[set] y0</code> Assign y-coordinate of start tangent
*
* @return Nothing.
*
* @since 1.0
*
*/
    public function set ty(_n:Number):void 
    {
      __tY         = _n; 
      __invalidated = true;
    }
 
/**
* <code>getX</code> Access the x-coordinate of the curve at the specified t-parameter
*
* @param _t:Number t-paramter in [0,1].
* 
* @return Number x-coordinate of quadratic Hermite curve at the specified t-parameter.  Extrapolating outside [0.1] is allowed, but not recommended.  Assign
* interpolation points and start tangent before calling this method.
*
* @since 1.0
*
*/
    public function getX(_t:Number):Number
    {
      if( __invalidated )
      {
        __computeCoef();
      }
      
      return __c0X + _t*(__c1X + _t*__c2X);
    }
    
/**
* <code>getY</code> Access the y-coordinate of the curve at the specified t-parameter
*
* @param _t:Number t-paramter in [0,1].
* 
* @return Number y-coordinate of quadratic Hermite curve at the specified t-parameter.  Extrapolating outside [0.1] is allowed, but not recommended.  Assign
* interpolation points and start tangent before calling this method.
*
* @since 1.0
*
*/
    public function getY(_t:Number):Number
    {
      if( __invalidated )
      {
        __computeCoef();
      }
      
      return __c0Y + _t*(__c1Y + _t*__c2Y);
    }
    
/**
* <code>getXPrime</code> Access the x-coordinate of dx/dt at the specified t-parameter
*
* @param _t:Number t-paramter in [0,1].
* 
* @return Number x-coordinate of dx/dt at the specified t-parameter.  Extrapolating outside [0.1] is allowed, but not recommended.  Assign
* interpolation points and start tangent before calling this method.
*
* @since 1.0
*
*/
    public function getXPrime(_t:Number):Number
    {
      if( __invalidated )
      {
        __computeCoef();
      }
      
      return __c1X + 2.0*__c2X*_t;
    }
 
/**
* <code>getYPrime</code> Access the x-coordinate of dy/dt at the specified t-parameter
*
* @param _t:Number t-paramter in [0,1].
* 
* @return Number y-coordinate of dy/dt at the specified t-parameter.  Extrapolating outside [0.1] is allowed, but not recommended.  Assign
* interpolation points and start tangent before calling this method.
*
* @since 1.0
*
*/   
    public function getYPrime(_t:Number):Number
    {
      if( __invalidated )
      {
        __computeCoef();
      }
      
      return __c1Y + 2.0*__c2Y*_t;
    }
    
    private function __computeCoef():void
    {
      // as an exercise, fold these coefficients directly into the x-y point evaluation and optimize
      __c0X = __p0X;
      __c0Y = __p0Y; 
      __c1X = __tX - __p0X; 
      __c1Y = __tY - __p0Y;
      __c2X = __p1X - __p0X - (__tX-__p0X);
      __c2Y = __p1Y - __p0Y - (__tY-__p0Y);
      
      __invalidated = false;
    }
  }
}