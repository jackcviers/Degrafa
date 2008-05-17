package com.degrafa.utilities
{
	import mx.core.Application;
	import flash.system.Security;

	/**
	* A representation of a loading location specified in terms of a base path and 
	* policy file to be accessed first
	* */
	public class  LoadingLocation 
	{
		private var _basepath:String=null;
		private var _policyFile:String=null;
		private var _requestedPolicyFile:Boolean = false;
		
		
		/**
		 * static utility function to extract location elements from a url or the location of the flex application
		 * @param	url
		 * @return  an object with protocol, domain, and basepath properties
		 */
		public static function extractLocation(url:String=null):Object
		{
		//TODO: consider converting this to regex. (but beware lack of accented characters not matching in \w)

		//if the url argument is not passed or the url appears to be a relative url then use the location of the flex application
		if (url == null || url.indexOf("//")==-1) url = Application.application.url;
			var retObj:Object = { };
			var arr:Array;
			
			if (url.indexOf("///")!=-1){ //required for file: protocol (works on pc, others?)
				arr=url.split("///");
				arr[1]="/"+arr[1];
			} else 	arr = url.split("//");
			
			retObj.protocol = arr.shift() + "//";
		
			arr=arr[0].split('/')
			
			retObj.domain = arr.shift();
			if (arr[arr.length-1]!="") arr[arr.length-1]=""
			
			retObj.basepath = "/"+arr.join("/")
			return retObj;
		}
		
		
		
		public function LoadingLocation(basepath:String = null, policyFile:String = null):void
		{
			if (basepath != null) {
				_basepath = basepath;
				_policyFile = policyFile;
			}
		}
		
		/**
		 * request the policyFile associated with this location, if it has not already been requested
		 */
		public function requestPolicyFile():void
		{
			var tmpLoc:Object;
			//if a policyfile is not specified then explicitly load a default instead of letting flash choose
		if (!_requestedPolicyFile) {
		if (_basepath){
				if (_policyFile == null)
				{
					tmpLoc = LoadingLocation.extractLocation(_basepath);
					_policyFile = tmpLoc.protocol + tmpLoc.domain + "/crossdomain.xml";
				}

				Security.loadPolicyFile(_policyFile);
				_requestedPolicyFile = true;
			
		} else {
			//basepath is not defined...so assume its the flex Application location - no policyfile needed
			tmpLoc = LoadingLocation.extractLocation(Application.application.url);
			_basepath = tmpLoc.protocol + tmpLoc.domain + tmpLoc.basepath;
			//assume we don't need a policyfile for this location, just flag as requested
			_requestedPolicyFile = true;
	
			}
		}
		}
		
		
		public function toString():String
		{
			return "[LoadingLocation " + _basepath + "]";
		}
		
		
		//getters/setters
		public function get basePath():String { return _basepath; }
		
		public function set basePath(value:String):void 
		{
			_basepath = value;
		}
		
		public function get policyFile():String { return _policyFile; }
		
		public function set policyFile(value:String):void 
		{
			_policyFile = value;
		}
		
		public function get requestedPolicyFile():Boolean { return _requestedPolicyFile; }

	}
}
	
