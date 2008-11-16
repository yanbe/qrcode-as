package qrcode {
  import flash.display.*;
  import flash.geom.*;

  public class SamplingGrid {
    public static function samplePixels(pixels:BitmapData, finderPattern:Object,
        alignmentPattern:Object=null, debug:BitmapData=null):BitmapData {
      // based on table 1 on JIS-X-0510:2004 p.13
      var sideLength:int = 17+finderPattern.roughVersion*4;
      var sampledPixels:BitmapData = new BitmapData(sideLength, sideLength);
      var mapper:PixelMapper = new PixelMapper(finderPattern);

      if (alignmentPattern==null) { // should be version 6 or lower
        for (var y:int=0; y<sideLength; y++) {
          for (var x:int=0; x<sideLength; x++) {
            var srcPoint:Point = mapper.mapPixel(x, y);
            var sampledPattern:uint = pixels.getPixel(srcPoint.x, srcPoint.y);
            sampledPixels.setPixel(x, y, sampledPattern);
            debug.setPixel(srcPoint.x, srcPoint.y, 0xff0000);
          }
        }
        return sampledPixels;
      } else {
        return sampledPixels;
      }
    }
  }    
}
