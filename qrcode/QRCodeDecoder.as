package qrcode {
  import flash.display.*;
  import flash.geom.*;
  import flash.utils.*;

  public class QRCodeDecoder {
    public static function decode(pixels:BitmapData,
        debug:BitmapData=null):DecodeResult {
      var binaryPixels:BitmapData = createBinaryPixels(pixels);
      debug.fillRect(new Rectangle(0,0,debug.width,debug.height), 0x00000000);
      debug.draw(binaryPixels);

      var patterns:Object = FinderPattern.findPattern(binaryPixels, debug);

      var result:DecodeResult = new DecodeResult();
      result.pos.leftTop = patterns.leftTop; 
      result.pos.rightTop = patterns.rightTop; 
      result.pos.leftBottom = patterns.leftBottom; 
      result.text = result.pos.leftTop.toString();

      return result;
    }

    private static function createBinaryPixels(pixels:BitmapData):BitmapData {
      var nDivision:int = 4;
      var binaryPixels:BitmapData = new BitmapData(pixels.width, pixels.height);

      var areaWidth:int=binaryPixels.width/nDivision;
      var areaHeight:int=binaryPixels.height/nDivision;
      
      for (var ay:int=0; ay<nDivision; ay++) {
        for (var ax:int=0; ax<nDivision; ax++) {
          var rectangle:Rectangle = new Rectangle(ax*areaWidth, ay*areaHeight, 
              areaWidth, areaHeight);

          var samples:ByteArray = pixels.getPixels(rectangle);
          var i:int;
          var offset:int;
          var threshold:uint=0;
          for (i=0,offset=0; i<samples.length; i++,
              offset+=samples.length/(nDivision*nDivision)) {
            threshold+=samples[offset] & 0xff;
          }
          threshold = threshold/i+0x40;
          var color:uint = 0x00000000;
          var maskColor:uint = 0x000000ff;
        
          binaryPixels.threshold(pixels, rectangle, new Point(ax*areaWidth,
                ay*areaHeight), "<=", threshold, color, maskColor, false);
        }
      }
      return binaryPixels;
    }
  }
}
