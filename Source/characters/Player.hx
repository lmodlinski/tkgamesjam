package characters;

import characters.talks.SmalltalkAnswer;
import room.RoomField;

class Player extends AbstractCharacter {
    public static inline var FART_LEVEL_RELEASE:Float = 0.2;
    public static inline var FART_LEVEL_BUILD:Float = 0.1;

    public static inline var SHAME_LEVEL_DECR:Float = 0.02;

    public var shame_level(default, null):Float;
    public var fart_level(default, null):Float;

    public var farting(default, null):Bool;

    public var smalltalk_with(default, null):Npc;
    public var smalltalk_ongoing(get, never):Bool;

    public function new() {
        super(new PlayerAsset());
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

        if (0 > this.shame_level - SHAME_LEVEL_DECR) {
            this.shame_level -= 0.0;
        } else {
            this.shame_level -= SHAME_LEVEL_DECR;
        }
    }

    public function talk():Void {
        if (null != this.field) {
            var target:RoomField = this.field.room.getFieldNextTo(this.field, this.direction);

            if (null != target && Std.is(target.occupied, Npc)) {
                var npc:Npc = cast(target.occupied, Npc);

                if (npc.smalltalk_available) {
                    npc.talk();

                    if (npc.smalltalk_unanswered) {
                        this.smalltalk_with = npc;
                    }
                }
            }
        }
    }

    public function answer(answer:SmalltalkAnswer):Void {
        if (this.smalltalk_ongoing) {
            this.smalltalk_with.answer(answer);
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

    public function get_smalltalk_ongoing():Bool {
        return null != this.smalltalk_with && this.smalltalk_with.smalltalk_unanswered;
    }
}
