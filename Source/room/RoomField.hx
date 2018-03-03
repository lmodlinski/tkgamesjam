package room;

import openfl.display.Sprite;
import characters.AbstractCharacter;

class RoomField extends Sprite {
    public static inline var STALE_DECR:Float = 0.01;

    public var room(default, null):Room;

    public var field_x(default, null):Int;
    public var field_y(default, null):Int;

    public var fart_level(default, set):Float;
    public var fart(get, never):Bool;

    public var occupied(default, null):Null<AbstractCharacter>;

    public function new(room:Room, x:Int, y:Int) {
        super();

        this.room = room;

        this.field_x = x;
        this.field_y = y;
    }

    public function onEnterFrame(delta:Int):Void {
        var decr:Float = STALE_DECR;

        if (this.room.ventilating_on) {
            decr += this.room.ventilating_decr;
        }

        if (null != this.occupied) {
            this.occupied.onEnterFrame(delta);
        }

        this.fart_level -= decr;
    }

    public function occupy(character:AbstractCharacter):Void {
        if (null == this.occupied) {
            this.occupied = character;

            character.field = this;
        }
    }

    public function free():Void {
        this.occupied = null;
    }

    public function get_fart():Bool {
        return 0 < fart_level;
    }

    public function set_fart_level(value:Float):Float {
        if (0.0 > value) {
            this.fart_level = 0.0;
        } else {
            this.fart_level = value;
        }

        return this.fart_level;
    }
}
