include <BOSL2/std.scad>

g_wall_thickness = 1;

g_groove_slot_radius = 14;
g_groove_slot_depth = 34;
g_groove_slot_height = 4.5;//4;
g_groove_slot_ledge_depth = 4;//3;
g_box_groove_spacing = 0;

//g_box_width = 172;
g_box_width = 178.5;
g_box_height = 87.2;
g_box_depth = 40;
g_box_cutout_height = g_box_height / 1.2;
g_box_cutout_depth = 100;
g_box_cutout_offset = g_box_depth / 3;


g_groove_slot_width_total = g_groove_slot_radius * 2 + g_wall_thickness * 2;

// Одна стенка + fillet
module side_wall(slot_depth, slot_height, slot_radius) {
  cuboid([g_wall_thickness, slot_depth, slot_height], anchor=CTR)
    attach(RIGHT, LEFT, align=FRONT)
      fillet(l=slot_height, r=slot_radius, ang=90);
}

module parabolic_groove(slot_depth, slot_height, slot_radius) {
  w = slot_radius * 2 + g_wall_thickness * 2;
  total_d = slot_depth + g_wall_thickness;

  attachable(anchor=CTR, size=[w, total_d, slot_height]) {
    union() {
      back(g_wall_thickness / 2) {
        // Левая стенка
        left(slot_radius + g_wall_thickness / 2)
          side_wall(slot_depth, slot_height, slot_radius);

        // Правая стенка
        right(slot_radius + g_wall_thickness / 2)
          mirror([1, 0, 0])
            side_wall(slot_depth, slot_height, slot_radius);

        // Передняя стенка
        fwd(slot_depth / 2)
          cuboid([w, g_wall_thickness, slot_height], anchor=BACK);
      }

      g_groove_slot_ledge_depth_total = g_groove_slot_ledge_depth + g_wall_thickness;
      attach(TOP, BOTTOM, spin=180, align=[LEFT, RIGHT])
        cuboid([g_groove_slot_ledge_depth_total, total_d, g_wall_thickness], rounding=1, edges=TOP, anchor=BOTTOM);
    }
    children();
  }
}

module box(width, depth, height, cutout_height = g_box_cutout_height, cutout_depth = g_box_cutout_depth) {
  echo("Cutout depth: ", g_wall_thickness + cutout_depth / 2);
  outer = [width, height, depth];
  inner = [width - 2 * g_wall_thickness, height - 2 * g_wall_thickness, depth];
  side_inner = [width * 2, cutout_height, cutout_depth];
  cutout_offset = g_wall_thickness + cutout_depth;
  up(height / 2)
    xrot(90)
      yrot(180)
        difference() {
          cuboid(outer, rounding=1);
          up(g_wall_thickness)
            cuboid(inner);
          down(g_box_cutout_offset)
            cuboid(side_inner, anchor=BOTTOM, rounding=10);
        }
}

function calc_num_of_elements(width, elem_width, wall_thickness) =
  floor((width - 2 * wall_thickness) / (elem_width));

total_groove_width = g_box_groove_spacing + g_groove_slot_width_total;
num_of_elements = calc_num_of_elements(g_box_width, total_groove_width, g_wall_thickness);
echo("Количество слотов: ", num_of_elements);
echo("Параметры расчета: ", g_box_width, total_groove_width, g_wall_thickness);

box(g_box_width, g_box_depth, g_box_height);
xcopies(spacing=total_groove_width, n=num_of_elements)
  left(g_groove_slot_radius)
    up(g_groove_slot_height / 2 + g_wall_thickness)
      parabolic_groove(g_groove_slot_depth, g_groove_slot_height, g_groove_slot_radius);
