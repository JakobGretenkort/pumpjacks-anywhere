-- Allow pumpjacks to be placed anywhere
local pumpjack = data.raw["mining-drill"]["pumpjack"]
if pumpjack then
    pumpjack.require_resources_to_place = false
end

-- Helper function to define hidden infinite resources
local function create_hidden_fluid(resource_name, fluid_name)
    local res = table.deepcopy(data.raw.resource["crude-oil"])
    res.name = resource_name

    -- It does not generate naturally
    res.autoplace = nil

    -- It is invisible
    res.hidden = true
    res.hidden_in_factoriopedia = true
    res.selectable_in_game = false
    res.flags = {"placeable-neutral", "not-on-map", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-in-mined-by"}

    -- It is infinite and does not deplete
    res.minable.results = {{type = "fluid", name = fluid_name, amount = 60}}
    res.infinite = true
    res.minimum = 100000
    res.normal = 100000
    res.infinite_depletion_amount = 0

    -- Clear all graphics so the resource patch is completely invisible
    local empty_animation = {
        filename = "__core__/graphics/empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
        frame_count = 1,
        variation_count = 1
    }
    res.stages = empty_animation
    res.stage_counts = {0}

    return res
end

data:extend({
    create_hidden_fluid("hidden-water-resource", "water"),
    create_hidden_fluid("hidden-lava-resource", "lava"),
    create_hidden_fluid("hidden-heavy-oil-resource", "heavy-oil"),
    create_hidden_fluid("hidden-ammoniacal-solution-resource", "ammoniacal-solution")
})