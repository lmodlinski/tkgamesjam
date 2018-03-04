package thoughts;

import characters.NpcType;
import openfl.display.Sprite;

class Thought extends Sprite {
    public static var TEXTS:Array<String> = [
        "What a pig!",
        "Filthy animals !",
        "I wish I went to med school",
        "Did he have an eggs?",
        "Fuckin' mortgage...",
        "Did someone die here?",
        "Who he think he is?",
        "Another day, another fuck up.",
        "I wish they all took stairs.",
        "I didn't shower today.",
        "Bloody skunks!",
        "Try not to breath, try not to...",
        "Just don't make eye contact!",
        "I see this shitstorm coming!",
        "Jerry, why did you leave me?",
        "Did I turned off the oven?",
        "2 and 2 makes 4, minus 1 is 3!",
        "I should buy a boat.",
        "Do they like me?",
        "Do I look fat in this outfit?",
    ];

    private var asset(null, null):ThoughtBubbleAsset;

    public var type(default, null):NpcType;

    public function new(npc:NpcType) {
        super();

        this.addChild(this.asset = new ThoughtBubbleAsset());

        this.asset.label_text.defaultTextFormat = Main.format;
        this.asset.label_text.text = TEXTS[Std.int(Math.random() * TEXTS.length)];

        this.asset.icon_type.gotoAndStop(Std.string(this.type = npc));
    }
}