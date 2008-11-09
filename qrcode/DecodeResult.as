package qrcode {
  import flash.geom.*;
  import flash.display.*;

  public class DecodeResult {
    public var version:uint;
    public var errorCorrectionLevel:uint;
    public var text:String;
    public var debug:BitmapData;
    public var across:Array;
    public var pos:Object = {leftTop:Point, rightTop:Point,
                             leftBottom:Point, rightBottom:Point};
  }
}
