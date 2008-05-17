package com.degrafa.utilities
{
	import flash.system.Security;
	import mx.core.Application;
	import com.degrafa.core.DegrafaObject;
	import mx.core.IMXMLObject;
	import mx.utils.NameUtil;
	import com.degrafa.utilities.LoadingLocation;
	
	//the default property for LoadingGroup is the array of LoadingLocation instances
	[DefaultProperty("locations")]
	
	/**
	* A LoadingGroup is a basic means to manage groups of external data assets (eg ExternalBitmaps) loaded from the same external location(s).
	* A LoadingGroup provides a means to specify a domain/basepath against which external asset urls can be further specified as a simple relative path.
	* E.g. If an ExternalBitmap has a LoadingGroup assigned to its loadingGroup property then it is expected that the ExternalBitmap url assignment is relative
	* This permits easy maintenance of ExternalBitmap locations in code as changes only need to be made at the relevant LoadingGroup instance.
	* Additionally, automated redundancy with backup copies of the ExternalBitmaps at multiple locations can be managed through the relevant LoadingGroup instance.
	* This example makes most sense when runtime bitmap media are accessed from domains other than the domain of the degrafa flex application
	* @author Greg Dove
	*/
	public class LoadingGroup implements IMXMLObject
	{
		private var _locations:Array = []; // array of loading locations
		private var _locationIndex:uint = 0; //most often this should be zero during runtime use unless there is a problem with that domain (and backups have been specified)
		private var _retriesPerLocation:uint = 1; //policy in the event of loading or permission errors 
				
		/**
		 * LoadingGroup constructor.
		 * @param	policyFile	optional quicksetup for a single location/domain LoadingGroup from as
		 * @param	basepath	optional quicksetup for a single location/domain LoadingGroup from as
		 */
		public function LoadingGroup(basepath:String = null, policyFile:String = null):void {
			if (basepath) addLocation(new LoadingLocation(basepath, policyFile));
		}
		
		public function addLocation(location:LoadingLocation):void
		{
		_locations.push(location);
		//if a policy file is not specified then explicitly specify the use of a/the default.	
		if (location.policyFile == null)
				{
					var tmpLoc:Object = LoadingLocation.extractLocation(location.basePath);
					location.policyFile = tmpLoc.protocol + tmpLoc.domain + "/crossdomain.xml";
				}
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
				case "application": //TODO: does AIR need them? uncertain, TO VERIFY
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
		/**
		 * requests the policy file associated with the current location index (once only, and if the security settings require it).
		 * a policy file request merely needs to precede any relevant external loading request(s)
		 * flash player will not 'fail' an external loading request while a relevant policy file request has been
		 * queued. It will only 'fail' it once the policy attempts have failed (explicit and default policy file locations)
		 */
		public function loadPolicyFile():void
		{
			if (LoadingGroup.requiresPolicyFile()) //don't bother if it's not necessary
			{
				if (!_locations[_locationIndex].requestedPolicyFile)
				{
					_locations[_locationIndex].requestPolicyFile();
				}
			}
			
		}
		
		/**
		 *  Request that LoadingGroup instance accesses return the next location: a single valid request for the next location will result in the next location being used for all subsequent
		 *  LoadingGroup instance associations
		 * @return a boolean value indicating whethe the request to advance to another location was successful
		 */
		public function nextLocation():Boolean
		{
			if (_locationIndex  < _locations.length-1) {
				_locationIndex++;
				loadPolicyFile();
				return true;
			} else {
				//no further options to try
				return false;
			}
			
		}
		/**
		 * method to access the current basePath setting for relative urls. This reflects
		 * the current status of the location index which is affected by calls to nextLocation
		 * @return a string representing the basePath against which to apply relative urls for the current location for this LoadingGroup
		 */
		public function getBasePath():String
		{
			return _locations[_locationIndex].basePath;
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

		private var _document:Object;
		/**
		*  The MXML document that created this object.
		**/
		public function get document():Object{
			return _document;
		}
			
		/**
		*  INTERFACE mx.core.IMXMLObject 
		* Called after the implementing object has been created and all component properties specified on the MXML tag have been initialized.
		* 
		* @param document The MXML document that created this object.
		* @param id The identifier used by document to refer to this object.  
		**/
    	public function initialized(document:Object, id:String):void{
	        
	        //if the id has not been set (through as perhaps)
	        if(!_id){	        
		        if(id){
		        	_id = id;
		        }
		        else{
		        	//if no id specified create one
		        	_id = NameUtil.createUniqueName(this);
		        }
	        }
	        _document=document;
	        
	        
	        _isInitialized = true;
	         	        
	      
	    }
	    
		
		public function toString():String
		{
			return "[LoadingGroup " + this.id + "]";
		}
	    /**
		* A boolean value indicating that this object has been initialized
		**/
		private var _isInitialized:Boolean;
	    public function get isInitialized():Boolean{
	    	return _isInitialized;
	    }	    
	    
		//getters/setters
		public function get retriesPerLocation():uint { return _retriesPerLocation; }
		
		public function set retriesPerLocation(value:uint):void 
		{
			_retriesPerLocation = value;
		}

		[ArrayElementType("com.degrafa.utilities.LoadingLocation")]
		public function set locations(value:Array):void
		{
			_locations = value;
		}
		
		public function get locationIndex():uint { return _locationIndex; }
	}
	
}