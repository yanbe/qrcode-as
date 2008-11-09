package qrcode {
  import flash.display.*;
  import flash.geom.*;

  public class FinderPattern {
    public static function findPattern(pixels:BitmapData):Object {
      var linesAcross:Array = findLinesAcross(pixels);
      var centors:Array = findCenters(linesAcross);
      return {leftTop:new Point(10,10),
        rightTop:new Point(200,10),
        leftBottom:new Point(10,200),
        across:linesAcross}; 
    }
    private static function findLinesAcross(pixels:BitmapData):Array {
      var reference:Array = new Array(1, 1, 3, 1, 1);
      var referenceSum:int = 7; //1+1+3+1+1
      var recent:Array = new Array();
      var linesAcross:Array = new Array(); 
      for (var y:int=0; y<pixels.height; y++) {
        var last:int = 0; 
        var current:int = 0;
        var length:int = 0;
        for (var x:int=0; x<pixels.width; x++) {
          current = pixels.getPixel(x, y);
          if (current==last) {
            length++;
          } else {
            if (recent.push(length) > reference.length) {
              recent.shift();
            }
            if (current==0) { //white->black transision
            } else { //black->white transition
              if (recent.length==reference.length) {
                var recentAverage:int = 0;
                var recentSum:int = 0;
                var i:int;
                for (i=0; i<recent.length; i++) {
                  recentSum+=recent[i];
                }
                recentAverage = recentSum/referenceSum;
                for (i=0; i<recent.length; i++) {
                  var t:int = reference[i]*recentAverage;
                  if ((recent[i]<t*0.5) || (recent[i]>t*2)) {
                    break;
                  }
                }
                if (i==recent.length) {
                  linesAcross.push({
                      end:new Point(x-1,y), 
                      offset:recentSum});
                }
              }
            }
            length = 1;
            last = current;
          }
        :
        recent = new Array();
        length = 0;
      }
      return linesAcross;
    }
  }
}
