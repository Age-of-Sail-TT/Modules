local Aos = require("../modules/aos.utilities.mdl.lua")

local Defense = {
	version = "resources defense system ver1.4.0",
	author = "Christian Roldan (Hadestia)"
	--legacy defenses = {}
	}

-- ----------------------------
--  Variable
-- ----------------------------

local defenses = Defense["defenses"]

-- ----------------------------
--  Tile
-- ----------------------------

local function isBlg(x, y)
  return Tile and Tile.isBuilding(x, y)
end

local function tileDraft(x, y)
  return Tile and Tile.getBuildingDraft(x, y)
end

local function tileWater(x, y)
  return Tile and Tile.isWater(x,y)
end

local function tileLand(x, y)
  return Tile and Tile.isLand(x, y)
end

-- ----------------------------
--  Weapon
-- ----------------------------

--  Enemy

local function underSiege()
  if (City.countBuildings(Draft.getDraft("$YourTownIsInRaid0")) > 0 or City.countBuildings(Draft.getDraft("AosEnemyTile00")) > 0) then return true end
  return false
end

local function isEnemyXY(enemy, x, y)
  for _,v in pairs(enemy) do
    if isBlg(x, y) and tileDraft(x, y):getId() == v then
      return true
    end
  end
  return false
end

--  Accuracy

local function isAccurate(rate)
  local scale = math.random(1,100)
  return scale <= rate
end

--  FX

local function miss(le, we, x, y)
  local neighborTiles = Util.collectRectTiles(x - 1, y - 1, 3, 3)
  local pick = neighborTiles:pick()
  
 --[[ local xx, yy; np = math.random(-1,1); xy = math.random(1,2)
  if xy == 1 then
    yy = y + np; xx = x
  else
    xx = x + np; yy = y
  end]]
  if tileLand(x, y) then
    if le ~= nil then Builder.buildBuilding(le, pick.x, pick.y) end
  elseif tileWater(x, y) then
    if we ~= nil then Builder.buildBuilding(we, pick.x, pick.y) end
  end
end

--  Shoot

local function shoot(x, y)
  Builder.remove(x, y)
end

local function shootFx(le, we, x, y)
  Builder.remove(x, y)
  if le ~= nil and we ~= nil then
    if tileLand(x, y) then
      Builder.buildBuilding(le, x, y)
      if math.random() > 0.5 then City.playSound(Draft.getDraft("$aos_sfx_shiphit"), x, y, 1.0, false) else City.playSound(Draft.getDraft("$aos_sfx_artillerycannon"), x, y, 1.0, false) end
    elseif tileWater(x, y) then
      Builder.buildBuilding(we, x, y)
      if math.random() > 0.5 then City.playSound(Draft.getDraft("$aos_sfx_shiphit"), x, y, 1.0, false) else City.playSound(Draft.getDraft("$aos_sfx_artillerycannon"), x, y, 1.0, false) end
    end
  end
end

--  Frames

local function setFrame(x,y,frame)
  return Tile.setBuildingFrame(x,y,frame)
end

local function posSetFrame(x,y,frame,ms)
  Runtime.postpone(function() Tile.setBuildingFrame(x,y,frame) end, ms or 1500)
end
--  Ammunition

local function isReloaded(x,y,sf,key)
  local stg = Tile.getBuildingStorage(x,y)[key]
  local sec = stg.reload * 1000
  if not stg.running then
    stg.running = true
    setFrame(x,y,sf)
    
    if not(stg.class==3) then
      Runtime.postpone(function()
        setFrame(x,y,stg.defaultFrame)
      end, 2000)
    end
    
    Runtime.postpone(function()
      stg.running = false
    end, sec)
    
    return true
  end
  return false
end

local function haveAmmo(cb, gp)
  if Aos.onTown() then
    local resources = Aos.getStorage('resources')
    if resources.cannonball >= cb and resources.gunpowder >= gp then
      resources.cannonball = resources.cannonball - cb
      resources.gunpowder = resources.gunpowder - gp
      resources = nil
      return true
    end
  end
  return false
end

-- ----------------------------
--  Available function
-- ----------------------------

Defense.underSiege = underSiege

Defense.isEnemyXY = isEnemyXY
Defense.isAccurate = isAccurate
Defense.isReloaded = isReloaded

Defense.haveAmmo = haveAmmo

Defense.shootFx = shootFx
Defense.miss = miss

Defense.setFrame = setFrame

return Defense