package characters;

import room.RoomField;
import openfl.display.Sprite;

class AbstractCharacter extends Sprite {
    // animation and sprite for
    public var id(default, null):String;

    public var field(default, default):Null<RoomField>;

    public function new() {
        super();
    }

    public function onEnterFrame(delta:Int):Void {

    }

    public function move(x:Int, y:Int):Void {

    }
}
