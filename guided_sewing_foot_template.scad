// The diameter of the MATIC rod
matic_rod_diameter = 1.6;

// The height at which the MATIC rod is placed over the plate (the least strict parameter, as the foot is amortized)
matic_rod_dz = 5.0; 

// The Y offset between the MATIC rod and the needle
matic_offset_dy = 5.0;

// The total width of the MATIC handle (including allowance)
matic_handle_width = 6.1; 

// The X offset between the needle and the center of the MATIC handle on Janome machines with a maximum stitch width of 7 mm 
janome_matic_offset_dx = -0.75;

// The width of the transport mechanism in the Janome machines
janome_transport_width = 16.0;

needle_tunnel_length_max = 7.0;
needle_tunnel_margin = 4.0;

foot_base_leftside_width = janome_transport_width / 2;
foot_base_rightside_width_full = janome_transport_width / 2;

guide_min_width = 1.6;
ear_width = 3.5;

foot_base_height = 3.2;

primary_front_length = 5.0;
primary_back_length = 16.0;

short_guide_front_length = 2.0;
short_guide_back_length = 6.0;

ears_piece_width = matic_handle_width + ear_width * 2;
right_ear_edge_x = janome_matic_offset_dx + matic_handle_width / 2 + ear_width;

module reflection(
    mirror_vector = [1, 0, 0]
) {
    union() {
        children();
        mirror(mirror_vector) {
            children();
        }
    }
}

module make_wing(
    width,
    front_length,
    back_length,
) {
    h_max = 5.0;
    dx = 1;
    
    rotate([180, -90, 0])
    linear_extrude(height=width)
    polygon(
        points=[
            [h_max, -back_length],
            [0, -back_length],
            [0.00, front_length + dx * 0],
            [0.05, front_length + dx * 1],
            [0.20, front_length + dx * 2],
            [0.50, front_length + dx * 3],
            [1.00, front_length + dx * 4],
            [2.00, front_length + dx * 5],
            [h_max, front_length + dx * 6]
        ],
        paths=[
            [0, 1, 2, 3, 4, 5, 6, 7, 8],
        ]
    );
}

module top_cutter_global() {
    a = 40;
    h = 20;
    
    translate([-a / 2, -a / 2, foot_base_height])
    cube([a, a, h]);
}

module ears_piece_base_local() {
    back_length = 8.0;
    height = 4.0;
    
    translate([-ears_piece_width/2, 0, 0])
    rotate([180, -90, 0])
    linear_extrude(height=ears_piece_width)
    polygon(
        points=[
            [height / 2, -back_length],
            [-height / 2, -back_length],
            [-height / 2, 3.4],
            [height / 2, 1.4],
        ],
        paths=[
            [0, 1, 2, 3],
        ]
    );
}

module matic_rod_cutter_local() {
    length = 40;
    
    translate([-length / 2, 0, 0])
    rotate([180, -90, 0])
    cylinder(h = length, r = matic_rod_diameter / 2, $fn = 20);
}

module matic_handle_cutter_local() {
    a = matic_handle_width;
    h = 30;
    
    translate([-a / 2, -h / 2, -h / 2])
    cube([a, h, h]);
}

module ears_piece_local() {
    difference() {
        difference() {
            ears_piece_base_local();
            matic_rod_cutter_local();
        }
        matic_handle_cutter_local();
    }
}

module ears_piece_global() {
    translate([
        janome_matic_offset_dx,
        matic_offset_dy,
        matic_rod_dz,
    ])
    ears_piece_local();
}

module make_needle_tunnel_cutter(
    length,
    width,
) {
    height = 10;

    translate([0, 0, -height / 2]) {
        translate([-length / 2, -width / 2, 0])
        cube([length, width, height]);

        reflection([1, 0, 0]) {
            translate([length / 2, 0, 0])
            cylinder(h = height, r = width / 2, $fn = 20);
        }
    }
}

module make_guided_foot(
    // The distance between the needle and the guide
    guide_offset,
    guide_depth = 0.8,
    use_full_width = true,
    use_full_length = false,
) {
    guide_front_length = use_full_length ? primary_front_length : short_guide_front_length;
    guide_back_length = use_full_length ? primary_back_length : short_guide_back_length;

    foot_base_rightside_width_free = use_full_width ? foot_base_rightside_width_full : right_ear_edge_x;
    foot_base_rightside_width = max(guide_offset, foot_base_rightside_width_free);
    guide_width = max(foot_base_rightside_width - guide_offset, guide_min_width);

    // The nominal lenth of the needle tunnel (the maximal usable stich width)
    needle_tunnel_length_safe = (foot_base_rightside_width - needle_tunnel_margin) * 2;
    needle_tunnel_length = min(needle_tunnel_length_safe, needle_tunnel_length_max);

    module foot_base_global() {
        translate([-foot_base_leftside_width, 0, 0])
        make_wing(
            width = foot_base_leftside_width + foot_base_rightside_width,
            front_length = primary_front_length,
            back_length = primary_back_length
        );
    }

    module guide_global() {
        translate([guide_offset, 0, -guide_depth])
        make_wing(
            width = guide_width,
            front_length = guide_front_length,
            back_length = guide_back_length
        );
    }

    module guided_foot_global() {
        difference() {
            difference() {
                union() {
                    foot_base_global();
                    guide_global();
                }

                top_cutter_global();
            };

            needle_tunnel_cutter_global();
        }

        ears_piece_global();
    }

    module needle_tunnel_cutter_global() {
        make_needle_tunnel_cutter(
            length = needle_tunnel_length,
            width = 2.5
        );
    }

    guided_foot_global();
}
