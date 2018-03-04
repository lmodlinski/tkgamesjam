package characters;

import motion.easing.Linear;
import motion.Actuate;
import openfl.display.MovieClip;
import room.Direction;
import room.RoomField;
import openfl.display.Sprite;

class AbstractCharacter extends Sprite {
    public var id(default, null):String;

    public var field(default, default):Null<RoomField>;
    public var direction(default, set):Direction;

    public var clip(default, null):MovieClip;

    public function new(clip:MovieClip) {
        super();

        this.addChild(this.clip = clip);
        this.clip.x = this.clip.width * 0.5;
        this.clip.y = this.clip.height * 0.5;

        this.direction = Direction.UP;
    }

    public function onEnterFrame(delta:Int):Void {

    }

    public function set_direction(value:Direction):Direction {
        if (value != this.direction) {
            switch(this.direction = value){
                case Direction.UP:
                    Actuate.tween(this.clip, 0.5, {rotation: 0}).ease(Linear.easeNone);
                case Direction.DOWN:
                    Actuate.tween(this.clip, 0.5, {rotation: 180}).ease(Linear.easeNone);
                case Direction.LEFT:
                    Actuate.tween(this.clip, 0.5, {rotation: -90}).ease(Linear.easeNone);
                case Direction.RIGHT:
                    Actuate.tween(this.clip, 0.5, {rotation: 90}).ease(Linear.easeNone);
            }
        }

        return this.direction;
    }
}
