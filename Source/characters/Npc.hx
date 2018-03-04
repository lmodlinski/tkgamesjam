package characters;

import openfl.Assets;
import flash.media.SoundChannel;
import characters.emoji.EmojiType;
import openfl.display.MovieClip;
import characters.talks.SmalltalkAnswer;
import characters.talks.Smalltalk;
import openfl.Vector;

class Npc extends AbstractCharacter {
    private static inline var EMOJI_X:Float = 65.0;
    private static inline var EMOJI_Y:Float = 65.0;

    public var type(default, null):NpcType;

    public var emoji(default, null):EmojiAsset;

    public var accusation(default, null):Float;
    public var accusing(get, never):Bool;

    public var time(default, null):Float;
    public var time_elapsed(default, null):Float;

    public var moving_min(default, null):Int;
    public var moving_max(default, null):Int;

    public var leaving_next_floor(get, never):Bool;

    public var smalltalks(default, null):Vector<Smalltalk>;

    public var smalltalk(default, null):Null<Smalltalk>;
    public var smalltalk_answer(default, null):Null<SmalltalkAnswer>;
    public var smalltalk_available(get, never):Bool;
    public var smalltalk_unanswered(get, never):Bool;
    public var smalltalk_answered(get, never):Bool;

    public var sound_smalltalk(default, null):SoundChannel;

    public function new(clip:MovieClip, type, accusation:Float, time:Float, moving_min:Int, moving_max:Int, smalltalks:Vector<Smalltalk>) {
        super(clip);

        this.type = type;
        this.accusation = accusation;

        this.time = time;

        this.addChild(this.emoji = new EmojiAsset());
        this.emoji.x = EMOJI_X;
        this.emoji.y = EMOJI_Y;
        this.emoji.gotoAndStop(Std.string(EmojiType.FART));
        this.emoji.visible = false;

        this.moving_min = moving_min;
        this.moving_max = moving_max;

        this.smalltalks = smalltalks;
    }

    override public function onEnterFrame(delta:Int):Void {
        super.onEnterFrame(delta);

        this.time_elapsed += delta / 1000.0;

        if (!this.emoji.visible && this.field.fart) {
            this.emoji.visible = true;
        }
    }

    public function talk():Void {
        if (this.smalltalk_available) {
            this.smalltalk = this.smalltalks.get(Std.int(Math.random() * this.smalltalks.length));

            this.sound_smalltalk = Assets.getSound('assets/Sounds/small_talk_' + Random.int(1, 3) + '.mp3').play(0.0, 1);
        }
    }

    public function answer(answer:SmalltalkAnswer):Bool {
        var result:Bool = false;

        if (null != this.smalltalk && null == this.smalltalk_answer) {
            result = this.smalltalk.check(this.smalltalk_answer = answer);

            this.emoji.gotoAndStop(Std.string(result ? EmojiType.CORRECT : EmojiType.WRONG));
            this.emoji.visible = true;

            this.sound_smalltalk.stop();
            this.sound_smalltalk = null;
        }

        return result;
    }

    public function driff():Int {
        return Random.int(this.moving_min, this.moving_max);
    }

    public function get_accusing():Bool {
        return this.field.fart && (
            null == this.smalltalk ||
            !this.smalltalk.shaming_stop ||
            null == this.smalltalk_answer ||
            (
                this.smalltalk_answered && !this.smalltalk.check(this.smalltalk_answer)
            )
        );
    }

    public function get_leaving_next_floor():Bool {
        return this.time_elapsed >= this.time;
    }

    public function get_smalltalk_available():Bool {
        return 0 < this.smalltalks.length && null == this.smalltalk && null == this.smalltalk_answer;
    }

    public function get_smalltalk_unanswered():Bool {
        return null != this.smalltalk && null == this.smalltalk_answer;
    }

    public function get_smalltalk_answered():Bool {
        return null != this.smalltalk && null != this.smalltalk_answer;
    }
}
