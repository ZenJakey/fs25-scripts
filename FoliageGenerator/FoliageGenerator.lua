-- Author:ZenJakey
-- Name:FoliageCreator
-- Namespace: local
-- Description:
-- Icon:
-- Hide: no
-- AlwaysLoaded: no
-- Author:KR-Softwares
-- Name:FoliageCreator
-- Description:
-- Icon:
-- Hide: no
-- Date: 04.12.2021

--VARIABLES--
--Path to InfoLayers
local pathFruitDensityGrle = "C:/Users/xxx/path/to/map/data/infoLayer_fruitDensity.grle"
local pathFieldDimensions = "";

-- Set numChannels
local bitsFruitDensityGdm = 10
local bitsFruitDensityGrle = 8
local bitsFieldDimensionsGrle = 8

-- Count of random generation (high value = more random foliages)
local maxFactor = 1000000

-- IMPORTANT NOTE!!
-- Below you can set the foliages. Please enter the decimal value from the yellow-Bits (yellow checkboxes in the GiantsEditor)
-- For example:
--      Foliage Layer: grass
--      State: harvest ready
--  This bits are active: 0,2,7
--  The bit 7 is the only yellow bit! Now calc the decimal value:
--  5->0
--  6->0
--  7->1
--  ->> 100 -> 4 (When you don't know how to calculate bin to dec, check this website: https://manderc.com/concepts/umrechner/index.php


-------------------
--NO CHANGES HERE--
local MODIFIER_GRASS = 1
local MODIFIER_DECOFOLIAGE = 2
--local MODIFIER_GROUNDFOLIAGE = 3
local MODIFIER_MEADOW = 4
local MODIFIER_DECOBUSH = 5
local MODIFIER_STONE = 6
local MODIFIER_FOREST_PLANTS = 7
-------------------

local generatorData = {
{
    name = "Grass", -- name of Channel (name is not importing)
    grleValue = 1, -- value of option of group of infolayer
    textureLayer = 104, -- Set Layer. LayerIDs see under CombinedLayers above (-1 for deactive)
    undergroundFoliage = 4, -- Set bit of the groundfoliage (is planting on the fill painted layer) (-1 for deactive)
    undergroundFoliageModifier = MODIFIER_GRASS, -- Set the modifier of the undergroundFoliage (foliageLayer)
    factorLimit = 1000000, -- Decrease this value, when you want a lower maxFactor for this entry
    randomFoliages = { -- Here you can set your different foliages who is generate randomly on the painted layer.
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 5 }, -- Set the modifier and the foliage-bit. You can define differents foliages with dublicate this line.
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 5 }, -- Tip: If you want more from foliage 5 as from 3, then you can add foliage multiple times.
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 3 },
    },
},
{
    name = "GrassDeco",
    grleValue = 2,
    textureLayer = 104,
    undergroundFoliage = 4,
    undergroundFoliageModifier = MODIFIER_GRASS,
    factorLimit = 800000,
    randomFoliages = {
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 5 },
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 3 },
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 2 },
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 4 },
        { modifier = MODIFIER_DECOBUSH, foliage = 1 },
    },
},
{
    name = "Forest",
    grleValue = 3,
    textureLayer = 102,
    undergroundFoliage = -1,
    undergroundFoliageModifier = -1,
    factorLimit = 1000000,
    randomFoliages = {
        { modifier = MODIFIER_DECOFOLIAGE, foliage = 5 },
        { modifier = MODIFIER_FOREST_PLANTS, foliage = 1 },
        { modifier = MODIFIER_FOREST_PLANTS, foliage = 8 },
        { modifier = MODIFIER_DECOBUSH, foliage = 3 },
        { modifier = MODIFIER_DECOBUSH, foliage = 1 },
        { modifier = MODIFIER_MEADOW, foliage = 3 },
    },
},
}

-------------------
--NO CHANGES HERE--
-------------------

--Terrain
local terrain = getChild(getRootNode(), "terrain")
local terrainSize = getTerrainSize(terrain)

--Load GRLE
local grle = createBitVectorMap("FruitDensity")
if not loadBitVectorMapFromFile(grle, pathFruitDensityGrle, bitsFruitDensityGrle) then
    print("Can't load file!")
    return;
end;
local localGrleWidth, localGrleHeight = getBitVectorMapSize(grle);

--Load GDM
local id_grass = getTerrainDataPlaneByName(terrain, "grass")
local id_decoFoliage = getTerrainDataPlaneByName(terrain, "decoFoliage")
--local id_groundFoliage = getTerrainDataPlaneByName(terrain, "groundFoliage")
local id_meadow = getTerrainDataPlaneByName(terrain, "meadow")
local id_decoBush = getTerrainDataPlaneByName(terrain, "decoBush")
local id_stonde = getTerrainDataPlaneByName(terrain, "stone")
local id_forest = getTerrainDataPlaneByName(terrain, "forestPlants")

print(id_grass .. " " .. id_decoFoliage .. " " .. id_meadow .. " " .. id_decoBush .. " " .. id_stonde .. " " .. id_forest)



local modifier_grass = DensityMapModifier.new(id_grass, 0, 4)
local modifier_decoFoliage = DensityMapModifier.new(id_decoFoliage, 0, 4)
--local modifier_groundFoliage = DensityMapModifier.new(id_groundFoliage, 0, bitsFruitDensityGdm)
local modifier_meadow = DensityMapModifier.new(id_meadow, 0, 4)
local modifier_decoBush = DensityMapModifier.new(id_decoBush, 0, 4)
local modifier_forestPlants = DensityMapModifier.new(id_forest, 0, 4)
local modifier_stone = DensityMapModifier.new(id_stonde, 0, 3)
--Load fieldDimensions
--local fieldDim = createBitVectorMap("FieldDefs");
--local useFieldDim = loadBitVectorMapFromFile(fieldDim, pathFieldDimensions, bitsFieldDimensionsGrle);

function createRandomParallelogram(size, randomSize)
    local height = size
    local width = size
    if randomSize then
        height = math.abs(2 * math.random() - 1) * size
        size = math.abs(2 * math.random() - 1) * size
    end
    local startWorldX = (2 * math.random() - 1) * terrainSize / 2       
    local startWorldZ = (2 * math.random() - 1) * terrainSize / 2
    local widthWorldX = startWorldX + width +  (2 * math.random() - 1) * size
    local widthWorldZ = startWorldZ + (2 * math.random() - 1) * size
    local heightWorldX = startWorldX + (2 * math.random() - 1) * size
    local heightWorldZ = startWorldZ + height + (2 * math.random() - 1) * size
    return startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ
end

function getModifierById(id)
    if id == MODIFIER_GRASS then
        return modifier_grass
    elseif id == MODIFIER_DECOFOLIAGE then
        return modifier_decoFoliage
    elseif id == MODIFIER_GROUNDFOLIAGE then
        return modifier_groundFoliage
    elseif id == MODIFIER_MEADOW then
        return modifier_meadow
    elseif id == MODIFIER_DECOBUSH then
        return modifier_decoBush
    elseif id == MODIFIER_STONE then
        return modifier_stone
    elseif id == MODIFIER_FOREST_PLANTS then
        print(modifier_forestPlants == nil)
        return modifier_forestPlants
    end
end

function getTableLength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function setValue(modifier, value, sx, sz, wx, wz, hx, hz)
    modifier:setParallelogramUVCoords(sx / terrainSize + 0.5, sz / terrainSize + 0.5, wx / terrainSize + 0.5, wz / terrainSize + 0.5, hx / terrainSize + 0.5, hz / terrainSize + 0.5, DensityCoordType.POINT_POINT_POINT)
    modifier:executeSet(value)
end

local localMapWidth = 0
if useFieldDim then
    localMapWidth, _ = getBitVectorMapSize(fieldDim)
end

local mapGrleFactor = terrainSize /localGrleHeight
local edges = localGrleHeight / 2
for z = 0, localGrleHeight - 1 do
    for x = 0, localGrleWidth - 1 do
        local bitValue = getBitVectorMapPoint(grle,x, z, 0, bitsFruitDensityGrle)   
        if bitValue > 0 then
            local canSet = true 
            
            local posX = (x - edges) * mapGrleFactor
            local posZ = (z - edges) * mapGrleFactor
            local posY = getTerrainHeightAtWorldPos(terrain, posX + 0.5, 0, posZ + 0.5)

            for _,data in pairs(generatorData) do
                if canSet then
                    --paint layer
                    if data.textureLayer ~= -1 and bitValue == data.grleValue then
                        setTerrainLayerAtWorldPos(terrain, data.textureLayer, posX + 0.5, posY, posZ + 0.5, 128.0)
                    end

                    --plant foliage
                    if data.undergroundFoliage ~= -1 and bitValue == data.grleValue then
                        setValue(getModifierById(data.undergroundFoliageModifier), data.undergroundFoliage, posX, posZ, posX+1, posZ, posX, posZ+1) 
                    end
                end   
            end    
        end            
    end
end

local grleMapFactor = localGrleHeight / terrainSize
local edgesRandom = terrainSize / 2
--Do random foliage
for i=1,maxFactor do
    local sx, sz, wx, wz, hx, hz = createRandomParallelogram(1, true)

    local grleX = (sx + edgesRandom) * grleMapFactor
    local grleZ = (sz + edgesRandom) * grleMapFactor

    local bitValue = getBitVectorMapPoint(grle, grleX, grleZ, 0, bitsFruitDensityGrle)
   

    if bitValue ~= nil and bitValue > 0 then
        if true then

            for _,data in pairs(generatorData) do
                if data.randomFoliages ~= nil then
                    local numRandomFoliages = getTableLength(data.randomFoliages)
                    if bitValue == data.grleValue and i < data.factorLimit and numRandomFoliages > 0 then
                        local randomFoliage = data.randomFoliages[math.random(1, numRandomFoliages)]
                        print(getModifierById(randomFoliage.modifier))
                        setValue(getModifierById(randomFoliage.modifier), randomFoliage.foliage, sx, sz, wx, wz, hx, hz)
                    end
                end
            end
        end
    end
  

end

print("Foliage created!")