if _G.zyronxStop then _G.zyronxStop() elseif _G.veastop then _G.veastop() end

local plrs, rs = cloneref(game:GetService("Players")), cloneref(game:GetService("RunService"))
local ws, rep = cloneref(game:GetService("Workspace")), cloneref(game:GetService("ReplicatedStorage"))
local hs, lp = cloneref(game:GetService("HttpService")), plrs.LocalPlayer
local uis = cloneref(game:GetService("UserInputService"))
local Lighting = cloneref(game:GetService("Lighting"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local up, flat = Vector3.yAxis, Vector3.new(1, 0, 1)
local playerWalkSpeed = 16
local totHumanoid = nil

local md = {
	r = { on = false, vis = false, a = 0.8, c = Color3.new() },
	b = { on = false, vis = false, a = 0.8, c = Color3.new() },
	g = { dive = false, catch = false },
	l = { on = false },
	p = { on = false, v = "pc" },
	s = { on = false },
	f = { on = false },
	a = { on = false, n = "" },
	v = { on = false, c = Color3.new(1, 1, 1) },
}
local cons, arm, lmb, bls = {}, {}, {}, {}
local chr, hrp, hum
local near, isb, sync
local bag, tm, held, owner
local press, start, keeper, jumping

local function oops(e) warn("Erro do Prisma Hub: " .. (string.gsub(tostring(e), "^.-:%d+: ", ""))) end
local function rnd() return string.lower(string.sub((string.gsub(hs:GenerateGUID(false), "-", "")), 1, math.random(6, 12))) end

do
	local tsz, traps = Vector3.new(2.5, 2.5, 2.5), {}
	local gid = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

	local function fake(o)
		for k in traps do
			if o:GetAttribute(k) ~= nil then return true end
		end
		return false
	end

	isb = function(o) return o.Parent ~= nil and o.Size == tsz and not o.Anchored and o:FindFirstChild("Owner") ~= nil and not fake(o) end

	local function addb(o)
		if o.Name ~= "TPS" or not o:IsA("BasePart") then return end
		for k, v in o:GetAttributes() do
			if type(v) == "string" and string.match(k, gid) and string.match(v, gid) then traps[k] = true end
		end
		bls[o] = true
	end

	local function watch(o)
		addb(o)
		if not (o:IsA("Folder") or o:IsA("Model")) or o:FindFirstChildOfClass("Humanoid") then return end
		for _, c in o:GetChildren() do addb(c) end
		cons[#cons + 1] = o.ChildAdded:Connect(addb)
	end

	for _, o in ws:GetChildren() do watch(o) end
	cons[#cons + 1] = ws.ChildAdded:Connect(watch)

	local nat, nb = 0

	near = function()
		local now = os.clock()
		if nb and now - nat < 0.1 and nb.Parent and not nb.Anchored then return nb end
		nb, nat = nil, now
		if not hrp then return end
		local pos, best = hrp.Position, math.huge
		for b in bls do
			if not b.Parent then
				bls[b] = nil
			elseif isb(b) then
				local d = (b.Position - pos).Magnitude
				if d < best then nb, best = b, d end
			end
		end
		return nb
	end
end

do
	local tmm, tml

	bag = function() return lp:FindFirstChildOfClass("Backpack") end

	tm = function()
		local bp = bag()
		local m = bp and bp:FindFirstChild("ToolManagement")
		if m ~= tmm then tmm, tml = m, m and require(m) end
		return tml
	end

	held = function()
		local ra = chr and chr:FindFirstChild("Right Arm")
		return ra ~= nil and ra:FindFirstChild("handsOn") ~= nil
	end

	owner = function(b)
		local o = b:FindFirstChild("Owner")
		return o and o.Value
	end

	start = function()
		local st = lp.PlayerGui:FindFirstChild("Start")
		return st, st and st:FindFirstChild("ImageLabel")
	end

	press = function(name)
		local _, il = start()
		local btn = il and il:FindFirstChild(name)
		if btn then firesignal(btn.MouseButton1Down) end
	end

	keeper = function()
		local bp = bag()
		return (bp and bp:FindFirstChild("GK") or chr and chr:FindFirstChild("GK")) ~= nil
	end

	jumping = function()
		local bp = bag()
		local mm = bp and bp:FindFirstChild("Module_Management")
		local j = mm and mm:FindFirstChild("Jumping")
		return j ~= nil and j.Value
	end
end

-- alcance
local rch = {}
do
	local run, co, sp, sv = coroutine.running, rep:FindFirstChild("ChangeOwner"), {}, {}
	local real, wr = setmetatable({}, { __mode = "k" }), setmetatable({}, { __mode = "k" })
	local oi, onc, orb, cb
	local tg, lb, pown
	local last, kick, snd, clm = 0, 0, 0, 0
	local lost, lt, lr = 0, 0, 0

	local function hk(on)
		if on == (oi ~= nil) then return end
		if not on then
			hookmetamethod(game, "__index", oi)
			hookmetamethod(game, "__namecall", onc)
			oi, onc = nil, nil
			return
		end
		local idx, nc
		idx = hookmetamethod(game, "__index", newcclosure(function(self, k)
			if k ~= "Position" or not sp[self] or real[run()] or checkcaller() then return idx(self, k) end
			local b = tg
			if b then return b.Position end
			return idx(self, k)
		end))
		nc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local m = getnamecallmethod()
			if m ~= "FireServer" and m ~= "GetPartBoundsInBox" or checkcaller() then return nc(self, ...) end
			if m == "FireServer" then
				if (...) ~= "BallSound" then return nc(self, ...) end
				local now = os.clock()
				if now - snd < 0.35 then return end
				snd = now
				return nc(self, ...)
			end
			local res, b = nc(self, ...), tg
			if not b or #res > 0 then return res end
			local _, _, prm = ...
			if typeof(prm) == "OverlapParams" and table.find(prm.FilterDescendantsInstances, b) then return { b } end
			return res
		end))
		oi, onc = idx, nc
	end

	local function rc(f)
		local function w(...)
			local th = run()
			real[th] = true
			local res = table.pack(pcall(f, ...))
			real[th] = nil
			if not res[1] then error(res[2], 0) end
			return table.unpack(res, 2, res.n)
		end
		wr[w] = true
		return w
	end

	local function wrap(root)
		for _, s in root:GetDescendants() do
			if not s:IsA("LocalScript") then continue end
			local env = getsenv(s)
			local f = type(env) == "table" and rawget(env, "AddPowers")
			if type(f) == "function" and not wr[f] then
				sv[env] = f
				rawset(env, "AddPowers", rc(f))
			end
		end
	end

	local function crv(on)
		for env, f in sv do
			if wr[rawget(env, "AddPowers")] then rawset(env, "AddPowers", f) end
		end
		table.clear(sv)
		cb = nil
		if not on then return end
		cb = bag()
		if cb then wrap(cb) end
		if chr then wrap(chr) end
	end

	local function gap(b)
		local p, best = b.Position, math.huge
		for _, l in lmb do
			local d = (p - l.Position).Magnitude
			if d < best then best = d end
		end
		return best
	end

	local function pick(now, b)
		b = lb or b
		if not b or held() then return end
		local g, far = gap(b), true
		if md.r.on and md.r.sz then far = (b.Position - hrp.Position).Magnitude > md.r.sz end
		if md.b.on and md.b.sz then far = g > md.b.sz end
		if lb and g <= lr then far = false end
		if far then pown = nil end
		if far or g <= 2 then return end
		local own = owner(b)
		if own and own ~= lp and pown == lp then lost = now end
		pown = own
		if own and own ~= lp and (now - lost < 0.4 or b:FindFirstChild("ReactDecline")) then return end
		return b
	end

	local function draw(b)
		local m, at = md.r, hrp
		if md.b.on then m, at = md.b, b or hrp end
		if not (at and m.vis and m.sz) or m.a >= 1 then
			if orb.Parent then orb.Parent = nil end
			return
		end
		local s = m.sz * 2
		if orb.Size.X ~= s then orb.Size = Vector3.one * s end
		if orb.Transparency ~= m.a then orb.Transparency = m.a end
		if orb.Color ~= m.c then orb.Color = m.c end
		orb.CFrame = CFrame.new(at.Position)
		if not orb.Parent then orb.Parent = ws.CurrentCamera end
	end

	function rch.lend(b, till, r)
		if lb ~= b then lt = 0 end
		lb, lt, lr = b, math.max(lt, till), r
	end

	function rch.step(now, b)
		if orb then draw(b) end
		if lb and (now > lt or not lb.Parent or held()) then lb = nil end
		tg = (md.r.on or md.b.on or lb) and pick(now, b)
		if not tg then return hk(false) end
		if co and owner(tg) == nil and now - clm > 0.1 then
			clm = now
			co:FireServer(tg, "Tackle")
		end
		local t = tm()
		if not (t and t.GetUsing()) then return hk(false) end
		if bag() ~= cb then crv(true) end
		hk(true)
		local bv = tg:FindFirstChild(lp.Name)
		if bv and bv:IsA("BodyVelocity") and bv.Velocity.Magnitude >= 45 then kick = now end
		if now - last < 0.03 or now - kick < 0.6 then return end
		last = now
		for _, p in lmb do
			firetouchinterest(p, tg, 0)
			firetouchinterest(p, tg, 1)
		end
	end

	function rch.stop()
		tg, lb = nil, nil
		hk(false)
		crv(false)
	end

	function rch.sync()
		local on = md.r.on or md.b.on
		if on and not orb then
			orb = Instance.new("Part")
			orb.Name, orb.Shape, orb.Material = rnd(), Enum.PartType.Ball, Enum.Material.ForceField
			orb.Anchored, orb.CanCollide, orb.CanTouch, orb.CanQuery, orb.CastShadow, orb.Massless = true, false, false, false, false, true
		elseif not on and orb then
			orb:Destroy()
			orb = nil
			rch.stop()
		end
	end

	function rch.bind()
		tg, cb = nil, nil
		table.clear(sp)
		if hrp then sp[hrp] = true end
		for _, p in lmb do sp[p] = true end
	end
end

local gl = {}
do
	local at, done, list, map = -9, false
	local op, rp = OverlapParams.new(), RaycastParams.new()
	op.FilterType, op.MaxParts = Enum.RaycastFilterType.Exclude, 300
	rp.FilterType, rp.RespectCanCollide = Enum.RaycastFilterType.Exclude, true

	local function aabb(p)
		local cf, s = p.CFrame, p.Size
		local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
		local e = Vector3.new(
			math.abs(r.X * s.X) + math.abs(u.X * s.Y) + math.abs(l.X * s.Z),
			math.abs(r.Y * s.X) + math.abs(u.Y * s.Y) + math.abs(l.Y * s.Z),
			math.abs(r.Z * s.X) + math.abs(u.Z * s.Y) + math.abs(l.Z * s.Z)
		) / 2
		return p.Position - e, p.Position + e
	end

	local function net(m, stad, anc, ap)
		local lo, hi
		for _, p in ws:GetPartBoundsInBox(CFrame.new(ap), Vector3.one * 50, op) do
			if p == anc or not p.CanCollide or p.Name == "TPS" or (p.Position - ap).Magnitude > 25 then continue end
			if not (p:IsDescendantOf(m) or stad and p:IsDescendantOf(stad)) then continue end
			local l, h = aabb(p)
			local e = h - l
			if e.X > 60 or e.Y > 60 or e.Z > 60 then continue end
			lo, hi = lo and lo:Min(l) or l, hi and hi:Max(h) or h
		end
		return lo, hi
	end

	local function mouth(lo, hi, mid, skip)
		local c = (lo + hi) / 2
		local n, line, hw
		if math.abs(mid.X - c.X) > math.abs(mid.Z - c.Z) then
			local s = c.X > mid.X and 1 or -1
			n, line, hw = Vector3.new(s, 0, 0), Vector3.new(s > 0 and lo.X or hi.X, lo.Y, c.Z), (hi.Z - lo.Z) / 2
		else
			local s = c.Z > mid.Z and 1 or -1
			n, line, hw = Vector3.new(0, 0, s), Vector3.new(c.X, lo.Y, s > 0 and lo.Z or hi.Z), (hi.X - lo.X) / 2
		end
		rp.FilterDescendantsInstances = skip
		local hit = ws:Raycast(line - n * 4 + Vector3.new(0, 12, 0), Vector3.new(0, -30, 0), rp)
		return { c = line, n = n, r = n:Cross(up), hw = hw, top = hi.Y, floor = hit and hit.Position.Y or lo.Y }
	end

	local function cmap()
		local v = rep:FindFirstChild("WorkspaceStadiumMap")
		return v and ws:FindFirstChild("WorkspaceStadiumMap" .. v.Value) or ws:FindFirstChild("WorkspaceStadiumMap")
	end

	local function piv(o) return o:IsA("Model") and o:GetPivot().Position or o.Position end

	local function build()
		local m = cmap()
		map, list, done = m, nil, false
		if not m then return end
		local a, b = m:FindFirstChild("Goal1"), m:FindFirstChild("Goal2")
		if not (a and b) then a, b = m:FindFirstChild("Team1"), m:FindFirstChild("Team2") end
		if not (a and b) then return end
		local skip = { ws.CurrentCamera, ws:FindFirstChild("WorkspaceCharacters") }
		op.FilterDescendantsInstances = skip
		local stad = ws:FindFirstChild("WorkspaceStadiumFolder")
		local pa, pb = piv(a), piv(b)
		local alo, ahi = net(m, stad, a, pa)
		local blo, bhi = net(m, stad, b, pb)
		if not (alo and blo) then return end
		local mid = (pa + pb) / 2
		list, done = { mouth(alo, ahi, mid, skip), mouth(blo, bhi, mid, skip) }, true
	end

	function gl.own(pos)
		local now = os.clock()
		if now - at > 2 then
			at = now
			if not done or cmap() ~= map then build() end
		end
		if not list then return end
		local bd, best = 75
		for _, g in list do
			local d = (pos - g.c).Magnitude
			if d < bd then best, bd = g, d end
		end
		return best
	end
end

-- mergulho automático (ajustes internos podem precisar de revisão após atualizações do jogo)
local gk = {}
do
	local k = {
		mid = 0.3, depth = 2.3, slide = 0.08, front = 8, lane = 1.5, lowy = 0.26, highup = 3.1, highvy = 3.5,
		airvy = 2.25, lift = 0.3, jv = 53.5, jg = 98.1, creach = 2.2, clead = 0.16, startup = 1 / 60,
	}
	local nrm, cls = { speed = 32, dur = 0.7, lag = 0 }, { speed = 30, dur = 0.45, lag = 0.065 }
	local pose = { 0, -3.1, 2.1, 0.3, -3.3, 2.1, 0.45, -2.9, 3, 0.6, -2.2, 2.8 }
	local drag = math.exp(-0.115 / 60)
	local mvs = {
		BodyVelocity = true, BodyAngularVelocity = true, BodyThrust = true, BodyPosition = true,
		LinearVelocity = true, AngularVelocity = true, VectorForce = true,
	}
	local pt, px, py = table.create(130, 0), table.create(130, 0), table.create(130, 0)
	local pz, qy = table.create(130, 0), table.create(130, 0)
	local sm = { n = 0, on = false }
	local fl = { hold = 0, ay = 0, cap = 0, lat = 0, fade = 0, unsure = false, guess = false }
	local st = { rx = 0, rz = 0, lx = 0, lz = 0, h2 = 0, air = false, jump = false, cls = false, spec = nrm }
	local pk = { n = 0, jump = false, tau = 0, score = 0 }
	local bs = { n = 0, jump = false, tau = 0, te = 0, i = 0 }
	local trk, born = setmetatable({}, { __mode = "k" }), setmetatable({}, { __mode = "k" })
	local busy, free, last = 0, 0, 0
	local cc, cg, cbusy, cw = {}, 0, false
	local actionToken = 0

	local function actionCancelled(token)
		return token ~= actionToken or not md.g.dive
	end

	local function grav(b)
		for _, c in b:GetChildren() do
			if c:IsA("BodyForce") and c.Name ~= "Curve" then return ws.Gravity - c.Force.Y / b:GetMass() end
		end
		return ws.Gravity
	end

	local function lsq(s, now, span, from, least)
		local n, sumt, sumv = 0, 0, Vector3.zero
		for j = 1, s.n do
			local i = (s.i - j) % 12 + 1
			local t = s.t[i]
			if t < from or now - t > span then break end
			n += 1
			sumt += t
			sumv += s.v[i]
		end
		if n < least then return end
		local mt, mv = sumt / n, sumv / n
		local num, den = Vector3.zero, 0
		for j = 1, n do
			local i = (s.i - j) % 12 + 1
			local d = s.t[i] - mt
			num += (s.v[i] - mv) * d
			den += d * d
		end
		if den < 1e-4 then return end
		return num / den
	end

	local function track(b, now)
		local v = b.AssemblyLinearVelocity
		local s = trk[b]
		if not s then
			s = {
				t = table.create(12, 0), v = table.create(12, Vector3.zero), n = 0, i = 0,
				kick = v.Magnitude > 15 and now - 1 / 60 or -9, seg = now, lt = now, lv = v,
				spin = 0, g = grav(b), gat = now,
			}
			trk[b] = s
		end
		local dt = now - s.lt
		if dt < 0.004 then return s end
		local guess = s.acc and s.lv + s.acc * dt or s.lv
		if dt > 0.1 then
			s.kick, s.spin, s.seg, s.n = v.Magnitude > 15 and now - 1 / 60 or -9, 0, now, 0
		elseif (v - guess).Magnitude > 12 + 60 * dt then
			local pv = s.lv
			if not (pv.Y < -4 and v.Y > 0 and (v * flat).Magnitude <= (pv * flat).Magnitude + 2) then s.kick, s.spin = now, 0 end
			s.seg, s.n = now, 0
		elseif s.seg < s.kick + 0.31 and now - s.kick >= 0.31 then
			s.seg = s.kick + 0.31
		end
		s.i = s.i % 12 + 1
		s.t[s.i], s.v[s.i] = now, v
		s.n = math.min(s.n + 1, 12)
		s.lt, s.lv = now, v
		if now - s.kick < 0.45 then
			local w = b.AssemblyAngularVelocity.Y
			if math.abs(w) > math.abs(s.spin) then s.spin = w end
		end
		if now - s.gat > 1 then s.g, s.gat = grav(b), now end
		s.acc, s.lift = lsq(s, now, 0.15, s.seg, 3), lsq(s, now, 0.07, math.max(s.seg, s.kick + 0.008), 2)
		return s
	end

	local function flight(b, s, now, v)
		local sp, age = (v * flat).Magnitude, now - s.kick
		fl.hold, fl.ay, fl.cap, fl.lat, fl.fade, fl.unsure, fl.guess, fl.bv = 0, 0, v.Y, 0, 0, false, false, nil
		local bv = b:FindFirstChildOfClass("BodyVelocity")
		if bv then
			born[bv] = born[bv] or now
			fl.hold, fl.bv = math.max(0.31 - (now - born[bv]), 0), bv
		elseif age < 0.31 then
			local a = s.lift
			fl.hold = (a and a.Y < -40) and 0 or 0.31 - age
			if not a then
				fl.unsure = true
			else
				fl.ay, fl.cap = a.Y, a.Y > 1 and math.max(v.Y, sp * 0.38) or v.Y
			end
		end
		if sp < 5 then return end
		local a = s.acc
		if fl.hold <= 0 and a and now - s.seg > 0.05 then
			local lat = a:Dot(v:Cross(up).Unit)
			if math.abs(lat) > 4 then fl.lat, fl.fade = lat, 40 end
		elseif math.abs(s.spin) > 20 and age < 1.5 then
			local f, m = s.spin > 0 and 2.5 or -3, b:GetMass()
			fl.lat = f * math.max(sp / 0.94 - 35 * math.max(age, 0.31), 0) / m
			fl.fade, fl.guess = math.abs(f) * 35 / m, true
		end
	end

	local function sim(b, s, now, floor, m, maxn, alt)
		local pos, vel = b.Position, b.AssemblyLinearVelocity
		flight(b, s, now, vel)
		local dt, gv = 1 / 60, Vector3.new(0, s.g, 0)
		local hold, lat, fade, bv = fl.hold, fl.lat, fl.fade, fl.bv
		local capy = alt and vel.Y or fl.cap
		local cap, hv
		if bv then
			local f, mass = bv.MaxForce, b:GetMass()
			cap, hv = Vector3.new(math.abs(f.X), math.abs(f.Y), math.abs(f.Z)) / mass, bv.Velocity
		end
		local d0, t = m and (pos - m.c):Dot(m.n), 0
		if not alt then sm.n, sm.on = 0, false end
		for i = 1, maxn do
			t += dt
			local nv
			if t <= hold then
				if hv then
					local need = (hv - vel) / dt + gv
					nv = vel + (Vector3.new(
						math.clamp(need.X, -cap.X, cap.X),
						math.clamp(need.Y, -cap.Y, cap.Y),
						math.clamp(need.Z, -cap.Z, cap.Z)
					) - gv) * dt
				else
					local vy = vel.Y
					if fl.ay > 0 and vy < capy then
						vy = math.min(vy + fl.ay * dt, capy)
					elseif fl.ay < 0 then
						vy += fl.ay * dt
					end
					nv = Vector3.new(vel.X, vy, vel.Z)
				end
			else
				local acc = -gv
				if lat ~= 0 then
					local side = vel:Cross(up)
					if side.Magnitude > 1e-3 then acc += side.Unit * lat end
					local drop = fade * dt
					lat = math.abs(lat) <= drop and 0 or lat - drop * math.sign(lat)
				end
				nv = vel + acc * dt
				if pos.Y <= floor + 0.05 then
					local h = math.sqrt(nv.X * nv.X + nv.Z * nv.Z)
					if h > 1e-3 then
						local f = math.max(h - (h > 24 and 31 or math.min(0.8 * h, 12)) * dt, 0) / h
						nv = Vector3.new(nv.X * f, nv.Y, nv.Z * f)
					end
				else
					nv = Vector3.new(nv.X * drag, nv.Y, nv.Z * drag)
				end
			end
			pos += (vel + nv) * (dt / 2)
			vel = nv
			if pos.Y < floor and vel.Y < 0 then
				local vy, f = -vel.Y * 0.61, math.max(1 + 0.009 * vel.Y, 0)
				pos = Vector3.new(pos.X, floor, pos.Z)
				vel = vy < 2 and Vector3.new(vel.X, 0, vel.Z) or Vector3.new(vel.X * f, vy, vel.Z * f)
			end
			if alt then
				qy[i] = pos.Y
				if i >= alt then return end
				continue
			end
			sm.n = i
			pt[i], px[i], py[i], pz[i] = t, pos.X, pos.Y, pos.Z
			if m then
				local d1 = (pos - m.c):Dot(m.n)
				if d0 < 0 and d1 >= 0 then
					local wide, high = bv and 0.6 or 0.8, bv and 0.3 or 0.5
					sm.on = math.abs((pos - m.c):Dot(m.r)) <= m.hw + wide and pos.Y <= m.top + high
					return
				end
				d0 = d1
			end
		end
	end

	local function line(b, m)
		local v = b.AssemblyLinearVelocity
		local vin = v:Dot(m.n)
		if vin >= 0.5 * (v * flat).Magnitude then return true end
		local off = b.Position - m.c
		return math.abs(off:Dot(m.r) - v:Dot(m.r) * off:Dot(m.n) / vin) <= m.hw + 0.8
	end

	local function yj(t) return math.max(k.jv * t - k.jg * t * t, 0) end

	local function fit(h, lo, hi) return math.min(h - lo, hi - h, st.h2 - lo, hi - st.h2) end

	local function body(r, tau)
		for i = 4, #pose, 3 do
			if tau <= pose[i] then
				local a = math.max(tau - pose[i - 3], 0) / (pose[i] - pose[i - 3])
				return r + pose[i - 2] + (pose[i + 1] - pose[i - 2]) * a, r + pose[i - 1] + (pose[i + 2] - pose[i - 1]) * a
			end
		end
		return r + pose[#pose - 1], r + pose[#pose]
	end

	local function low(tau, front)
		local r = k.lowy
		if st.cls and not front then
			local f = math.max(tau - 0.05, 0)
			r = math.max(2.5 - k.jg * f * f, -2)
		elseif st.air then
			r = (front and 0 or -3) + 1.5 * tau
		end
		return body(r, tau)
	end

	local function high(tau, base, tj)
		if st.cls and base > 0 then
			return body(math.max(base + 0.4 + (k.jv - 2 * k.jg * tj + 7.2) * tau - 93.75 * tau * tau, -2), tau)
		end
		if st.cls then
			local f = math.max(tau - 0.07, 0)
			return body(math.max(7.5 - k.jg * f * f, -2), tau)
		end
		if base > 0 then return body(base + k.lift + k.airvy * tau, tau) end
		if st.air then return body(k.airvy * tau, tau) end
		return body(k.highup + k.highvy * tau, tau)
	end

	local function try(btn, n, jump, tau, margin, cost, axis)
		if margin < -0.25 then return end
		local score = math.min(margin, 1) - cost
		if pk.btn and score <= pk.score then return end
		pk.btn, pk.n, pk.jump, pk.tau, pk.score, pk.axis = btn, n, jump, tau, score, axis
	end

	local function jcatch(te, h)
		local most, bt = -math.huge
		for tj = 0.1, 0.5, 0.04 do
			if tj > te then break end
			local y = yj(tj)
			local f = fit(h, y - 0.2, y + 3.9)
			if f > most then most, bt = f, tj end
		end
		if bt then try("High Catch", bt, true, math.max(bt - 0.2, 0), most, 0.4, nil) end
	end

	local function jdive(te, h, n, btn, axis, deep)
		for tj = 0.06, 0.27, 0.03 do
			for e = -k.slide, k.slide + 0.001, k.slide do
				local after = n + e
				if after >= 0 and tj + after <= te and after <= st.spec.dur + 0.05 then
					local lo, hi = high(after, yj(tj), tj)
					try(btn, tj + after, true, tj, math.min(fit(h, lo, hi), deep), 0.45 + 2 * math.abs(e), axis)
				end
			end
		end
	end

	local function opts(te, along, ahead, h)
		pk.btn = nil
		local spec = st.spec
		if math.sqrt(along * along + ahead * ahead) <= k.creach then
			local n = k.startup + k.clead
			if te >= n and te <= 0.5 then
				try("Low Catch", n, false, 0, fit(h, -3.2, 1.2), 0, nil)
				try("High Catch", n, false, 0, fit(h, -0.2, 3.9), 0.02, nil)
			end
			if st.jump and not st.cls and h > 3 then jcatch(te, h) end
		end
		if math.abs(along) <= k.lane and ahead > -1 and ahead <= k.front then
			local n = math.max(ahead - k.mid, 0) / nrm.speed
			if n <= te and n <= nrm.dur then
				local lo, hi = low(n, true)
				try("GK H", n, false, 0, fit(h, lo, hi), 0.12, "look")
			end
		end
		local side = math.abs(along)
		if math.abs(ahead) > k.depth or side < 1 then return end
		local n = spec.lag + math.max(side - k.mid, 0) / spec.speed
		if n > spec.dur then return end
		local left, deep = along < 0, k.depth - math.abs(ahead)
		local axis = left and "left" or "right"
		local lb, hb = left and "GK Z" or "GK C", left and "GK Z2" or "GK C2"
		for e = -k.slide, k.slide + 0.001, k.slide / 2 do
			local tau = n + e
			if tau >= 0 and tau <= te then
				local lo, hi = low(tau)
				try(lb, tau, false, 0, math.min(fit(h, lo, hi), deep), 0.1 + 2 * math.abs(e), axis)
				lo, hi = high(tau, 0)
				try(hb, tau, false, 0, math.min(fit(h, lo, hi), deep), 0.25 + 2 * math.abs(e), axis)
			end
		end
		if st.jump and h > 4 then jdive(te, h, n, hb, axis, deep) end
	end

	local function cut(b, upto)
		local own = owner(b)
		for _, p in plrs:GetPlayers() do
			if p == lp or p == own then continue end
			local c = p.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			if not r then continue end
			local rp = r.Position
			for i = 2, upto - 1, 2 do
				local dx, dz = px[i] - rp.X, pz[i] - rp.Z
				if dx * dx + dz * dz <= 12.25 then
					local dy = py[i] - rp.Y
					if dy >= -2.5 and dy <= 7 then return true end
				end
			end
		end
		return false
	end

	local function camon(n)
		if n and n ~= cg then return end
		for _, c in cc do c:Enable() end
		table.clear(cc)
		if cw then
			cw:Disconnect()
			cw = nil
		end
	end

	local function camoff()
		camon()
		cg += 1
		for _, c in getconnections(rs.RenderStepped) do
			local f = c.Function
			if type(f) == "function" and not isexecutorclosure(f) and string.find(debug.info(f, "s"), ".Backpack.GK.", 1, true) then
				c:Disable()
				cc[#cc + 1] = c
			end
		end
		local cam, h = ws.CurrentCamera, hum
		cw = cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			local s = cam.CameraSubject
			if s ~= h and s and chr and s:IsDescendantOf(chr) then cam.CameraSubject = h end
		end)
		return cg
	end

	local function go(btn, jump, tau, axis)
		busy = os.clock() + 0.9 + tau
		local token = actionToken
		task.spawn(function()
			local function cancelled()
				return actionCancelled(token)
			end

			if cancelled() then return end
			if jump and hum then
				pcall(function()
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			if tau > 0 then
				local t0 = os.clock()
				repeat
					rs.Heartbeat:Wait()
					if cancelled() then return end
				until os.clock() - t0 >= tau - 1 / 120
			end

			local r = hrp
			if cancelled() or not (r and hum and hum.Health > 0) or held() then return end

			local seen = {}
			for _, o in r:GetChildren() do
				if o:IsA("BodyVelocity") then seen[o] = true end
			end

			local t = tm()
			if axis and md.g.catch and t and type(t.CatchTheBall) == "function" then
				pcall(t.CatchTheBall)
				task.delay(0.25, function()
					if not cancelled() and md.g.catch then pcall(t.CatchTheBall) end
				end)
				task.delay(0.5, function()
					if not cancelled() and md.g.catch then pcall(t.CatchTheBall) end
				end)
			end

			local ok, err = pcall(press, btn)
			if not ok then warn("[Prisma Hub] Falha ao acionar defesa: " .. tostring(err)) end
			if not axis then return end

			for _ = 1, 4 do
				if cancelled() then return end
				for _, o in r:GetChildren() do
					if o:IsA("BodyVelocity") and not seen[o] then return end
				end
				rs.Heartbeat:Wait()
			end

			if token == actionToken then
				busy = os.clock() + 0.15
			end
		end)
	end

	local function frame()
		local cf = hrp.CFrame
		local rv, lv = (cf.RightVector * flat).Unit, (cf.LookVector * flat).Unit
		local cgk = rep:FindFirstChild("ClassicGK")
		local grounded = hum.FloorMaterial ~= Enum.Material.Air
		st.rx, st.rz, st.lx, st.lz = rv.X, rv.Z, lv.X, lv.Z
		st.cls = cgk ~= nil and cgk.Value
		st.spec, st.air = st.cls and cls or nrm, not grounded
		st.jump = grounded and hum.JumpPower >= 30
		return grounded or jumping()
	end

	local function threat(m, now)
		local hit, be
		for o in bls do
			local v = o.AssemblyLinearVelocity
			if not o.Parent or v.Magnitude < 1 then continue end
			track(o, now)
			local into = v:Dot(m.n)
			if into < 6 then continue end
			local d = -(o.Position - m.c):Dot(m.n)
			if d < -1 or d > 110 then continue end
			local eta = d / into
			if eta > 1.7 or (be and eta >= be) or not isb(o) or owner(o) == lp then continue end
			hit, be = o, eta
		end
		return hit
	end

	local function effort(r0, gap)
		local bsh, bw, bi = 6, 0
		local spec = st.spec
		for i = 1, sm.n do
			local te = pt[i]
			if te > spec.dur then continue end
			local fx, fz = px[i] - r0.X, pz[i] - r0.Z
			if math.abs(fx * st.lx + fz * st.lz) > k.depth + 1 then continue end
			local need = math.max(math.abs(fx * st.rx + fz * st.rz) - k.mid, 0)
			local short = math.max(need - spec.speed * (te - spec.lag + k.slide), 0)
			if short < bsh then bi, bsh, bw = i, short, te - spec.lag - need / spec.speed end
		end
		if not bi or bsh <= 0 and bw > gap then return end
		local left = (px[bi] - r0.X) * st.rx + (pz[bi] - r0.Z) * st.rz < 0
		local _, hi = low(pt[bi])
		local lowb = py[bi] - r0.Y <= hi
		go(left and (lowb and "GK Z" or "GK Z2") or (lowb and "GK C" or "GK C2"), false, 0, left and "left" or "right")
	end

	function gk.dive(now)
		local gap = math.clamp(now - last, 1 / 240, 0.05)
		last = now
		if now < busy or held() or hum.Health <= 0 then return end
		local m = gl.own(hrp.Position)
		if not m then return end
		local b = threat(m, now)
		if not b or not keeper() then return end
		local t = tm()
		if not t or type(t.GetUsing) ~= "function" or not frame() then return end
		local usingOk, usingTool = pcall(t.GetUsing)
		if not usingOk or usingTool or not md.g.dive then return end
		local s, floor = trk[b], m.floor + 1.25
		sim(b, s, now, floor, m, 110)
		if not sm.on or fl.unsure or fl.guess and not line(b, m) then return end
		local alt = not fl.bv and fl.hold > 0 and fl.ay > 0
		if alt then sim(b, s, now, floor, m, 110, sm.n) end
		local r0 = hrp.Position
		local top, first = -math.huge
		bs.btn = nil
		for i = 1, sm.n do
			local te = pt[i]
			local fx, fz = px[i] - r0.X, pz[i] - r0.Z
			local h = py[i] - r0.Y
			st.h2 = alt and qy[i] - r0.Y or h
			opts(te, fx * st.rx + fz * st.rz, fx * st.lx + fz * st.lz, h)
			if pk.btn then
				first = first or te
				local score = pk.score - 0.5 * (te - first)
				if score > top then
					top = score
					bs.btn, bs.n, bs.jump, bs.tau, bs.axis, bs.te, bs.i = pk.btn, pk.n, pk.jump, pk.tau, pk.axis, te, i
				end
			end
		end
		if not bs.btn then return effort(r0, gap) end
		if bs.te - bs.n > gap or cut(b, bs.i) then return end
		go(bs.btn, bs.jump, bs.tau, bs.axis)
	end

	-- agarrar automaticamente
	local function posed()
		local torso = chr and chr:FindFirstChild("Torso")
		if not torso then return false end
		for _, w in torso:GetChildren() do
			if w:IsA("Weld") and w.Part1 and string.find(w.Part1.Name, "Arm", 1, true) then return true end
		end
		return false
	end

	local function grab(b, t0)
		repeat rs.Heartbeat:Wait() until posed() or os.clock() - t0 > 0.12
		while os.clock() - t0 < 0.55 and posed() and not held() and b.Parent and hrp do
			if (b.Position - hrp.Position).Magnitude <= md.g.cr then
				for _, p in lmb do
					firetouchinterest(p, b, 0)
					firetouchinterest(p, b, 1)
				end
			end
			rs.Heartbeat:Wait()
		end
		cbusy = false
	end

	function gk.catch(now, b)
		if cbusy or not (b and b.Parent and md.g.cr and hrp) or now < free or now < busy or not md.g.dive or held() then return end
		local off, v = b.Position - hrp.Position, b.AssemblyLinearVelocity
		local d = off.Magnitude
		if d > md.g.cr or v:Dot(off) > 4 * d or owner(b) == lp and v.Magnitude > 2 or not keeper() then return end
		local t = tm()
		if not t or type(t.GetUsing) ~= "function" or lp:FindFirstChild("handsOnCooldown") then return end
		local usingOk, usingTool = pcall(t.GetUsing)
		if not usingOk or usingTool then return end
		cbusy = true
		rch.lend(b, now + 0.6, md.g.cr)
		local ok, err = pcall(function()
			press(off.Y >= 0 and "High Catch" or "Low Catch")
			task.spawn(grab, b, now)
		end)
		if not ok then
			cbusy = false
			warn("[Prisma Hub] Falha no Auto Catch: " .. tostring(err))
		end
	end

	function gk.settle()
		local t = tm()
		local b = t and t.getHeldBall()
		if not b then return end
		local dl = os.clock() + 0.6
		task.spawn(function()
			repeat
				for _, c in b:GetChildren() do
					if mvs[c.ClassName] or c.Name == "Curve" then c:Destroy() end
				end
				if hrp and hum then
					local v = hrp.AssemblyLinearVelocity
					if (v * flat).Magnitude > hum.WalkSpeed + 10 then
						t.DestroyBodyMovers()
						hrp.AssemblyLinearVelocity = Vector3.new(0, math.min(v.Y, 0), 0)
					end
				end
				rs.Heartbeat:Wait()
			until os.clock() > dl or not b.Parent
		end)
	end

	function gk.free() free = os.clock() + 1.2 end

	function gk.path(b, now, floor, m, n)
		sim(b, track(b, now), now, floor, m, n)
		return sm.n, sm.on, pt, px, py, pz
	end

	function gk.cancel()
		actionToken += 1
		busy, cbusy = 0, false
	end

	gk.stop = function()
		gk.cancel()
		camon()
	end
end

-- seleção automática do pé
local leg = {}
do
	local fn, slot

	local function using(t)
		if fn ~= t.SetUsing then
			fn, slot = t.SetUsing, nil
			for i, v in debug.getupvalues(fn) do
				if type(v) == "boolean" then slot = i end
			end
		end
		if slot then return debug.getupvalue(fn, slot) end
		return t.GetUsing()
	end

	function leg.step(b)
		local t = tm()
		if not (t and b) or using(t) then return end
		local d = (b.Position - hrp.Position):Dot(hrp.CFrame.RightVector)
		local f = d > 0 and "R" or "L"
		if math.abs(d) < 0.1 or t.check() == f then return end
		t.Set(f)
		local st, il = start()
		local a, c = st and st:FindFirstChild("Foot"), il and il:FindFirstChild("Foot")
		if a then a.Text = f end
		if c then c.Text = f end
	end
end

-- simulação de plataforma
local plat = {}
do
	local uis = cloneref(game:GetService("UserInputService"))
	local cl, ids = rep:FindFirstChild("Client"), { pc = 1, mobile = 2, console = 3 }
	local real = uis.GamepadEnabled and 3 or uis.TouchEnabled and 2 or 1
	local con

	local function apply()
		local cur, want = lp:GetAttribute("Platform"), md.p.on and ids[md.p.v] or real
		if cl and cur ~= nil and cur ~= want then cl:FireServer("Platform", want) end
	end

	function plat.sync()
		if md.p.on and not con then
			con = lp:GetAttributeChangedSignal("Platform"):Connect(apply)
		elseif not md.p.on and con then
			con:Disconnect()
			con = nil
		end
		apply()
	end
end

-- defesa e interceptação
local shd = {}
do
	local cv, co, lit = rep:FindFirstChild("ChangeValue"), rep:FindFirstChild("ChangeOwner"), cloneref(game:GetService("Lighting"))
	local pb, po, took
	local kick, fire = 0, 0

	local function side(p)
		local n = p.Team and p.Team.Name or ""
		return string.find(n, "Home", 1, true) and 1 or string.find(n, "Away", 1, true) and 2, string.sub(n, 1, 1) == "-"
	end

	local function foe(p)
		if not p or p == lp then return false end
		local s, gk = side(p)
		return not gk and (not s or s ~= side(lp))
	end

	function shd.step(now, b)
		if b ~= pb then
			pb, po, took = b, b and owner(b), nil
			return
		end
		if not (b and cv and co and md.s.r) then return end
		local o, bv, d = owner(b), b:FindFirstChild(lp.Name), (b.Position - hrp.Position).Magnitude
		if bv and bv:IsA("BodyVelocity") and bv.Velocity.Magnitude >= 40 then kick = now end
		if took and o == lp then
			local push = b:FindFirstChild(took.Name)
			if push then push:Destroy() end
			b.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * flat + b.AssemblyLinearVelocity * up
			took = nil
		elseif took and now - fire > 0.6 then
			took = nil
		end
		if po == lp and foe(o) and d <= md.s.r and now - kick > 0.5 and now - fire > 0.15 and not held() and not lit:FindFirstChild("Goal") then
			fire, took = now, o
			cv:FireServer(b)
			co:FireServer(b)
		end
		po = o
	end
end

-- seguir a bola automaticamente
local fol = {}
do
	local tag, bound, ctl = rnd(), false

	local function travel(s, t)
		local d = 0
		if s > 24 then
			local t1 = math.min(t, (s - 24) / 31)
			d, s, t = s * t1 - 15.5 * t1 * t1, s - 31 * t1, t - t1
		end
		local t2 = math.min(t, s / 12)
		return d + s * t2 - 6 * t2 * t2
	end

	local function walk()
		if not (hrp and hum and hrp.Parent) or hum.Health <= 0 or held() then return end
		ctl = ctl or require(lp.PlayerScripts.PlayerModule):GetControls()
		if ctl:GetMoveVector().Magnitude > 0 then return end
		local b = near()
		if not b then return end
		local me, p, v = hrp.Position, b.Position, b.AssemblyLinearVelocity * flat
		local s, q = v.Magnitude, p
		if s > 1 then
			local dir, air = v / s, p.Y > me.Y
			for t = 0.05, 1.5, 0.05 do
				q = p + dir * (air and s * t or travel(s, t))
				if ((q - me) * flat).Magnitude <= hum.WalkSpeed * t then break end
			end
		end
		local d = (q - me) * flat
		if d.Magnitude > 0.5 then hum:Move(d.Unit, false) end
	end

	function fol.sync()
		if md.f.on and not bound then
			bound = true
			rs:BindToRenderStep(tag, Enum.RenderPriority.Input.Value + 1, walk)
		elseif not md.f.on and bound then
			bound = false
			rs:UnbindFromRenderStep(tag)
		end
	end
end

-- cópia local da aparência do avatar
local ava = {}
do
	local kinds = { Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true, CharacterMesh = true, Accessory = true }
	local mine, worn, looks = {}, {}, {}
	local cur, face, old, watch
	local tok = 0

	local function strip(o)
		if not kinds[o.ClassName] or worn[o] then return end
		mine[o] = o.Parent
		o.Parent = nil
	end

	local function undo()
		if watch then
			watch:Disconnect()
			watch = nil
		end
		for o in worn do o:Destroy() end
		for o, p in mine do
			if p.Parent then o.Parent = p end
		end
		if face and face.Parent then face.Texture = old end
		table.clear(worn)
		table.clear(mine)
		face = nil
	end

	local function uid(n)
		local q = string.lower(n)
		for _, p in plrs:GetPlayers() do
			if string.sub(string.lower(p.Name), 1, #q) == q or string.sub(string.lower(p.DisplayName), 1, #q) == q then return p.UserId end
		end
		return plrs:GetUserIdFromNameAsync(n)
	end

	local function hat(x, c)
		local h = x:FindFirstChild("Handle")
		if not h then return end
		h.CanCollide, h.CanTouch, h.CanQuery, h.Massless = false, false, false, true
		local a = h:FindFirstChildOfClass("Attachment")
		local to = a and c:FindFirstChild(a.Name, true)
		local w = Instance.new("Weld")
		w.Name, w.Part0, w.Part1 = rnd(), h, to and to.Parent or c.Head
		w.C0, w.C1 = to and a.CFrame or x.AttachmentPoint, to and to.CFrame or CFrame.new(0, 0.5, 0)
		w.Parent = h
		x.Parent = c
	end

	local function dress(c, m)
		for _, o in c:GetChildren() do strip(o) end
		watch = c.ChildAdded:Connect(strip)
		for _, o in m:GetChildren() do
			if kinds[o.ClassName] then
				local x = o:Clone()
				worn[x] = true
				if x:IsA("Accessory") then hat(x, c) else x.Parent = c end
			end
		end
		local f, head = m:FindFirstChild("face"), c:FindFirstChild("Head")
		face = f and f:IsA("Decal") and head and head:FindFirstChild("face")
		if face then face.Texture, old = f.Texture, face.Texture end
	end

	local function wear(n, my)
		local id = uid(n)
		looks[id] = looks[id] or plrs:GetCharacterAppearanceAsync(id)
		if my == tok and chr and hum then dress(chr, looks[id]) end
	end

	function ava.sync()
		local want = md.a.on and md.a.n ~= "" and md.a.n or nil
		if want == cur then return end
		cur, tok = want, tok + 1
		undo()
		if want then task.spawn(xpcall, wear, oops, want, tok) end
	end

	function ava.bind()
		undo()
		cur = nil
		ava.sync()
	end
end

-- previsão da trajetória da bola
local prd = {}
do
	local rp, tris, hex, pts = RaycastParams.new(), {}, {}, {}
	local bulkp, bulkc, sig, rim = {}, {}, { n = -1 }, {}
	local at, last = 0, 1
	local fold, con
	local lv, spot, shown
	rp.FilterType, rp.RespectCanCollide = Enum.RaycastFilterType.Exclude, true
	for q = 1, 6 do rim[q] = Vector3.new(math.cos(q * math.pi / 3), 0, math.sin(q * math.pi / 3)) end

	local function piece(pool, i)
		local p = pool[i]
		if p then return p end
		p = Instance.new("Part")
		p.Name, p.Material, p.Transparency = rnd(), Enum.Material.Neon, 1
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
		p.Parent = fold
		pool[i], sig.dirty = p, true
		return p
	end

	local function put(p, a, b) bulkp[#bulkp + 1], bulkc[#bulkc + 1] = p, CFrame.lookAt((a + b) / 2, b) end

	local function hide()
		if not shown then return end
		shown, spot, sig.n = false, nil, -1
		for _, p in tris do p.Transparency = 1 end
		for _, p in hex do p.Transparency = 1 end
	end

	local function trace(b, now)
		rp.FilterDescendantsInstances = { fold, b, ws:FindFirstChild("WorkspaceCharacters"), chr }
		local hit = ws:Raycast(b.Position, Vector3.new(0, -60, 0), rp)
		local floor = (hit and hit.Position.Y or b.Position.Y - 1.25) + 1.25
		local n, _, _, px, py, pz = gk.path(b, now, floor, nil, 150)
		local c = 1
		pts[1] = b.Position
		for i = 2, n, 2 do
			local p = Vector3.new(px[i], py[i], pz[i])
			local w = ws:Raycast(pts[c], p - pts[c], rp)
			c += 1
			pts[c] = w and w.Normal.Y < 0.6 and w.Position or p
			if pts[c] ~= p or py[i] <= floor + 0.05 and py[i - 1] > floor + 0.05 then break end
		end
		for i = c + 1, #pts do pts[i] = nil end
		return c
	end

	local function tri(n, p, dir, side, r, sz, col, tr, set)
		local a, b, c = p + dir * r, p + (side * 0.866 - dir * 0.5) * r, p - (side * 0.866 + dir * 0.5) * r
		local e1, e2, e3 = piece(tris, n * 3 - 2), piece(tris, n * 3 - 1), piece(tris, n * 3)
		if set then
			e1.Size, e2.Size, e3.Size = sz, sz, sz
			e1.Color, e2.Color, e3.Color = col, col, col
			e1.Transparency, e2.Transparency, e3.Transparency = tr, tr, tr
		end
		put(e1, a, b)
		put(e2, b, c)
		put(e3, c, a)
	end

	local function ground(spin, r, col, set)
		local sz = Vector3.new(0.12, 0.06, r)
		for q = 1, 6 do
			local p = piece(hex, q)
			p.Size = sz
			if set then p.Color, p.Transparency = col, 0.1 end
			put(p, spin * (rim[q] * r), spin * (rim[q % 6 + 1] * r))
		end
	end

	local function draw(first, land)
		shown = true
		local eye, col = ws.CurrentCamera.CFrame.Position, md.v.c
		local total = 0
		for i = first + 1, land do total += (pts[i] - pts[i - 1]).Magnitude end
		local gap = math.max(2.6, total / 24)
		local size = math.floor(math.min(gap / 2.6, 2.5) * 20 + 0.5) / 20
		local w = 0.13 * math.min(size, 1.8)
		local fresh = sig.dirty or sig.n < 0 or sig.size ~= size or sig.col ~= col
		table.clear(bulkp)
		table.clear(bulkc)
		local n, acc, want = 0, 0, gap - (os.clock() * 7 * size) % gap
		for i = first + 1, land do
			local seg = pts[i] - pts[i - 1]
			local len = seg.Magnitude
			while len > 0 and acc + len >= want and n < 24 do
				n += 1
				local p, dir = pts[i - 1] + seg * ((want - acc) / len), seg.Unit
				local side, k = dir:Cross(eye - p), n / 24
				local r = 0.43 * size * (1 - 0.45 * k)
				side = side.Magnitude > 1e-3 and side.Unit or up
				tri(n, p, dir, side, r, Vector3.new(w, w, r * 1.732), col, 0.05 + 0.65 * k, fresh or n > sig.n)
				want += gap
			end
			acc += len
		end
		if fresh or n < sig.n then for i = n * 3 + 1, #tris do tris[i].Transparency = 1 end end
		local g = pts[land] - Vector3.new(0, 1.2, 0)
		spot = spot and spot:Lerp(g, 0.35) or g
		ground(CFrame.new(spot) * CFrame.Angles(0, os.clock() * 0.6, 0), 1.86 + math.sin(os.clock() * 5) * 0.14, col, fresh)
		ws:BulkMoveTo(bulkp, bulkc, Enum.BulkMoveMode.FireCFrameChanged)
		sig.size, sig.col, sig.n, sig.dirty = size, col, n, false
	end

	local function frame()
		local b, now = near(), os.clock()
		local v = b and b.AssemblyLinearVelocity
		if not v or v.Magnitude < 3 or held() then return hide() end
		if now - at >= 0.1 or (v - lv).Magnitude > 8 then at, lv, last = now, v, trace(b, now) end
		local first = math.max(1, math.min(1 + math.floor((now - at) * 30), last - 1))
		pts[first] = b.Position
		draw(first, last)
	end

	function prd.sync()
		if md.v.on and not con then
			fold = Instance.new("Folder")
			fold.Name, fold.Parent = rnd(), ws.CurrentCamera
			con = rs.PreRender:Connect(function() xpcall(frame, oops) end)
		elseif not md.v.on and con then
			con:Disconnect()
			fold:Destroy()
			con, fold, shown = nil, nil, false
			table.clear(tris)
			table.clear(hex)
		end
	end
end

do
	local hb

	local function step()
		if not (hrp and hum and hrp.Parent) then return end
		local now, b = os.clock(), near()
		if md.g.dive then gk.dive(now) end
		if md.g.catch then gk.catch(now, b) end
		if md.l.on then leg.step(b) end
		if md.s.on then shd.step(now, b) end
		rch.step(now, b)
	end

	sync = function()
		local on = md.r.on or md.b.on or md.g.dive or md.g.catch or md.l.on or md.s.on
		rch.sync()
		prd.sync()
		plat.sync()
		fol.sync()
		ava.sync()
		if on and not hb then
			hb = rs.Heartbeat:Connect(function() xpcall(step, oops) end)
		elseif not on and hb then
			hb:Disconnect()
			hb = nil
			rch.stop()
		end
	end
end

do
	local lnm = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

	local function bind(c)
		c = c or lp.Character
		if not c then return end
		chr, hrp, hum = c, nil, nil
		table.clear(lmb)
		for _, x in arm do x:Disconnect() end
		table.clear(arm)
		rch.bind()
		local h, r = c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
		for _, n in lnm do
			local p = c:WaitForChild(n, 5)
			if p then lmb[#lmb + 1] = p end
		end
		if chr ~= c then return end
		hum, hrp = h, r
		totHumanoid = h
		pcall(function() h.WalkSpeed = playerWalkSpeed end)
		rch.bind()
		ava.bind()
		local ra = c:FindFirstChild("Right Arm")
		if not ra then return end
		arm[1] = ra.ChildAdded:Connect(function(o) if o.Name == "handsOn" and (md.g.dive or md.g.catch) then gk.settle() end end)
		arm[2] = ra.ChildRemoved:Connect(function(o) if o.Name == "handsOn" then gk.free() end end)
	end

	if lp.Character then task.spawn(bind, lp.Character) end
	cons[#cons + 1] = lp.CharacterAdded:Connect(bind)
end

-- Integração da interface do Prisma Hub
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/PcHrq47J/raw"))()

local Window = Library:CreateWindow({
    Title = "Prisma Hub",
    Subtitle = "Interface totalmente em português",
    SubtitleColor = Color3.fromRGB(190, 140, 255),
    Logo = "rbxassetid://88074866415621",
    LogoSize = 32,
    SphereText = false,
    SphereWords = "NX",
    SphereImage = "rbxassetid://88074866415621",
    SphereIconSize = 38,
    UITheme = "Purple",
    PanelTheme = "Default",
    PanelSync = true,
    FpsPosition = "TopLeft",
})
Window:AddCredit("Hypol-X", "https://discord.gg/2ERyMtmsd2")

-- Funções adicionais do Kirtium.
local extraCons = {}
local extraState = { powerShoot = false, shootForce = 5, ballSpeed = 70 }
local function addExtraConnection(connection)
    extraCons[#extraCons + 1] = connection
    return connection
end

-- Velocidade e FOV.
local walkSpeedConnection
local function setPlayerSpeed(value)
    playerWalkSpeed = math.clamp(tonumber(value) or 16, 16, 150)
    if hum then pcall(function() hum.WalkSpeed = playerWalkSpeed end) end

    if playerWalkSpeed > 16 and not walkSpeedConnection then
        walkSpeedConnection = rs.Heartbeat:Connect(function()
            if not (hrp and hum and hrp.Parent) then return end
            local direction = hum.MoveDirection
            if direction.Magnitude > 0.1 then
                local velocity = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(
                    direction.X * playerWalkSpeed,
                    velocity.Y,
                    direction.Z * playerWalkSpeed
                )
            end
        end)
    elseif playerWalkSpeed <= 16 and walkSpeedConnection then
        walkSpeedConnection:Disconnect()
        walkSpeedConnection = nil
    end
end

local originalFov = ws.CurrentCamera and ws.CurrentCamera.FieldOfView or 70
local function setPlayerFov(value)
    if ws.CurrentCamera then
        ws.CurrentCamera.FieldOfView = math.clamp(tonumber(value) or originalFov, 40, 150)
    end
end
local function restorePlayerFov()
    if ws.CurrentCamera then ws.CurrentCamera.FieldOfView = originalFov end
end

-- Anti-AFK.
local antiAfkConnection
local function setAntiAfk(enabled)
    if enabled and not antiAfkConnection then
        antiAfkConnection = lp.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    elseif not enabled and antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

-- Power Shoot.
local powerShootConnection
local lastPowerKick = 0
local function powerShootStep()
    if not extraState.powerShoot or extraState.shootForce <= 0 or not (hrp and hum) then return end
    local ball = near()
    if not ball or not ball.Parent or (ball.Position - hrp.Position).Magnitude > 3 then return end
    if hum.MoveDirection.Magnitude < 0.1 or os.clock() - lastPowerKick < 0.5 then return end

    local direction = ball.Position - hrp.Position
    if direction.Magnitude < 0.001 or direction.Unit:Dot(hum.MoveDirection.Unit) <= 0.5 then return end
    lastPowerKick = os.clock()

    pcall(function()
        local previous = ball:FindFirstChild("PrismaKickForce")
        if previous then previous:Destroy() end
        local force = Instance.new("BodyVelocity")
        force.Name = "PrismaKickForce"
        force.Velocity = hrp.CFrame.LookVector * extraState.shootForce * 45
            + Vector3.new(0, extraState.shootForce * 9, 0)
        force.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000)
        force.Parent = ball
        task.delay(0.15, function()
            pcall(function() if force and force.Parent then force:Destroy() end end)
        end)
    end)
end
local function setPowerShoot(enabled)
    extraState.powerShoot = enabled
    if enabled and not powerShootConnection then
        powerShootConnection = rs.Heartbeat:Connect(function() xpcall(powerShootStep, oops) end)
    elseif not enabled and powerShootConnection then
        powerShootConnection:Disconnect()
        powerShootConnection = nil
    end
end

-- Curve Shot.
local curveState = { active = false, side = "None", dip = false, curvePower = 0, dipPower = 0 }
local curveConnection
local function curveStep()
    if not curveState.active then return end
    local ball = near()
    if not ball or not ball:IsA("BasePart") then return end
    local velocity = ball.AssemblyLinearVelocity
    if velocity.Magnitude <= 15 then return end

    local adjustment = Vector3.zero
    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
    if curveState.side ~= "None" and horizontal.Magnitude > 2 then
        local side = horizontal:Cross(Vector3.yAxis).Unit
        if curveState.side == "Left" then side = -side end
        adjustment += side * (curveState.curvePower / 180)
    end
    if curveState.dip then
        adjustment += Vector3.new(0, -(curveState.dipPower / 180), 0)
    end
    if adjustment.Magnitude > 0 then
        ball.AssemblyLinearVelocity = velocity + adjustment
    end
end
local function applyCurvePreset(name)
    if name == "Curva para esquerda" then
        curveState.side, curveState.dip = "Left", true
        curveState.curvePower, curveState.dipPower = 60, 20
        curveState.active = true
    elseif name == "Curva para direita" then
        curveState.side, curveState.dip = "Right", false
        curveState.curvePower, curveState.dipPower = 80, 0
        curveState.active = true
    else
        curveState.side, curveState.dip = "None", false
        curveState.curvePower, curveState.dipPower = 0, 0
        curveState.active = false
    end

    if curveState.active and not curveConnection then
        curveConnection = rs.Heartbeat:Connect(function() xpcall(curveStep, oops) end)
    elseif not curveState.active and curveConnection then
        curveConnection:Disconnect()
        curveConnection = nil
    end
end

-- Controle manual da bola.
local controlEnabled, controllingBall = false, false
local controlledBall, controlGui, controlButton
local controlRenderConnection, controlInputConnection
local savedCameraType, savedCameraSubject, savedMouseBehavior
local controlKey, controlKeyName = Enum.KeyCode.U, "U"
local cameraYaw, cameraPitch = 0, 0.2
local cameraDistance, cameraHeight = 16, 6
local function restoreControlCamera()
    local camera = ws.CurrentCamera
    if camera and savedCameraType then
        camera.CameraType = savedCameraType
        camera.CameraSubject = savedCameraSubject
    end
    uis.MouseBehavior = savedMouseBehavior or Enum.MouseBehavior.Default
    savedCameraType, savedCameraSubject, savedMouseBehavior = nil, nil, nil
end
local function stopBallControl()
    controllingBall = false
    if controlRenderConnection then controlRenderConnection:Disconnect(); controlRenderConnection = nil end
    if controlInputConnection then controlInputConnection:Disconnect(); controlInputConnection = nil end
    restoreControlCamera()
    controlledBall = nil
    if controlButton then
        controlButton.Text = "Controlar bola"
        controlButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end
local function startBallControl(ball)
    if not ball or not ball:IsA("BasePart") then return end
    stopBallControl()
    local camera = ws.CurrentCamera
    if not camera then return end

    controlledBall, controllingBall = ball, true
    savedCameraType, savedCameraSubject, savedMouseBehavior =
        camera.CameraType, camera.CameraSubject, uis.MouseBehavior

    local look = camera.CFrame.LookVector
    cameraYaw = math.atan2(-look.X, -look.Z)
    cameraPitch = math.asin(math.clamp(look.Y, -1, 1))
    camera.CameraType = Enum.CameraType.Scriptable
    uis.MouseBehavior = Enum.MouseBehavior.LockCenter
    if controlButton then
        controlButton.Text = "Controle ativo"
        controlButton.BackgroundColor3 = Color3.fromRGB(35, 125, 75)
    end

    controlInputConnection = uis.InputChanged:Connect(function(input)
        if not controllingBall then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            cameraYaw -= input.Delta.X * 0.004
            cameraPitch = math.clamp(cameraPitch - input.Delta.Y * 0.004, -1.2, 1.2)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            cameraYaw -= input.Delta.X * 0.006
            cameraPitch = math.clamp(cameraPitch - input.Delta.Y * 0.006, -1.2, 1.2)
        end
    end)

    controlRenderConnection = rs.RenderStepped:Connect(function()
        if not controllingBall or not controlledBall or not controlledBall.Parent then
            stopBallControl()
            return
        end
        local currentCamera = ws.CurrentCamera
        if not currentCamera then return end
        local direction = CFrame.fromEulerAnglesYXZ(cameraPitch, cameraYaw, 0).LookVector
        pcall(function()
            controlledBall.AssemblyLinearVelocity = direction * extraState.ballSpeed
            controlledBall.AssemblyAngularVelocity = Vector3.zero
        end)
        local position = controlledBall.Position - direction * cameraDistance + Vector3.new(0, cameraHeight, 0)
        currentCamera.CFrame = CFrame.lookAt(position, controlledBall.Position + Vector3.new(0, 1.5, 0))
    end)
end
local function toggleBallControl()
    if controllingBall then
        stopBallControl()
        return
    end
    local ball = near()
    if ball and ball.Parent and hrp and (ball.Position - hrp.Position).Magnitude <= 80 then
        startBallControl(ball)
    else
        Library:Notify({ Title = "Prisma Hub", Desc = "Nenhuma bola válida foi encontrada por perto.", Be = "Error" })
    end
end
local function createControlGui()
    if controlGui then return end
    controlGui = Instance.new("ScreenGui")
    controlGui.Name = "PrismaControlBall"
    controlGui.ResetOnSpawn = false
    controlGui.DisplayOrder = 1001
    controlGui.Parent = lp:WaitForChild("PlayerGui")

    controlButton = Instance.new("TextButton")
    controlButton.Name = "ControlarBola"
    controlButton.Size = UDim2.new(0, 150, 0, 44)
    controlButton.Position = UDim2.new(0.04, 0, 0.18, 0)
    controlButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    controlButton.TextColor3 = Color3.new(1, 1, 1)
    controlButton.Text = "Controlar bola"
    controlButton.TextSize = 15
    controlButton.Font = Enum.Font.GothamBold
    controlButton.Parent = controlGui
    Instance.new("UICorner", controlButton).CornerRadius = UDim.new(0, 9)
    controlButton.MouseButton1Click:Connect(toggleBallControl)
end
local function setControlEnabled(enabled)
    controlEnabled = enabled
    if enabled then
        createControlGui()
        if controlGui then controlGui.Enabled = true end
    else
        stopBallControl()
        if controlGui then controlGui:Destroy(); controlGui, controlButton = nil, nil end
    end
end
local function setControlKeyFromText(value)
    local name = tostring(value or ""):gsub("%s+", "")
    local key = Enum.KeyCode[name]
    if name == "" or not key then
        Library:Notify({ Title = "Prisma Hub", Desc = "Tecla inválida. Exemplo: U ou K.", Be = "Error" })
        return
    end
    controlKey, controlKeyName = key, name
end
addExtraConnection(uis.InputBegan:Connect(function(input, processed)
    if not processed and controlEnabled and input.KeyCode == controlKey then
        toggleBallControl()
    end
end))

-- Controles móveis: joystick, botões R/T e pulo.
local totMobileActive, totMobileGui = false, nil
local totMobileConnections, totHeldKeys = {}, {}
local totMoveVector, totActiveInput, totJumpHeld = Vector3.zero, nil, false
local function addTotConnection(connection)
    totMobileConnections[#totMobileConnections + 1] = connection
    return connection
end
local function sendTotKey(key, down)
    pcall(function() VirtualInputManager:SendKeyEvent(down, key, false, game) end)
end
local function disableTotMobile()
    totMobileActive = false
    for _, connection in ipairs(totMobileConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(totMobileConnections)
    for key in pairs(totHeldKeys) do sendTotKey(key, false) end
    table.clear(totHeldKeys)
    totMoveVector, totActiveInput, totJumpHeld = Vector3.zero, nil, false
    if totMobileGui then totMobileGui:Destroy(); totMobileGui = nil end
    pcall(function()
        require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Enable()
    end)
end
local function enableTotMobile()
    if totMobileActive then disableTotMobile() end
    pcall(function()
        require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Disable()
    end)

    totMobileGui = Instance.new("ScreenGui")
    totMobileGui.Name = "PrismaTotMobile"
    totMobileGui.ResetOnSpawn = false
    totMobileGui.IgnoreGuiInset = true
    totMobileGui.DisplayOrder = 1000
    totMobileGui.Parent = lp:WaitForChild("PlayerGui")
    totMobileActive, totHumanoid = true, hum

    local base = Instance.new("Frame")
    base.Name = "Joystick"
    base.Size = UDim2.new(0, 180, 0, 180)
    base.Position = UDim2.new(0, 24, 1, -210)
    base.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    base.BackgroundTransparency = 0.35
    base.Active = true
    base.Parent = totMobileGui
    Instance.new("UICorner", base).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 52, 0, 52)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    knob.BackgroundTransparency = 0.12
    knob.Parent = base
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function makeKeyButton(name, key, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 58, 0, 58)
        button.Position = position
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        button.Text = name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 19
        button.Font = Enum.Font.GothamBold
        button.Parent = totMobileGui
        Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

        local function setDown(down)
            if down and not totHeldKeys[key] then
                totHeldKeys[key] = true
                sendTotKey(key, true)
                button.BackgroundColor3 = Color3.fromRGB(0, 145, 220)
            elseif not down and totHeldKeys[key] then
                totHeldKeys[key] = nil
                sendTotKey(key, false)
                button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            end
        end
        addTotConnection(button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setDown(true)
            end
        end))
        addTotConnection(button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setDown(false)
            end
        end))
    end
    makeKeyButton("R", Enum.KeyCode.R, UDim2.new(1, -145, 1, -245))
    makeKeyButton("T", Enum.KeyCode.T, UDim2.new(1, -75, 1, -245))

    local jump = Instance.new("TextButton")
    jump.Size = UDim2.new(0, 68, 0, 68)
    jump.Position = UDim2.new(1, -100, 1, -115)
    jump.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    jump.Text = "PULAR"
    jump.TextColor3 = Color3.new(1, 1, 1)
    jump.TextSize = 13
    jump.Font = Enum.Font.GothamBold
    jump.Parent = totMobileGui
    Instance.new("UICorner", jump).CornerRadius = UDim.new(1, 0)
    addTotConnection(jump.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            totJumpHeld = true
        end
    end))
    addTotConnection(jump.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            totJumpHeld = false
        end
    end))

    local radius = 62
    addTotConnection(base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            totActiveInput = input
        end
    end))
    addTotConnection(uis.InputChanged:Connect(function(input)
        if not totMobileActive or input ~= totActiveInput then return end
        local center = base.AbsolutePosition + base.AbsoluteSize / 2
        local offset = Vector2.new(input.Position.X, input.Position.Y) - center
        if offset.Magnitude > radius then offset = offset.Unit * radius end
        knob.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
        totMoveVector = Vector3.new(offset.X / radius, 0, offset.Y / radius)
    end))
    addTotConnection(uis.InputEnded:Connect(function(input)
        if input == totActiveInput then
            totActiveInput = nil
            totMoveVector = Vector3.zero
            knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end))
    addTotConnection(rs.RenderStepped:Connect(function()
        if not totMobileActive or not totHumanoid then return end
        if totJumpHeld then totHumanoid.Jump = true end
        if totMoveVector.Magnitude > 0.05 then
            local camera = ws.CurrentCamera
            if camera then
                local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
                local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
                if forward.Magnitude > 0 then forward = forward.Unit end
                if right.Magnitude > 0 then right = right.Unit end
                local movement = right * totMoveVector.X - forward * totMoveVector.Z
                if movement.Magnitude > 0 then totHumanoid:Move(movement, false) end
            end
        else
            totHumanoid:Move(Vector3.zero, false)
        end
    end))
end

-- Skybox, chuva e iluminação.
local originalLighting = {
    ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd,
    ShadowSoftness = Lighting.ShadowSoftness,
    ExposureCompensation = Lighting.ExposureCompensation,
}
local originalSkies = {}
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Sky") then originalSkies[#originalSkies + 1] = child:Clone() end
end
local rainFolder, rainConnection, rainSound
local function clearPrismaRain()
    if rainConnection then rainConnection:Disconnect(); rainConnection = nil end
    if rainFolder then rainFolder:Destroy(); rainFolder = nil end
    if rainSound then
        pcall(function() rainSound:Stop(); rainSound:Destroy() end)
        rainSound = nil
    end
end
local function removeAllSkies()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then child:Destroy() end
    end
end
local function restoreSkyAndLighting()
    clearPrismaRain()
    removeAllSkies()
    for _, saved in ipairs(originalSkies) do saved:Clone().Parent = Lighting end
    for property, value in pairs(originalLighting) do
        pcall(function() Lighting[property] = value end)
    end
end
local function applyPrismaSky(option)
    clearPrismaRain()
    if option == "Padrão" then restoreSkyAndLighting(); return end

    local ids
    if option == "Sol" then
        Lighting.ClockTime, Lighting.Brightness = 7, 2
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 255)
        Lighting.Ambient = Color3.fromRGB(255, 210, 160)
        Lighting.FogColor, Lighting.FogEnd = Color3.fromRGB(255, 170, 100), 100000
        ids = {
            "rbxassetid://541743453", "rbxassetid://541743443",
            "rbxassetid://541743446", "rbxassetid://541743436",
            "rbxassetid://541743435", "rbxassetid://541743441",
        }
    elseif option == "Lua" or option == "Chuva" then
        Lighting.ClockTime, Lighting.Brightness = 21, 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Ambient = option == "Chuva" and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(0, 0, 0)
        Lighting.FogColor = option == "Chuva" and Color3.fromRGB(100, 100, 120) or Color3.fromRGB(150, 150, 150)
        Lighting.FogEnd = 100000
        ids = {
            "rbxassetid://4498828382", "rbxassetid://4498828812",
            "rbxassetid://4498829917", "rbxassetid://4498830911",
            "rbxassetid://4498830417", "rbxassetid://4498831746",
        }
    end

    if ids then
        removeAllSkies()
        local sky = Instance.new("Sky")
        sky.Name = "PrismaCustomSky"
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = ids[1], ids[2], ids[3]
        sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = ids[4], ids[5], ids[6]
        sky.Parent = Lighting
    end

    if option == "Chuva" then
        rainFolder = Instance.new("Folder")
        rainFolder.Name = "PrismaRain"
        rainFolder.Parent = ws
        local drops = {}
        for index = 1, 50 do
            local part = Instance.new("Part")
            part.Name = "PrismaRainDrop"
            part.Size = Vector3.new(0.05, 3, 0.05)
            part.Anchored, part.CanCollide = true, false
            part.CanTouch, part.CanQuery, part.CastShadow = false, false, false
            part.Material = Enum.Material.SmoothPlastic
            part.Color, part.Transparency = Color3.fromRGB(160, 200, 255), 0.5
            part.Parent = rainFolder
            drops[index] = { part = part, x = math.random(-100, 100), z = math.random(-100, 100), y = math.random(0, 50) }
        end
        rainConnection = rs.RenderStepped:Connect(function(dt)
            if not rainFolder or not rainFolder.Parent then clearPrismaRain(); return end
            local center = hrp and hrp.Position or Vector3.zero
            for _, entry in ipairs(drops) do
                entry.y -= 120 * dt
                if entry.y < center.Y - 12 then
                    entry.y = center.Y + 50
                    entry.x, entry.z = math.random(-100, 100), math.random(-100, 100)
                end
                entry.part.Position = center + Vector3.new(entry.x, entry.y - center.Y, entry.z)
            end
        end)
        rainSound = Instance.new("Sound")
        rainSound.Name, rainSound.SoundId = "PrismaRainAmbience", "rbxassetid://365362615"
        rainSound.Looped, rainSound.Volume = true, 0.4
        rainSound.Parent = ws
        pcall(function() rainSound:Play() end)
    end
end

-- Cor do gramado.
local grassOriginalColors = setmetatable({}, { __mode = "k" })
local function applyGrassColor(color)
    for _, part in ipairs(ws:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = string.lower(part.Name)
            local grass = part.Material == Enum.Material.Grass
                or string.find(name, "grass", 1, true)
                or string.find(name, "pitch", 1, true)
                or string.find(name, "field", 1, true)
                or string.find(name, "grama", 1, true)
            local line = string.find(name, "line", 1, true) or string.find(name, "linha", 1, true)
            if grass and not line then
                if grassOriginalColors[part] == nil then grassOriginalColors[part] = part.Color end
                part.Color = color
            end
        end
    end
end
local function restoreGrassColor()
    for part, color in pairs(grassOriginalColors) do
        if part and part.Parent then pcall(function() part.Color = color end) end
        grassOriginalColors[part] = nil
    end
end

-- Skins locais da bola, com opção de restaurar a aparência original.
local prismaBallSkins = {
    ["Champions laranja"] = { Texture = "http://www.roblox.com/asset/?id=6631296730", Mesh = "rbxassetid://4545270159" },
    ["Champions azul"] = { Texture = "rbxassetid://8108082224", Mesh = "rbxassetid://4454597214" },
    ["Champions branca"] = { Texture = "http://www.roblox.com/asset/?id=7897839361", Mesh = "rbxassetid://4761031195" },
}
local prismaBallOriginals = setmetatable({}, { __mode = "k" })
local function findPrismaBalls()
    local result = {}
    for _, part in ipairs(ws:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = string.lower(part.Name)
            if name == "football" or name == "ball" or name == "soccerball" or name == "tps"
                or name == "hitbox" or name == "bola" or string.find(name, "tcs", 1, true) then
                result[#result + 1] = part
            end
        end
    end
    return result
end
local function rememberBallAppearance(part)
    if prismaBallOriginals[part] then return end
    local snapshot = { meshPart = part:IsA("MeshPart"), decals = {}, special = nil }
    if part:IsA("MeshPart") then
        pcall(function() snapshot.meshId, snapshot.textureId = part.MeshId, part.TextureID end)
    else
        local special = part:FindFirstChildOfClass("SpecialMesh")
        if special then
            snapshot.special = {
                object = special, meshType = special.MeshType, meshId = special.MeshId,
                textureId = special.TextureId, scale = special.Scale, offset = special.Offset,
            }
        end
    end
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("Decal") or child:IsA("Texture") then
            snapshot.decals[child] = { texture = child.Texture, transparency = child.Transparency }
        end
    end
    prismaBallOriginals[part] = snapshot
end
local function restorePrismaBallSkins()
    for part, snapshot in pairs(prismaBallOriginals) do
        if part and part.Parent then
            pcall(function()
                if snapshot.meshPart then
                    part.MeshId, part.TextureID = snapshot.meshId, snapshot.textureId
                elseif snapshot.special then
                    local special = snapshot.special.object
                    if special and special.Parent then
                        special.MeshType, special.MeshId = snapshot.special.meshType, snapshot.special.meshId
                        special.TextureId, special.Scale, special.Offset =
                            snapshot.special.textureId, snapshot.special.scale, snapshot.special.offset
                    end
                else
                    local special = part:FindFirstChild("PrismaBallSkinMesh")
                    if special then special:Destroy() end
                end
                for decal, values in pairs(snapshot.decals) do
                    if decal and decal.Parent then
                        decal.Texture, decal.Transparency = values.texture, values.transparency
                    end
                end
            end)
        end
        prismaBallOriginals[part] = nil
    end
end
local function applyPrismaBallSkin(name)
    if name == "Original" then restorePrismaBallSkins(); return end
    local skin = prismaBallSkins[name]
    if not skin then return end
    for _, part in ipairs(findPrismaBalls()) do
        rememberBallAppearance(part)
        pcall(function()
            if part:IsA("MeshPart") then
                part.MeshId, part.TextureID = skin.Mesh, skin.Texture
            else
                local special = part:FindFirstChildOfClass("SpecialMesh")
                if not special then
                    special = Instance.new("SpecialMesh")
                    special.Name = "PrismaBallSkinMesh"
                    special.Parent = part
                end
                special.MeshType, special.MeshId, special.TextureId = Enum.MeshType.FileMesh, skin.Mesh, skin.Texture
            end
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child.Texture, child.Transparency = skin.Texture, 0
                end
            end
        end)
    end
end

-- A aba Sobre é a página principal; as demais ficam separadas por categoria.
local SobreTab = Window:CreateTab("Sobre", true, false)
local AlcanceTab = Window:CreateTab("Alcance", false, false)
local GoleiroTab = Window:CreateTab("Goleiro", false, false)
local MovimentoTab = Window:CreateTab("Movimentação", false, false)
local DefesaTab = Window:CreateTab("Defesa", false, false)
local PrevisaoTab = Window:CreateTab("Previsão", false, false)
local UtilidadesTab = Window:CreateTab("Utilidades", false, false)
local BolaTab = Window:CreateTab("Bola", false, false)
local VisualTab = Window:CreateTab("Visual", false, false)
local ConfigTab = Window:CreateTab("Configurações", false, false)

local SobrePage = SobreTab:CreatePage("Visão geral")
local AlcancePage = AlcanceTab:CreatePage("Alcance")
local GoleiroPage = GoleiroTab:CreatePage("Ações de goleiro")
local MovimentoPage = MovimentoTab:CreatePage("Movimentação")
local DefesaPage = DefesaTab:CreatePage("Defesa")
local PrevisaoPage = PrevisaoTab:CreatePage("Previsão da bola")
local UtilidadesPage = UtilidadesTab:CreatePage("Ferramentas")
local ConfigPage = ConfigTab:CreatePage("Preferências")
local BolaPage = BolaTab:CreatePage("Controle da bola")
local VisualPage = VisualTab:CreatePage("Personalização visual")

local function bindValue(target, key)
    return function(value)
        target[key] = value
        sync()
    end
end

local function bindNumber(target, key, minimum, maximum)
    return function(value)
        if value == nil or value == "" then
            target[key] = nil
        else
            local number = tonumber(value)
            if not number then return end
            target[key] = math.clamp(number, minimum, maximum)
        end
        sync()
    end
end

local function addNumberInput(section, title, target, key, minimum, maximum, description)
    section:AddTextbox(title, "Digite um valor...", bindNumber(target, key, minimum, maximum), {
        Title = title,
        Description = description,
        Numeric = true,
        MinValue = minimum,
        MaxValue = maximum,
        AllowEmpty = true,
        SubmitOnEnter = true,
    })
end

-- Aba Alcance: somente funções relacionadas ao alcance.
do
    local AlcanceJogadorSection = AlcancePage:CreateSection("Alcance do jogador")
    AlcanceJogadorSection:AddToggle("Alcance", md.r.on, bindValue(md.r, "on"), {
        Title = "Ativar alcance",
        Description = "Ativa a função de alcance. Defina um tamanho antes de ativá-la.",
    })
    addNumberInput(AlcanceJogadorSection, "Tamanho do alcance", md.r, "sz", 0.5, 100,
        "Limite de distância utilizado pela função de alcance.")
    AlcanceJogadorSection:AddToggle("Visualizador do alcance", md.r.vis, bindValue(md.r, "vis"), {
        Title = "Mostrar visualizador do alcance",
        Description = "Exibe o raio de alcance ao redor do seu personagem.",
    })
    AlcanceJogadorSection:AddColorPicker("Cor do visualizador do alcance", md.r.c, bindValue(md.r, "c"), {
        Title = "Cor do visualizador",
    })
    AlcanceJogadorSection:AddSlider("Transparência do visualizador", 0, 1, md.r.a,
        bindValue(md.r, "a"), { Title = "Transparência do visualizador" })

    local AlcanceBolaSection = AlcancePage:CreateSection("Alcance da bola")
    AlcanceBolaSection:AddToggle("Alcance da bola", md.b.on, bindValue(md.b, "on"), {
        Title = "Ativar alcance da bola",
        Description = "Ativa a função de alcance da bola. Defina um tamanho antes de ativá-la.",
    })
    addNumberInput(AlcanceBolaSection, "Tamanho do alcance da bola", md.b, "sz", 0.5, 100,
        "Distância medida entre as partes do seu personagem e a bola.")
    AlcanceBolaSection:AddToggle("Visualizador do alcance da bola", md.b.vis, bindValue(md.b, "vis"), {
        Title = "Mostrar visualizador da bola",
        Description = "Exibe o visualizador do alcance da bola.",
    })
    AlcanceBolaSection:AddColorPicker("Cor do visualizador da bola", md.b.c,
        bindValue(md.b, "c"), { Title = "Cor do visualizador da bola" })
    AlcanceBolaSection:AddSlider("Transparência do visualizador da bola", 0, 1, md.b.a,
        bindValue(md.b, "a"), { Title = "Transparência do visualizador da bola" })
end

-- Aba Goleiro: somente funções específicas de goleiro.
do
    local GoleiroSection = GoleiroPage:CreateSection("Ações automáticas de goleiro")
    GoleiroSection:AddToggle("Agarrar automaticamente", md.g.catch, bindValue(md.g, "catch"), {
        Title = "Agarrar automaticamente",
        Description = "Tenta agarrar automaticamente a bola que estiver próxima.",
    })
    addNumberInput(GoleiroSection, "Distância para agarrar", md.g, "cr", 3, 45,
        "Distância máxima utilizada pela função de agarrar automaticamente.")
    GoleiroSection:AddToggle("Mergulho automático", md.g.dive, bindValue(md.g, "dive"), {
        Title = "Mergulho automático",
        Description = "Prevê chutes que se aproximam e seleciona uma ação de goleiro.",
    })
end

-- Aba Movimentação: funções automáticas e ajustes do jogador.
do
    local MovimentoSection = MovimentoPage:CreateSection("Movimentação automática")
    MovimentoSection:AddToggle("Escolha automática do pé", md.l.on, bindValue(md.l, "on"), {
        Title = "Escolha automática do pé",
        Description = "Ajusta automaticamente o pé selecionado em relação à bola.",
    })

    local followToggle = MovimentoSection:AddToggle("Seguir a bola automaticamente", md.f.on, bindValue(md.f, "on"), {
        Title = "Seguir a bola automaticamente",
        Description = "Move o personagem em direção à posição prevista da bola quando você não está usando os controles de movimento.",
    })

    local followKey, followKeyName = Enum.KeyCode.K, "K"
    MovimentoSection:AddTextbox("Tecla para seguir a bola", "Ex.: K", function(value)
        local name = tostring(value or ""):gsub("%s+", "")
        local key = Enum.KeyCode[name]
        if name ~= "" and key then
            followKey, followKeyName = key, name
        else
            Library:Notify({ Title = "Prisma Hub", Desc = "Tecla inválida para seguir a bola.", Be = "Error" })
        end
    end, {
        Title = "Atalho do seguir a bola",
        Description = "Pressione a tecla escolhida para ativar ou desativar o seguir automático.",
        AllowEmpty = false,
        SubmitOnEnter = true,
    })
    addExtraConnection(uis.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == followKey then
            local nextState = not md.f.on
            local ok = pcall(function() followToggle:Set(nextState) end)
            if not ok then
                md.f.on = nextState
                sync()
            end
        end
    end))

    local AjustesJogadorSection = MovimentoPage:CreateSection("Ajustes do jogador")
    AjustesJogadorSection:AddSlider("Velocidade do jogador", 16, 150, 16, function(value)
        setPlayerSpeed(value)
    end, {
        Title = "Velocidade",
        Description = "Ajusta a velocidade local de caminhada do personagem.",
    })
    AjustesJogadorSection:AddSlider("Campo de visão (FOV)", 40, 150, originalFov, function(value)
        setPlayerFov(value)
    end, {
        Title = "Campo de visão",
        Description = "Ajusta o campo de visão da câmera.",
    })
    AjustesJogadorSection:AddButton("Restaurar FOV original", restorePlayerFov, {
        Title = "Restaurar FOV",
        Description = "Volta ao campo de visão registrado quando o script iniciou.",
    })
end

-- Aba Defesa: funções de bloqueio e interceptação.
do
    local DefesaSection = DefesaPage:CreateSection("Proteção e interceptação")
    DefesaSection:AddToggle("Proteção", md.s.on, bindValue(md.s, "on"), {
        Title = "Ativar proteção",
        Description = "Ativa a rotina de interceptação da bola presente no script original.",
    })
    addNumberInput(DefesaSection, "Distância da proteção", md.s, "r", 2, 12,
        "Distância máxima utilizada pela função de proteção.")
end

-- Aba Previsão: somente visualização da trajetória da bola.
do
    local PrevisaoSection = PrevisaoPage:CreateSection("Previsão da trajetória")
    PrevisaoSection:AddToggle("Previsão da bola", md.v.on, bindValue(md.v, "on"), {
        Title = "Ativar previsão da bola",
        Description = "Desenha uma previsão visual da trajetória da bola.",
    })
    PrevisaoSection:AddColorPicker("Cor da previsão", md.v.c, bindValue(md.v, "c"), {
        Title = "Cor da previsão",
    })
end

-- Aba Utilidades: opções de dispositivo e aparência do avatar.
do
    local PlataformaSection = UtilidadesPage:CreateSection("Dispositivo")
    PlataformaSection:AddToggle("Alterar dispositivo informado", md.p.on, bindValue(md.p, "on"), {
        Title = "Ativar alteração de dispositivo",
        Description = "Altera o valor de plataforma enviado pelo script original.",
    })

    local plataformas = {
        ["Computador"] = "pc",
        ["Celular"] = "mobile",
        ["Console"] = "console",
    }
    PlataformaSection:AddDropdown("Dispositivo", { "Computador", "Celular", "Console" }, false,
        function(escolha)
            md.p.v = plataformas[escolha] or "pc"
            sync()
        end, {
            Title = "Dispositivo simulado",
            DefaultEnabled = true,
            DefaultOptions = { "Computador" },
        })

    local AvatarSection = UtilidadesPage:CreateSection("Aparência do avatar")
    AvatarSection:AddToggle("Copiar aparência do avatar", md.a.on, bindValue(md.a, "on"), {
        Title = "Copiar aparência do avatar",
        Description = "Copia localmente as roupas e os acessórios do avatar do jogador selecionado.",
    })
    AvatarSection:AddTextbox("Nome do jogador", "Digite o nome do jogador...",
        bindValue(md.a, "n"), {
            Title = "Nome de usuário ou nome de exibição",
            Description = "Digite o nome de usuário ou o nome de exibição do jogador cuja aparência deseja copiar.",
            AllowEmpty = true,
            SubmitOnEnter = true,
        })

    local SessaoSection = UtilidadesPage:CreateSection("Sessão e controles móveis")
    SessaoSection:AddToggle("Anti-AFK", false, function(enabled)
        setAntiAfk(enabled)
    end, {
        Title = "Anti-AFK",
        Description = "Ativa ou desativa a prevenção de desconexão por inatividade.",
    })
    SessaoSection:AddButton("Reconectar ao servidor", function()
        Library:Notify({ Title = "Prisma Hub", Desc = "Tentando reconectar ao servidor atual...", Be = "Success" })
        task.spawn(function()
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
            end)
            if not ok then
                Library:Notify({ Title = "Prisma Hub", Desc = "Não foi possível reconectar: " .. tostring(err), Be = "Error" })
            end
        end)
    end, {
        Title = "Rejoin",
        Description = "Sai e tenta entrar novamente na mesma instância.",
    })
    SessaoSection:AddToggle("Controles móveis TOT", false, function(enabled)
        if enabled then
            enableTotMobile()
        else
            disableTotMobile()
        end
    end, {
        Title = "Controles móveis",
        Description = "Mostra joystick, botões R/T e botão de pulo personalizados.",
    })
end

-- Aba Bola: funções extras de controle da bola.
do
    local PowerSection = BolaPage:CreateSection("Chute e curva")
    PowerSection:AddToggle("Power Shoot", false, function(enabled)
        setPowerShoot(enabled)
    end, {
        Title = "Power Shoot",
        Description = "Aplica força adicional ao tocar na bola enquanto você se move em direção a ela.",
    })
    PowerSection:AddSlider("Força do chute", 0, 10, 5, function(value)
        extraState.shootForce = value
    end, {
        Title = "Força do chute",
        Description = "Define a intensidade adicional do chute.",
    })
    PowerSection:AddDropdown("Tipo de curva", {
        "Padrão", "Curva para esquerda", "Curva para direita",
    }, false, function(option)
        applyCurvePreset(option)
    end, {
        Title = "Curve Shot",
        Description = "Escolhe uma curva local para a trajetória da bola.",
        DefaultEnabled = true,
        DefaultOptions = { "Padrão" },
    })

    local ControlSection = BolaPage:CreateSection("Controle manual")
    ControlSection:AddToggle("Controle manual da bola", false, function(enabled)
        setControlEnabled(enabled)
    end, {
        Title = "Controlar bola",
        Description = "Exibe um botão móvel e permite controlar a direção da bola pela câmera.",
    })
    ControlSection:AddSlider("Velocidade de controle", 10, 200, 70, function(value)
        extraState.ballSpeed = value
    end, {
        Title = "Velocidade da bola",
        Description = "Define a velocidade usada durante o controle manual.",
    })
    ControlSection:AddTextbox("Tecla do controle da bola", "U", function(value)
        setControlKeyFromText(value)
    end, {
        Title = "Atalho do controle",
        Description = "Tecla para iniciar ou parar o controle manual da bola. Atual: " .. controlKeyName,
        AllowEmpty = false,
        SubmitOnEnter = true,
    })
end

-- Aba Visual: skybox, cor do gramado e skin da bola.
do
    local SkySection = VisualPage:CreateSection("Céu e iluminação")
    SkySection:AddDropdown("Skybox", { "Padrão", "Sol", "Lua", "Chuva" }, false, function(option)
        applyPrismaSky(option)
    end, {
        Title = "Skybox",
        Description = "Altera o céu e, na opção Chuva, adiciona efeito e som de chuva.",
        DefaultEnabled = true,
        DefaultOptions = { "Padrão" },
    })

    local GrassSection = VisualPage:CreateSection("Cor do gramado")
    local grassColorPickerReady = false
    GrassSection:AddColorPicker("Cor do gramado", Color3.fromRGB(255, 255, 255), function(color)
        if not grassColorPickerReady then
            grassColorPickerReady = true
            return
        end
        applyGrassColor(color)
    end, {
        Title = "Cor do campo",
        Description = "Altera localmente a cor das partes identificadas como gramado ou campo.",
    })
    GrassSection:AddButton("Restaurar cor original do gramado", restoreGrassColor, {
        Title = "Restaurar gramado",
        Description = "Restaura as cores registradas antes da personalização.",
    })

    local BallSkinSection = VisualPage:CreateSection("Aparência da bola")
    BallSkinSection:AddDropdown("Skin da bola", {
        "Original", "Champions laranja", "Champions azul", "Champions branca",
    }, false, function(option)
        applyPrismaBallSkin(option)
    end, {
        Title = "Skin da bola",
        Description = "Altera localmente a malha e a textura das bolas encontradas.",
        DefaultEnabled = true,
        DefaultOptions = { "Original" },
    })
    BallSkinSection:AddButton("Restaurar aparência original da bola", restorePrismaBallSkins, {
        Title = "Restaurar bola",
        Description = "Restaura a malha, a textura e os decalques registrados.",
    })
end

-- Aba Sobre: identificação do script, jogador, experiência e comunidade.
do
    local IdentidadeSection = SobrePage:CreateSection("Sobre o Prisma Hub")
    IdentidadeSection:AddIndicator("Nome do script", false, function()
        return "Prisma Hub"
    end, { Title = "Nome", Description = "Nome desta interface." })
    IdentidadeSection:AddIndicator("Estado do script", false, function()
        return "Carregado"
    end, { Title = "Estado", Description = "Indica que a interface foi inicializada." })
    IdentidadeSection:AddIndicator("Biblioteca da interface", false, function()
        return "ZyronX"
    end, { Title = "Biblioteca", Description = "Biblioteca utilizada para montar a interface." })
    IdentidadeSection:AddIndicator("Crédito da versão-base", false, function()
        return "Hypol-X"
    end, { Title = "Crédito", Description = "Crédito que já constava na versão-base do arquivo." })

    local JogadorSection = SobrePage:CreateSection("Informações do jogador")
    JogadorSection:AddIndicator("Nome de usuário", false, function()
        return lp.Name
    end, { Title = "Usuário", Description = "Nome de usuário da sua conta Roblox." })
    JogadorSection:AddIndicator("Nome de exibição", false, function()
        return lp.DisplayName
    end, { Title = "Nome de exibição", Description = "Nome público exibido no Roblox." })
    JogadorSection:AddIndicator("ID do jogador", false, function()
        return tostring(lp.UserId)
    end, { Title = "ID da conta", Description = "Identificador numérico da sua conta Roblox." })
    JogadorSection:AddIndicator("Idade da conta", false, function()
        return tostring(lp.AccountAge) .. " dias"
    end, { Title = "Tempo de conta", Description = "Quantidade de dias desde a criação da conta." })
    JogadorSection:AddIndicator("Assinatura", false, function()
        return lp.MembershipType and lp.MembershipType.Name or "Não disponível"
    end, { Title = "Tipo de assinatura", Description = "Tipo de associação Roblox informado pela plataforma." })
    JogadorSection:AddIndicator("Equipe do jogador", false, function()
        return lp.Team and lp.Team.Name or "Sem equipe"
    end, { Title = "Equipe", Description = "Equipe atual do jogador nesta experiência." })
    JogadorSection:AddIndicator("Vida do personagem", false, function()
        if not hum then return "Personagem indisponível" end
        return string.format("%.0f / %.0f", hum.Health, hum.MaxHealth)
    end, { Title = "Vida", Description = "Vida atual e vida máxima do personagem." })
    JogadorSection:AddIndicator("Estado do personagem", false, function()
        if not hum then return "Não carregado" end
        return hum.Health > 0 and "Vivo" or "Fora de ação"
    end, { Title = "Estado do personagem", Description = "Estado atual do Humanoid." })

    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
    local nomeExperiencia = tostring(game.Name)
    local nomeCriador = "ID " .. tostring(game.CreatorId)
    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        if ok and type(info) == "table" then
            if type(info.Name) == "string" and info.Name ~= "" then
                nomeExperiencia = info.Name
            end
            if type(info.Creator) == "table" and type(info.Creator.Name) == "string" then
                nomeCriador = info.Creator.Name
            end
        end
    end)

    local ExperienciaSection = SobrePage:CreateSection("Informações da experiência")
    ExperienciaSection:AddIndicator("Nome da experiência", false, function()
        return nomeExperiencia
    end, { Title = "Experiência", Description = "Nome público da experiência, quando disponível." })
    ExperienciaSection:AddIndicator("ID do lugar", false, function()
        return tostring(game.PlaceId)
    end, { Title = "ID do lugar", Description = "Identificador do lugar atual do Roblox." })
    ExperienciaSection:AddIndicator("ID da experiência", false, function()
        return tostring(game.GameId)
    end, { Title = "ID da experiência", Description = "Identificador da experiência/universo." })
    ExperienciaSection:AddIndicator("Criador da experiência", false, function()
        return nomeCriador
    end, { Title = "Criador", Description = "Nome do criador, quando a plataforma disponibilizar essa informação." })
    ExperienciaSection:AddIndicator("Tipo de criador", false, function()
        return game.CreatorType and game.CreatorType.Name or "Não disponível"
    end, { Title = "Tipo de criador", Description = "Indica se a experiência pertence a uma conta ou grupo." })
    ExperienciaSection:AddIndicator("Versão do lugar", false, function()
        return tostring(game.PlaceVersion)
    end, { Title = "Versão", Description = "Número da versão publicada do lugar atual." })
    ExperienciaSection:AddIndicator("Jogadores no servidor", false, function()
        return tostring(#plrs:GetPlayers()) .. " / " .. tostring(plrs.MaxPlayers)
    end, { Title = "Jogadores", Description = "Quantidade atual de jogadores e limite do servidor." })
    ExperienciaSection:AddIndicator("Tipo de servidor", false, function()
        return game.PrivateServerId ~= "" and "Servidor privado" or "Servidor público"
    end, { Title = "Servidor", Description = "Tipo de servidor informado pelo Roblox." })

    local StatusSection = SobrePage:CreateSection("Status e comunidade")
    StatusSection:AddIndicator("Bola próxima", false, function()
        return near() and "Detectada" or "Não detectada"
    end, { Title = "Detecção da bola", Description = "Informa se o script está detectando uma bola próxima." })
    StatusSection:AddIndicator("Ambiente de execução", false, function()
        if type(identifyexecutor) == "function" then
            local ok, name, version = pcall(identifyexecutor)
            if ok then
                return version and (tostring(name) .. " " .. tostring(version)) or tostring(name)
            end
        end
        return "Desconhecido"
    end, { Title = "Ambiente de execução", Description = "Nome do ambiente de execução, quando essa informação estiver disponível." })
    StatusSection:AddCopyButton("Copiar convite do Discord", "https://discord.gg/2ERyMtmsd2", {
        Title = "Discord do Prisma Hub",
        Example = "Copia o convite do Discord que já estava configurado no script.",
    })
end

-- Aba Configurações: preferências da interface e salvamento.
do
    local AparenciaSection = ConfigPage:CreateSection("Aparência")
    local temas = {
        ["Padrão"] = "Default",
        ["Exploitador"] = "Exploiter",
        ["Hacker"] = "Hacker",
        ["Espaço"] = "Space",
        ["Buraco negro interestelar"] = "Interstellar Black Hole",
        ["Sistema estelar"] = "Star System",
        ["Terra"] = "Earth",
        ["Verde"] = "Green",
        ["Roxo"] = "Purple",
        ["Rosa"] = "Pink",
        ["RGB"] = "RGB",
        ["Marrom"] = "Brown",
        ["Azul"] = "Blue",
        ["Ciano"] = "Cyan",
        ["Branco"] = "White",
        ["Vermelho"] = "Red",
    }
    AparenciaSection:AddDropdown("Tema", {
        "Padrão", "Exploitador", "Hacker", "Espaço", "Buraco negro interestelar",
        "Sistema estelar", "Terra", "Verde", "Roxo", "Rosa", "RGB", "Marrom",
        "Azul", "Ciano", "Branco", "Vermelho",
    }, false, function(escolha)
        local temaInterno = temas[escolha] or "Purple"
        Window:SetTheme(temaInterno)
        Library:Notify({ Title = "Tema alterado", Desc = "Tema selecionado: " .. escolha, Be = "Success" })
    end, {
        Title = "Tema da interface",
        DefaultEnabled = true,
        DefaultOptions = { "Roxo" },
    })

    AparenciaSection:AddSlider("Transparência da janela", 0, 100, 0, function(valor)
        Window:SetTransparency(valor / 100)
    end, { Title = "Transparência da janela", Description = "0 significa opaca; 100 significa totalmente transparente." })

    local posicoesFPS = {
        ["Superior esquerdo"] = "TopLeft",
        ["Superior central"] = "TopMiddle",
        ["Superior direito"] = "TopRight",
        ["Inferior esquerdo"] = "BottomLeft",
        ["Inferior direito"] = "BottomRight",
    }
    AparenciaSection:AddDropdown("Posição do contador de FPS", {
        "Superior esquerdo", "Superior central", "Superior direito", "Inferior esquerdo", "Inferior direito",
    }, false, function(escolha)
        Window:SetFpsPosition(posicoesFPS[escolha] or "TopLeft")
    end, {
        Title = "Posição do contador de FPS",
        DefaultEnabled = true,
        DefaultOptions = { "Superior esquerdo" },
    })

    local ConfigSection = ConfigPage:CreateSection("Salvar configurações")
    ConfigSection:AddConfigManager("prismaHubSavers")
end

-- Desativa as funções em segundo plano e libera conexões e interceptações.
local function stopAll()
    md.r.on, md.b.on, md.s.on, md.l.on = false, false, false, false
    md.g.dive, md.g.catch = false, false
    md.f.on, md.p.on, md.a.on, md.v.on = false, false, false, false
    sync()
    gk.stop()

    -- Encerra também os recursos adicionados nesta integração.
    setAntiAfk(false)
    setPowerShoot(false)
    applyCurvePreset("Padrão")
    setControlEnabled(false)
    disableTotMobile()
    restoreSkyAndLighting()
    restoreGrassColor()
    restorePrismaBallSkins()
    setPlayerSpeed(16)
    restorePlayerFov()

    for _, connection in extraCons do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(extraCons)

    for _, connection in cons do
        pcall(function() connection:Disconnect() end)
    end
    for _, connection in arm do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(cons)
    table.clear(arm)

    if _G.zyronxStop == stopAll then _G.zyronxStop = nil end
    if _G.veastop == stopAll then _G.veastop = nil end
    Library:Notify({ Title = "Prisma Hub", Desc = "Todas as funções em segundo plano foram desativadas.", Be = "Success" })
end

_G.zyronxStop = stopAll
_G.veastop = stopAll

local ControleSection = ConfigPage:CreateSection("Controle do script")
ControleSection:AddButton("Desativar todas as funções", stopAll, {
    Title = "Desativar todas as funções",
    Description = "Desativa os módulos e desconecta as conexões em segundo plano.",
    Confirm = {
        Title = "Desativar todas as funções?",
        Description = "Todas as funções ativas serão desativadas.",
        Yes = "Desativar",
        No = "Cancelar",
        Danger = true,
    },
})

Library:Notify({
    Title = "Prisma Hub",
    Desc = "Prisma Hub carregado com sucesso.",
    Be = "Success",
})
