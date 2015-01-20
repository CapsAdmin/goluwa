
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

do
	os.setcd = fs.setcd
	os.getcd = fs.getcd

	local stack = {}
	
	function os.pushcd(dir)
		table.insert(stack, os.getcd())
		os.setcd(dir)
	end
	
	function os.popcd()
		local old = table.remove(stack)
		if old then
			os.setcd(old)
		end
	end
end

do -- by Python1320
	local dd=60*60*24
	local hh=60*60
	local mm=60

	function os.datetable(a)
		check(a, "number")
		
		local negative=false
		if a<0 then negative=true a=a*-1 end
		local f,s,m,h,d
		f=a - math.floor(a)
		f=math.Round(f*10)*0.1
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
			s=s,
			m=m,
			h=h,
			d=d,
			n=negative
		}
	end
end

do -- by Python1320
	local conjunction=  " and"
	local conjunction2= ","
	
	function os.prettydate(t)
		check(t, "number", "table")

		if type(t)=="number" then
			t=datetable(t)
		end

		local tbl={}
		if t.d~=0 then
			table.insert(tbl,t.d .." day"..(t.d==1 and "" or "s"))
		end

		local lastand
		if t.h~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.h .." hour"..(t.h==1 and "" or "s"))
		end
		if t.m~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.m .." minute"..(t.m==1 and "" or "s"))
		end
		if t.s~=0 or #tbl==0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.s .."."..math.Round(t.f*10).." seconds")
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