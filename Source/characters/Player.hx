package characters;

class Player extends AbstractCharacter {
    public static inline var FART_LEVEL_RELEASE:Float = 0.2;
    public static inline var FART_LEVEL_BUILD:Float = 0.1;

    public static inline var FART_LEVEL_MAX:Float = 10.0;
    public static inline var SHAME_LEVEL_MAX:Float = 10.0;

    public var shame_level(default, null):Float;
    public var ashamed(get, never):Bool;

    public var fart_level(default, null):Float;
    public var fart_blamed(get, never):Bool;

    public var farting(default, null):Bool;

    public function new() {
        super();
    }

    override public function onEnterFrame(delta:Int):Void {
        super.onEnterFrame(delta);

        if (this.farting) {
            if (0.0 < this.fart_level && 0.0 <= this.fart_level - FART_LEVEL_RELEASE) {
                this.fart_level -= FART_LEVEL_RELEASE;

                this.field.fart_level += FART_LEVEL_RELEASE;
            }
        } else {
            this.fart_level += FART_LEVEL_BUILD;
        }
    }

    public function accuse(value:Float):Void {
        this.shame_level += value;
    }

    public function fart():Void {
        this.farting = true;
    }

    public function hold():Void {
        this.farting = false;
    }

    public function get_ashamed():Bool {
        return SHAME_LEVEL_MAX <= this.shame_level;
    }

    public function get_fart_blamed():Bool {
        return FART_LEVEL_MAX <= this.fart_level;
    }
}
