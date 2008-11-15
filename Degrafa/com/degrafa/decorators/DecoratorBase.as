package com.degrafa.decorators{
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.geometry.command.CommandStack;

	public class DecoratorBase extends DegrafaObject implements IDecorator{
		public function DecoratorBase():void{
			super();
		}
		
		//overridden in sub classes
		public function initialize(stack:CommandStack):void{
			
			//walk the stack to add the delegates
			
		}
		
	}
}