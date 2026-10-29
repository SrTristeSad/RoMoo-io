# Importar os animais 3D (CC0) no RoMoo io

Os **arquivos 3D reais** já estão armazenados em `assets/animals/` no repositório. Eles não são apenas links e podem ser baixados com o código do projeto.

| Animal | Arquivo | Origem/autor | Licença |
| --- | --- | --- | --- |
| Vaca | `Cow.gltf` | Quaternius, Ultimate Animated Animal Pack | CC0 1.0 |
| Touro | `Bull.gltf` | Quaternius, Ultimate Animated Animal Pack | CC0 1.0 |
| Lobo | `Wolf.gltf` | Quaternius, Ultimate Animated Animal Pack | CC0 1.0 |
| Ovelha | `Sheep.fbx` | Quaternius, Farm Animal Pack | CC0 1.0 |

Fontes oficiais:
- https://quaternius.com/packs/ultimateanimatedanimals.html
- https://quaternius.com/packs/farmanimal.html
- https://creativecommons.org/publicdomain/zero/1.0/

Cópias de transporte dos arquivos recuperadas de repositórios públicos:
- Cow.gltf, Bull.gltf e Wolf.gltf: https://github.com/benjaminpjones/catch-the-animal/tree/main/models/glTF
- Sheep.fbx: https://github.com/Dewflash/isekai-leveling/tree/main/assets/sourced/quaternius-farm-animals

O Quaternius informa CC0 para esses **pacotes específicos**. A versão mais recente de sua licença geral é diferente, portanto mantenha estas referências de origem para auditoria futura. Não redistribuir imagens de divulgação ou conteúdos adicionais que não sejam parte dos modelos CC0.

## Passos no Roblox Studio

1. Faça download do repositório RoMoo-io (ZIP no GitHub) ou use `git clone https://github.com/SrTristeSad/RoMoo-io.git`.
2. Abra o place do jogo usando Rojo. Certifique-se de estar no modo de **edição**, não no Play.
3. No Roblox Studio, clique **Arquivo > Importar** (ou Import 3D) e selecione primeiro `assets/animals/Cow.gltf`.
4. Confirme a importação e verifique o modelo (por vezes o importador cria uma hierarquia de Models dentro de Models).
5. No Explorer, abra `ServerStorage`. Crie uma pasta chamada exatamente `RoMooAnimalModels`.
6. Arraste o `Model` importado da Workspace para essa pasta e renomeie o Model externo para `Cow`.
7. Repita o processo para `Bull.gltf` → `Bull`, `Wolf.gltf` → `Wolf` e `Sheep.fbx` → `Sheep`.
8. Clique **Play**. O servidor procura os Model templates no ServerStorage e exibe essas malhas em lugar dos protótipos de partes.

**Atenção:** importa-se o arquivo no Studio para gerar as malhas com IDs do Roblox. Apenas deixar o .gltf/.fbx na pasta do GitHub NÃO disponibiliza automaticamente as malhas dentro do place. A importação no Studio ainda é uma etapa manual e pode exigir que o usuário publique a experiência e passe pela moderação de assets.

Se alguma malha não carregar ou tiver problema de proporção, o sistema mantém os animais simples como fallback. Se os animais estiverem virados de costas, ajuste a orientação dos Model templates em ServerStorage. O código escala os modelos para até aproximadamente 8–10 studs, sem alterar os arquivos de origem.

As **animações de esqueleto** dos modelos fonte não são executadas automaticamente no MVP; é necessário importá-las/publicá-las e configurar as tracks em uma etapa posterior. A IA de movimento e combate já existe nos scripts do servidor.

## Referência oficial Roblox

https://create.roblox.com/docs/studio/importer

O importador aceita FBX, OBJ e glTF e suporta malhas com rigging/animações. Depois da importação, o Roblox associa IDs próprios às malhas.

## Verificação do repositório

Arquivos fonte esperados (git blob SHA):
- Cow.gltf: `f90a67b34818693e418c1cf6ae5c9565ec1d90fc`
- Bull.gltf: `2c501bc7f6d6237322206db027e4b7fb41eace37`
- Wolf.gltf: `36f718eabfc65c25c971acfd3ef73b5fcc3fc7b9`
- Sheep.fbx: `4ee5ad12550dda6896a86e9d67ea637ac9897791`
