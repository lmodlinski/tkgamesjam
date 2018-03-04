package characters.talks;

import motion.Actuate;
import openfl.Vector;
import openfl.display.Sprite;

class SmalltalkView extends Sprite {
    private static inline var ANSWER_Y:Float = 170.0;
    private static inline var ANSWER_INCR:Float = 125.0;

    private var asset(null, null):SmalltalkAsset;
    private var asset_answers(null, null):Vector<SmalltalkAnswerAsset>;

    private var model(null, null):Smalltalk;

    public function new() {
        super();

        this.addChild(this.asset = new SmalltalkAsset());

        this.asset_answers = new Vector<SmalltalkAnswerAsset>();
    }

    public function show(model:Smalltalk):Void {
        if (null == this.model) {
            this.model = model;

            this.asset.label_text.defaultTextFormat = Main.format;
            this.asset.label_text.text = this.model.text;

            for (i in 0...this.model.answers.length) {
                var answer:SmalltalkAnswer = this.model.answers.get(i);
                var answer_asset:SmalltalkAnswerAsset = new SmalltalkAnswerAsset();
                answer_asset.label_text.defaultTextFormat = Main.format;
                answer_asset.label_text.text = answer.text;

                this.addChild(answer_asset);
                answer_asset.y = ANSWER_Y + i * ANSWER_INCR;
                answer_asset.alpha = 0.0;

                Actuate.tween(answer_asset, 1.0, {alpha: 1.0}).delay((i + 1) * 0.5);

                this.asset_answers.push(answer_asset);
            }
        }
    }

    public function dismiss():Void {
        if (null != this.model) {
            for (answer in this.asset_answers) {
                this.removeChild(answer);
            }

            this.asset_answers = new Vector<SmalltalkAnswerAsset>();
            this.model = null;
        }
    }
}
