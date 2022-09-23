do -- virtual merge
	local root = {
		merged = {1},
		a = {
			b = {
				c = {
					ok = true,
				},
			},
		},
	}
	local foo = {
		merged = {2},
		a = {
			lol = {
				lol2 = {
					ok = true,
				},
			},
		},
		b = {c = {
			ok = true,
		}},
	}
	local bar = {
		merged = {3},
		b = {
			c = {
				notok = {
					ok = true,
				},
			},
		},
	}
	local virt = table.virtual_merge({}, {root, foo, bar})
	assert(#virt.merged == 3)

	for i, v in ipairs(virt.merged) do
		assert(i == v[1])
	end

	assert(virt.a.b.c.ok)
	assert(virt.a.lol.lol2.ok)
	assert(virt.b.c.ok)
	assert(virt.b.c.notok.ok)
end