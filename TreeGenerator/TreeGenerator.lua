-- Author:ZenJakey
-- Name:TreeGenerator
-- Namespace: local
-- Description:
-- Icon:
-- Hide: no
-- AlwaysLoaded: no
-- Author:kevink98 / LS-Modcompany
-- Name:TreeCreator
-- Description: Full documentation on github
-- Icon:
-- Hide: no

----------------
-- how to use --
----------------

-- Youtube link: https://www.youtube.com/watch?v=GDMGusGCPJk


--VARIABLES--
--Path
local pathFruitDensityGrle = "C:/Users/dabos/Documents/My Games/FarmingSimulator2025/mods/FS25_auto_gen/map/data/infoLayer_treegen.grle"
local pathFieldDimensions = "";

--Bits
local bitsFruitDensityGrle = 8
local bitsFieldDimensionsGrle = 8

local channels = {
    {
        name = "DenseForest", -- must match Transform Group name in root -> trees -> Tree Templates
        grleValue = 1, -- must match desired infoLayer option 'value'
        factor = 100000, -- how dense trees should be
        treeRadius = 0.5, -- how close trees can be together
    },
    {
        name = "Forest",
        grleValue = 2,
        factor = 75000,
        treeRadius = 0.5,
    },
    {
        name = "LowDensity",
        grleValue = 3,
        factor = 30000,
        treeRadius = 0.75,
    },
}

-------------------
--NO CHANGES HERE--
-------------------

--Terrain
local rootNode = getRootNode()
local terrain = getChild(rootNode, "terrain")
local terrainSize = getTerrainSize(terrain)
--Load GRLE
local grle = createBitVectorMap("FruitDensity")
if not loadBitVectorMapFromFile(grle, pathFruitDensityGrle, bitsFruitDensityGrle) then
    print("Can't load file!")
    return;
end;

--Load fieldDimensions
local fieldDim = createBitVectorMap("FieldDefs");
local useFieldDim = false

--Function from Seasonsmod - Create a random parallelogram
function createRandomPosition()
    local h1 = math.random(-terrainSize/2, terrainSize/2)
    local l1 = math.random(1, 9)
    local h2 = math.random(-terrainSize/2, terrainSize/2)
    local l2 = math.random(1, 9)
        
    local x = h1 + l1 * 0.1
    local z = h2 + l2 * 0.1
    local y = getTerrainHeightAtWorldPos(terrain, x, 0, z)
    
    return  x,y,z
end

local localMapWidth = 0
if useFieldDim then
    localMapWidth, _ = getBitVectorMapSize(fieldDim)
end

local parentTg = getChild(rootNode, "trees")
local templatesTg = getChild(parentTg, "TreeTemplates")

local allTrees = {}

function canPlaceTree(x,z,radius)
    for _,tree in pairs(allTrees) do
        local dx = math.abs(x - tree.x)
        local dz = math.abs(z - tree.z)
        if math.sqrt(dx*dx - dz*dz) < radius then
            return false
        end
    end
    return true
end

function moveToTerrain(node)
    local mID = node
        --print( string.format("id == %i name == %s",mID,getName(mID) ));
        local mPosX, mPosY, mPosZ = getWorldTranslation(mID);
        --print( string.format("x = %f y =%f z=%f",mPosX,mPosY,mPosZ) );
        local mHeight = getTerrainHeightAtWorldPos(terrain,mPosX, mPosY, mPosZ );
        --print(string.format("h = %f",mHeight) );
        mPosX, mPosY, mPosZ = worldToLocal(mID,mPosX, mHeight, mPosZ);
        --print( string.format("x = %f y =%f z=%f",mPosX,mPosY,mPosZ) );
        local mLocPosX, mLocPosY, mLocPosZ = getTranslation(mID);
        --print( string.format("x = %f y =%f z=%f",mLocPosX,mLocPosY,mLocPosZ) );
        local mNewPosY = mLocPosY + mPosY;
        --print( string.format("Y == %f",mNewPosY));
        setTranslation(mID,mLocPosX,mNewPosY,mLocPosZ);
end
for i in channels do
    local startTreeCount = #allTrees
    local channel = channels[i]
    print("Processing channel " .. channel.name .. ".")
    local name = channel.name
    local useBit = channel.grleValue
    print("    grle value: " .. useBit)
    local factor = channel.factor
    print("    factor: " .. factor)
    local radius = channel.treeRadius
    print("    radius: " .. radius)
    local templateTg = getChild(templatesTg, name)
    print("    templateTg: " .. templateTg)
    if templateTg ~= 0 then
        local numTemplates = getNumOfChildren(templateTg)
        for i=1,factor do
            local x, y, z = createRandomPosition()
            local value = getBitVectorMapPoint(grle, x + terrainSize/2, z + terrainSize/2, 0, bitsFruitDensityGrle)
            local canSet = true
            if canSet and value == useBit and canPlaceTree(x,z,radius) then
                local templateNum = math.random(0, numTemplates-1)
                local newTree = clone(getChildAt(templateTg, templateNum), false, true)
                link(parentTg, newTree)
                local yRot = math.random( ) * 2 * math.pi
                setTranslation(newTree, x,y,z)
                setRotation(newTree, 0, yRot, 0)
                moveToTerrain(newTree)
                table.insert(allTrees, {x=x, z=z})
            end
        end
    end
    local treesPlanted = #allTrees - startTreeCount
    print("    " .. name .. " had " .. treesPlanted .. " trees planted.")
end
print(#allTrees .. " Trees created!")