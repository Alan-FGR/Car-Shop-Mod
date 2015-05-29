local szabocarshop = {}

local showmenu = false
local previewv = 0
local previewvvalue = 0
local previewcamrot = 0

local function deletepreview() 
	if (previewv ~= 0) then
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(previewv, true, true)
		VEHICLE.DELETE_VEHICLE(previewv)
	end
end

local function spawnpreviewv(data)
		
		local hash = data[1]
		
		deletepreview()
		
		if (STREAMING.IS_MODEL_IN_CDIMAGE(hash) and STREAMING.IS_MODEL_A_VEHICLE(hash)) then
		
			previewvvalue = data[2]
		
			STREAMING.REQUEST_MODEL(hash)
			
			ENTITY.SET_ENTITY_VISIBLE(PLAYER.PLAYER_PED_ID(), false)
			while (not STREAMING.HAS_MODEL_LOADED(hash)) do
				CONTROLS.DISABLE_ALL_CONTROL_ACTIONS(2)
				wait(0)
				CONTROLS.DISABLE_ALL_CONTROL_ACTIONS(2)
			end
			
			local spawnpos = {-374.5, -122.5, 38.5}
			
			local nearv = VEHICLE.GET_CLOSEST_VEHICLE(spawnpos[1],spawnpos[2],spawnpos[3], 3, 0, 70)
			if (nearv ~= 0) then
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(nearv, true, true)
				VEHICLE.DELETE_VEHICLE(nearv)
			end
			
			previewv = VEHICLE.CREATE_VEHICLE(hash, spawnpos[1],spawnpos[2],spawnpos[3], 0, true, true)
			PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), previewv, -1)
			ENTITY.SET_ENTITY_VISIBLE(PLAYER.PLAYER_PED_ID(), true)
			VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(previewv);
			
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		
		end

end

local function addmoneytoplayer(val)

	mhash = GAMEPLAY.GET_HASH_KEY("SP0_TOTAL_CASH")
	if (PED.IS_PED_MODEL(PLAYER.PLAYER_PED_ID(), GAMEPLAY.GET_HASH_KEY("player_one"))) then                                
		mhash = GAMEPLAY.GET_HASH_KEY("SP1_TOTAL_CASH")                                     
	elseif (PED.IS_PED_MODEL(PLAYER.PLAYER_PED_ID(), GAMEPLAY.GET_HASH_KEY("player_two"))) then
		mhash = GAMEPLAY.GET_HASH_KEY("SP2_TOTAL_CASH")  
	end
	
	local _, curval = STATS.STAT_GET_INT(mhash, 0, -1)
	STATS.STAT_SET_INT(mhash, curval+val, true)
		
end

local function gotochoosecolor()
	szgui.curmenu = 'colors'
	szgui.curbut = 1
end

local function choosecolor()
	showmenu = false
	szgui.curmenu = 'main'
	CONTROLS.ENABLE_ALL_CONTROL_ACTIONS(2)
	
	addmoneytoplayer(-previewvvalue)
	
end

local function selectcolor(col)
	if(col[1] ~= 256) then
		VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(previewv,col[1],col[2],col[3])
	end
end

function szabocarshop.unload() end
function szabocarshop.quit()

	showmenu = false
	szgui.curmenu = 'main'
	CONTROLS.ENABLE_ALL_CONTROL_ACTIONS(2)
	
	local playerPed = PLAYER.PLAYER_PED_ID()
	local playerInV = PED.IS_PED_IN_ANY_VEHICLE(playerPed, false)
	
	if (not playerInV) then
		ENTITY.SET_ENTITY_COORDS(playerPed, -366.1, -103.1, 38.5, true, true, true, true)
	end
	
	deletepreview()

end

local function getlistfromdb(db,vtype)
	list = {}
	for k,e in pairs(db) do
		if (e[3] == vtype) then
			table.insert(list, {e[1],e[2]})
		end
	end
	return list
end

local function addlisttomenu(list, menustr)

	local currentmenu = 0

	for i,car in ipairs(list) do
		
		local curmenustr = menustr..tostring(currentmenu)
		
		if ((i-1) % 15 == 0) then
			currentmenu = currentmenu + 1
			curmenustr = menustr..tostring(currentmenu)
			szgui.menus[curmenustr] = {}
			table.insert(szgui.menus[curmenustr], {"Previous", szgui.gotomenu, menustr..tostring(currentmenu-1)})
		end
		
		local vname = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(car[1])
		-- print("added", vname, "to menu", curmenustr)
		table.insert(szgui.menus[curmenustr], {vname .. " $" .. tostring(car[2]), gotochoosecolor, car, spawnpreviewv})
		
		if ((i-1) % 15 == 14 or i == #list) then
			table.insert(szgui.menus[curmenustr], {"Next", szgui.gotomenu, menustr..tostring(currentmenu+1)})
			table.insert(szgui.menus[curmenustr], {"Cancel", szgui.gotomenu, 'main'})
		end	
		
	end
end

function szabocarshop.init()
	
	szgui.menus['colors'] = {
	{"Don't Change", choosecolor, {256,255,255}, selectcolor},
	{"White", choosecolor, {255,255,255}, selectcolor},
	{"Black", choosecolor, {0,0,0}, selectcolor},
	{"Red", choosecolor, {200,10,10}, selectcolor},
	{"Yellow", choosecolor, {255,200,0}, selectcolor},
	{"Blue", choosecolor, {0,128,255}, selectcolor},
	{"Green", choosecolor, {80,180,20}, selectcolor},
	{"Cancel", szgui.gotomenu, 'main'}
	}

local allcars = {
{	0xB779A091	,	1000000	, 	"s"},--s	adder							
{	0x4C80EB0E	,	250000	, 	"u"},--u	airbus							
{	0x5D0AAC8F	,	5000	, 	"u"},--u	airtug							
{	0x63ABADE7	,	9000	, 	"b"},--b	akuma							
{	0x45D56ADA	,	400000	, 	"u"},--u	ambulance							
{	0x31F0B376	,	2500000	, 	"x"},--x	annihilator							
-- {	0xB8081009	,	5000	, 	"d"},--d	armytanker							
-- {	0xA7FF33F5	,	5000	, 	"d"},--d	armytrailer	(army	flatbed	trailer)				
-- {	0x9E6B14D6	,	5000	, 	"d"},--d	armytrailer2	(flatbed	with	cutter	trailer)			
{	0x94204D89	,	45000	, 	"n"},--n	asea							
{	0x9441D8D5	,	45000	, 	"n"},--n	asea2	(snowy	asea)					
{	0x8E9254FB	,	35000	, 	"n"},--n	asterope							
{	0x806B9CC3	,	7000	, 	"b"},--b	bagger							
-- {	0xE82AE656	,	5000	, 	"d"},--d	baletrailer							
{	0xCFCA3668	,	70000	, 	"v"},--v	baller							
{	0x08852855	,	90000	, 	"v"},--v	baller2	(RangeRover	Evoque)					
{	0xC1E908D2	,	90000	, 	"s"},--s	banshee							
{	0xCEEA3F4B	,	450000	, 	"u"},--u	barracks	(barracks	with	backcover)				
{	0x4008EABB	,	450000	, 	"u"},--u	barracks2	(barracks	semi)					
{	0xF9300CC5	,	10000	, 	"b"},--b	bati							
{	0xCADD5D2D	,	12000	, 	"b"},--b	bati2	(bati	livery)					
{	0x7A61B330	,	125000	, 	"u"},--u	benson							
{	0x432AA566	,	16000	, 	"o"},--o	bfinjection							
{	0x32B91AE8	,	85000	, 	"u"},--u	biff							
{	0xFEFD644F	,	30000	, 	"n"},--n	bison							
{	0x7B8297C5	,	30000	, 	"u"},--u	bison2	(cowboy	construction	bison)				
{	0x67B3F020	,	30000	, 	"u"},--u	bison3	(landscapeing	bison)					
{	0x32B29A4B	,	95000	, 	"v"},--v	bjxl							
{	0x8125BCF9	,	8000	, 	"o"},--o	blazer							
{	0xFD231729	,	9000	, 	"o"},--o	blazer2	(lifeguard	blazer)					
{	0xB44F0582	,	12000	, 	"o"},--o	blazer3	(trevor's	hotrod	blazer)				
-- {	0xF7004C86	,	5000	, 	"d"},--d	blimp							
{	0xEB70965F	,	25000	, 	"n"},--n	blista							
{	0x43779C54	,	500	, 	"c"},--c	bmx							
-- {	0x1F3D44B5	,	5000	, 	"d"},--d	boattrailer	(trailer	for	boats)				
{	0x3FC5D440	,	23000	, 	"n"},--n	bobcatxl							
{	0xAA699BB6	,	25000	, 	"o"},--o	bodhi2	(trevor's	truck)					
{	0x898ECCEA	,	45000	, 	"u"},--u	boxville	(water&power	boxville)					
{	0xF21B33BE	,	45000	, 	"u"},--u	boxville2	(postal	boxville)					
{	0x07405E08	,	45000	, 	"u"},--u	boxville3	(humane	boxville)					
{	0xD756460C	,	35000	, 	"m"},--m	buccaneer							
{	0xEDD516C6	,	35000	, 	"m"},--m	buffalo							
{	0x2BEC3CBE	,	35000	, 	"m"},--m	buffalo2	(franklin's	buffalo)					
{	0x7074F39D	,	125000	, 	"u"},--u	bulldozer							
{	0x9AE6DDA1	,	155000	, 	"s"},--s	bullet							
{	0xAFBB2CA4	,	15000	, 	"u"},--u	burrito	(cowboy	construction	phartegas	atomic	water	&	power
{	0xC9E8FF76	,	15000	, 	"u"},--u	burrito2	(bugstars	burrito)					
{	0x98171BD3	,	15000	, 	"u"},--u	burrito3	(nolivery	burrito)					
{	0x353B561D	,	15000	, 	"u"},--u	burrito4	(cowboy	construction	burrito)				
{	0x437CF2A0	,	15000	, 	"u"},--u	burrito5	(snowy	burrito)					
{	0xD577C962	,	250000	, 	"u"},--u	bus							
{	0x2F03547B	,	1200000	, 	"x"},--x	buzzard							
{	0x2C75F0DD	,	2000000	, 	"x"},--x	buzzard2	(buzzard	with	nogun)				
-- {	0xC6C3242D	,	5000	, 	"d"},--d	cablecar							
{	0x44623884	,	5200	, 	"u"},--u	caddy	(prolaps	caddy)					
{	0xDFF0594C	,	5200	, 	"u"},--u	caddy2	(caddy	convertible)					
{	0x6FD95F68	,	7600	, 	"u"},--u	camper							
{	0x7B8AB45F	,	195000	, 	"s"},--s	carbonizzare							
{	0x00ABB0C0	,	40000	, 	"b"},--b	carbonrs							
{	0xFCFCB68B	,	2200000	, 	"x"},--x	cargobob							
{	0x60A7EA10	,	2200000	, 	"x"},--x	cargobob2	(medical	cargobob)					
{	0x53174EEF	,	2200000	, 	"x"},--x	cargobob3	(trevor's	cargobob)					
-- {	0x15F27762	,	5000	, 	"d"},--d	cargoplane							
{	0x779F23AA	,	60000	, 	"v"},--v	cavalcade	(gtaiv	cavalcade/Cadillac	Escalade	2005)			
{	0xD0EB2BE5	,	60000	, 	"v"},--v	cavalcade2	(gtav	cavalcade/Cadillac	Escalade	2013)			
{	0xB1D95DA0	,	650000	, 	"s"},--s	cheetah							
{	0x84718D34	,	75000	, 	"u"},--u	coach							
{	0x13B57D8A	,	185000	, 	"s"},--s	cogcabrio							
{	0xC1AE4D16	,	85000	, 	"s"},--s	comet2							
{	0x067BC037	,	95000	, 	"s"},--s	coquette							
{	0x1ABA13B5	,	3000	, 	"c"},--c	cruiser							
{	0x132D5A1A	,	225000	, 	"o"},--o	crusader							
-- {	0xD9927FE3	,	5000	, 	"d"},--d	cuban800							
{	0xC3FBA120	,	4555000	, 	"x"},--x	cutter							
{	0x77934CEE	,	15000	, 	"b"},--b	daemon							
{	0xBC993509	,	25000	, 	"n"},--n	dilettante							
{	0x64430650	,	25000	, 	"u"},--u	dilettante2	(merryweather	patrol	car)				
-- {	0x3D961290	,	5000	, 	"d"},--d	dinghy							
-- {	0x107F392C	,	5000	, 	"d"},--d	dinghy2	(2-Seater)						
{	0x698521E3	,	4000	, 	"u"},--u	dloader							
-- {	0x806EFBEE	,	5000	, 	"d"},--d	docktrailer	(shipping	container	trailer)				
{	0xCB44B1CA	,	25000	, 	"u"},--u	docktug							
{	0x04CE68AC	,	65000	, 	"m"},--m	dominator							
{	0x9C669788	,	12000	, 	"b"},--b	double							
{	0x462FE277	,	155000	, 	"v"},--v	dubsta							
{	0xE882E5F6	,	165000	, 	"v"},--v	dubsta2	(blacked	out	dubsta)				
{	0x810369E2	,	45000	, 	"u"},--u	dump							
{	0x9CF21E0F	,	20000	, 	"o"},--o	dune							
{	0x1FD824AF	,	250000	, 	"o"},--o	dune2	(spacedocker)						
{	0x39D6779E	,	275000	, 	"x"},--x	duster							
{	0xDE3D9D22	,	95000	, 	"s"},--s	elegy2							
{	0xD7278283	,	25000	, 	"n"},--n	emperor							
{	0x8FC3AADC	,	5000	, 	"n"},--n	emperor2	(rusty	emperor)					
{	0xB5FCF74E	,	25000	, 	"n"},--n	emperor3	(snowy	emperor)					
{	0xB2FE5CF9	,	795000	, 	"s"},--s	entityxf							
{	0xFFB15B5E	,	205000	, 	"n"},--n	exemplar							
{	0xDCBCBE48	,	185000	, 	"s"},--s	f620							
{	0x0350D1AB	,	5000	, 	"b"},--b	faggio2							
{	0x432EA949	,	85000	, 	"m"},--m	fbi	(fbi	buffalo)					
{	0x9DC66994	,	165000	, 	"u"},--u	fbi2	(fbi	granger)					
{	0xE8A8BDA8	,	100000	, 	"n"},--n	felon							
{	0xFAAD85EE	,	110000	, 	"n"},--n	felon2	(felon	gt	convertible)				
{	0x8911B9F5	,	145000	, 	"s"},--s	feltzer2							
{	0x73920F8E	,	1500000	, 	"u"},--u	firetruk							
{	0xCE23D3BF	,	4000	, 	"c"},--c	fixter							
{	0x50B0215A	,	55000	, 	"u"},--u	flatbed							
{	0x58E49664	,	8000	, 	"u"},--u	forklift							
{	0xBC32A33B	,	165000	, 	"v"},--v	fq2							
-- {	0x3D6AAA9B	,	5000	, 	"d"},--d	freight	(train)						
-- {	0x0AFD22A6	,	5000	, 	"d"},--d	freightcar							
-- {	0x36DCFF98	,	5000	, 	"d"},--d	freightcont1							
-- {	0x0E512E79	,	5000	, 	"d"},--d	freightcont2							
-- {	0x264D9262	,	5000	, 	"d"},--d	freightgrain							
-- {	0xD1ABB666	,	5000	, 	"d"},--d	freighttrailer	(big	flatbed	trailer)				
{	0x2C634FBD	,	1300000	, 	"x"},--x	frogger							
{	0x742E9AC0	,	1300000	, 	"x"},--x	frogger2	(trevor's	frogger)					
{	0x71CB2FFB	,	24000	, 	"n"},--n	fugitive							
{	0x1DC0BA53	,	36000	, 	"s"},--s	fusilade							
{	0x7836CE2F	,	15000	, 	"n"},--n	futo							
{	0x94B395C5	,	32000	, 	"m"},--m	gauntlet							
{	0x97FA4F36	,	25000	, 	"u"},--u	gburrito							
-- {	0x3CC7F596	,	5000	, 	"d"},--d	graintrailer							
{	0x9628879C	,	35000	, 	"v"},--v	granger							
{	0xA3FC0F4D	,	29000	, 	"v"},--v	gresley							
{	0x34B7390F	,	25000	, 	"n"},--n	habanero							
{	0x1A7FCEFA	,	500000	, 	"u"},--u	handler							
{	0x5A82F9AE	,	150000	, 	"u"},--u	hauler							
{	0x11F76C14	,	15000	, 	"b"},--b	hexer							
{	0x0239E390	,	90000	, 	"m"},--m	hotknife							
{	0x18F25AC7	,	440000	, 	"s"},--s	infernus							
{	0xB3206692	,	9000	, 	"n"},--n	ingot							
{	0x34DD8AA1	,	16000	, 	"n"},--n	intruder							
{	0xB9CB3B69	,	18000	, 	"n"},--n	issi2	(issi	convertible)					
{	0xDAC67112	,	15000	, 	"n"},--n	jackal							
{	0x3EAB5555	,	475000	, 	"x"},--x	jb700							
-- {	0x3F119114	,	5000	, 	"d"},--d	jet							
-- {	0x33581161	,	5000	, 	"d"},--d	jetmax							
{	0xF8D48E7A	,	14000	, 	"u"},--u	journey							
{	0x206D1B68	,	100000	, 	"s"},--s	khamelion							
{	0x4BA4E8DC	,	58000	, 	"v"},--v	landstalker							
{	0xB39B0AE6	,	5000000	, 	"x"},--x	lazer							
{	0x1BF8D381	,	15000	, 	"u"},--u	lguard							
-- {	0x250B0C5E	,	5000	, 	"d"},--d	luxor							
-- {	0x97E55D11	,	5000	, 	"d"},--d	mammatus							
{	0x81634188	,	10000	, 	"n"},--n	manana							
-- {	0xC1CE1183	,	5000	, 	"d"},--d	marquis							
{	0x9D0450CA	,	780000	, 	"x"},--x	maverick							
{	0x36848602	,	20000	, 	"o"},--o	mesa							
{	0xD36A4B44	,	20000	, 	"o"},--o	mesa2	(snowy	mesa)					
{	0x84F42E51	,	50000	, 	"o"},--o	mesa3	(merryweather	mesa)					
-- {	0x33C9E158	,	5000	, 	"d"},--d	metrotrain							
{	0xED7EADA4	,	30000	, 	"n"},--n	minivan							
{	0xD138A6BB	,	35000	, 	"u"},--u	mixer							
{	0x1C534995	,	35000	, 	"u"},--u	mixer2	(wheels	on	back)				
{	0xE62B361B	,	490000	, 	"s"},--s	monroe							
{	0x6A4BD8F6	,	1000	, 	"u"},--u	mower							
{	0x35ED670B	,	15000	, 	"u"},--u	mule							
{	0xC1632BEB	,	15000	, 	"u"},--u	mule2	(?)						
{	0xDA288376	,	12000	, 	"b"},--b	nemesis							
{	0x3D8FA25C	,	120000	, 	"s"},--s	ninef							
{	0xA8E38B01	,	120000	, 	"s"},--s	ninef2	(ninef	convertible)					
{	0x506434F6	,	80000	, 	"n"},--n	oracle	(gta4	oracle)					
{	0xE18195B2	,	80000	, 	"n"},--n	oracle2	(oracle	xs)					
{	0x21EEE87D	,	165000	, 	"u"},--u	packer							
{	0xCFCFEB3B	,	50000	, 	"v"},--v	patriot							
{	0x885F3671	,	150000	, 	"u"},--u	pbus							
{	0xC9CEAF06	,	9000	, 	"b"},--b	pcj							
{	0xE9805550	,	24000	, 	"s"},--s	penumbra							
{	0x6D19CCBC	,	15000	, 	"n"},--n	peyote							
{	0x809AA4CB	,	195000	, 	"u"},--u	phantom							
{	0x831A21D5	,	35000	, 	"m"},--m	phoenix							
{	0x59E0FBF3	,	15000	, 	"n"},--n	picador							
{	0x79FBB0C5	,	45000	, 	"u"},--u	police	(police	stanier)					
{	0x9F05F101	,	55000	, 	"u"},--u	police2	(police	buffalo)					
{	0x71FA16EA	,	45000	, 	"u"},--u	police3	(police	interceptor)					
{	0x8A63C7B9	,	35000	, 	"u"},--u	police4	(undercover	police	stanier)				
{	0xFDEFAEC3	,	15000	, 	"b"},--b	policeb	(police	bike)					
{	0xA46462F7	,	25000	, 	"u"},--u	policeold1	(snowy	police	rancher)				
{	0x95F4C618	,	25000	, 	"u"},--u	policeold2	(snowy	police	esperanto)				
{	0x1B38E955	,	30000	, 	"u"},--u	policet	(police	transport	van)				
{	0x1517D4D9	,	850000	, 	"x"},--x	polmav							
{	0xF8DE29A8	,	13000	, 	"u"},--u	pony	(sunset	bleach	sprunk	postal	pony)		
{	0x38408341	,	13000	, 	"u"},--u	pony2	(weed	van)					
{	0x7DE35E7D	,	95000	, 	"u"},--u	pounder							
{	0xA988D3A2	,	28000	, 	"n"},--n	prairie							
{	0x2C33B46E	,	45000	, 	"u"},--u	pranger							
-- {	0xE2E7D4AB	,	5000	, 	"d"},--d	predator							
{	0x8FB66F9B	,	1900	, 	"n"},--n	premier							
{	0xBB6B404F	,	21000	, 	"n"},--n	primo							
-- {	0x153E1B0A	,	5000	, 	"d"},--d	proptrailer	(mobile	home	trailer)				
{	0x9D96B45B	,	95000	, 	"v"},--v	radi							
-- {	0x174CB172	,	5000	, 	"d"},--d	raketrailer							
{	0x6210CBB0	,	45000	, 	"n"},--n	rancherxl							
{	0x7341576B	,	45000	, 	"n"},--n	rancherxl2	(snowy	rancher)					
{	0x8CB29A14	,	132000	, 	"s"},--s	rapidgt							
{	0x679450AF	,	140000	, 	"s"},--s	rapidgt2	(rapid	gt	convertible)				
{	0xD83C13CE	,	37500	, 	"u"},--u	ratloader							
{	0xB802DD46	,	18000	, 	"o"},--o	rebel	(rusty	rebel)					
{	0x8612B64B	,	22000	, 	"o"},--o	rebel2	(clean	rebel)					
{	0xFF22D208	,	16000	, 	"n"},--n	regina							
{	0xBE819C63	,	95000	, 	"u"},--u	rentalbus							
{	0x2EA68690	,	3000000	, 	"u"},--u	rhino							
{	0xB822A1AA	,	550000	, 	"u"},--u	riot							
{	0xCD935EF9	,	150000	, 	"u"},--u	ripley							
{	0x7F5C91F1	,	85000	, 	"v"},--v	rocoto							
{	0x2560B2FC	,	35000	, 	"u"},--u	romero							
{	0x9A5B1DCC	,	35000	, 	"u"},--u	rubble							
{	0xCABD11E8	,	10000	, 	"b"},--b	ruffian							
{	0xF26CEFF9	,	32000	, 	"m"},--s	ruiner							
{	0x4543B74D	,	15000	, 	"u"},--u	rumpo	(weazel	news	rumpo)				
{	0x961AFEF7	,	15000	, 	"u"},--u	rumpo2	(deludamol	rumpo)					
{	0x9B909C94	,	28000	, 	"m"},--m	sabregt							
{	0xDC434E51	,	35000	, 	"n"},--n	sadler							
{	0x2BC345D1	,	35000	, 	"n"},--n	sadler2	(snowy	sadler)					
{	0x2EF89E46	,	7000	, 	"b"},--b	sanchez	(sanchez	livery)					
{	0xA960B13E	,	7000	, 	"b"},--b	sanchez2	(sanchez	paint)					
{	0xB9210FD0	,	45000	, 	"o"},--o	sandking	(sandking	4	door)				
{	0x3AF8C345	,	65000	, 	"o"},--o	sandking2	(sandking	2	door)				
{	0xB52B5113	,	35000	, 	"n"},--n	schafter2							
{	0xD37B7976	,	80000	, 	"n"},--n	schwarzer							
{	0xF4E1AA15	,	1000	, 	"c"},--c	scorcher							
{	0x9A9FD3DF	,	25000	, 	"u"},--u	scrap							
-- {	0xC2974024	,	5000	, 	"d"},--d	seashark	(speedophile	seashark)					
-- {	0xDB4388E4	,	5000	, 	"d"},--d	seashark2	(lifeguard	seashark)					
{	0x48CECED3	,	30000	, 	"v"},--v	seminole							
{	0x50732C82	,	25000	, 	"n"},--n	sentinel	(sentinel	xs)					
{	0x3412AE2D	,	25000	, 	"n"},--n	sentinel2	(sentinel	Convertible)					
{	0x4FB1A214	,	45000	, 	"v"},--v	serrano							
-- {	0xB79C1BF5	,	5000	, 	"d"},--d	shamal							
{	0x9BAA707C	,	45000	, 	"u"},--u	sheriff	(sheriff	stanier)					
{	0x72935408	,	65000	, 	"u"},--u	sheriff2	(sheriff	granger)					
{	0x3E48BF23	,	2500000	, 	"x"},--x	skylift							
{	0xCFB3870C	,	15000	, 	"u"},--u	speedo							
{	0x2B6DC64A	,	15000	, 	"u"},--u	speedo2	(clown	van)					
-- {	0x17DF5EC2	,	5000	, 	"d"},--d	squalo							
{	0xA7EDE74D	,	10000	, 	"n"},--n	stanier							
{	0x5C23AF9B	,	1000000	, 	"s"},--s	stinger							
{	0x82E499FA	,	1100000	, 	"s"},--s	stingergt							
{	0x6827CF72	,	18000	, 	"u"},--u	stockade							
{	0xF337AB36	,	18000	, 	"u"},--u	stockade3	(snowy	stockade)					
{	0x66B4FC45	,	22000	, 	"n"},--n	stratum							
{	0x8B13F083	,	180000	, 	"n"},--n	stretch							
{	0x81794C70	,	250000	, 	"x"},--x	stunt							
-- {	0x2DFF622F	,	5000	, 	"d"},--d	submersible							
{	0x39DA2754	,	58000	, 	"n"},--n	sultan							
-- {	0xEF2295C9	,	5000	, 	"d"},--d	suntrap							
{	0x42F2ED16	,	250000	, 	"n"},--n	superd							
{	0x16E478C1	,	99000	, 	"s"},--s	surano							
{	0x29B0DA97	,	13000	, 	"n"},--n	surfer	(surfer	with	surfboard)				
{	0xB1D80E06	,	13000	, 	"n"},--n	surfer2	(surfer	without	surfboard)				
{	0x8F0E3594	,	31000	, 	"n"},--n	surge							
{	0x744CA80D	,	15000	, 	"u"},--u	taco							
{	0xC3DDFDCE	,	55000	, 	"n"},--n	tailgater							
-- {	0xD46F4737	,	5000	, 	"d"},--d	tanker							
-- {	0x22EDDC30	,	5000	, 	"d"},--d	tankercar							
{	0xC703DB5F	,	25000	, 	"u"},--u	taxi							
{	0x02E19879	,	25000	, 	"u"},--u	tiptruck							
{	0xC7824E5E	,	25000	, 	"u"},--u	tiptruck2	(sand)						
-- {	0x761E2AD3	,	5000	, 	"d"},--d	titan							
{	0x1BB290BC	,	15000	, 	"n"},--n	tornado	(clean	tornado)					
{	0x5B42A5C4	,	17000	, 	"n"},--n	tornado2	(clean	tornado	with	carbon	roof)		
{	0x690A4153	,	9000	, 	"n"},--n	tornado3	(rusty	tornado)					
{	0x86CF7CDD	,	16000	, 	"n"},--n	tornado4	(tornado	with	guitar/mariachi	car)			
{	0x73B1C3CB	,	85000	, 	"u"},--u	tourbus							
{	0xB12314E0	,	35000	, 	"u"},--u	towtruck	(large	towtruck)					
{	0xE5A2D6C6	,	30000	, 	"u"},--u	towtruck2	(small	towtruck)					
-- {	0x7BE032C6	,	5000	, 	"d"},--d	tr2	(car	carrier	trailer)				
-- {	0x6A59902D	,	5000	, 	"d"},--d	tr3	(marquis	trailer)					
-- {	0x7CAB34D0	,	5000	, 	"d"},--d	tr4	(super	car	carrier	trailer)			
{	0x61D6BA8C	,	1000	, 	"u"},--u	tractor	(rusty	tractor)					
{	0x843B73DE	,	65000	, 	"u"},--u	tractor2	(farm	tractor)					
{	0x562A97BD	,	65000	, 	"u"},--u	tractor3	(snowy	tractor)					
-- {	0x782A236D	,	5000	, 	"d"},--d	trailerlogs	(log	trailer)					
-- {	0xCBB2BE0E	,	5000	, 	"d"},--d	trailers	(metal	trailer)					
-- {	0xA1DA3C91	,	5000	, 	"d"},--d	trailers2	(up	&	atom	cluckinbell	piswasser	trailer)	
-- {	0x8548036D	,	5000	, 	"d"},--d	trailers3	(biggoods	trailer)					
-- {	0x2A72BEAB	,	5000	, 	"d"},--d	trailersmall	(small	construction	trailer)				
{	0x72435A19	,	85000	, 	"u"},--u	trash							
-- {	0xAF62F6B2	,	5000	, 	"d"},--d	trflat	(flatbed	trailer)					
{	0x4339CD69	,	2500	, 	"c"},--c	tribike	(green	whippet	race	bike)			
{	0xB67597EC	,	2500	, 	"c"},--c	tribike2	(red	endurex	race	bike)			
{	0xE823FB48	,	2500	, 	"c"},--c	tribike3	(blue	tri-cycles	race	bike)			
-- {	0x1149422F	,	5000	, 	"d"},--d	tropic							
-- {	0x967620BE	,	5000	, 	"d"},--d	tvtrailer	(fame	or	shame	trailer)			
{	0x1ED0A534	,	25000	, 	"u"},--u	utillitruck	(building	&	renovation	utillitruck)			
{	0x34E6BF6B	,	25000	, 	"u"},--u	utillitruck2	(landscape	gas	building	&	renovation	utillitruck)	
{	0x7F2153DF	,	25000	, 	"u"},--u	utillitruck3	(landscape	utillitruck)					
{	0x142E0DC3	,	240000	, 	"s"},--s	vacca							
{	0xF79A00F7	,	9000	, 	"b"},--b	vader							
-- {	0x9C429B6A	,	5000	, 	"d"},--d	velum							
{	0xCEC6B9B7	,	21000	, 	"m"},--m	vigero							
{	0x9F4B77BE	,	150000	, 	"s"},--s	voltic							
{	0x1F3766E3	,	8000	, 	"n"},--n	voodoo2	(rusty	voodoo)					
{	0x69F06B57	,	25000	, 	"n"},--n	washington							
{	0x03E5F6B8	,	16000	, 	"u"},--u	youga							
{	0xBD1B39C3	,	50000	, 	"n"},--n	zion	(zion	xs)					
{	0xB8E2AE18	,	54000	, 	"n"},--n	zion2	(zion	Convertible)					
{	0x2D3BD401	,	10000000, 	"s"} --s	ztype							
}

local newgen = {
{	0x49863E9C	,	250000	},--        marshall=
{	0xEC8F7094	,	279000	},--        dukes2=
{	0xDCBC1C3B	,	17000	},--        Blista3=
{	0x3DEE5EDA	,	17000	},--        Blista2=
-- {	0xCA495705	,	1000000	},--    
-- {	0xC07107EE	,	1000000	},--    
{	0xE2C013E	,	42000	},--        buffalo3=
{	0x2B26F456	,	62000	},--        dukes=
{	0x72A4C31E	,	71000	},--        stalion=
{	0xE80F67EE	,	71000	},--        stalion2=
{	0xC96B73D9	,	75000	},--        dominator2=
{	0x14D22159	,	42000	},--        gauntlet2=
-- {	0xDB6B4924	,	1000000	},--
}

local dlc = {
{	0xEB298297	,	75000	},--        bifta = 0x
{	0x05852838	,	51000	},--        kalahari =
{	0x58B3979C	,	50000	},--        paradise =
-- {	0x0DC60D2B	,	1000000	},--    speeder = 
{	0x06FF6914	,	500000	},--        btype = 0x
{	0xB2A716A3	,	240000	},--        jester = 0
{	0x185484E1	,	500000	},--        turismor =
{	0x2DB8D1AA	,	150000	},--        alpha = 0x
-- {	0x4FF77E37	,	1000000	},--    vestra = 0
{	0xF77ADE32	,	275000	},--        massacro =
{	0xAC5DF515	,	725000	},--        zentorno =
{	0x1D06D681	,	195000	},--        huntley = 
{	0x6D6F8F43	,	75000	},--        thrust = 0
{	0x322CF98F	,	140000	},--        rhapsody =
{	0x51D83328	,	120000	},--        warrener =
{	0xB820ED5E	,	160000	},--        blade = 0x
{	0x047A6BC1	,	200000	},--        glendale =
{	0xE644E480	,	85000	},--        panto = 0x
{	0xB6410173	,	249000	},--        dubsta3 = 
{	0x404B6381	,	400000	},--        pigalle = 
{	0xCD93A7DB	,	400000	},--        monster = 
{	0x2C509634	,	20000	},--        sovereign 
-- {	0x6CBD1D6D	,	1000000	},--    besra = 0x
-- {	0x09D80F93	,	1000000	},--miljmiljet = 0et
{	0x3C4E2113	,	395000	},--        coquette2 
{	0xEBC24DF2	,	1500000	},--        swift = 0x
{	0x44C4E977	,	92500	},--        innovat = 
{	0x4B6C568A	,	82000	},--        hakuchou =
{	0xBF1691E0	,	448000	},--        furoregt =
{	0xBE0E6126	,	350000	},--        jester2 = 
{	0xDA5819A3	,	290000	},--        massacro2 
{	0xDCE1D9F7	,	39000	},--        ratloader2
{	0x2B7F9DE3	,	20000	},--        slamvan = 
{	0x85A5B471	,	20000	},--        mule3 = 0x
-- {	0x403820E8	,	1000000	},--    velum2 = 0
-- {	0x74998082	,	1000000	},--    tanker2 = 
{	0x3822BDFE	,	680000	},--        casco = 0x
{	0x1A79847A	,	16000	},--        boxville4 
{	0x39D6E83F	,	3000000	},--        hydra = 0x
{	0x9114EADA	,	675000	},--        insurgent 
{	0x7B7E56F0	,	650000	},--        insurgent2
{	0x11AA0E14	,	18000	},--        gburrito2 
{	0x83051506	,	950000	},--        technical 
-- {	0x1E5E54EA	,	1000000	},--    dinghy3 = 
{	0xFB133A17	,	1950000	},--        savage = 0
{	0x6882FA73	,	48000	},--        enduro = 0
{	0x825A9F4C	,	375000	},--        guardian =
{	0x26321E67	,	750000	},--        lectro = 0
{	0xAE2BFE94	,	95000	},--        kuruma = 0
{	0x187D938D	,	195000	},--        kuruma2 = 
{	0xB527915C	,	35000	},--        trash2 = 0
{	0x2592B5CF	,	450000	},--        barracks3 
{	0xA09E15FD	,	2850000	},--        valkyrie =
{	0x31ADBBFC	,	21000	},--        slamvan2 =

}

	addlisttomenu(getlistfromdb(allcars,'n'), 'normal')
	addlisttomenu(getlistfromdb(allcars,'b'), 'bike')
	addlisttomenu(getlistfromdb(allcars,'s'), 'sport')
	addlisttomenu(getlistfromdb(allcars,'m'), 'muscle')
	addlisttomenu(getlistfromdb(allcars,'v'), 'suv')
	addlisttomenu(getlistfromdb(allcars,'o'), 'off')
	addlisttomenu(getlistfromdb(allcars,'u'), 'util')
	addlisttomenu(getlistfromdb(allcars,'x'), 'xtra')
	addlisttomenu(getlistfromdb(allcars,'c'), 'cycle')
	
	addlisttomenu(newgen, 'new')
	addlisttomenu(dlc, 'dlc')
	
	szgui.menus['main'] = {
	{"General", szgui.gotomenu, 'normal1'},
	{"Bikes", szgui.gotomenu, 'bike1'},
	{"Sport Cars", szgui.gotomenu, 'sport1'},
	{"Muscle Cars", szgui.gotomenu, 'muscle1'},
	{"SUVs", szgui.gotomenu, 'suv1'},
	{"Off-Road", szgui.gotomenu, 'off1'},
	{"Cycles", szgui.gotomenu, 'cycle1'},
	{"Utilities", szgui.gotomenu, 'util1'},
	{"Extras", szgui.gotomenu, 'xtra1'},
	{"New Gen", szgui.gotomenu, 'new1'},
	{"DLC", szgui.gotomenu, 'dlc1'},
	{"Quit", szabocarshop.quit},
	}

	blip = UI.ADD_BLIP_FOR_COORD(-368.1, -101.1, 39.5)
	UI.SET_BLIP_SCALE(blip, 0.8)
	UI.SET_BLIP_COLOUR(blip, 0x9900FFFF)
	-- UI.SET_BLIP_NAME_FROM_TEXT_FILE(blip, "Szabo Car Shop")

end


function szabocarshop.tick()
	
	-- doorcoors: -368.1, -101.1, 39.5
	
	local playerPed = PLAYER.PLAYER_PED_ID()
	local playerCoords = ENTITY.GET_ENTITY_COORDS(playerPed, true)
	local doordist = GAMEPLAY.GET_DISTANCE_BETWEEN_COORDS(playerCoords.x, playerCoords.y, playerCoords.z, -368.1, -101.1, 39.5, true	)
	
	local playerInV = PED.IS_PED_IN_ANY_VEHICLE(playerPed, false)
	
	if (not playerInV and doordist < 1 and not showmenu) then
		showmenu = true
		
	end
	
	if (showmenu) then
		szgui.domagic()
		CONTROLS.DISABLE_ALL_CONTROL_ACTIONS(2)
		CONTROLS.ENABLE_CONTROL_ACTION(2,0,1)
		-- For v10 - use 1 instead of true ^^^^here
		if (playerInV) then
			CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(previewcamrot)
			CAM.SET_GAMEPLAY_CAM_RELATIVE_PITCH(0, 10)
		end
		
		previewcamrot = previewcamrot+2
		if (previewcamrot > 360) then previewcamrot = 0 end
		
	end
	
end

szgui={}
szgui.menus = {}
szgui.curbut = 1
szgui.curmenu = 'main'
szgui.butsstates = {false,false,false,false}
szgui.keysstates = {false,false,false,false}

function szgui.domagic()
						     --	up						down			(accept)enter		(cancel)back  escape [or get_key_pressed(27)]
	local curbutsstates = {get_key_pressed(40), get_key_pressed(38), get_key_pressed(13), get_key_pressed(8)}
	
	local upkey = (curbutsstates[1] and not szgui.butsstates[1]) or CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(2, 187)
	local downkey = (curbutsstates[2] and not szgui.butsstates[2]) or CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(2, 188)
	local acceptkey = (curbutsstates[3] and not szgui.butsstates[3]) or CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(2, 201)
	local cancelkey = (curbutsstates[4] and not szgui.butsstates[4]) or CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(2, 202)
	szgui.butsstates = curbutsstates

	if (upkey and not szgui.keysstates[1]) then szgui.curbut = szgui.curbut+1; szgui.selectcall(szgui.curbut)
	elseif (downkey and not szgui.keysstates[2]) then szgui.curbut = szgui.curbut-1; szgui.selectcall(szgui.curbut)
	elseif (acceptkey and not szgui.keysstates[3]) then	szgui.menus[szgui.curmenu][szgui.curbut][2](szgui.menus[szgui.curmenu][szgui.curbut][3])
	elseif (cancelkey and not szgui.keysstates[4]) then	szgui.menus[szgui.curmenu][#szgui.menus[szgui.curmenu]][2](szgui.menus[szgui.curmenu][#szgui.menus[szgui.curmenu]][3])
	end
	szgui.keysstates = {upkey,downkey,acceptkey,cancelkey}
	
	if (szgui.menus[szgui.curmenu] == nil) then
		szgui.curmenu = 'main'
		szgui.butsstates = curbutsstates
		return 2
	end
	
	if (szgui.curbut > #szgui.menus[szgui.curmenu]) then szgui.curbut=1 elseif szgui.curbut < 1 then szgui.curbut = #szgui.menus[szgui.curmenu] end
	for i,but in ipairs(szgui.menus[szgui.curmenu]) do
		szgui.drawbut(i)
	end

end

function szgui.selectcall(index)
	if (szgui.menus[szgui.curmenu][index] ~= nil and szgui.menus[szgui.curmenu][index][4] ~= nil) then
		szgui.menus[szgui.curmenu][index][4](szgui.menus[szgui.curmenu][szgui.curbut][3])
	end
end

function szgui.gotomenu(menu)
	szgui.curmenu = menu
	szgui.curbut = 1
end

function szgui.drawbut(index)
	local y=index*0.05;local cols = {255,255,255,100}
	if (index == szgui.curbut) then cols = {255,0,0,160} end
	GRAPHICS.DRAW_RECT(0,0.02+y,0.5,0.05, cols[1], cols[2], cols[3], cols[4]);GRAPHICS.DRAW_RECT(0,0.045+y,0.5,0.005, 0, 0, 0, 90);
	UI.SET_TEXT_FONT(0);UI.SET_TEXT_SCALE(0.5, 0.5);UI.SET_TEXT_COLOUR(255, 255, 255, 255);UI.SET_TEXT_WRAP(0, 1);UI.SET_TEXT_CENTRE(false);UI.SET_TEXT_DROPSHADOW(10, 10, 0, 0, 0);UI.SET_TEXT_EDGE(10, 0, 0, 0, 255);UI._SET_TEXT_ENTRY("STRING")
	UI._ADD_TEXT_COMPONENT_STRING(szgui.menus[szgui.curmenu][index][1]);UI._DRAW_TEXT(0, y)
end

return szabocarshop
	
