package;

import level.LevelFactory;
import flash.media.SoundChannel;
import openfl.Assets;
import openfl.text.TextFormat;
import characters.NpcType;
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
    public static var format(default, null) = new TextFormat('Gill Sans');

    private var level(null, null):Level;
    private var level_factory(null, null):LevelFactory;

    private var start_screen(null, null):ScreenStartAsset;
    private var start_sound(null, null):SoundChannel;

    private var lost_screen(null, null):ScreenLostAsset;
    private var won_screen(null, null):ScreenWonAsset;

    public var screen(default, default):ScreenType;

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

        this.level_factory = new LevelFactory();

        this.start_screen = new ScreenStartAsset();
        this.start_screen.label_text.defaultTextFormat = Main.format;
        this.start_screen.label_text.text = 'Press ENTER to play!';
        this.start_screen.label_text.text = 'Press ENTER to play!';

        this.lost_screen = new ScreenLostAsset();
        this.lost_screen.label_text.defaultTextFormat = Main.format;
        this.lost_screen.label_text.text = 'Press ENTER to play!';

        this.won_screen = new ScreenWonAsset();
        this.won_screen.label_text.defaultTextFormat = Main.format;
        this.won_screen.label_text.text = 'Press ENTER to play!';

        this.screen = ScreenType.START;
        this.addChild(this.start_screen);

        this.start_sound = Assets.getSound('assets/Sounds/menu_music.mp3').play();

        this.addListeners();
        this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
    }

    public function addListeners():Void {
        this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        switch(this.screen){
            case ScreenType.LOST:
                if (Keyboard.ENTER == e.keyCode) {
                    this.removeChild(this.lost_screen);
                    this.addChild(this.start_screen);

                    this.screen = ScreenType.START;
                    this.start_sound = Assets.getSound('assets/Sounds/menu_music.mp3').play();
                }
            case ScreenType.WON:
                if (Keyboard.ENTER == e.keyCode) {
                    this.removeChild(this.won_screen);
                    this.addChild(this.start_screen);

                    this.screen = ScreenType.START;
                    this.start_sound = Assets.getSound('assets/Sounds/menu_music.mp3').play();
                }
            case ScreenType.START:
                if (Keyboard.ENTER == e.keyCode) {
                    this.start();
                }
            case ScreenType.LEVEL:
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
                        this.level.answer(0);
                    case Keyboard.NUMBER_2:
                        this.level.answer(1);
                    case Keyboard.NUMBER_3:
                        this.level.answer(2);
                    case Keyboard.F:
                        this.level.room.ventilate();
                    default:
                }
        }
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        switch(this.screen){
            case ScreenType.LEVEL:
                switch(e.keyCode){
                    case Keyboard.SPACE:
                        this.level.player.hold();
                    default:
                }
            default:
        }
    }

    public function start():Void {
        var player:Player = new Player();
        var room:Room = new Room(5, 5, 2, 0, 4, 0);

        if (null != this.level) {
            this.removeChild(this.level);
        }

        this.level = this.level_factory.createLevel('assets/levels/test_level.json');
        this.level.addRoom(room);
        this.level.addPlayer(player, 2, 2);
        this.level.start();

        this.addChild(this.level);

        if (this.debug) {
            this.addChild(this.debug_fps = new FPS());
        }

        if (null != this.start_sound) {
            this.start_sound.stop();
            this.start_sound = null;
        }

        switch(this.screen){
            case ScreenType.START:
                this.removeChild(this.start_screen);
            case ScreenType.LOST:
                this.removeChild(this.lost_screen);
            case ScreenType.WON:
                this.removeChild(this.won_screen);
            default:
        }

        this.screen = ScreenType.LEVEL;
    }

    public function won():Void {
        this.screen = ScreenType.WON;

        this.removeChild(this.level);
        this.addChild(this.won_screen);
    }

    public function lost():Void {
        this.screen = ScreenType.LOST;

        this.removeChild(this.level);
        this.addChild(this.lost_screen);
    }

    private function onEnterFrame(e:Event):Void {
        var time = Lib.getTimer();
        var delta = time - this.time;

        if (null != this.level && LevelResult.ONGOING == this.level.result) {
            this.level.onEnterFrame(delta);

            switch(this.level.result){
                case LevelResult.FINISHED_LOST:
                    this.lost();
                case LevelResult.FINISHED_WON:
                    this.won();
                default:
            }
        }

        this.time = time;
    }
}

enum ScreenType {
    START;
    LEVEL;
    WON;
    LOST;
}