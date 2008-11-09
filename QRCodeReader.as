package {
  import flash.display.*;
  import flash.events.*;
  import flash.geom.*;
  import flash.media.*;
  import flash.text.*;
  import flash.utils.*;
  import qrcode.*;

  public class QRCodeReader extends Sprite {
    private var video:Video;
    private var pixels:BitmapData;
    private var debug:BitmapData;
    private var text:TextField;

    public function QRCodeReader() {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;

      var camera:Camera = Camera.getCamera();      

      if (camera!=null) {
        camera.setMode(640, 480, 30);
        video = new Video(camera.width,camera.height);
        video.attachCamera(camera);
        pixels = new BitmapData(video.width, video.height, false, 0x00000000);
        createBitmap(pixels, 0, 0);
        debug = new BitmapData(video.width, video.height, false, 0x00000000);
        createBitmap(debug, 640, 0);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        text = createTextField(0, 480, 640, 480);
      }
    }

    private function createTextField(x:Number, y:Number, width:Number,
        height:Number):TextField {
      var result:TextField = new TextField();
      result.x = x;
      result.y = y;
      result.width = width;
      result.height = height;
      addChild(result);
      return result;
    }

    private function createBitmap(pixels:BitmapData, x:int, y:int):Bitmap {
      var result:Bitmap = new Bitmap(pixels);
      result.x = x;
      result.y = y;
      result.width = pixels.width;
      result.height = pixels.height;
      addChild(result);
      return result;
    }

    private function onEnterFrame(event:Event):void {
      pixels.draw(video);
      var result:DecodeResult = QRCodeDecoder.decode(pixels);
      text.text = result.text;
      debug.fillRect(new Rectangle(0,0,debug.width,debug.height), 0x00000000);
      debug.draw(result.debug);
      for each(var line:Object in result.across) {
        for (var i:int=0; i<line.offset; i++) {
          debug.setPixel(line.end.x-i, line.end.y, 0x00ff00);
        }
      }
    }
  }
}
