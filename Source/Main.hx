package;

import level.LevelFactory;
import flash.media.SoundChannel;
import openfl.Assets;
import openfl.text.TextFormat;
import level.LevelResult;
import level.Level;
import room.Direction;
import characters.Player;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.events.Event;
import room.Room;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
    public static var format(default, null) = new TextFormat('Gill Sans');

    public static inline var FART_CAPACITY:Float = 10.0;

    public static inline var FART_BIG:Float = 9.0;
    public static inline var FART_MEDIUM:Float = 5.0;
    public static inline var FART_SMALL:Float = 0.0;

    public static inline var FART_LEVEL_RELEASE:Float = 0.3;
    public static inline var FART_LEVEL_BUILD:Float = 0.1;

    public static inline var FART_DECR_OVER_TIME:Float = 0.006;
    public static inline var SHAME_LEVEL_DECR_OVER_TIME:Float = 0.01;

    public static inline var SMALLTALK_COOLDOWN:Float = 3.0;

    public static inline var VENTILATING_COOLDOWN:Float = 15.0;
    public static inline var VENTILATING_DURATION:Float = 3.0;
    public static inline var VENTILATING_DECR_OVER_TIME:Float = 0.2;

    private var level(null, null):Level;
    private var level_factory(null, null):LevelFactory;

    private var start_screen(null, null):ScreenStartAsset;
    private var start_sound(null, null):SoundChannel;

    private var lost_screen(null, null):ScreenLostAsset;
    private var won_screen(null, null):ScreenWonAsset;

    public var screen(default, default):ScreenType;

    public var sound_lost_screen(default, null):SoundChannel;
    public var sound_won_screen(default, null):SoundChannel;

    // system
    private var time(null, null):Int;

    // debug
    private var debug_fps(null, null):FPS;

    public function new() {
        super();

        this.level_factory = new LevelFactory();

        this.start_screen = new ScreenStartAsset();
        this.start_screen.label_text.defaultTextFormat = Main.format;
        this.start_screen.label_text.text = 'Press ENTER to play!';
        this.start_screen.label_text.text = 'Press ENTER to play!';

        this.lost_screen = new ScreenLostAsset();
        this.lost_screen.label_text.defaultTextFormat = Main.format;
        this.lost_screen.label_text.text = 'Press ENTER to go back to Menu!';

        this.won_screen = new ScreenWonAsset();
        this.won_screen.label_text.defaultTextFormat = Main.format;
        this.won_screen.label_text.text = 'Press ENTER to go back to Menu!';

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

                    if (null != this.sound_lost_screen) {
                        this.sound_lost_screen.stop();
                        this.sound_lost_screen = null;
                    }

                    this.screen = ScreenType.START;
                    this.start_sound = Assets.getSound('assets/Sounds/menu_music.mp3').play();
                }
            case ScreenType.WON:
                if (Keyboard.ENTER == e.keyCode) {
                    this.removeChild(this.won_screen);
                    this.addChild(this.start_screen);

                    if (null != this.sound_won_screen) {
                        this.sound_won_screen.stop();
                        this.sound_won_screen = null;
                    }

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

        this.level = this.level_factory.createLevel('assets/levels/levels_ver3.json');
        this.level.addRoom(room);
        this.level.addPlayer(player, 2, 2);
        this.level.start();

        this.addChild(this.level);
        this.addChild(this.debug_fps = new FPS());

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

        this.sound_won_screen = Assets.getSound('assets/Sounds/oh.mp3').play(0.0, 1);
    }

    public function lost():Void {
        this.screen = ScreenType.LOST;

        this.removeChild(this.level);
        this.addChild(this.lost_screen);

        this.sound_lost_screen = Assets.getSound('assets/Sounds/fart5.mp3').play(0.0, 1);
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