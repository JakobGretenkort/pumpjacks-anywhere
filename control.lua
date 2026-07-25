local surface_resources = {
    ["nauvis"] = "hidden-water-resource",
    ["vulcanus"] = "hidden-lava-resource",
    ["gleba"] = "hidden-water-resource",
    ["fulgora"] = "hidden-heavy-oil-resource",
    ["aquilo"] = "hidden-ammoniacal-solution-resource"
}

local function is_placed_on_resource(entity)
    local surface = entity.surface

    local resources = surface.find_entities_filtered{
        type = "resource",
        position = entity.position
    }

    for _, res in pairs(resources) do
        if res.prototype.resource_category == "basic-fluid" then
            if res.position.x == entity.position.x and res.position.y == entity.position.y then
                return true
            end
        end
    end

    return false
end

local function spawn_resource(entity)
    local surface = entity.surface

    local resource_name = surface_resources[surface.name]
    if not resource_name then return end

    surface.create_entity{
        name = resource_name,
        position = entity.position,
        force = entity.force
    }

    -- Bugfix: Because the resource spawns after the jack is placed,
    -- it gets stuck in a 'no minable resources' status.
    -- Moving the pumpjack to its own position fixes this problem
    entity.teleport(entity.position)
end

local function remove_resource(entity)
    local surface = entity.surface

    local resources = surface.find_entities_filtered{
        type = "resource",
        position = entity.position
    }

    for _, resource in pairs(resources) do
        if resource.name:find("^hidden") then
            resource.destroy()
        end
    end
end

-- Triggered when a pumpjack is placed by a player, robot, or script
local function on_entity_built(event)
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if entity.name ~= "pumpjack" then return end

    if not is_placed_on_resource(entity) then
        spawn_resource(entity)
    end
end

-- Triggered when a pumpjack is mined or destroyed
local function on_entity_removed(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    if entity.name ~= "pumpjack" then return end

    remove_resource(entity)
end

-- Register all relevant build events
local build_events = {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive
}

for _, event_id in ipairs(build_events) do
    script.on_event(event_id, on_entity_built)
end

-- Register all relevant removal events
local remove_events = {
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_entity_died,
    defines.events.script_raised_destroy
}

for _, event_id in ipairs(remove_events) do
    script.on_event(event_id, on_entity_removed)
end