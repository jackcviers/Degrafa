////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.utilities.external {
	
	


	
	/**
	* The ExternalDataAsset class defines the properties for an external data source used at runtime by Degrafa. 
	* You can use an ExternalDataAsset object in actionscript - it may be useful to 
	* set up preloading, for example, but in mxml use of an ExternalDataAsset is already encapsulated into 
	* the Degrafa class that uses the content (when it is ready) by virtue of its source property assignment.
	* The data content provided by an ExternalDataAsset will only be available once the asset from the external url has 
	* loaded.
	*/
	public interface IExternalData {
	
		

		
		//process the URLLoader or Loader object to extract the data from 
		//after a successful load has finished, returning a Status value
		//function processLoad(_loader:Object):String
		//perform cleanup activities after successful load
		//function cleanUp():void

	}
}
	
