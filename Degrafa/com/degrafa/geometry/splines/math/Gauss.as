//
// Gauss.as - Gauss-Legendre Numerical Integration. 
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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)
//

package com.degrafa.geometry.splines.math{
	
	import flash.events.EventDispatcher;

	public class Gauss extends EventDispatcher{
  	
		public static const MAX_POINTS:Number = 8;
	
	    // core
	    private var _abscissa:Array;         // abscissa table
	    private var _weight:Array;           // weight table
	
		/**
		* @description 	Method: Gauss() - Construct a new Gauss instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	    public function Gauss(){
	    	 
	    	_abscissa = new Array();
	      	_weight   = new Array();
	     
		  	// N=2
		  	_abscissa.push(-0.5773502692);
		 	_abscissa.push( 0.5773502692);
		
		  	_weight.push(1);
		  	_weight.push(1);
		
		  	// N=3
		  	_abscissa.push(-0.7745966692);
		 	_abscissa.push( 0.7745966692);
		  	_abscissa.push(0);
		
		  	_weight.push(0.5555555556); 
		  	_weight.push(0.5555555556);
		  	_weight.push(0.8888888888);
		
		  	// N=4
		  	_abscissa.push(-0.8611363116);
		  	_abscissa.push( 0.8611363116);
		  	_abscissa.push(-0.3399810436);
		  	_abscissa.push( 0.3399810436);
		
		  	_weight.push(0.3478548451);
		  	_weight.push(0.3478548451);
		  	_weight.push(0.6521451549);
		  	_weight.push(0.6521451549);
		
		  	// N=5
		  	_abscissa.push(-0.9061798459);
		  	_abscissa.push( 0.9061798459);
		  	_abscissa.push(-0.5384693101);
		  	_abscissa.push( 0.5384693101);
		  	_abscissa.push( 0.0000000000);
		
		  	_weight.push(0.2369268851);
		  	_weight.push(0.2369268851);
		  	_weight.push(0.4786286705);
		  	_weight.push(0.4786286705);
		  	_weight.push(0.5688888888);
		 
		  	// N=6
		  	_abscissa.push(-0.9324695142);
		  	_abscissa.push( 0.9324695142);
		  	_abscissa.push(-0.6612093865);
		  	_abscissa.push( 0.6612093865);
		  	_abscissa.push(-0.2386191861);
		  	_abscissa.push( 0.2386191861);
		
		  	_weight.push(0.1713244924);
		  	_weight.push(0.1713244924);
		  	_weight.push(0.3607615730);
		  	_weight.push(0.3607615730);
		  	_weight.push(0.4679139346);
		  	_weight.push(0.4679139346);
		 
		  	// N=7
		  	_abscissa.push(-0.9491079123);
		  	_abscissa.push( 0.9491079123);
		  	_abscissa.push(-0.7415311856);
		  	_abscissa.push( 0.7415311856);
		  	_abscissa.push(-0.4058451514);
		  	_abscissa.push( 0.4058451514);
		  	_abscissa.push( 0.0000000000);
		
		  	_weight.push(0.1294849662);
		  	_weight.push(0.1294849662);
		  	_weight.push(0.2797053915);
		  	_weight.push(0.2797053915);
		  	_weight.push(0.3818300505);
		  	_weight.push(0.3818300505);
		  	_weight.push(0.4179591837);
		
		  	// N=8
		  	_abscissa.push(-0.9602898565); 
		  	_abscissa.push( 0.9602898565);
		  	_abscissa.push(-0.7966664774);
		  	_abscissa.push( 0.7966664774);
		  	_abscissa.push(-0.5255324099);
		  	_abscissa.push( 0.5255324099);
		  	_abscissa.push(-0.1834346425); 
		  	_abscissa.push( 0.1834346425);
		
		  	_weight.push(0.1012285363);
		  	_weight.push(0.1012285363);
		  	_weight.push(0.2223810345);
		  	_weight.push(0.2223810345);
		  	_weight.push(0.3137066459);
		  	_weight.push(0.3137066459);
		  	_weight.push(0.3626837834);
		  	_weight.push(0.3626837834);
	    }
	
		/**
		* @description 	Method: eval(_f:Function, _a:Number, _b:Number, _n:Number) - Approximate integral over specified range
		*
		* @param _f:Function - Reference to function to be integrated - must accept a numerical argument and return 
		*                      the function value at that argument.
		*
		* @param _a:Number   - Left-hand value of interval.
		* @param _b:Number   - Right-hand value of inteval.
		* @param _n:Number   - Number of points -- must be between 2 and 8
		*
		* @return Number - approximate integral value over [_a, _b]
		*
		* @since 1.0
		*
		*/
	    public function eval(_f:Function, _a:Number, _b:Number, _n:uint):Number{
	      
	    	if( isNaN(_a) || isNaN(_b) ){
	        	return 0;
	      	} 
	
	      	if( _a >= _b ){
	        	return 0;
	      	}	
	
	      	if( !(_f is Function) ){
	        	return 0;
	      	}
	 
	      	if( isNaN(_n) || _n < 2 ){
	        	return 0;
	      	}
	
	      	var n:uint = Math.max(_n,2);
	      	n = Math.min(n,MAX_POINTS);
	
	      	var l:uint = (n==2) ? 0 : n*(n-1)/2 - 1;
	      	var sum:Number = 0;
	
	      	if( _a == -1 && _b == 1 ){
	      		for( var i:uint=0; i<n; ++i )
	          		sum += _f(_abscissa[l+i])*_weight[l+i];
	
	        	return sum;
	      	}
	      	else{
	        	// change of variable
	        	var mult:Number = 0.5*(_b-_a);
	        	var ab2:Number  = 0.5*(_a+_b);
	        	for( i=0; i<n; ++i )
	          		sum += _f(ab2 + mult*_abscissa[l+i])*_weight[l+i];
		    
		    	return mult*sum;
	      	
	      	}
	      	
	    }
	}
}