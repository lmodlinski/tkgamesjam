package characters.talks;

import openfl.Vector;

class Smalltalk {
    public var id(default, null):String;

    public var text(default, null):String;

    public var answers(default, null):Vector<SmalltalkAnswer>;
    public var correct(default, null):SmalltalkAnswer;

    public var shame_decr(default, null):Float;
    public var shaming_stop(default, null):Bool;

    public function new(id:String, text:String, shame_decr:Float, shaming_stop:Bool = true) {
        this.id = id;
        this.text = text;

        this.answers = new Vector<SmalltalkAnswer>();

        this.shame_decr = shame_decr;
        this.shaming_stop = shaming_stop;
    }

    public function addAnswer(answer:SmalltalkAnswer, correct:Bool = false):Void {
        this.answers.push(answer);

        if (correct) {
            this.correct = answer;
        }
    }

    public function check(answer:SmalltalkAnswer):Bool {
        return answer.id == this.correct.id;
    }
}
