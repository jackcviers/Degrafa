package com.degrafa.utilities.swf
{
	import com.degrafa.utilities.SWFReader;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SWFShapeReader
	{
		
		private var shapeType:int;
		
		private var numFillBits:uint;
		private var numLineBits:uint;
		
		private var fillStyles:Array;
		private var lineStyles:Array;
		
		public var path:String;
		
		public var drawCommands:Array=[];
		
		private var lastMovePoint:Point= new Point(0,0);
		private var hasMove:Boolean;
		
		private var x:Number;
		private var y:Number;
		
		private var xx:Number;
		private var yy:Number;
		
		public static var RETURN_TYPE_PATH:int =0;
		public static var RETURN_TYPE_DRAW_COMMAND_ARRAY:int =1;
		
		public function readShape(start:uint, end:uint, bytes:ByteArray,returnType:int=0):void {
			
			//trace('{ShapeReader.readShape} start = ' + start + '; end = ' + end);
		
			var bits:uint;
			
			bytes.position = start;
			bytes.endian = Endian.LITTLE_ENDIAN;

			shapeType = 1;
			fillStyles = [];
			lineStyles = [];

	
			// Read the number of fill/line bits
			SWFReader.syncBits();			
			
			numFillBits = SWFReader.readUBits(4, bytes);
			numLineBits = SWFReader.readUBits(4, bytes);
		
//			numFillBits = 0;
//			numLineBits = 1;	
						
			//trace('fill bits: ' + numFillBits + ', line bits: ' + numLineBits);
	
			if(returnType==RETURN_TYPE_PATH){
				path = "";
		
					readShapeRecords(bytes);
					
				path += "Z";
			}
			else if (returnType==RETURN_TYPE_DRAW_COMMAND_ARRAY){
				drawCommands.length=0;
				readShapeRecords(bytes,returnType);
				
				//close the path
				drawCommands.push({type:1,x:lastMovePoint.x,y:lastMovePoint.y});
				
			}
		}
		
		public function readShapeRecords(bytes:ByteArray,returnType:int=0):Array {
			
			var records:Array = [];
			var record:Object;

			xx = yy = x = y = Number.NaN;
			
			do {
				record = readOneShapeRecord(bytes,returnType);
				if (record) {
					records.push(record); 
				}
			}
			while (record);
			
			return records;
		}
		
		private function readOneShapeRecord(bytes:ByteArray,returnType:int=0):Object {
			
			var record:Object = new Object();
			
			var typeFlag:uint;
			
			// Style change record flags
			var newStylesFlag:uint;
			var lineStyleFlag:uint;
			var fillStyle1Flag:uint;
			var fillStyle0Flag:uint;
			var moveToFlag:uint;

			// Edge record flags
			var straightFlag:uint;
			var generalLineFlag:int;
			var vertLineFlag:int;
			
			var numBits:uint;
			
			var moveDeltaX:int;
			var moveDeltaY:int;
			var controlDeltaX:int;
			var controlDeltaY:int;
			var anchorDeltaX:int;
			var anchorDeltaY:int;
			var fillStyle0:int;
			var fillStyle1:int;
			var lineStyle:int;
			
			var fontBaseline:int = Number.NaN;
						
			typeFlag = SWFReader.readUBits(1, bytes);
			
			if (typeFlag == 0) {	// Type of zero means it's a non-edge record

				newStylesFlag = SWFReader.readUBits(1, bytes); 		
				lineStyleFlag = SWFReader.readUBits(1, bytes);		
				fillStyle1Flag = SWFReader.readUBits(1, bytes);		
				fillStyle0Flag = SWFReader.readUBits(1, bytes);		
				moveToFlag = SWFReader.readUBits(1, bytes);		

	
					if (newStylesFlag | lineStyleFlag | fillStyle1Flag | fillStyle0Flag | moveToFlag) {
					
					
				//	trace('[StyleChangeRecord] ' + newStylesFlag + ' ' + lineStyleFlag + ' ' + fillStyle1Flag + ' ' + fillStyle0Flag + ' ' + moveToFlag);					
					// If any of these flags are set, it's a StyleChangeRecord
					
					if (moveToFlag) {
						numBits = SWFReader.readUBits(5, bytes);	
							
						moveDeltaX = SWFReader.readSBits(numBits, bytes);
	
						moveDeltaY = SWFReader.readSBits(numBits, bytes);
						
						
						if (isNaN(x) && isNaN(y)) {						

							fontBaseline = 0; // 1024 - (moveDeltaY / 20);

						//	trace('Baseline: ' + fontBaseline);

							x = moveDeltaX / 20;
							y = moveDeltaY / 20 + fontBaseline;
														
							xx = moveDeltaX;
							yy = moveDeltaY;
						}
						else {
							x = moveDeltaX / 20;
							y = moveDeltaY / 20; // + fontBaseline;
							xx = moveDeltaX;
							yy = moveDeltaY;
						}
						
						if(returnType==RETURN_TYPE_PATH){
							path += "M" + (Math.abs(x) < 0.0001 ? 0 : x) + "," + (Math.abs(y) < 0.0001 ? 0 : y);	
						}
						else{	
							
							//set the current point to close to
							lastMovePoint.x = (Math.abs(x) < 0.0001 ? 0 : x);
							lastMovePoint.y = (Math.abs(y) < 0.0001 ? 0 : y);
							
							//finally add the move	
							drawCommands.push({type:0, x:(Math.abs(x) < 0.0001 ? 0 : x),y:(Math.abs(y) < 0.0001 ? 0 : y)});
						}
						
						//trace('SSCR' + numBits + '\t' + moveDeltaX +  '\t' + moveDeltaY + '\t\t\t\t\t\t' + xx + '\t' + yy);
								
					}
					
					
				
					if (fillStyle0Flag) {
						fillStyle0 = SWFReader.readUBits(numFillBits, bytes);
					}
					
					if (fillStyle1Flag) {
						fillStyle1 = SWFReader.readUBits(numFillBits, bytes);
					}
					
					if (lineStyleFlag) {
						lineStyle = SWFReader.readUBits(numLineBits, bytes);
					}

					
					if (newStylesFlag && (shapeType == 2 || shapeType == 3)) {
						fillStyles = readFillStyles(bytes);
						lineStyles = readLineStyles(bytes);
						SWFReader.syncBits();
						numFillBits = SWFReader.readUBits(4, bytes);
						numLineBits = SWFReader.readUBits(4, bytes);
 					}
 					
					
				}
				else {
					
				//	trace('[EndShapeRecord]');
										
					// It's an EndShapeRecord, return null.
					return null;	
				}
				
			}
			else {	// Handle the edge records now.
				
				straightFlag = SWFReader.readUBits(1, bytes);

				numBits = SWFReader.readUBits(4, bytes) + 2;
	
				if (straightFlag) {		// It's a straight edge
							
					generalLineFlag =	SWFReader.readUBits(1, bytes);
					
					if (generalLineFlag == 0) {
						vertLineFlag = 	SWFReader.readUBits(1, bytes);
					}
					
					moveDeltaX = (generalLineFlag == 1 || vertLineFlag == 0) ? SWFReader.readSBits(numBits, bytes) : 0;
					moveDeltaY = (generalLineFlag == 1 || vertLineFlag == 1) ? SWFReader.readSBits(numBits, bytes) : 0;					

					xx += moveDeltaX;
					yy += moveDeltaY;

					//trace('SER\t' + moveDeltaX + '\t' + moveDeltaY + '\t\t\t\t\t\t' + xx + '\t' + yy);
				
					x += moveDeltaX / 20;
					y += moveDeltaY / 20 + fontBaseline;
					
					if(returnType==RETURN_TYPE_PATH){						
						path += "L" + (Math.abs(x) < 0.0001 ? 0 : x) + "," + (Math.abs(y) < 0.0001 ? 0 : y);
					}
					else{
						drawCommands.push({type:1, x:(Math.abs(x) < 0.0001 ? 0 : x),y:(Math.abs(y) < 0.0001 ? 0 : y)});
					}
						
					
				}
				else {					// It's a curved edge
					
					controlDeltaX = SWFReader.readSBits(numBits, bytes);
					controlDeltaY = SWFReader.readSBits(numBits, bytes);
					anchorDeltaX  = SWFReader.readSBits(numBits, bytes);
					anchorDeltaY  = SWFReader.readSBits(numBits, bytes);					
					
					var cx:Number = x + controlDeltaX / 20;
					var cy:Number = y + controlDeltaY / 20 + fontBaseline;
					var ax:Number = cx + anchorDeltaX / 20;
					var ay:Number = cy + anchorDeltaY / 20 + fontBaseline;
					
					x = ax;
					y = ay;

					xx += controlDeltaX + anchorDeltaX;
					yy += controlDeltaY + anchorDeltaY;
					
					if(returnType==RETURN_TYPE_PATH){
						path += "Q" + (Math.abs(cx) < 0.0001 ? 0 : cx) + "," + (Math.abs(cy) < 0.0001 ? 0 : cy) + "," + (Math.abs(ax) < 0.0001 ? 0 : ax) + "," + (Math.abs(ay) < 0.0001 ? 0 : ay);	
					}
					else{
						drawCommands.push({type:2, cx:(Math.abs(cx) < 0.0001 ? 0 : cx),
						cy:(Math.abs(cy) < 0.0001 ? 0 : cy),
						x1:(Math.abs(ax) < 0.0001 ? 0 : ax),
						y1:(Math.abs(ay) < 0.0001 ? 0 : ay)});
					}
					//trace('CER\t' + controlDeltaX + '\t' + controlDeltaY +'\t' + anchorDeltaX + '\t' + anchorDeltaY + '\t\t\t\t' + xx + '\t' + yy);

					
				}
				
			
			}
		
			return record;
		}

		private function readFillStyles(bytes:ByteArray):Array {
			var results:Array = [];
			var count:uint = bytes.readUnsignedByte();
			
			if ((shapeType == 2 || shapeType == 3) && count == 0xFF) {	
				count = bytes.readUnsignedShort();
			}
			
			while (count--) {
				results.push(readOneFillStyle(bytes));
			}
				
			return results;
		}
		
		private function readLineStyles(bytes:ByteArray):Array {
			var results:Array = [];
			var count:uint = bytes.readUnsignedByte();
			
			if (count == 0xFF) {	
				count = bytes.readUnsignedShort();
			}
			
			while (count--) {
				if (shapeType < 4) {
					results.push(readOneLineStyle(bytes));
				}
				else {
					throw new Error('ouch panic');
//					results.push(readOneLineStyle2(bytes));
				}
			}
				
			return results;	
		}

		private function readOneFillStyle(bytes:ByteArray):void {
			
			var type:uint = bytes.readUnsignedByte();
			var red:uint, green:uint, blue:uint, alpha:uint;
			
			switch(type) {
				case 0x00:		// Solid Fill
				case 0x10:		// Linear Gradient Fill
				case 0x12:		// Radial Gradient Fill
				case 0x13:		// Focal Gradient Fill
				case 0x40:		// Repeating Bitmap Fill
				case 0x41:		// Clipped Bitmap Fill
				case 0x42:		// Non-Smoothed Repeating Bitmap
				case 0x43:		// Non-Smoothed Clipped Bitmap
					break;
				default:
					//trace('Invalid Fill Style...');
					break;
			}
			
			if (type == 0x00) {
				
				red = bytes.readUnsignedByte();
				green = bytes.readUnsignedByte();
				blue = bytes.readUnsignedByte();
				
				if (shapeType == 3) {
					alpha = bytes.readUnsignedByte();
				}
				
			}
			
			if (type > 0) {
				throw new Error('ouch panic');
			}
			
		}
		
		private function readOneLineStyle(bytes:ByteArray):void {

			var width:uint = bytes.readUnsignedShort();
			var red:uint = bytes.readUnsignedByte();
			var green:uint = bytes.readUnsignedByte();
			var blue:uint = bytes.readUnsignedByte();
			
			if (shapeType == 3) {
				var alpha:uint = bytes.readUnsignedByte();
			}
						
		}

	}
}
