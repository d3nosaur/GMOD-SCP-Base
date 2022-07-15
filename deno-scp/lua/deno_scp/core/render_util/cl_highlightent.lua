local highlightedEntities = {}

local function DrawHighlightedEntities()
    if table.IsEmpty(highlightedEntities) then
        hook.Remove("PostDrawOpaqueRenderables", "D_SCP_HighlightEntities")
    end

    for color, entities in pairs(highlightedEntities) do
        render.SetStencilWriteMask( 0xFF )
        render.SetStencilTestMask( 0xFF )
        render.SetStencilReferenceValue( 0 )
        render.SetStencilCompareFunction( STENCIL_ALWAYS )
        render.SetStencilPassOperation( STENCIL_KEEP )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.ClearStencil()

        render.SetStencilEnable(true)
        render.SetStencilCompareFunction( STENCIL_NEVER )
        render.SetStencilFailOperation( STENCIL_REPLACE )

        render.SetStencilReferenceValue( 1 )
        render.SetStencilWriteMask( 1 )

        for ent, _ in pairs(entities) do
            if IsValid(ent) then
                ent:DrawModel()
            else
                highlightedEntities[color][ent] = nil
            end
        end

        render.SetStencilTestMask(1)
        render.SetStencilReferenceValue( 1 )
        render.SetStencilCompareFunction( STENCIL_EQUAL )
        render.ClearBuffersObeyStencil( color.r, color.g, color.b, color.a or 255, false )
        
        render.SetStencilEnable(false)
    end
end

render.HighlightEntity = function(entity, enabled, color)
    color = color or Color(255, 255, 255, 255)

    if not entity then return end

    if not enabled and highlightedEntities[color] and highlightedEntities[color][entity] then
        highlightedEntities[color][entity] = nil
        
        if table.IsEmpty(highlightedEntities[color]) then
            highlightedEntities[color] = nil
        end

        return
    end

    if table.IsEmpty(highlightedEntities) then
        highlightedEntities[color] = {}
        highlightedEntities[color][entity] = true

        hook.Add("PostDrawOpaqueRenderables", "D_SCP_HighlightEntities", DrawHighlightedEntities)
        return
    end

    for color, entities in pairs(highlightedEntities) do
        if entities[entity] then
            highlightedEntities[color][entity] = nil
        end
    end

    highlightedEntities[color] = highlightedEntities[color] or {}
    highlightedEntities[color][entity] = true
end