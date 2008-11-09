package qrcode {
  import flash.display.*;
  import flash.geom.*;
  import flash.utils.*;

  public class QRCodeDecoder {
    public static function decode(pixels:BitmapData):DecodeResult {
      var b:BitmapData = createBinaryImage(pixels);
      var patterns:Object = FinderPattern.findPattern(b);
      var result:DecodeResult = new DecodeResult();
      result.across = patterns.across;
      result.pos.leftTop = patterns.leftTop; 
      result.pos.rightTop = patterns.rightTop; 
      result.pos.leftBottom = patterns.leftBottom; 
      result.text = "("+result.pos.leftTop.x+", "+result.pos.leftTop.y+") "+result.across.length;
      result.debug = b;
      return result;
    }

    private static function createBinaryImage(pixels:BitmapData):BitmapData {
      var nDivision:int = 4;
      var b:BitmapData = new BitmapData(pixels.width, pixels.height);

      var areaWidth:int=b.width/nDivision;
      var areaHeight:int=b.height/nDivision;
      
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
        
          b.threshold(pixels, rectangle, new Point(ax*areaWidth, ay*areaHeight), "<=", threshold, color,
              maskColor, false);
        }
      }
      return b;
    }
  }
}
