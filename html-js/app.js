//var canvas = document.createElement("canvas");
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var PIXEL_SIZE = 5;
var width = 500;
var height = 500;
var colors = [];
var turns = [];
var color;

var Direction ={
    up: 0,
    right: 1,
    down: 2,
    left: 3
}

canvas.width = width;
canvas.height = height;
document.body.appendChild(canvas);



var Ant = function(x,y,dir){
    this.x = x;
    this.y = y;
    this.steps=0;
    this.dir = dir;
}

Ant.prototype.step = function() {

    this.steps++;
    document.getElementById("steps").innerHTML = this.steps;
    var imgd = ctx.getImageData(ant.x, ant.y, 1, 1);
    var pixel = imgd.data[0]<<16|imgd.data[1]<<8|imgd.data[2];
    color = colors.indexOf(pixel)==-1?0:colors.indexOf(pixel);

    ant.dir = (ant.dir+turns[color])%4;
    color++;
    color %= pattern.length;
    draw_block_pixel(this.x,this.y,colors[color]);

    switch (ant.dir){
            case Direction.up:
                ant.y-=PIXEL_SIZE;
                break;
            case Direction.right:
                ant.x+=PIXEL_SIZE;
                break;
            case Direction.down:
                ant.y+=PIXEL_SIZE;
                break;
            case Direction.left:
                ant.x-=PIXEL_SIZE;
                break;
        }
        ant.x = (ant.x +width) % width;
        ant.y = (ant.y +height) % height;
};

var draw_block_pixel = function (x,y,color){
    var r = ((color&0xFF0000)>>>16);
    var g = ((color&0x00FF00)>>>8);
    var b = ((color&0xFF));
    
    /*var style = "rgba("+((color&0xFF0000)>>>16)+","+((color&0x00FF00)>>>8)+","+((color&0xFF))+","+(1)+")";;
    ctx.fillStyle = style;
    ctx.fillRect( x, y, 5, 5 );*/
    var id = ctx.createImageData(1,1); // only do this once per page
    var d  = id.data;
    d[0]   = r;
    d[1]   = g;
    d[2]   = b;
    d[3]   = 255;
    
    for (var i = 0; i < PIXEL_SIZE; i++){
        for (var j = 0; j < PIXEL_SIZE; j++){
            ctx.putImageData( id, x+j, y+i );   
        }
    }
}

var init = function(){
    ctx.fillStyle = "rgba(0,0,0,1)";
    ctx.fillRect( 0, 0, width, height );
    text = document.getElementById("pattern");
    pattern =text.value;

    if (pattern == ""){
        pattern = "rl";
    }

    document.getElementById("btnReset").addEventListener("click", function(){
        init();
    });

    pattern = pattern.toLowerCase();
    ant = new Ant(width/2,height/2, Math.floor((Math.random() * 3)) );
    for (var i = 0; i < pattern.length; i++){
        var r = Math.floor((Math.random() * 255));
        var g = Math.floor((Math.random() * 255));
        var b = Math.floor((Math.random() * 255));
        var c = r << 16 | g << 8 | b;
        var tt = c.toString(16);
        colors[i] = c;
        if (pattern.charAt(i) == 'l'){
            turns[i] = Direction.left;
        }else if (pattern.charAt(i) == 'r'){
            turns[i] = Direction.right;
        }
    }
}



var main = function() {
    ant.step();

    requestAnimationFrame(main);
}



init();
main();
