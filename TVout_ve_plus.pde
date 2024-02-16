/*
* A port or emulation of TVout_ve_plus for testing purposes.
* As much as possible it uses the same code as TVout_ve_plus.
* As much as possible the file structure is the same.
*
* Some changes exist:
* - display.screen[] doesn't exist (it just pointed to screen[] anyway,
*     so anywhere that display.screen[] is used, just use screen[] instead.
* - Some of the setup and teardown functions don't make sense here so were skipped,
*     like begin() and end().
* - Use "static final" instead of "#DEFINE". It's not quite the same, but close enough.
* - No unsigned data types, so use a larger type instead, and be wary of anywhere with
*     intentional rollover.
* - Data type sizes are different too but we don't need to worry about memory, so just
*     use int for most/all things, unless you need bigger.
* - The Processing-specific screen drawing function drawTVoutScreen() has been added to
*     this library, to ease its use in Processing.
*
* TODO:
* - Finish implementing everything.
* - Document everything.
* - Turn this into a proper library!
*
*/

static final int  PAL   = 1;
static final int  NTSC  = 0;
static final int  _PAL  = 1;
static final int  _NTSC = 0;

static final int WHITE  = 1;
static final int BLACK  = 0;
static final int INVERT = 2;

// Had to add `DIR_` prefix since the words were already reserved words
static final int  DIR_UP    = 0;
static final int  DIR_DOWN  = 1;
static final int  DIR_LEFT  = 2;
static final int  DIR_RIGHT = 3;

static final int  DEC = 10;
static final int  HEX = 16;
static final int  OCT  = 8;
static final int  BIN  = 2;
static final int  BYTE = 0;

static final int _CYCLES_PER_US = 1; // might be wrong?


class TVout_ve_plus {
  int[] screen;
  // These three were private, but I haven't done that to these yet:
  int cursor_x;
  int cursor_y;
  int[] font;
    
  public class TVout_ve_plus_vid {
    public int scanLine;
    public long frames;
    public int start_render;
    public int lines_frame;
    public int vres;
    public int hres;
    public int output_delay;
    public int vscale_const;
    public int vscale;
    public int vsync_end;
    //uint8_t * screen; //don't use this
    
    // This construstor is a simplified version of render_setup() moved to here.
    //TVout_ve_plus_vid(int x, int y) {
    TVout_ve_plus_vid() {
      //display.screen = scrnptr;
      hres = DISPLAYWIDTH/8;
      vres = DISPLAYHEIGHT;
      frames = 0;
      //display.vscale_const = _NTSC_LINE_DISPLAY/display.vres - 1;
      vscale_const = 216/vres - 1;
      vscale = vscale_const;
      //display.start_render = _NTSC_LINE_MID - ((display.vres * (display.vscale_const+1))/2) + 8;
      start_render = 131 - ((vres * (vscale_const+1))/2) + 8;
      output_delay = 11;
      vsync_end = 3;
      lines_frame = 262;
      scanLine = lines_frame+1;
    }
  }

  TVout_ve_plus_vid display = new TVout_ve_plus_vid();

  TVout_ve_plus() {
    // default to 128 * 96 if no size provided
    this(128, 96);
  }
  TVout_ve_plus(int x, int y) {
    //screen = (unsigned char*)malloc(x * y * sizeof(unsigned char));
    screen = new int[(x/8)*y];
    cursor_x = 0;
    cursor_y = 0;
  }


  // SKIPPED
  //char TVout_ve_plus::begin(uint8_t mode) {}


  // SKIPPED
  //char TVout_ve_plus::begin(uint8_t mode, uint8_t x, uint8_t y) {}


  // SKIPPED
  //void TVout_ve_plus::end() {}


  /* Fill the screen with some color.
   *
   * Arguments:
   *  color:
   *    The color to fill the screen with.
   *    (see color note at the top of this file)
  */
  void fill(int colorVal) {
    switch (colorVal) {
      case BLACK:
        cursor_x = 0;
        cursor_y = 0;
        for (int i = 0; i < (display.hres)*display.vres; i++)
          screen[i] = 0;
        break;
      case WHITE:
        cursor_x = 0;
        cursor_y = 0;
        for (int i = 0; i < (display.hres)*display.vres; i++)
          screen[i] = 0xFF;
        break;
      case INVERT:
        for (int i = 0; i < display.hres*display.vres; i++)
          screen[i] = ~screen[i];
        break;
    }
  } // end of fill


  // Formerly was a macro used as an alias
  void clear_screen() {
    fill(0);
  }


  // Formerly was a macro used as an alias
  void invert(int theColor) {
    // Note theColor isn't used. It was the same way in TVout_ve_plus.h.
    fill(2);
  }


  /* Gets the Horizontal resolution of the screen
   *
   * Returns:
   *  The horizonal resolution.
  */
  int hres() {
    return display.hres*8;
  } // end of hres
  
  
  /* Gets the Vertical resolution of the screen
   *
   * Returns:
   *  The vertical resolution
  */
  int vres() {
    return display.vres;
  } // end of vres


  // TODO: FIXME! - Not sure what to do about the font part yet.
  ///* Return the number of characters that will fit on a line
  // *
  // * Returns:
  // *  The number of characters that will fit on a text line starting from x=0.
  // *  Will return -1 for dynamic width fonts as this cannot be determined.
  //*/
  //int char_line() {
  //  return ((display.hres*8)/pgm_read_byte(font));
  //} // end of char_line


  /* delay for x ms
   * The resolution is 16ms for NTSC and 20ms for PAL
   *
   * Arguments:
   *  x:
   *    The number of ms this function should consume.
  */
  void delay(int x) {
    //long time = millis() + x;
    //while(millis() < time);
    delay(x); // just use the built in delay
  } // end of delay


  /* Delay for x frames, exits at the end of the last display line.
   * delay_frame(1) is useful prior to drawing so there is little/no flicker.
   *
   * Arguments:
   *  x:
   *    The number of frames to delay for.
   */
  void delay_frame(int x) {
    int stop_line = (int)(display.start_render + (display.vres*(display.vscale_const+1)))+1;
    while (x > 0) {
      while (display.scanLine != stop_line);
      while (display.scanLine == stop_line);
      x--;
    }
  } // end of delay_frame


  /* Get the time in ms since begin was called.
   * The resolution is 16ms for NTSC and 20ms for PAL
   *
   * Returns:
   *  The time in ms since video generation has started.
  */
  int millis() {
    //if (display.lines_frame == _NTSC_LINE_FRAME) {
    //  return display.frames * _NTSC_TIME_SCANLINE * _NTSC_LINE_FRAME / 1000;
    //}
    //else {
    //  return display.frames * _PAL_TIME_SCANLINE * _PAL_LINE_FRAME / 1000;
    //}
    return millis(); // just use the built-in millis()
  } // end of millis


  /* force the number of times to display each line.
   *
   * Arguments:
   *  sfactor:
   *    The scale number of times to repeate each line.
   */
  void force_vscale(int sfactor) {
    delay_frame(1);
    display.vscale_const = sfactor - 1;
    display.vscale = sfactor - 1;
  }
  
  
  /* force the output start time of a scanline in micro seconds.
   *
   * Arguments:
   *  time:
   *    The new output start time in micro seconds.
   */
  void force_outstart(int time) {
    delay_frame(1);
    display.output_delay = ((time * _CYCLES_PER_US) - 1);
  }
  
  
  /* force the start line for active video
   *
   * Arguments:
   *  line:
   *    The new active video output start line
   */
  void force_linestart(int line) {
    delay_frame(1);
    display.start_render = line;
  }


  /* Set the color of a pixel
   *
   * Arguments:
   *  x:
   *    The x coordinate of the pixel.
   *  y:
   *    The y coordinate of the pixel.
   *  c:
   *    The color of the pixel
   *    (see color note at the top of this file)
   */
  void set_pixel(int x, int y, int c) {
    if (x >= display.hres*8 || y >= display.vres)
      return;
    sp(x,y,c);
  } // end of set_pixel


  /* get the color of the pixel at x,y
   *
   * Arguments:
   *  x:
   *    The x coordinate of the pixel.
   *  y:
   *    The y coordinate of the pixel.
   *
   * Returns:
   *  The color of the pixel.
   *  (see color note at the top of this file)
   *
   * Thank you gijs on the arduino.cc forum for the non obviouse fix.
   */
  int get_pixel(int x, int y) {
    if (x >= display.hres*8 || y >= display.vres)
      return 0;
    if ((screen[x/8+y*display.hres] & (0x80 >>(x&7))) > 0)
      return 1;
    return 0;
  } // end of get_pixel


  /* Draw a line from one point to another
   *
   * Arguments:
   *  x0:
   *    The x coordinate of point 0.
   *  y0:
   *    The y coordinate of point 0.
   *  x1:
   *    The x coordinate of point 1.
   *  y1:
   *    The y coordinate of point 1.
   *  c:
   *    The color of the line.
   *    (see color note at the top of this file)
   */
  void draw_line(int x0, int y0, int x1, int y1, int c) {
    if (x0 > display.hres*8 || y0 > display.vres || x1 > display.hres*8 || y1 > display.vres)
      return;
    if (x0 == x1)
      draw_column(x0,y0,y1,c);
    else if (y0 == y1)
      draw_row(y0,x0,x1,c);
    else {
      int e;
      int dx;
      int dy;
      int j;
      int temp;
      int s1;
      int s2;
      int xchange;
      int x,y;
  
      x = x0;
      y = y0;
  
      //take absolute value
      if (x1 < x0) {
        dx = x0 - x1;
        s1 = -1;
      }
      else if (x1 == x0) {
        dx = 0;
        s1 = 0;
      }
      else {
        dx = x1 - x0;
        s1 = 1;
      }
  
      if (y1 < y0) {
        dy = y0 - y1;
        s2 = -1;
      }
      else if (y1 == y0) {
        dy = 0;
        s2 = 0;
      }
      else {
        dy = y1 - y0;
        s2 = 1;
      }
  
      xchange = 0;
  
      if (dy>dx) {
        temp = dx;
        dx = dy;
        dy = temp;
        xchange = 1;
      }
  
      e = ((int)dy<<1) - dx;
  
      for (j=0; j<=dx; j++) {
        sp(x,y,c);
  
        if (e>=0) {
          if (xchange==1) x = x + s1;
          else y = y + s2;
          e = e - ((int)dx<<1);
        }
        if (xchange==1)
          y = y + s2;
        else
          x = x + s1;
        e = e + ((int)dy<<1);
      }
    }
  } // end of draw_line


  /* Fill a row from one point to another
   *
   * Argument:
   *  line:
   *    The row that fill will be performed on.
   *  x0:
   *    edge 0 of the fill.
   *  x1:
   *    edge 1 of the fill.
   *  c:
   *    the color of the fill.
   *    (see color note at the top of this file)
   */
  void draw_row(int line, int x0, int x1, int c) {
    int lbit;
    int rbit;
  
    if (x0 == x1)
      set_pixel(x0,line,c);
    else {
      if (x0 > x1) {
        lbit = x0;
        x0 = x1;
        x1 = lbit;
      }
      lbit = 0xff >> (x0&7);
      x0 = x0/8 + display.hres*line;
      rbit = ~(0xff >> (x1&7));
      x1 = x1/8 + display.hres*line;
      if (x0 == x1) {
        lbit = lbit & rbit;
        rbit = 0;
      }
      if (c == WHITE) {
        screen[x0++] |= lbit;
        while (x0 < x1)
          screen[x0++] = 0xff;
        screen[x0] |= rbit;
      }
      else if (c == BLACK) {
        screen[x0++] &= ~lbit;
        while (x0 < x1)
          screen[x0++] = 0;
        screen[x0] &= ~rbit;
      }
      else if (c == INVERT) {
        screen[x0++] ^= lbit;
        while (x0 < x1)
          screen[x0++] ^= 0xff;
        screen[x0] ^= rbit;
      }
    }
  } // end of draw_row
  
  
  /* Fill a column from one point to another
   *
   * Argument:
   *  row:
   *    The row that fill will be performed on.
   *  y0:
   *    edge 0 of the fill.
   *  y1:
   *    edge 1 of the fill.
   *  c:
   *    the color of the fill.
   *    (see color note at the top of this file)
   */
  void draw_column(int row, int y0, int y1, int c) {
    int bit;
    int theByte;
  
    if (y0 == y1)
      set_pixel(row,y0,c);
    else {
      if (y1 < y0) {
        bit = y0;
        y0 = y1;
        y1 = bit;
      }
      bit = 0x80 >> (row&7);
      theByte = row/8 + y0*display.hres;
      if (c == WHITE) {
        while ( y0 <= y1) {
          screen[theByte] |= bit;
          theByte += display.hres;
          y0++;
        }
      }
      else if (c == BLACK) {
        while ( y0 <= y1) {
          screen[theByte] &= ~bit;
          theByte += display.hres;
          y0++;
        }
      }
      else if (c == INVERT) {
        while ( y0 <= y1) {
          screen[theByte] ^= bit;
          theByte += display.hres;
          y0++;
        }
      }
    }
  } // end of draw_column


  /* draw a rectangle at x,y with a specified width and height
   *
   * Arguments:
   *  x0:
   *    The x coordinate of upper left corner of the rectangle.
   *  y0:
   *    The y coordinate of upper left corner of the rectangle.
   *  w:
   *    The widht of the rectangle.
   *  h:
   *    The height of the rectangle.
   *  c:
   *    The color of the rectangle.
   *    (see color note at the top of this file)
   *  fc:
   *    The fill color of the rectangle.
   *    (see color note at the top of this file)
   *    default =-1 (no fill)
   */
  void draw_rect(int x0, int y0, int w, int h, int c, int fc) {
    if (fc != -1) {
      for (int i = y0; i < y0+h; i++)
        draw_row(i,x0,x0+w,fc);
    }
    //TODO //FIXME - subtract 1 from w and h when adding below?
    // (As it is now, drawing a box of width 1 will be 2 pixels wide.)
    draw_line(x0,y0,x0+w,y0,c);
    draw_line(x0,y0,x0,y0+h,c);
    draw_line(x0+w,y0,x0+w,y0+h,c);
    draw_line(x0,y0+h,x0+w,y0+h,c);
  } // end of draw_rect


  /* draw a circle given a coordinate x,y and radius both filled and non filled.
   *
   * Arguments:
   *  x0:
   *    The x coordinate of the center of the circle.
   *  y0:
   *    The y coordinate of the center of the circle.
   *  radius:
   *    The radius of the circle.
   *  c:
   *    The color of the circle.
   *    (see color note at the top of this file)
   *  fc:
   *    The color to fill the circle.
   *    (see color note at the top of this file)
   *    defualt  =-1 (do not fill)
   */
  void draw_circle(int x0, int y0, int radius, int c, int fc) {
    int f = 1 - radius;
    int ddF_x = 1;
    int ddF_y = -2 * radius;
    int x = 0;
    int y = radius;
    int pyy = y;
    int pyx = x;
    
    //there is a fill color
    if (fc != -1)
      draw_row(y0,x0-radius,x0+radius,fc);
  
    sp(x0, y0 + radius,c);
    sp(x0, y0 - radius,c);
    sp(x0 + radius, y0,c);
    sp(x0 - radius, y0,c);
  
    while(x < y) {
      if(f >= 0) {
        y--;
        ddF_y += 2;
        f += ddF_y;
      }
      x++;
      ddF_x += 2;
      f += ddF_x;
  
      //there is a fill color
      if (fc != -1) {
        //prevent double draws on the same rows
        if (pyy != y) {
          draw_row(y0+y,x0-x,x0+x,fc);
          draw_row(y0-y,x0-x,x0+x,fc);
        }
        if (pyx != x && x != y) {
          draw_row(y0+x,x0-y,x0+y,fc);
          draw_row(y0-x,x0-y,x0+y,fc);
        }
        pyy = y;
        pyx = x;
      }
      sp(x0 + x, y0 + y,c);
      sp(x0 - x, y0 + y,c);
      sp(x0 + x, y0 - y,c);
      sp(x0 - x, y0 - y,c);
      sp(x0 + y, y0 + x,c);
      sp(x0 - y, y0 + x,c);
      sp(x0 + y, y0 - x,c);
      sp(x0 - y, y0 - x,c);
    }
  } // end of draw_circle


  /* place a bitmap at x,y where the bitmap is defined as {width,height,imagedata....}
   *
   * Arguments:
   *  x:
   *    The x coordinate of the upper left corner.
   *  y:
   *    The y coordinate of the upper left corner.
   *  bmp:
   *    The bitmap data to print.
   *  i:
   *    The offset into the image data to start at.  This is mainly used for fonts.
   *    default = 0
   *  width:
   *    Override the bitmap width. This is mainly used for fonts.
   *    default =0 (do not override)
   *  height:
   *    Override the bitmap height. This is mainly used for fonts.
   *    default = 0 (do not override)
   */
  void bitmap(int x, int y, int[] bmp, int i, int theWidth, int lines) {
    int temp;
    int lshift;
    int rshift;
    int save;
    int xtra;
    int si = 0;
  
    rshift = x&7;
    lshift = 8-rshift;
    if (theWidth == 0) {
      //theWidth = pgm_read_byte((uint32_t)(bmp) + i);
      theWidth = bmp[i];
      i++;
    }
    if (lines == 0) {
      lines = bmp[i];
      i++;
    }
  
    if ((theWidth & 7) > 0) {
      xtra = theWidth & 7;
      theWidth = theWidth/8;
      theWidth++;
    }
    else {
      xtra = 8;
      theWidth = theWidth/8;
    }
  
    for (int l = 0; l < lines; l++) {
      si = (y + l)*display.hres + x/8;
      if (theWidth == 1)
        temp = 0xff >> rshift + xtra;
      else
        temp = 0;
      save = screen[si];
      screen[si] &= ((0xff << lshift) | temp);
      temp = bmp[i++];
      screen[si++] |= temp >> rshift;
      for ( int b = i + theWidth-1; i < b; i++) {
        save = screen[si];
        screen[si] = temp << lshift;
        temp = bmp[i];
        screen[si++] |= temp >> rshift;
      }
      if (rshift + xtra < 8)
        screen[si-1] |= (save & (0xff >> rshift + xtra)); //test me!!!
      if (rshift + xtra - 8 > 0)
        screen[si] &= (0xff >> rshift + xtra - 8);
      screen[si] |= temp << lshift;
    }
  } // end of bitmap


  // Simplified bitmap function
  void bitmap(int x, int y, int[] bmp) {
    bitmap(x, y, bmp, 0, 0, 0);
  }

  
  /* shift the pixel buffer in any direction
   * This function will shift the screen in a direction by any distance.
   *
   * Arguments:
   *  distance:
   *    The distance to shift the screen
   *  direction:
   *    The direction to shift the screen the direction and the integer values:
   *    DIR_UP    = 0
   *    DIR_DOWN  = 1
   *    DIR_LEFT  = 2
   *    DIR_RIGHT = 3
   *
   * NOTE: This doesn't loop the screen, so when something moves off screen it's gone.
   */
  void shift(int distance, int direction) {
    int src; // uint8_t * src;
    int dst; // uint8_t * dst;
    int end; // uint8_t * end;
    int shift;
    int tmp;
    switch(direction) {
      case DIR_UP:
        dst = 0;
        src = 0 + distance*display.hres;
        end = 0 + display.vres*display.hres;
  
        while (src < end) {
          screen[dst] = screen[src];
          screen[src] = 0;
          dst++;
          src++;
        }
        break;
      case DIR_DOWN:
        dst = 0 + display.vres*display.hres - 1;
        src = dst - distance*display.hres;
        end = 0;
  
        while (src >= end) {
          screen[dst] = screen[src];
          screen[src] = 0;
          dst--;
          src--;
        }
        break;
      case DIR_LEFT:
        shift = distance & 7;

        for (int line = 0; line < display.vres; line++) {
          dst = 0 + display.hres*line;
          src = dst + distance/8;
          end = dst + display.hres-2;
          while (src <= end) {
            tmp = 0;
            tmp = (screen[src] << shift) & 0xFF;
            screen[src] = 0;
            src++;
            tmp |= screen[src] >> (8 - shift);
            screen[dst] = tmp;
            dst++;
          }
          tmp = 0;
          tmp = (screen[src] << shift) & 0xFF;
          screen[src] = 0;
          screen[dst] = tmp;
        }
        break;
      case DIR_RIGHT:
        shift = distance & 7;
  
        for (int line = 0; line < display.vres; line++) {
          dst = 0 + display.hres-1 + display.hres*line;
          src = dst - distance/8;
          end = dst - display.hres+2;
          while (src >= end) {
            tmp = 0;
            tmp = (screen[src] >> shift) & 0xFF;
            screen[src] = 0;
            src--;
            tmp |= (screen[src] << (8 - shift)) & 0xFF;
            screen[dst] = tmp;
            dst--;
          }
          tmp = 0;
          tmp = (screen[src] >> shift) & 0xFF;
          screen[src] = 0;
          screen[dst] = tmp;
        }
        break;
    }
  } // end of shift


  /* Inline version of set_pixel that does not perform a bounds check
   * This function will be replaced by a macro.
   */
  void sp(int x, int y, int c) {
    if (c==1)
      screen[(x/8) + (y*display.hres)] |= 0x80 >> (x&7);
    else if (c==0)
      screen[(x/8) + (y*display.hres)] &= ~0x80 >> (x&7);
    else
      screen[(x/8) + (y*display.hres)] ^= 0x80 >> (x&7);
  } // end of sp

  
  // SKIPPED
  //void TVout_ve_plus::set_vbi_hook()


  // SKIPPED
  //void TVout_ve_plus::set_hbi_hook()


  // SKIPPED
  //void TVout_ve_plus::tone()

  
  // SKIPPED
  //void TVout_ve_plus::tone()
  
  
  // SKIPPED
  //void TVout_ve_plus::noTone()
  
  
  // SKIPPED
  //void TVout_ve_plus::capture()
 
  
  // SKIPPED
  //void TVout_ve_plus::resume()
  
  
  // SKIPPED
  //void TVout_ve_plus::setDataCapture() 


  // *********************************************************************
  // From TVout_ve_plusPrint:
  // *********************************************************************

  void select_font(int[] f) {
    font = f;
  }


  /*
   * print an 8x8 char c at x,y
   * x must be a multiple of 8      //FIXME: I don't think the 'multiple of 8' thing is true?
   */
  void print_char(int x, int y, int c) {
    //c -= pgm_read_byte(font+2);
    //int ic = c - font[0+2];
    c -= font[0+2];
    //bitmap(x, y, font, (c*pgm_read_byte(font+1))+3, pgm_read_byte(font), pgm_read_byte(font+1));
    bitmap(x, y, font, (c*font[0+1])+3, font[0], font[0+1]);
  }

  void print_char(int x, int y, char c) {
    print_char(x, y, int(c));
  }


  /*
   * Print a row of a character from the currently selected font at x,y.
   * Row sets the first row to print, lines sets how many lines after the row to also print.
   *
   * Arguments:
   *  x:
   *  y:
   *  c:
   *  row:
   *  lines:
   *
   */
  void print_char_row(int x, int y, char c, int row, int lines) {
    //c -= pgm_read_byte(font+2);
    int ic = int(c) - font[0+2];
    //bitmap(x, y, font, (c*pgm_read_byte(font+1))+3+row, pgm_read_byte(font), lines);
    bitmap(x, y, font, (ic*font[0+1])+3+row, font[0], lines);
  }


  void inc_txtline() {
    if (cursor_y >= (display.vres - font[0+1]))
      shift(font[0+1],DIR_UP);
    else
      cursor_y += font[0+1];
  }

  //************************************************************ write()

  /* default implementation: may be overridden */
  void write(char[] str) {
    //while (*str)
    //  write(*str++);
    for (int i = 0; i < str.length; i++) {
      write(str[i]);
    }
  }
  
  /* default implementation: may be overridden */
  void write(int[] buffer, int size) {
    //while (size--)
    //  write(*buffer++);
    for (int i = 0; i < size; i++) {
      write(buffer[i]);
    }
  }

  // Added just for Processing
  void write(int[] buffer) {
    //while (size--)
    //  write(*buffer++);
    for (int i = 0; i < buffer.length; i++) {
      write(buffer[i]);
    }
  }

  // Added just for Processing
  void write(String str) {
    for (int i = 0; i < str.length(); i++) {
      write(str.charAt(i));
    }
  }

  void write(char c) {
    write(int(c));
  }

  void write(int c) {
    switch(c) {
      case 0:      //null
        break;
      case 10:      //line feed
        cursor_x = 0;
        inc_txtline();
        break;
      case 8:         //backspace
        //cursor_x -= pgm_read_byte(font);
        cursor_x = cursor_x - font[0];
        print_char(cursor_x, cursor_y, ' ');
        break;
      case 13:        //carriage return !?!?!?!VT!?!??!?!
        cursor_x = 0;
        break;
      case 14:        //form feed new page(clear screen)
        //clear_screen();
        break;
      default:
        if (cursor_x >= (display.hres*8 - font[0])) {
          cursor_x = 0;
          inc_txtline();
          print_char(cursor_x, cursor_y, c);
        }
        else
          print_char(cursor_x,cursor_y,c);
        cursor_x += font[0];
    }
  }

  //************************************************************ write_row()

  /*
   *TODO: Document this function.
   *
   *
   *
   */
  /* default implementation: may be overridden */
  void write_row(String str, int row, int lines) {
    //while (*str)
    //  write_row(*str++, row, lines);
    for (int i = 0; i < str.length(); i++) {
      write_row(int(str.charAt(i)), row, lines);
    }
  }

  void write_row(char[] str, int row, int lines) {
    //while (*str)
    //  write_row(*str++, row, lines);
    for (int i = 0; i < str.length; i++) {
      write_row(int(str[i]), row, lines);
    }
  }

  /*
   *TODO: Document this function.
   *
   *
   *
   */
  /* default implementation: may be overridden */
  void write_row(int[] buffer, int size, int row, int lines) {
    //while (size--)
    //  write_row(*buffer++, row, lines);
    for (int i = 0; i < buffer.length; i++) {
      write_row(buffer[i], row, lines);
    }
  }

  // ADDED FOR PROCESSING
  void write_row(int[] c, int row, int lines) {
    for (int i = 0; i < c.length; i++) {
      write_row(c[i], row, lines);
    }
  }

  /*
   *TODO: Document this function.
   *
   *
   *
   */
  void write_row(int c, int row, int lines) {
    switch(c) {
      case 0:      //null
        break;
      case 10:      //line feed
        cursor_x = 0;
        inc_txtline();
        break;
      case 8:         //backspace
        cursor_x -= font[0];
        print_char(cursor_x,cursor_y,' ');
        break;
      case 13:        //carriage return !?!?!?!VT!?!??!?!
        cursor_x = 0;
        break;
      case 14:        //form feed new page(clear screen)
        //clear_screen();
        break;
      default:
        if (cursor_x >= (display.hres*8 - font[0])) {
          cursor_x = 0;
          inc_txtline();
          print_char_row(cursor_x, cursor_y, char(c), row, lines);
        }
        else {
          print_char_row(cursor_x, cursor_y, char(c), row, lines);
        }
        cursor_x += font[0];
    }
  }

  //************************************************************ print()

  void print(char[] str) {
    write(str);
  }

  // ADDED FOR PROCESSING
  void print(int[] c) {
    write(c);
  }

  // ADDED FOR PROCESSING
  void print(String str) {
    write(str);
  }

  //************************************************************ print_row()

  /*
   *TODO: Document this function.
   *
   *
   *
   */
  void print_row(char[] str, int row, int lines) {
    write_row(str, row, lines);
  }

  // ADDED FOR PROCESSING
  void print_row(int[] c, int row, int lines) {
    write_row(c, row, lines);
  }

  // ADDED FOR PROCESSING
  void print_row(String str, int row, int lines) {
    write_row(str, row, lines);
  }

  //************************************************************ print() with base

  void print(char c, int base) {
    this.print((int) c, base);
  }
  
  void print(char c) {
    this.print((int) c, BYTE);
  }

  // SKIPPED
  //void print(unsigned char b, int base)
  
  // SKIPPED
  //void print(unsigned int n, int base)
  
  void print(int n, int base) {
    if (base == 0) {
      write(int(n)); // My change, since base 0 doesn't make any sense
    } else if (base == 10) {
      if (n < 0) {
        this.print('-');
        n = -n;
      }
      printNumber(n, 10);
    } else {
      printNumber(n, base);
    }
  }

  // ADDED FOR PROCESSING
  void print(int c) {
    this.print((int) c, DEC);
  }

  // SKIPPED
  //void print(unsigned long n, int base)

  void print(float n, int digits) {
    printFloat(n, digits);
  }

  void print(float n) {
    printFloat(n, 2);
  }

  //************************************************************ println()

  void println() {
    this.print('\r');
    this.print('\n');
  }
  
  void println(char[] c) {
    this.print(c);
    this.println();
  }

  // ADDED FOR PROCESSING
  void println(int[] c) {
    this.print(c);
    this.println();
  }

  // ADDED FOR PROCESSING
  void println(String str) {
    this.print(str);
    this.println();
  }

  //************************************************************ println_row()

  /*
   *TODO: Document this function.
   *
   *
   */
  void println_row(char[] c, int row, int lines) {
    print_row(c, row, lines);
    println();                  //FIXME: Might need to do something about this?
  }

  // ADDED FOR PROCESSING
  void println_row(int[] c, int row, int lines) {
    print_row(c, row, lines);
    println();                  //FIXME: Might need to do something about this?
  }

  // ADDED FOR PROCESSING
  void println_row(String str, int row, int lines) {
    print_row(str, row, lines);
    println();                  //FIXME: Might need to do something about this?
  }

  //************************************************************ println() with base
  
  void println(char c, int base) {
    print(c, base);
    println();
  }

  void println(char c) {
    println(c, BYTE);
  }

  // SKIPPED
  //void println(unsigned char b, int base)
  
  void println(int n, int base) {
    print(n, base);
    println();
  }

  void println(int n) {
    println(n, DEC);
  }
  
  // SKIPPED
  //void println(unsigned int n, int base)
  
  void println(long n, int base) {
    print(n, base);
    println();
  }

  void println(long n) {
    println(n, DEC);
  }

  // SKIPPED
  //void TVout_ve_plus::println(unsigned long n, int base)

  void println(float n, int digits) {
    print(n, digits);
    println();
  }

  void println(float n) {
    println(n, 2);
  }

  //************************************************************ printPGM()

  void printPGM(char[] str) {
    //char c;
    //while ((c = pgm_read_byte(str))) {
    //  str++;
    //  write(c);
    //}
    for (int i = 0; i < str.length; i++) {
      write(str[i]);
    }
  }

  // ADDED FOR PROCESSING
  void printPGM(int[] str) {
    //char c;
    //while ((c = pgm_read_byte(str))) {
    //  str++;
    //  write(c);
    //}
    for (int i = 0; i < str.length; i++) {
      write(str[i]);
    }
  }
  
  void printPGM(int x, int y, char[] str) {
    //char c;
    cursor_x = x;
    cursor_y = y;
    //while ((c = pgm_read_byte(str))) {
    //  str++;
    //  write(c);
    //}
    for (int i = 0; i < str.length; i++) {
      write(str[i]);
    }
  }

  // ADDED FOR PROCESSING
  void printPGM(int x, int y, int[] str) {
    //char c;
    cursor_x = x;
    cursor_y = y;
    //while ((c = pgm_read_byte(str))) {
    //  str++;
    //  write(c);
    //}
    for (int i = 0; i < str.length; i++) {
      write(str[i]);
    }
  }
  
  void set_cursor(int x, int y) {
    cursor_x = x;
    cursor_y = y;
  }

  //************************************************************ print() with x,y

  void print(int x, int y, char[] str) {
    cursor_x = x;
    cursor_y = y;
    write(str);
  }

  // ADDED FOR PROCESSING
  void print(int x, int y, int[] str) {
    cursor_x = x;
    cursor_y = y;
    write(str);
  }

  // ADDED FOR PROCESSING
  void print(int x, int y, String str) {
    cursor_x = x;
    cursor_y = y;
    write(str);
  }

  //************************************************************ print() with x,y and base

  void print(int x, int y, char c, int base) {
    cursor_x = x;
    cursor_y = y;
    print((int) c, base);
  }

  void print(int x, int y, char c) {
    print(x, y, c, BYTE);
  }

  // SKIPPED
  //void TVout_ve_plus::print(uint8_t x, uint8_t y, unsigned char b, int base)
  
  void print(int x, int y, int n, int base) {
    cursor_x = x;
    cursor_y = y;
    print((int) n, base);
  }

  void print(int x, int y, int n) {
    print(x, y, n, DEC);
  }

  // SKIPPED
  //void TVout_ve_plus::print(uint8_t x, uint8_t y, unsigned int n, int base)
  
  void print(int x, int y, long n, int base) {
    cursor_x = x;
    cursor_y = y;
    print(n,base);
  }

  void print(int x, int y, long n) {
    print(x, y, n, DEC);
  }

  // SKIPPED
  //void print(uint8_t x, uint8_t y, unsigned long n, int base)
  
  void print(int x, int y, float n, int digits) {
    cursor_x = x;
    cursor_y = y;
    print(n,digits);
  }

  void print(int x, int y, float n) {
    print(x, y, n, 2);
  }

  //************************************************************ print_row() with x,y

  /*
   *TODO: Document this function.
   *
   *
   */
  void print_row(int x, int y, char str[], int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    write_row(str, row, lines);
  }
  
  // ADDED FOR PROCESSING
  void print_row(int x, int y, int str[], int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    write_row(str, row, lines);
  }
  
  // ADDED FOR PROCESSING
  void print_row(int x, int y, String str, int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    write_row(str, row, lines);
  }

  //************************************************************ println() with x,y

  void println(int x, int y, char[] c) {
    cursor_x = x;
    cursor_y = y;
    print(c);
    println();
  }
  
  void println(int x, int y, int[] c) {
    cursor_x = x;
    cursor_y = y;
    print(c);
    println();
  }
  
  void println(int x, int y, String str) {
    cursor_x = x;
    cursor_y = y;
    print(str);
    println();
  }

  //************************************************************ println() with x,y and base

  void println(int x, int y, char c, int base) {
    cursor_x = x;
    cursor_y = y;
    print(c, base);
    println();
  }

  void println(int x, int y, char c) {
    println(x, y, c, BYTE);
  }

  // SKIPPED
  //void TVout_ve_plus::println(uint8_t x, uint8_t y, unsigned char b, int base)

  void println(int x, int y, int n, int base) {
    cursor_x = x;
    cursor_y = y;
    print(n, base);
    println();
  }

  void println(int x, int y, int n) {
    println(x, y, n, DEC);
  }

  // SKIPPED
  //void TVout_ve_plus::println(uint8_t x, uint8_t y, unsigned int n, int base)

  void println(int x, int y, long n, int base) {
    cursor_x = x;
    cursor_y = y;
    print(n, base);
    println();
  }

  void println(int x, int y, long n) {
    println(x, y, n, DEC);
  }

  // SKIPPED
  //void TVout_ve_plus::println(uint8_t x, uint8_t y, unsigned long n, int base)
  
  void println(int x, int y, float n, int digits) {
    cursor_x = x;
    cursor_y = y;
    print(n, digits);
    println();
  }

  void println(int x, int y, float n) {
    println(x, y, n, 2);
  }

  //************************************************************ println_row() with x,y

  /*
   *TODO: Document this function.
   *
   *
   */
  void println_row(int x, int y, char[] c, int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    print_row(c, row, lines);
    println();
  }

  // ADDED FOR PROCESSING
  void println_row(int x, int y, int[] c, int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    print_row(c, row, lines);
    println();
  }

  // ADDED FOR PROCESSING
  void println_row(int x, int y, String str, int row, int lines) {
    cursor_x = x;
    cursor_y = y;
    print_row(str, row, lines);
    println();
  }

  void printNumber(int n, int base) {
    //unsigned char buf[8 * sizeof(long)]; // Assumes 8-bit chars.
    int[] buf = new int[8*2];
    int i = 0;
  
    if (n == 0) {
      print('0');
      return;
    }
  
    while (n > 0) {
      buf[i++] = n % base;
      n /= base;
    }
  
    for (; i > 0; i--)
      print((char) (buf[i - 1] < 10 ?
        '0' + buf[i - 1] :
        'A' + buf[i - 1] - 10));
  }

  void printFloat(float number, int digits) {
    // Handle negative numbers
    if (number < 0.0) {
       print('-');
       number = -number;
    }
  
    // Round correctly so that print(1.999, 2) prints as "2.00"
    float rounding = 0.5;
    for (int i=0; i<digits; ++i) {
      rounding /= 10.0;
    }
    
    number += rounding;
  
    // Extract the integer part of the number and print it
    int int_part = (int)number;
    float remainder = number - (float)int_part;
    print(int_part);
  
    // Print the decimal point, but only if there are digits beyond
    if (digits > 0) {
      print(".");
    }
    
    // Extract digits from the remainder one at a time
    while (digits-- > 0) {
      remainder *= 10.0;
      int toPrint = int(remainder);
      print(toPrint);
      remainder -= toPrint;
    }
  }


  // *********************************************************************
  // *********************************************************************
  // Custom functions I added just to this processing version!
  // *********************************************************************
  // *********************************************************************

  // I guess this can't work inside the class??
  // Or I just don't know how to call processing's println instead of the class's println.
  //
  //// Print some info to the console for debugging purposes
  //void printInfo() {
  //  println("Length of screen array: ", screen.length);
  //  //TODO add more info
  //}

  // 
  void drawTVoutScreen() {
    for (int j = 0; j < DISPLAYHEIGHT; j++) {
      for (int i = 0; i < (DISPLAYWIDTH/8); i++) {
        int theByte;
        int theBit;
        theByte = screen[i+(j*(DISPLAYWIDTH/8))];
        // Keep this unrolled bit around just in case it ends up being faster.
        //theBit = (theByte & (1 << 7)) >> 7;
        //set((i*8)+0, j, color(theBit));
        //theBit = (theByte & (1 << 6)) >> 6;
        //set((i*8)+1, j, color(theBit));
        //theBit = (theByte & (1 << 5)) >> 5;
        //set((i*8)+2, j, color(theBit));
        //theBit = (theByte & (1 << 4)) >> 4;
        //set((i*8)+3, j, color(theBit));
        //theBit = (theByte & (1 << 3)) >> 3;
        //set((i*8)+4, j, color(theBit));
        //theBit = (theByte & (1 << 2)) >> 2;
        //set((i*8)+5, j, color(theBit));
        //theBit = (theByte & (1 << 1)) >> 1;
        //set((i*8)+6, j, color(theBit));
        //theBit = (theByte & (1 << 0)) >> 0;
        //set((i*8)+7, j, color(theBit));
        for (int k = 0; k < 8; k++) {
          theBit = (theByte & (1 << (7-k))) >> (7-k);
          set((i*8)+k, j, color(theBit));
        }
      }
    }
    // Enlarge the pixels to fill our window
    image(get(0, 0, DISPLAYWIDTH, DISPLAYHEIGHT), 0, 0, width, height);
  }

}
