// Probe.v

// Generated using ACDS version 18.0 614

`timescale 1 ps / 1 ps
module Probe (
		input  wire [127:0] probe,  //  probes.probe
		output wire [15:0]  source  // sources.source
	);

	altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("null"),
		.probe_width             (128),
		.source_width            (16),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
	) in_system_sources_probes_0 (
		.source     (source), // sources.source
		.probe      (probe),  //  probes.probe
		.source_ena (1'b1)    // (terminated)
	);

endmodule
