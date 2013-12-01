$fn = 100;

trap_base_r = 20.0;
trap_base_h = 20.0;

ant_hole_r = 2.0;
ant_holes = 5.0;

zip_tie_w = 4.6;
zip_tie_h = 1.25;

tip_guard_d_ratio = 0.5;
tip_guard_h_ratio = 0.3;

mark_ring_h = 2.0;

wall_thickness = 1.0;
thick_wall_thickness = 2.5;

padding = 0.75;
loose_padding = 0.75;

poison_well_h = ((1.0 - tip_guard_h_ratio) * trap_base_h) - wall_thickness;

zip_tie_cutter_w = zip_tie_w + (2 * loose_padding);
zip_tie_cutter_h = zip_tie_h + (2 * loose_padding);

connector_w = zip_tie_cutter_h + thick_wall_thickness;
cross_bar_w = (2 * trap_base_r) + (2 * connector_w);
cross_bar_h = zip_tie_cutter_w + (2 * thick_wall_thickness);
cross_bar_thickness = thick_wall_thickness + (zip_tie_cutter_w / 2.0) + zip_tie_h + padding;

//make_lid();

//make_base();

//make_for_design();

make_for_printing();

module make_for_design() {
	difference() {
		union() {
			make_base();

			translate([0, 0, trap_base_h + cross_bar_thickness + 0.5])
				rotate([180, 0, 0])
					make_lid();
		}

		translate([0, 0, -0.5])
			cube([trap_base_r, trap_base_r, trap_base_h + cross_bar_thickness + 1.5]);
	}
}

module make_for_printing() {
	translate([-trap_base_r - connector_w - 1.0, 0, 0])
		make_lid();

	translate([trap_base_r + connector_w + 1.0, 0, 0])
		make_base();
}

module make_base() {
	union() {
		difference() {
			union() {
				cylinder(trap_base_h, trap_base_r, trap_base_r, [0, 0, 0]);
	
				make_cross_bar();

				rotate([0, 0, 90])
					make_cross_bar();
			}
		
			// cut hollow
			translate([0, 0, wall_thickness])
				cylinder(trap_base_h, trap_base_r - wall_thickness, 
						trap_base_r - wall_thickness, [0, 0, 0]);
		}

		// poison well total fill mark
		translate([0, 0, poison_well_h + wall_thickness - (mark_ring_h / 2.0)])
			make_marking_ring();

		// poison well borax fill mark
		translate([0, 0, (poison_well_h / 10.0) + wall_thickness - (mark_ring_h / 2.0)])
			make_marking_ring();
	}
}

module make_lid() {
	difference() {
		union() {
			difference() {
				union() {
					// main lid
					cylinder(cross_bar_thickness, trap_base_r, trap_base_r, [0, 0, 0]);
	
					// lid lip
					cylinder(cross_bar_thickness + thick_wall_thickness, 
							trap_base_r - wall_thickness - padding, 
							trap_base_r - wall_thickness - padding, [0, 0, 0]);
	
					make_cross_bar();

					rotate([0, 0, 90])
						make_cross_bar();
				}

				// cut lid hollow
				translate([0, 0, wall_thickness])
					cylinder(cross_bar_thickness + thick_wall_thickness, 
							trap_base_r - (2 * wall_thickness) - padding, 
							trap_base_r - (2 * wall_thickness) - padding, [0, 0, 0]);
			}

			translate([0, 0, 0.5])
				difference() {
					// tip guard tube
					cylinder(cross_bar_thickness + (tip_guard_h_ratio * trap_base_h) - 0.5, 
							tip_guard_d_ratio * trap_base_r,
							tip_guard_d_ratio * trap_base_r, [0, 0, 0]);
	
					// tip guard tube hollow
					translate([0, 0, -1.0])
						cylinder(cross_bar_thickness + (tip_guard_h_ratio * trap_base_h) + 1.0, 
								(tip_guard_d_ratio * trap_base_r) - wall_thickness,
								(tip_guard_d_ratio * trap_base_r) - wall_thickness, [0, 0, 0]);
				}
		}
	
		translate([0, 0, -0.5])
			cylinder(wall_thickness + 1.0, ant_hole_r, ant_hole_r, [0, 0, 0]);

		for(i = [0 : 360 / ant_holes : 360]) {
			rotate([0, 0, i])
				translate([0, 
						((tip_guard_d_ratio * trap_base_r) - wall_thickness) - ant_hole_r, -0.5])
					cylinder(wall_thickness + 1.0, ant_hole_r, ant_hole_r, [0, 0, 0]);
		}
	}
}

module make_cross_bar() {
	translate([-cross_bar_w / 2.0, -cross_bar_h / 2.0, 0])
		difference() {
			// main bar
			cube([cross_bar_w, cross_bar_h, cross_bar_thickness]);
		
			// cut hole for ziptie 
			translate([zip_tie_cutter_h + thick_wall_thickness, thick_wall_thickness, -0.5])
				rotate([0, 0, 90])
					cube([zip_tie_cutter_w, zip_tie_cutter_h, cross_bar_thickness + 1.0]);
		
			// cut hole for ziptie 
			translate([cross_bar_w - thick_wall_thickness, thick_wall_thickness, -0.5])
				rotate([0, 0, 90])
					cube([zip_tie_cutter_w, zip_tie_cutter_h, cross_bar_thickness + 1.0]);

			// cut notch for ziptie
			make_connector_cutter();

			// cut notch for ziptie
			translate([cross_bar_w - thick_wall_thickness, 0, 0])
				make_connector_cutter();
		}
}

module make_connector_cutter() {
	translate([-0.5, thick_wall_thickness, 0])
		rotate([90, 0, 90])
			linear_extrude(height=thick_wall_thickness + 1.0)
				polygon([
						[0, -0.5],
						[0, zip_tie_h + padding],
						[(zip_tie_cutter_w / 2.0), cross_bar_thickness - thick_wall_thickness],
						[zip_tie_cutter_w, zip_tie_h + padding],
						[zip_tie_cutter_w, -0.5],
					]);
}

module make_marking_ring() {
	difference() {
		cylinder(mark_ring_h, trap_base_r - (wall_thickness / 2.0), 
				trap_base_r - (wall_thickness / 2.0), [0, 0, 0]);

		translate([0, 0, -0.01])
			cylinder(trap_base_r - wall_thickness, trap_base_r - wall_thickness, 0, [0, 0, 0]);

		translate([0, 0, mark_ring_h + 0.01])
			rotate([180, 0, 0])
				cylinder(trap_base_r - wall_thickness, trap_base_r - wall_thickness, 0, [0, 0, 0]);
	}
}








