package com.degrafa.utilities.external
{
	import mx.core.Application;
	import flash.system.Security;
	import mx.utils.NameUtil;

	/**
	* A representation of a loading location specified in terms of a base path and 
	* crossdomain policy file to be accessed. To be associated with externally loaded content.
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
		/**
		 * a test to see if the local application requires loading of policy files to permit access to external data
		 * @return boolean value indicating whether this application type requires loading of policy files prior to accessing data
		 */
		private static function requiresPolicyFile():Boolean
		{
			var rpf:Boolean;
			switch (Security.sandboxType)
			{
				case "application": //TODO: does AIR need them? don't think so, uncertain, TO VERIFY
					rpf= false;
				break;
				case Security.REMOTE:
				case Security.LOCAL_TRUSTED:
				case Security.LOCAL_WITH_NETWORK:
					rpf= true;
				break;
				case Security.LOCAL_WITH_FILE:
					trace('this swf cannot communicate with the internet');
					rpf= false;
				break;
			}
			return rpf;
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
		if (!_requestedPolicyFile && LoadingLocation.requiresPolicyFile()) {
		if (_basepath){
				if (_policyFile == null)
				{
						tmpLoc = LoadingLocation.extractLocation(_basepath);
					_policyFile = tmpLoc.protocol + tmpLoc.domain + "/crossdomain.xml";
				}
				//may need to consider excluding the file:// protocol here, where a policy file would not be required although its not unsually specified.
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
		
		private var _id:String;
		/**
		* The identifier used by document to refer to this object.
		**/ 
		public function get id():String{
			
			if(_id){
				return _id;	
			}
			else{
				_id =NameUtil.createUniqueName(this);
				return _id;
			}
		}
		public function set id(value:String):void{
			_id = value;
		}
		
		/**
		* The name that refers to this object.
		**/ 
		public function get name():String{
			return id;
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
	
