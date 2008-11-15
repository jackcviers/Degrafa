package com.degrafa.geometry.display{
	
	import flash.display.DisplayObject;
	
	public interface IDisplayObjectProxy{
		function get displayObject():DisplayObject;
		function get transformBeforeRender():Boolean;
		function get layoutMode():String;
	}
}