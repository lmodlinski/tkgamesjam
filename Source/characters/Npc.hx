package characters;

import openfl.display.MovieClip;
import characters.talks.SmalltalkAnswer;
import characters.talks.Smalltalk;
import openfl.Vector;

class Npc extends AbstractCharacter {
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

    public function new(clip:MovieClip, accusation:Float, time:Float, moving_min:Int, moving_max:Int, smalltalks:Vector<Smalltalk>) {
        super(clip);

        this.accusation = accusation;

        this.time = time;

        this.moving_min = moving_min;
        this.moving_max = moving_max;

        this.smalltalks = smalltalks;
    }

    override public function onEnterFrame(delta:Int):Void {
        super.onEnterFrame(delta);

        this.time_elapsed = delta / 1000.0;
    }

    public function talk():Void {
        if (this.smalltalk_available) {
            this.smalltalk = this.smalltalks.get(Std.int(Math.random() * this.smalltalks.length));
        }
    }

    public function answer(answer:SmalltalkAnswer):Bool {
        if (null != this.smalltalk && null == this.smalltalk_answer) {
            this.smalltalk_answer = answer;

            return this.smalltalk.check(answer);
        }

        return false;
    }

    public function driff():Int {
        return Random.int(this.moving_min, this.moving_max);
    }

    public function get_accusing():Bool {
        return this.field.fart && (null == this.smalltalk || null == this.smalltalk_answer || !this.smalltalk.check(this.smalltalk_answer));
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
}
