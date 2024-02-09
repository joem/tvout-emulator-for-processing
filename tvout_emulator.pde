/**************************************************************************
 * This is an as-complete-as-possible Arduino TVout emulator.
 *
 * (Specifically it emulates the TVout_ve_plus library since that's my fork,
 * but it's compatible. TVout_ve_plus just adds features and fixes bugs.)
 * 
 * The resolution is based on the DISPLAYWIDTH and DISPLAYHEIGHT constants
 * set right at the beginning. The MULT constant is used to enlarge the output
 * so that the pixels aren't super tiny.
 *
 * You can draw to the tv.screen array. Anything in the array is drawn.
 *
 * How it works: Anything in the TVout_ve_plus::screen array is displayed.
 * You can access this array directly. It's a 1D array of ints, and the lowest
 * 8 bits of the ints are the the pixels. This means TVout_ve_plus::screen[0]
 * has the first 8 pixels, TVout_ve_plus::screen[1] has next 8 pixels, and so on.
 *
 * Or you can use the drawing functions from TVout_ve_plus:
 *   set_pixel(x, y, color)
 *   draw_row(y, x1, x2, color)
 *   draw_column(x, y1, y2, color)
 *   draw_line(x1, y1, x2, y2, color)
 *   draw_rect(x, y, w, h, stroke color, fill color)
 *   draw_circle(x, y, r, stroke color, fill color)
 * [ADD THE FULL LIST OF FUNCTIONS!!!]
 *
 * The colors for all these functions are:
 *   0 = BLACK
 *   1 = WHITE
 *   2 = INVERT
 * You can use the number or the all-caps name interchangably.
 * 
 ***************************************************************************/

static final int DISPLAYWIDTH = 136;
static final int DISPLAYHEIGHT = 96;
// This means the display is 17 x 12 characters (if using 8x8 font).

static final int MULT = 5;

TVout_ve_plus tv = new TVout_ve_plus(DISPLAYWIDTH, DISPLAYHEIGHT);

//int[] testbmp = {
//  8,8,
//  0x00, 0x18, 0x3C, 0x3C, 0x18, 0x18, 0x00, 0x18 
//};

//int[] testbmp2 = {
//  8,8,
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000"),
//  unbinary("11110000")
//};

void settings() {
  // setting size() in settings() so I can use variables
  size(DISPLAYWIDTH*MULT, DISPLAYHEIGHT*MULT);
  noSmooth(); // Make enlarged pixels blocky instead of smooth
}

void setup() {
  tv.printInfo();
  tv.fill(BLACK);
  colorMode(RGB, 1.0, 1.0, 1.0);
  //noLoop(); // Run draw() once and only once. // DEBUG
  //tv.screen[1] = 170; // DEBUG - test writing directly to tv.screen
  //tv.set_pixel(1, 1, WHITE); // DEBUG - test writing with set_pixel()
  //tv.draw_row(3,0,80,WHITE); // DEBUG - test
  //tv.draw_column(3,0,80,WHITE); // DEBUG - test
  //tv.draw_line(0,0,80,30,WHITE); // DEBUG - test
  //tv.draw_rect(4, 14, 110, 30, WHITE, INVERT); // DEBUG - test
  //tv.draw_circle(68, 48, 40, WHITE, BLACK); // DEBUG - test
  
  //tv.draw_rect(68-2, 48-2, 7+4, 7+4, WHITE, BLACK); // DEBUG - bound the bitmap
  //for (int i = 0; i < 8+12; i=i+2) { tv.set_pixel(68-6+i, 48-2, INVERT); } // DEBUG h1
  //for (int i = 0; i < 8+12; i=i+2) { tv.set_pixel(68-2, 48-6+i, INVERT); } // DEBUG v1
  //tv.set_pixel(68-2, 48-2, INVERT); // DEBUG fix top-left ruler intersection
  ////tv.draw_rect(68, 48, 7, 7, WHITE, WHITE); // DEBUG - show 8x8 spot
  ////tv.bitmap(68, 48, testbmp, 0, 0, 0); // DEBUG - test
  //tv.bitmap(68, 48, testbmp); // DEBUG - test simplified version
  
  //// Use the bitmap() function to display all characters in a tvout font
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 0*8, font8x8, 3 + (0*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 1*8, font8x8, 3 + (1*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 2*8, font8x8, 3 + (2*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 3*8, font8x8, 3 + (3*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 4*8, font8x8, 3 + (4*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 5*8, font8x8, 3 + (5*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 17; i++) { tv.bitmap(i*8, 6*8, font8x8, 3 + (6*17*8) + (8 * i), 8, 8); } // DEBUG
  //for (int i = 0; i < 9; i++) { tv.bitmap(i*8, 7*8, font8x8, 3 + (7*17*8) + (8 * i), 8, 8); } // DEBUG
  
  tv.select_font(font8x8); // DEBUG - test
  //tv.print_char(10, 10, 'A'); // DEBUG - test
  //tv.print_char_row(10, 10, 'A', 0, 4); // DEBUG - test

  //println(tv.cursor_y); // DEBUG - test
  //tv.inc_txtline(); // DEBUG - test
  //println(tv.cursor_y); // DEBUG - test

  //char[] arr = {'H', 'e', 'l', 'l', 'o', ' '}; // DEBUG - test
  //tv.write(arr); // DEBUG - test
  //String str = "Howdy"; // DEBUG - test
  //tv.write(str); // DEBUG - test
  //tv.write("Hola"); // DEBUG - test
  //tv.write_row(int('A'), 0, 8);
  //tv.write_row("HELLO", 0, 4);
  tv.print("Hola"); // DEBUG - test

}


void draw() {

  //tv.shift(1, DIR_RIGHT); // DEBUG

  // Always do the following at the end of draw():
  tv.drawTVoutScreen();
}
