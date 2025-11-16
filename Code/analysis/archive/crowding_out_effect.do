*preserve
	keep hhid07 t head_ins_group
	reshape wide head_ins_group, i(hhid07) j(t)
restore