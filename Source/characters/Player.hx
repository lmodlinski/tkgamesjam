package characters;

import room.Direction;
import openfl.Assets;
import flash.media.SoundChannel;
import characters.talks.SmalltalkAnswer;
import room.RoomField;

class Player extends AbstractCharacter {
    public var shame_level(default, set):Float;
    public var fart_level(default, null):Float;

    public var farting(default, null):Bool;

    public var smalltalk_with(default, null):Npc;
    public var smalltalk_ongoing(get, never):Bool;
    public var smalltalk_cooldown(default, set):Float;

    public var sound_fart(default, null):SoundChannel;

    public function new() {
        super(new PlayerAsset());
    }

    override public function onEnterFrame(delta:Int):Void {
        super.onEnterFrame(delta);

        if (this.farting && !this.field.full) {
            if (0.0 < this.fart_level) {
                this.fart_level -= Main.FART_LEVEL_RELEASE;

                this.field.fart_level += Main.FART_LEVEL_RELEASE;
            } else {
                this.hold();
            }
        } else {
            this.fart_level += Main.FART_LEVEL_BUILD;
        }

        this.shame_level -= Main.SHAME_LEVEL_DECR_OVER_TIME;

        if (0.0 < this.smalltalk_cooldown && null != this.smalltalk_with && this.smalltalk_with.smalltalk_answered) {
            this.smalltalk_cooldown -= delta / 1000.0;
        }
    }

    public function talk():Void {
        if (0 >= this.smalltalk_cooldown && null != this.field) {
            var target:RoomField = this.field.room.getFieldNextTo(this.field, this.direction);

            if (null != target && Std.is(target.occupied, Npc)) {
                var npc:Npc = cast(target.occupied, Npc);

                if (npc.smalltalk_available) {
                    npc.talk();

                    if (npc.smalltalk_unanswered) {
                        this.smalltalk_with = npc;
                        this.smalltalk_with.direction = this.getOppositeDirection();
                    }
                }
            }
        }
    }

    public function getOppositeDirection():Direction {
        switch(this.direction){
            case Direction.DOWN:
                return Direction.UP;
            case Direction.LEFT:
                return Direction.RIGHT;
            case Direction.UP:
                return Direction.DOWN;
            case Direction.RIGHT:
                return Direction.LEFT;
        }
    }

    public function answer(answer:SmalltalkAnswer):Bool {
        this.smalltalk_cooldown = Main.SMALLTALK_COOLDOWN;

        return this.smalltalk_with.answer(answer);
    }

    public function accuse(value:Float):Void {
        this.shame_level += value;
    }

    public function fart():Void {
        this.farting = true;

        if (null == this.sound_fart) {
            this.sound_fart = Assets.getSound('assets/Sounds/fart' + Random.int(1, 5) + '.mp3').play(0.0, 1);
        }
    }

    public function hold():Void {
        this.farting = false;

        this.sound_fart = null;
    }

    public function get_smalltalk_ongoing():Bool {
        return null != this.smalltalk_with && this.smalltalk_with.smalltalk_unanswered;
    }

    public function set_shame_level(value:Float):Float {
        if (0.0 > value) {
            this.shame_level = 0.0;
        } else {
            this.shame_level = value;
        }

        return this.shame_level;
    }

    public function set_smalltalk_cooldown(value:Float):Float {
        if (0.0 > value) {
            this.smalltalk_cooldown = 0.0;
        } else {
            this.smalltalk_cooldown = value;
        }

        return this.smalltalk_cooldown;
    }
}
