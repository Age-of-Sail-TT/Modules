local MAIN = {
	pending = {}
	}

local function addPreLocation(key,orgX,orgY)
  local p = MAIN.pending
  p.key = key
  p.orgX = orgX
  p.orgY = orgY
  City.createDraftDrawer("$aos_trainstation_destination_selector00").select()
end

local function getValues()
  local p = MAIN.pending
  return p.key, p.orgX, p.orgY
end


local function transferToStorage()
  local stg =  City.getStorage()['[AoS]Train_Station']
  local p = MAIN.pending
  if #p > 0 then
    stg[p.key] = {orgX = p.orgX, orgY = p.orgY, targetX = p.tX, targetY = p.tY, schedule = p.sched}
  else
    Debug.toast('failed')
  end
end

local function removeUndefinedStation()
  local stg =  City.getStorage()['[AoS]Train_Station']
  if #stg > 0 then
    for k,_ in pairs(stg) do
      if Tile.isBuilding(k.orgX,k.orgY) and (Tile.getBuildingDraft(k.orgX,k.orgY):getId() ~= '$railwaystationAos01' or Tile.getBuildingDraft(k.orgX,k.orgY):getId() ~= '$railwaystationAos02') then
        stg[k] = nil
      elseif not(Tile.isBuilding(k.orgX,k.orgY)) then
        stg[k] = nil
      end
    end
  end
end

MAIN.addPreLocation = addPreLocation
MAIN.getValues = getValues
MAIN.transferToStorage = transferToStorage
MAIN.removeUndefinedStation = removeUndefinedStation

return MAIN