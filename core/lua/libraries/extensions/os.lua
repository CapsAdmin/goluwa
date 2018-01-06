do
	local ffi = desire("ffi")

	if ffi then
		if WINDOWS then
			ffi.cdef[[int _putenv_s(const char *var_name, const char *new_value)]]

			function os.setenv(key, val)
				ffi.C._putenv_s(key, val)
			end
		else
			ffi.cdef[[int setenv(const char *var_name, const char *new_value, int change_flag)]]

			function os.setenv(key, val, flag)
				ffi.C.setenv(key, val, flag or 0)
			end
		end
	else
		function os.setenv(key, val, flag)
			logn("ffi.C.setenv(", key, val, flag or 0, ")")
		end
	end
end

do -- by Python1320
	local dd=60*60*24
	local hh=60*60
	local mm=60

	function os.datetable(a)
		local negative=false
		if a<0 then negative=true a=a*-1 end
		local f,s,m,h,d
		f=a - math.floor(a)
		f=math.round(f*10)*0.1
		a=math.floor(a)
		d=math.floor(a/dd)
		a=a-d*dd
		h=math.floor(a/hh)
		a=a-h*hh
		m=math.floor(a/mm)
		a=a-m*mm
		s=a
		return {
			f=f,
			sec=s,
			min=m,
			hour=h,
			day=d,
			n=negative
		}
	end
end

do -- by Python1320
	local conjunction=  " and"
	local conjunction2= ","

	function os.prettydate(t, just_time)
		if type(t)=="number" then
			t = os.datetable(t)
		end

		if just_time then t.n = nil end

		local tbl={}
		if t.day~=0 then
			table.insert(tbl,t.day .." day"..(t.day==1 and "" or "s"))
		end

		local lastand
		if t.hour~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.hour .." hour"..(t.hour==1 and "" or "s"))
		end
		if t.min~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.min .." minute"..(t.min==1 and "" or "s"))
		end
		if t.sec~=0 or #tbl==0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.sec .."."..math.round((t.f or 0)*10).." seconds")
		end
		if t.n then
			table.insert(tbl," in the past")
		end
		for k,v in pairs(tbl) do
			if v==conjunction and k~=lastand then
				tbl[k]=conjunction2
			end
		end

		return table.concat ( tbl , "" )
	end
end

function os.executeasync(str)
	if LINUX then
		return os.execute([[eval ']]..str..[[' &]])
	else
		return os.execute(str)
	end
end