package;

import level.LevelResult;
import openfl.Vector;
import level.Floor;
import level.Level;
import room.Direction;
import characters.Player;
import openfl.ui.Keyboard;
import openfl.ui.GameInput;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.events.Event;
import room.Room;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
    private var level(null, null):Level;

    // input
    private var gamepad(null, null):GameInput;

    // system
    private var time(null, null):Int;

    // debug
    private var debug_fps(null, null):FPS;

    private var debug(null, null):Bool;

    public function new() {
        super();

        this.debug = true;

        this.initialize();

        this.addListeners();
        this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
    }

    public function addListeners():Void {
        this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        switch(e.keyCode){
            case Keyboard.W:
                this.level.room.move(this.level.player, Direction.UP);
            case Keyboard.S:
                this.level.room.move(this.level.player, Direction.DOWN);
            case Keyboard.A:
                this.level.room.move(this.level.player, Direction.LEFT);
            case Keyboard.D:
                this.level.room.move(this.level.player, Direction.RIGHT);
            case Keyboard.SPACE:
                this.level.player.fart();
            case Keyboard.E:
                this.level.player.talk();
            case Keyboard.NUMBER_1:
                if (this.level.player.smalltalk_ongoing) {
                    this.level.player.smalltalk_with.answer(this.level.player.smalltalk_with.smalltalk.answers.get(0));
                }
            case Keyboard.NUMBER_2:
                if (this.level.player.smalltalk_ongoing) {
                    this.level.player.smalltalk_with.answer(this.level.player.smalltalk_with.smalltalk.answers.get(1));
                }
            case Keyboard.NUMBER_3:
                if (this.level.player.smalltalk_ongoing) {
                    this.level.player.smalltalk_with.answer(this.level.player.smalltalk_with.smalltalk.answers.get(2));
                }
            case Keyboard.F:
                this.level.room.ventilate();
            case Keyboard.ENTER:
                this.level.start();
            default:
        }
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        switch(e.keyCode){
            case Keyboard.SPACE:
                this.level.player.hold();
            default:
        }
    }

    public function initialize():Void {
        var player:Player = new Player();
        var room:Room = new Room(5, 5, 2, 0, 4, 0);

        var floors:Vector<Floor> = new Vector<Floor>();
        floors.push(new Floor(1, 15, 2, 2, 4));
        floors.push(new Floor(2, 15, 2, 2, 4));
        floors.push(new Floor(3, 15, 2, 2, 4));
        floors.push(new Floor(4, 15, 2, 2, 4));
        floors.push(new Floor(5, 15, 2, 2, 4));

        this.level = new Level(floors, 100.0, 100.0);
        this.level.addRoom(room);
        this.level.addPlayer(player, 2, 2);

        this.addChild(this.level);

        if (this.debug) {
            this.addChild(this.debug_fps = new FPS());
        }
    }

    private function onEnterFrame(e:Event):Void {
        var time = Lib.getTimer();
        var delta = time - this.time;

        if (LevelResult.ONGOING == this.level.result) {
            this.level.onEnterFrame(delta);
        }

        this.time = time;
    }
}