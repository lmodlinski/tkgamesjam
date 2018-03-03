package characters.talks;

import openfl.display.Sprite;
import characters.talks.Smalltalk;

class SmalltalkAnswer {
    public var context(default, default):Smalltalk;

    public var id(default, null):String;
    public var text(default, null):String;

    public function new(id:String, text:String) {
        this.id = id;
        this.text = text;
    }
}
