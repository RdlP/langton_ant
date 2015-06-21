using SDL;
using SDLGraphics;

public class LangtonAnt : Object {

    enum Direction{
        UP,
        RIGHT,
        DOWN,
        LEFT
    }

    private const int SCREEN_WIDTH = 500;
    private const int SCREEN_HEIGHT = 500;
    private const int SCREEN_BPP = 32;
    private const int DELAY = 1000;
    private const uint8 PIXEL_SIZE = 3;

    private unowned SDL.Screen screen;
    private GLib.Rand rand;
    private bool done;
    private Ant ant;
    private int steps;
    private int64 now;
    public static string pattern;
    private uint32 []colors;
    private uint8 []turns;

    struct Ant {
        public uint32 x;
        public uint32 y;
        public uint32 dir;

        public Ant(uint32 x, uint32 y, uint32 dir = -1){
            this.x = x;
            this.y = y;
            GLib.Rand r = new GLib.Rand ();
            if (dir == -1){
                this.dir = r.int_range (0, 3);
            }else{
                this.dir = dir;
            }
        }
    }

    public static uint8 indexOf(uint32[] colors, uint32 match){
        for (uint8 i = 0; i < colors.length; i++){
            if (colors[i] == match){
                return i;
            }
        }
        return 0;
    }

    public LangtonAnt () {
        this.rand = new GLib.Rand ();
        colors = new uint32[pattern.length];
        turns = new uint8[pattern.length];
        for (uint32 i = 0; i < pattern.length; i++){
            uint32 c = rand.next_int();
            colors[i] = c;
            if (pattern[i].tolower() == 'l'){
                turns[i] = Direction.RIGHT;
            }else if (pattern[i].tolower() == 'r'){
                turns[i] = Direction.LEFT;
            }
        }
    }

    private void prepare_matrix_draw(){
        for (int i = 0; i < SCREEN_WIDTH; i+=PIXEL_SIZE){
            for (int j = SCREEN_HEIGHT-1; j >= 0; j--){
                uint32 *pixels = (uint32*)screen.pixels;
                pixels[j*SCREEN_WIDTH + i] = screen.format.map_rgba(0xFF,0xFF,0x00, 0x60); 
            }
        }
        for (int i = 0; i < SCREEN_WIDTH; i++){
            for (int j = SCREEN_HEIGHT-1; j >= 0; j-=PIXEL_SIZE){
                uint32 *pixels = (uint32*)screen.pixels;

                pixels[j*SCREEN_WIDTH + i] = screen.format.map_rgba(0xFF,0xFF,0x00, 0x60); 
            }
        }
        this.screen.flip ();
    }

    public void step(){

        /*if (ant.x < 5 || ant.y < 5 || ant.x > SCREEN_WIDTH-5 || ant.y > SCREEN_HEIGHT-5){
            if (!finish){
                var end = GLib.get_real_time () / 1000;
                uint64 milliseconds = end-now;
                stdout.printf("Milisegundos: "+milliseconds.to_string()+"\n");
            }
            finish = true;
            return;
        }*/
        steps++;

        stdout.printf(""+steps.to_string()+"\n");
        uint32 *pixels = (uint32*)screen.pixels;
        uint32 pixel = pixels[ant.y*SCREEN_WIDTH + ant.x];
        uint8 color = (indexOf(colors, pixel));
        ant.dir = (ant.dir+turns[color])%4;
        color++;
        color %= (uint8)pattern.length;
        uint32 pos = ant.y*SCREEN_WIDTH + ant.x;
        

        draw_block_pixel(pos, colors[color]);
        switch (ant.dir){
            case Direction.UP:
                ant.y=ant.y-PIXEL_SIZE;
                break;
            case Direction.RIGHT:
                ant.x=ant.x+PIXEL_SIZE;
                break;
            case Direction.DOWN:
                ant.y=ant.y+PIXEL_SIZE;
                break;
            case Direction.LEFT:
                ant.x=ant.x-PIXEL_SIZE;
                break;
        }
        ant.x = (ant.x +SCREEN_WIDTH) % SCREEN_WIDTH;
        ant.y = (ant.y +SCREEN_HEIGHT) % SCREEN_HEIGHT;
        
    }

    public void draw_block_pixel(uint32 pos, uint32 color){
        uint32 y = pos / SCREEN_WIDTH;
        uint32 x = pos % SCREEN_WIDTH;
        uint32 *pixels = (uint32*)screen.pixels;
        for(uint32 i=x; i<x + PIXEL_SIZE;i++){
            for(uint32 j = y; j < y + PIXEL_SIZE; j++){
                pixels[j*SCREEN_WIDTH + i] = color; 
            }
        }
        this.screen.flip ();
    }

    public void run () {
        init_video ();
        set_background((uint32)0xFF000000);
        //prepare_matrix_draw();
        ant = Ant(SCREEN_WIDTH/2,SCREEN_HEIGHT/2);
        now = GLib.get_real_time () / 1000;
        while (!done) {
            step();
            process_events ();
        }
    }

    private void init_video () {
        uint32 video_flags = SurfaceFlag.DOUBLEBUF
                           | SurfaceFlag.HWACCEL
                           | SurfaceFlag.HWSURFACE;

        this.screen = Screen.set_video_mode (SCREEN_WIDTH, SCREEN_HEIGHT,
                                             SCREEN_BPP, video_flags);
        if (this.screen == null) {
            stderr.printf ("No se ha podido iniciar el modo de video.\n");
        }

        SDL.WindowManager.set_caption ("Hormiga de Langton", "");
    }

    private void process_events () {
        Event event;
        while (Event.poll (out event) == 1) {
            switch (event.type) {
            case EventType.QUIT:
                this.done = true;
                break;
            case EventType.KEYDOWN:
                if (event.key.keysym.sym == KeySymbol.ESCAPE) {
                    done = true;
                }
                break;
            }
        }
    }

    public void set_background(uint32 color){
        uint32 *pixels = (uint32*)screen.pixels;
        for (uint32 i = 0; i< SCREEN_HEIGHT * SCREEN_WIDTH; i++){
            pixels[i] = color; 
        }

        this.screen.flip ();
    }

    public static int main (string[] args) {
        SDL.init (InitFlag.EVERYTHING);

        if (args.length < 2){
            pattern = "rl";
        }else{
            pattern = args[1];
        }

        var langton = new LangtonAnt ();

        langton.run ();

        SDL.quit ();

        return 0;
    }
}
