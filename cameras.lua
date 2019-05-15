

--[[ 

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

			C A M E R A S
	 

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
 
** Usage: 
Add this file to mod root, and this to your control.lua events:

require "cameras"

cam_on_init() ==>  on_init / on_changed
cam_on_tick(event) ==>  on_tick 
cam_on_gui_click(event) ==>  on_gui_click 


** Create cameras with:
CreateCameraForConnectedPlayers(Object,Text,size,seconds,Zoom)
CreateCameraForForce(Force,Object,Text,size,seconds,Zoom)
CreateCameraForPlayer(player,Object,Text,size,AutoCloseTick,Zoom)


Parameters:
Object = may be an entity or a fixed position. If entity is a unit, camera will follow its position
Text = nil or {text='Camera', color={r=1,g=1,b=1}}
size = camera size
AutoCloseTick = when it will be closed in game.tick
Zoom = Camera Zoon
]]


--## CAMERAS

-- Object may be an entity or a fixed position, if entity, camera will follow it
function CreateCameraForPlayer(player,Object,Text,size,AutoCloseTick,Zoom)
if Zoom==nil then Zoom=0.5 end
local tick=game.tick
local guileft
if not player.gui.left.mf_flow_cameras then
   guileft = player.gui.left.add({type="flow", name="mf_flow_cameras", direction="horizontal"})
   else
   guileft = player.gui.left.mf_flow_cameras end
   guileft.style.horizontally_stretchable = false

while guileft["mf_framecam"..tick] do
	  tick=tick+1
      end
local frname="mf_framecam"..tick
local frame = guileft.add({ type="frame", name=frname, direction="vertical"})   
	frame.style.horizontally_stretchable = false
	--frame.style.minimal_height = size+55
  	--frame.style.maximal_height = size+55
	--frame.style.minimal_width = size+10
	--frame.style.maximal_width = size+10

local position
if Object and Object.valid and Object.position then
	position=Object.position 
	local tabdata = {camframe=frame,tick=tick, entity=Object,autoclosetick=AutoCloseTick}
	table.insert(global.mf_frame_cameras,tabdata)
	else 
	local tabdata = {camframe=frame,tick=tick, entity=nil,autoclosetick=AutoCloseTick}
	table.insert(global.mf_frame_cameras,tabdata)
	position=Object 
	end 

local Capt = 'Camera'
if Text and Text.text then Capt = Text.text end

local tab   = frame.add{type = "table", column_count = 2} 
local closeb = tab.add{name="mf_bt_cameraclose"..tick, type="button", style = mod_gui.button_style, caption="X"}
local title = tab.add{type = "label", caption = Capt}

title.style.font = "default-bold"
if Text and Text.color then title.style.font_color = Text.color  end

local cam = frame.add({ type="camera", name="mf_camera"..tick, position = position, zoom = Zoom })
      cam.style.width = size
	  cam.style.height = size

end


function CreateCameraForConnectedPlayers(Object,Text,size,seconds,Zoom)
local AutoCloseTick
if seconds then AutoCloseTick = game.tick + seconds*60 end
if size==nil then size=210 end
	for p, pl in pairs(game.connected_players) do
			CreateCameraForPlayer(pl,Object,Text,size,AutoCloseTick,Zoom) 
		end
end

function CreateCameraForForce(Force,Object,Text,size,seconds,Zoom)
local AutoCloseTick
if seconds then AutoCloseTick = game.tick + seconds*60 end
if size==nil then size=210 end
	for p, pl in pairs(Force.connected_players) do
		CreateCameraForPlayer(pl,Object,Text,size,AutoCloseTick,Zoom) 
		end
end


function CloseAllCameras()
if #global.mf_frame_cameras>0 then
	for K,tabdata in pairs (global.mf_frame_cameras) do
		local frame = tabdata.camframe
		if frame and frame.valid then frame.destroy() end
		end
	global.mf_frame_cameras = {}
	end
end


function CloseAllCamerasForPlayer(player)
if #global.mf_frame_cameras>0 then
	for K,tabdata in pairs (global.mf_frame_cameras) do
		local frame = tabdata.camframe
		if player==frame.gui.player then
			if frame and frame.valid then frame.destroy() end end
		end
	global.mf_frame_cameras = {}
	end
end

-- Gui click
function CameraClose(player,num)
if player.gui.left.mf_flow_cameras then
if player.gui.left.mf_flow_cameras["mf_framecam"..num] then
   player.gui.left.mf_flow_cameras["mf_framecam"..num].destroy() 
   end end
end


-- ************  EVENTS ********************************


function cam_on_gui_click(event)
local player = game.players[event.element.player_index]
local name = event.element.name
	if string.sub(name,1,17)=="mf_bt_cameraclose" then
		CameraClose(player,string.sub(name,18,string.len(name)))
		end
end


--#Camera Updates
function cam_on_tick(event)
if #global.mf_frame_cameras>0 then
local kill=false
	for K,tabdata in pairs (global.mf_frame_cameras) do
	
		local frame = tabdata.camframe
		local tick  = tabdata.tick
		local entity= tabdata.entity
		local autoclosetick  = tabdata.autoclosetick
		if frame and frame.valid then 
			if entity and entity.valid then
				frame["mf_camera"..tick].position = entity.position end
			if autoclosetick and autoclosetick<game.tick then kill=true end
			else kill=true end
		if kill then 
			if frame and frame.valid then frame.destroy() end
			table.remove(global.mf_frame_cameras,K) 
			end
		end
	end
end


function cam_on_init()
if not global.mf_frame_cameras  then global.mf_frame_cameras = {} end
end

