all:
	mxmlc -debug=true -default-size 640 260 QRCodeReader.as
	#fdb QRCodeReader.swf
	#open -a "Firefox" QRCodeReader.swf
	#open -a "Flash Player" QRCodeReader.swf
