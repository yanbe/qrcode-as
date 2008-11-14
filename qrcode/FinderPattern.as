package qrcode {
  import flash.display.*;
  import flash.geom.*;

  public class FinderPattern {
    private static const HORIZONTAL:int = 0;
    private static const VERTICAL:int = 1;

    public static function findPattern(pixels:BitmapData,
        debug:BitmapData=null):Object {
      var linesAcrossHorizontally:Array = findLinesAcross(pixels, HORIZONTAL);
      var linesAcrossVertically:Array = findLinesAcross(pixels, VERTICAL);
      var line:Object;
      var i:int;
      if (debug!=null) {
        for each(line in linesAcrossHorizontally) {
          drawLine(debug, line, 0x00ff00, HORIZONTAL); 
        }
        for each(line in linesAcrossVertically) { 
          drawLine(debug, line, 0x00ff00, VERTICAL); 
        }
      }
      var horizontalHints:Array = findPositionDetectionPatternHints(linesAcrossHorizontally);
      var verticalHints:Array = findPositionDetectionPatternHints(linesAcrossVertically);

      if (debug!=null) {
        for each(line in horizontalHints) { 
          drawLine(debug, line, 0xff0000, HORIZONTAL); 
        }
        for each(line in verticalHints) { 
          drawLine(debug, line, 0xff0000, VERTICAL); 
        }
      }

      var patterns:Array = findPositionDetectionPatterns(horizontalHints,
          verticalHints);
       patterns= orderPositionDetectionPatterns(patterns); 

      if (debug!=null && patterns.length==3) {
        var triangle:Shape = new Shape();
        triangle.graphics.lineStyle(1, 0x0000ff);
        triangle.graphics.moveTo(patterns[0].x, patterns[0].y);
        triangle.graphics.lineTo(patterns[1].x, patterns[1].y);
        triangle.graphics.lineStyle(1, 0xff0000);
        triangle.graphics.lineTo(patterns[2].x, patterns[2].y);
        triangle.graphics.lineStyle(1, 0x0000ff);
        triangle.graphics.lineTo(patterns[0].x, patterns[0].y);
        debug.draw(triangle);
      }

      return {leftTop: patterns[0],
        rightTop: patterns[1],
        leftBottom: patterns[2]
      };
    }

    private static function drawLine(debug:BitmapData, line:Object,
        color:uint, direction:int):void {
      var l:Shape = new Shape();
      l.graphics.lineStyle(1, color);
      l.graphics.moveTo(line.endPoint.x, line.endPoint.y);
      if (direction==HORIZONTAL) {
        l.graphics.lineTo(line.endPoint.x-line.offset, line.endPoint.y);
      } else {
        l.graphics.lineTo(line.endPoint.x, line.endPoint.y-line.offset);
      }
      debug.draw(l);
    }

    private static function findLinesAcross(pixels:BitmapData, 
        direction:int):Array {
      var MAX_SIDE_PRIMARY:int;
      var MAX_SIDE_SECONDARY:int;
      if (direction==HORIZONTAL) {
        MAX_SIDE_PRIMARY=pixels.width; MAX_SIDE_SECONDARY=pixels.height;
      } else if (direction==VERTICAL) {
        MAX_SIDE_PRIMARY=pixels.height; MAX_SIDE_SECONDARY=pixels.width;
      }

      var reference:Array = new Array(1, 1, 3, 1, 1);
      var referenceSum:int = 7; //1+1+3+1+1
      var recent:Array = new Array();
      var linesAcross:Array = new Array(); 

      for (var b:int=0; b<MAX_SIDE_SECONDARY; b++) {
        var last:int = 0; 
        var current:int = 0;
        var length:int = 0;
        for (var a:int=0; a<MAX_SIDE_PRIMARY; a++) {
          current = direction==HORIZONTAL ? pixels.getPixel(a,b) : 
            pixels.getPixel(b,a);

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
                  var endPoint:Point = direction==HORIZONTAL ? 
                    new Point(a-1,b) : 
                    new Point(b,a-1);
                  linesAcross.push({endPoint:endPoint, offset:recentSum});
                }
              }
            }
            length = 1;
            last = current;
          }
        }
        recent = new Array();
        length = 0;
      }
      return linesAcross;
    }

    private static function findPositionDetectionPatternHints(linesAcross:Array): Array {
      var clusters:Array = new Array();
      var i:int;
      for each (var target:Object in linesAcross) {
        for (i=0; i < clusters.length; i++) {
          var lastElement:Object = clusters[i][clusters[i].length-1];
          if (Point.distance(lastElement.endPoint, target.endPoint) < 3) {
            clusters[i].push(target);
          }
        }
        if (i == clusters.length) {
          clusters.push(new Array(target));
        }
      }  

      clusters.sortOn("length", Array.DESCENDING | Array.NUMERIC);

      var clusterCenters:Array = new Array();
      if (clusters.length>=3) {
        for (i=0; i<clusters.length && clusterCenters.length<3; i++) {
          var candidate:Object = clusters[i][int(clusters[i].length/2)];
          var j:int=0;
          for (j=0; j<clusterCenters.length; j++) {
            // avoid too near points
            if (Point.distance(candidate.endPoint, clusterCenters[j].endPoint) < 3) {
              break;
            }
          }
          if (j==clusterCenters.length) {
            clusterCenters.push(candidate);
          }
        }
      }

      return clusterCenters;
    }

    private static function findPositionDetectionPatterns(horizontal3Centers:Array,
        vertical3Centers:Array):Array {
      var centers:Array = new Array();
      for each(var h:Object in horizontal3Centers) {
        for each(var v:Object in vertical3Centers) {
          if (Point.distance(h.endPoint, v.endPoint) < h.offset) {
            centers.push(new Point(h.endPoint.x-h.offset/2,
                  v.endPoint.y-v.offset/2));
            break;
          }
        }
      }
      return centers;
    }

    private static function orderPositionDetectionPatterns(centers:Array): Array {
      var longest:Object = {index:0, length:0};
      for (var i:int=0; i<centers.length; i++) {
        var currentLength:int = Point.distance(centers[i],
            centers[(i+1)%centers.length]);
        if (currentLength>longest.length) {
          longest.index=i;
          longest.length=currentLength;
        }
      }
      switch (longest.index) {
        case 0:
          centers.unshift(centers.pop());
          break;
        case 1:
          break;
        case 2:
          centers.push(centers.shift());
          break;
        default:
          break;
      }

      return centers;
    }
  }
}
