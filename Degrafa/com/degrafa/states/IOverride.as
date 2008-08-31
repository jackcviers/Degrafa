////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

//modified for degrafa

package com.degrafa.states{

	import com.degrafa.geometry.Geometry;
	
	public interface IOverride{
		function initialize():void
		function apply(parent:IDegrafaStateClient):void;
		function remove(parent:IDegrafaStateClient):void;
	}
	
}
