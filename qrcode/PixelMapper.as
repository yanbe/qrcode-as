package qrcode {
  import flash.geom.*;
  public class PixelMapper {
    private var origin:Point;
    private var scaleX:Number;
    private var scaleY:Number;
    private var sin:Number;
    private var cos:Number;

    public function PixelMapper(finderPattern:Object):void {
      this.origin = finderPattern.leftTop;
      var r:Number = Point.distance(finderPattern.leftTop, finderPattern.rightTop);
      this.cos = (finderPattern.rightTop.x-finderPattern.leftTop.x)/r;
      this.sin = (finderPattern.rightTop.y-finderPattern.leftTop.y)/r;
      this.scaleX = finderPattern.moduleWidth;
      this.scaleY = finderPattern.moduleHeight;
    }

    public function mapPixel(x:Number, y:Number): Point {
      var map:Point = this.origin.clone();
      map.x+=this.scaleX*(x-3)*this.cos-this.scaleX*(y-3)*this.sin;
      map.y+=this.scaleY*(y-3)*this.cos+this.scaleY*(x-3)*this.sin;
      return map;
    }
  }
}
