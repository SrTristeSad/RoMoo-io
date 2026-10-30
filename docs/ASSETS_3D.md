# RoMoo-io — Assets 3D reais (natureza e animais)

## O que entrou nesta versao

| Tipo | Arquivos em `assets/nature/` |
| --- | --- |
| Arvores | `tree-default.glb`, `tree-oak.glb`, `tree-cone.glb`, `tree-pinetalla.glb` |
| Rochas | `rock-largea.glb`, `rock-largeb.glb` |
| Arbustos | `plant-bushlarge.glb`, `plant-bushdetailed.glb` |
| Cactos | `cactus-tall.glb`, `cactus-short.glb` |

Autor: **Kenney**, Nature Kit (licenca **CC0 1.0**).
- Pagina original: https://kenney.nl/assets/nature-kit
- Cópia verificada dos mesmos arquivos: https://github.com/Hidencod/tge-assets/tree/main/packs/nature-kit
- Licenca: https://creativecommons.org/publicdomain/zero/1.0/

Os 10 GLB foram copiados por identidade binaria (SHA Git idêntico ao repositório de origem).
Os arquivos sao fontes para importacao e **nao ficam incorporados automaticamente no .rbxlx**.

## O que funciona ao abrir o novo place (sem importar GLB)

O codigo de jogo agora tenta carregar o **Synty Nature Pack oficial do Roblox**
(modelo gratuito ID `6933438443`) por `AssetService:LoadAssetAsync` **no servidor**,
uma vez na inicializacao da partida. O carregador:
- Procura recursos com nomes de arvores, arbustos e rochas, criando ate quatro variantes de cada;
- Copia **apenas geometria**, removendo scripts e qualquer comportamento do modelo;
- Coloca as variantes na pasta temporaria `ServerStorage/RoMooResourceModels`;
- Preserva a coleta infinita, pois a logica de recursos e hitbox continua no `World`;
- Usa a geometria nativa anterior caso nao consiga carregar/encontrar uma variante.

**Importante:** nao foi possivel executar o Roblox Studio aqui. O resultado final do
carregamento do pacote no ambiente Roblox, o desempenho no celular e a escolha
dos objetos ainda precisam ser conferidos no jogo. Se necessario, desative
o carregamento automatico mudando `Config.NatureAssetsEnabled = false`.

Synty original: https://create.roblox.com/marketplace/asset/6933438443/Synty-Nature-Pack
Segundo a pagina oficial, esse pacote foi licenciado para jogos Roblox.

## Como usar os 10 modelos Kenney em vez do pacote automatico

1. Abra a compilacao `RoMoo-io-Teste.rbxlx` no Roblox Studio em **modo de edicao**.
2. No menu **Arquivo > Importar**, selecione os arquivos `assets/nature/*.glb`.
   Use a fila de importacao para adicionar varios modelos ao mesmo tempo.
3. No Explorer, selecione os **Models** recem-importados no `Workspace`.
4. Abra a **Command Bar** e cole/execute o conteudo do arquivo
   `scripts/OrganizarModelosNatureza-Studio.luau`.
5. Verifique `ServerStorage/RoMooResourceModels` com pastas `Tree`,
   `Rock`, `Bush` e `Cactus`.
6. Salve um arquivo novo **.rbxlx** no Studio. Rode Play e confira as variacoes.

O pacote Kenney tem escala original pequena: o `World.importedResource` ajusta
os modelos para a escala do RoMoo. Cactos ficam como biblioteca importada para
uso decorativo futuro; **nao substituem** as regras de floresta do gerador.
A biblioteca importada e salva no place editado pelo Studio (nao nos
arquivos Luau do Rojo). O carregador automatico respeita categorias
ja existentes em `ServerStorage`.

## Animais disponiveis (fonte ja no repositorio)

- `assets/animals/Wolf.gltf`
- `assets/animals/Cow.gltf`
- `assets/animals/Bull.gltf`
- `assets/animals/Sheep.fbx`

Leia `docs/IMPORTAR_ANIMAIS_3D.md`: o lobo real pode substituir o fallback
quando seu modelo `Wolf` estiver em `ServerStorage/RoMooAnimalModels`.
Os arquivos de vaca, touro e ovelha estao disponíveis para
integracao posterior; a versão atual **nao gera automaticamente essas especies**.
As animacoes dos GLTF/FBX tambem nao sao conectadas automaticamente a IA.

## O que a compilacao valida

O GitHub Actions valida sintaxe Luau, liga `NatureAssets` ao Rojo,
verifica os cabeçalhos `glTF` dos 10 GLB, gera o place e publica
um segundo ZIP de modelos 3D. A execucao **nao** faz testes visuais
no Roblox Studio e nao autentica importacoes de malhas na conta Roblox.
