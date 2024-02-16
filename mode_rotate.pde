int cx = 136/2;
int cy = 96/2;
int x1 = cx - 10;
int y1 = cy - 10;
int x2 = cx + 10;
int y2 = cy + 10;
int xx1, yy1, xx2, yy2;
float angle = 0;

void mode_rotate() {
  //tv.set_pixel(1, 1, WHITE); // DEBUG - test writing with set_pixel()
  //tv.draw_row(3,0,80,WHITE); // DEBUG - test
  //tv.draw_column(3,0,80,WHITE); // DEBUG - test
  //tv.draw_line(0,0,80,30,WHITE); // DEBUG - test

  tv.fill(BLACK); // clear screen

  angle += 0.01;

  xx1 = int(rot_x(float(x1), float(y1), angle, cx, cy));
  yy1 = int(rot_y(float(x1), float(y1), angle, cx, cy));

  xx2 = int(rot_x(float(x2), float(y2), angle, cx, cy));
  yy2 = int(rot_y(float(x2), float(y2), angle, cx, cy));

  // center X for reference
  tv.set_pixel(cx, cy, WHITE);
  tv.set_pixel(cx+1, cy+1, WHITE);
  tv.set_pixel(cx-1, cy-1, WHITE);
  tv.set_pixel(cx-1, cy+1, WHITE);
  tv.set_pixel(cx+1, cy-1, WHITE);

  tv.set_pixel(x1, y1, WHITE); // stationary (top-left)
  tv.set_pixel(x2, y2, WHITE); // stationary (bottom-right)
  tv.set_pixel(xx1, yy1, WHITE); // rotating (starting top-left, going CW)
  tv.set_pixel(xx2, yy2, WHITE); // rotating (starting bottom-right, going CW)
  //tv.draw_line(xx1, yy1, xx2, yy2, WHITE); // rotating

  //tv.set_pixel(x1, y2, WHITE); // stationary (bottom-left)
  //tv.set_pixel(x2, y1, WHITE); // stationary (top-right)
  //tv.set_pixel(xx1, yy2, WHITE); // rotating (starting bottom-left, going CCW)
  //tv.set_pixel(yy2, xx1, WHITE); // rotating (starting bottom-left, going CCW)
  //tv.set_pixel(xx2, yy1, WHITE); // rotating (starting top-right, going CCW)
  //tv.draw_line(xx1, yy2, xx2, yy1, WHITE);




}

float rot_x(float x, float y, float angle) {
  return rot_x(x, y, angle, 0, 0);
}

float rot_x(float x, float y, float angle, float center_x, float center_y) {
  // x` = x*cos - y*sin
  return (((x-center_x) * cos(angle)) - ((y-center_y) * sin(angle)) + center_x);
}

//int rot_x(int x, int y, int angle) {
//  //return int((x * cos(angle)) - (y * sin(angle)));
//  return int(rot_x(float(x), float(y), float(angle)));
//}

float rot_y(float x, float y, float angle) {
  return rot_y(x, y, angle, 0, 0);
}

float rot_y(float x, float y, float angle, float center_x, float center_y) {
  // y` = x*sin + y*cos
  return (((x-center_x) * sin(angle)) + ((y-center_y) * cos(angle)) + center_y);
}

//int rot_y(int x, int y, int angle) {
//  //return int((x * sin(angle)) + (y * cos(angle)));
//  return int(rot_y(float(x), float(y), float(angle)));
//}
