# O que está sendo substituído no Roblox (pesquisa até 30/10/2026)

- **Compatibility Lighting** foi descontinuado: Roblox migrou para iluminação Voxel + Retro Tone Mapping. O antigo aviso de migração do Studio não indica bug do RoMoo. Fonte: https://devforum.roblox.com/t/compatibility-lighting-becomes-retro-tone-mapping-sunset-migration/3128560
- **Lighting.Technology** está sendo substituído por `Lighting.LightingStyle` e `PrioritizeLightingQuality`; não usar configurações antigas de Legacy/Compatibility. Fonte: https://create.roblox.com/docs/reference/engine/enums/Technology
- **Água antiga** foi migrada para a tecnologia Shorelines; o RoMoo usa `Terrain` com `Enum.Material.Water`, e não água legada. Fonte: https://devforum.roblox.com/t/migration-to-shorelines-and-old-water-deprecation/3007235
- **APIs antigas de voxel** (`Terrain:SetCell`, `GetCell`, `AutowedgeCell`) são deprecated; usar `FillBlock`, `FillBall` e APIs modernas de voxel. Fonte: https://create.roblox.com/docs/reference/engine/classes/Terrain
- **InsertService:LoadAsset** ainda existe, mas `AssetService:LoadAssetAsync` é o caminho atual para obter modelos de terceiros. Esta API exige as permissões da experiência para carregar assets livres de terceiros. Fonte: https://create.roblox.com/docs/reference/engine/classes/AssetService
- **Inventário da Toolbox**: usuários estão sendo orientados a usar o Asset Manager; isso não significa que a Creator Store inteira será encerrada. Fonte de contexto (discussão de criadores, não anúncio formal de fechamento): https://devforum.roblox.com/t/merge-toolbox-into-the-asset-manager/4955844
- **Terrain scattering** e **path splines** anunciados em setembro de 2026 estão em roadmap/early access. Não assumir que já estão disponíveis para todos; usamos geração controlada por Luau. Fonte: https://devforum.roblox.com/t/creator-roadmap-2026-fall-update/4880208

**Decisões de engenharia:** preferir `Terrain`, `AssetService` (quando assets autorizados), R15/Avatar normal, modelos 3D sem scripts de terceiros e física replicada com validação pelo servidor.
