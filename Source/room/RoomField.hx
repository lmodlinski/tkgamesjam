package room;

import openfl.display.Sprite;
import characters.AbstractCharacter;

class RoomField extends Sprite {
    public static inline var STALE_DECR:Float = 0.01;

    private var asset(null, null):RoomFieldAsset;
    private var asset_fart(null, null):FartAsset;

    public var room(default, null):Room;

    public var field_x(default, null):Int;
    public var field_y(default, null):Int;

    public var fart_level(default, set):Float;
    public var fart(get, never):Bool;

    public var is_entrance(default, null):Bool;

    public var occupied(default, null):Null<AbstractCharacter>;

    public function new(room:Room, x:Int, y:Int, is_entrance:Bool = false) {
        super();

        this.addChild(this.asset = new RoomFieldAsset());
        this.addChild(this.asset_fart = new FartAsset());

        this.room = room;

        this.field_x = x;
        this.field_y = y;

        this.is_entrance = is_entrance;
    }

    public function onEnterFrame(delta:Int):Void {
        var decr:Float = STALE_DECR;

        if (this.room.ventilating_on) {
            decr += this.room.ventilating_decr;
        }

        if (null != this.occupied) {
            this.occupied.onEnterFrame(delta);
        }

        if (this.asset_fart.visible = this.fart) {
            this.fart_level -= decr;
        }
    }

    public function occupy(character:AbstractCharacter):Void {
        if (null == this.occupied) {
            this.addChild(this.occupied = character);

            character.field = this;
        }
    }

    public function getDirection(to:RoomField):Direction {
        var x_dt:Int = this.field_x - to.field_x;
        var y_dt:Int = this.field_y - to.field_y;

        if (0 != x_dt) {
            return x_dt > 0 ? Direction.LEFT : Direction.RIGHT;
        } else {
            return y_dt > 0 ? Direction.UP : Direction.DOWN;
        }
    }

    public function free():Void {
        if (null != this.occupied) {
            this.removeChild(this.occupied);
        }

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
