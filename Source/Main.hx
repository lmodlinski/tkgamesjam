package;

import characters.Npc;
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
    private var player(null, null):Player;
    private var room(null, null):Room;

    private var ongoing(null, null):Bool;

    private var time(null, null):Int;

    // input
    private var gamepad(null, null):GameInput;

    // debug
    private var debug_fps(null, null):FPS;

    private var debug(null, null):Bool;

    public function new() {
        super();

        this.debug = true;
        this.debug_fps = new FPS();

        this.addChild(this.debug_fps);

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
                this.room.move(this.player, Direction.UP);
            case Keyboard.S:
                this.room.move(this.player, Direction.DOWN);
            case Keyboard.A:
                this.room.move(this.player, Direction.LEFT);
            case Keyboard.D:
                this.room.move(this.player, Direction.RIGHT);
            case Keyboard.SPACE:
                this.player.fart();
            case Keyboard.F:
                this.room.ventilate();
            case Keyboard.ENTER:
                this.start();
            default:
        }
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        switch(e.keyCode){
            case Keyboard.SPACE:
                this.player.hold();
            default:
        }
    }

    public function start():Void {
        this.player = new Player();

        this.addChild(this.room = new Room(5, 5));
        this.room.add(this.player, 3, 2);

        this.room.add(new Npc(Math.random()), 1, 1);
        this.room.add(new Npc(Math.random()), 2, 2);

        this.ongoing = true;
    }

    private function onEnterFrame(e:Event):Void {
        var time = Lib.getTimer();
        var delta = time - this.time;

        if (this.ongoing) {
            this.room.onEnterFrame(delta);

            if (this.debug) {
                js.Browser.console.log(
                    this.player.field.field_x + '|' + this.player.field.field_y + ' | Fart: ' + Std.int(this.player.field.fart_level)
                );
            }
        }

        this.time = time;
    }
}