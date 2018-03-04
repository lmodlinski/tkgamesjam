package room;

import motion.Actuate;
import openfl.display.Sprite;
import characters.AbstractCharacter;

class RoomField extends Sprite {
    private var asset(null, null):RoomFieldAsset;
    private var asset_fart(null, null):FartAsset;

    public var room(default, null):Room;

    public var field_x(default, null):Int;
    public var field_y(default, null):Int;

    public var fart_level(default, set):Float;
    public var fart(get, never):Bool;

    public var full(default, null):Bool;

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
        var decr:Float = Main.FART_DECR_OVER_TIME;

        if (this.room.ventilating_on) {
            decr += this.room.ventilating_decr;
        }

        if (null != this.occupied) {
            this.occupied.onEnterFrame(delta);
        }

        if (this.asset_fart.visible = this.fart) {
            this.fart_level -= decr;

            if (0 >= this.fart_level) {
                this.full = false;
            }

            if (Main.FART_BIG < this.fart_level) {
                this.asset_fart.gotoAndStop(3);
            } else if (Main.FART_MEDIUM < this.fart_level) {
                this.asset_fart.gotoAndStop(2);
            } else {
                this.asset_fart.gotoAndStop(1);
            }
        }
    }

    public function occupy(character:AbstractCharacter):Void {
        if (null == this.occupied) {
            this.parent.addChild(this.occupied = character);
            Actuate.tween(this.occupied, 2.0, {x: this.x, y: this.y});

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
            this.parent.removeChild(this.occupied);
        }

        this.occupied = null;
    }

    public function get_fart():Bool {
        return 0 < fart_level;
    }

    public function set_fart_level(value:Float):Float {
        if (0.0 > value) {
            this.fart_level = 0.0;
        } else if (value >= Main.FART_CAPACITY) {
            this.fart_level = Main.FART_CAPACITY;

            this.full = true;
        } else {
            this.fart_level = value;
        }

        return this.fart_level;
    }
}
