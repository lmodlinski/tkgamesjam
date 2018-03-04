package thoughts;

import characters.Npc;
import motion.Actuate;
import thoughts.Thought;
import openfl.Vector;
import openfl.display.Sprite;

class ThoughtBubbleView extends Sprite {
    public static inline var LIMIT:Int = 7;

    public static inline var ELEMENT_HEIGHT:Int = 70;

    public var thoughts(default, null):Vector<Thought>;

    public function new() {
        super();

        this.thoughts = new Vector<Thought>();
    }

    public function push(thought:Thought):Void {
        if (LIMIT <= this.thoughts.length) {
            this.removeChild(this.thoughts.pop());
        }

        this.thoughts.push(thought);
        this.addChild(thought);
    }

    public function invalidate(npcs:Vector<Npc>):Void {
        var found:Bool = true;

        while (found) {
            found = false;

            for (i in 0 ... this.thoughts.length) {
                var though_found:Bool = false;

                for (npc in npcs) {
                    if (this.thoughts.get(i).type == npc.type) {
                        though_found = true;

                        break;
                    }
                }

                if (!though_found) {
                    this.removeChild(this.thoughts.splice(i, 1).get(0));

                    found = true;
                    break;
                }
            }
        }
    }

    public function revalidate():Void {
        for (i in 0 ... this.thoughts.length) {
            Actuate.tween(this.thoughts.get(i), 1.0, {y: i * ELEMENT_HEIGHT});
        }
    }
}
