package characters;

import openfl.display.MovieClip;
import room.Direction;
import room.RoomField;
import openfl.display.Sprite;

class AbstractCharacter extends Sprite {
    public var id(default, null):String;

    public var field(default, default):Null<RoomField>;
    public var direction(default, default):Direction;

    public function new(clip:MovieClip) {
        super();

        this.addChild(clip);

        this.direction = Direction.DOWN;
    }

    public function onEnterFrame(delta:Int):Void {

    }
}
