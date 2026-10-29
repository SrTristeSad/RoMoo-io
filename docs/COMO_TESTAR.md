# Como testar o RoMoo io no Roblox Studio

## Opção A — baixar o arquivo já compilado
1. Abra **Actions** no repositório: https://github.com/SrTristeSad/RoMoo-io/actions/workflows/build-studio.yml
2. Abra a execução mais recente **verde** do fluxo "Gerar teste do RoMoo no Roblox Studio".
3. Em **Artifacts**, clique em **RoMoo-io-Teste-Roblox-Studio** para baixar um ZIP.
4. Extraia o ZIP e abra **RoMoo-io-Teste.rbxlx** no Roblox Studio.
5. Clique **Play / Test (F5)**. Não precisa de Rojo instalado para abrir esse arquivo.

Se não houver execução verde ou o artefato não estiver disponível, use a opção B e envie o log da falha.

## Opção B — gerar o arquivo no seu PC (Windows)
1. Abra https://github.com/SrTristeSad/RoMoo-io e clique em **Code > Download ZIP**.
2. Extraia toda a pasta do ZIP no Windows.
3. Clique duas vezes em **TESTAR-ROMOO.cmd**.
4. O script baixa o Rojo oficial 7.7.1, compila a versão atual e tenta abrir o arquivo no Studio.
5. Se o Studio não abrir, use **Arquivo > Abrir** no Roblox Studio para selecionar **RoMoo-io-Teste.rbxlx**.
6. Para futuras atualizações, baixe o novo ZIP da branch main e repita.

O ZIP do projeto não inclui modelos importados do Roblox Studio automaticamente. Vaca, touro, lobo e ovelha ainda usarão visuais procedurais até importar os modelos 3D via `docs/IMPORTAR_ANIMAIS_3D.md`.

## Teste solo (primeiros 3 minutos)
- [ ] Abrir o place e pressionar **F5**.
- [ ] O jogador surge no centro com câmera atrás dele; grama 3D, flores, neve/deserto e animais 3D são exibidos.
- [ ] **WASD** caminha; mouse mira; **1** seleciona marreta.
- [ ] Chegue perto de árvores/rochas/arbustos e minérios de ouro, aponte o mouse e segure o botão esquerdo; os recursos dão materiais por golpe, quebram e reaparecem.
- [ ] Selecionar parede na barra, coletar madeira suficiente e construir.
- [ ] Tentar erguer construção sem recursos: a operação deve ser recusada.
- [ ] Usar comida (Q) quando estiver ferido.
- [ ] A janela **Exibir > Saída (Output)** não deve ter erros vermelhos.

## Teste multiplayer
1. No Studio escolha **Test / Server & Clients**, **2 clients** e execute.
2. Teste golpes contra outro jogador; depois crie uma parede entre os dois.
3. No painel **CLÃ: SOLO**, o jogador A cria um código numérico de 6 dígitos.
4. O jogador B digita o código e clica em **ENTRAR**.
5. Verifique se os aliados ficam verdes no minimapa, não recebem dano entre si e se o pad de cura funciona.
6. O jogador B sai do clã; verifique que ataques voltam a causar dano.

## Se encontrar um problema
Envie **uma captura da janela Output e da tela do jogo**. Inclua a ação que gerou o erro (ex.: F5, clicar em árvore, Q, criar clã). Não publique a experiência ainda: a validação dentro do Studio é obrigatória.

O jogo não precisa ser publicado para este teste e não depende de DataStore. Testar em modo solo e multi-clientes é recomendado pela documentação do Roblox:
https://create.roblox.com/docs/pt-br/studio/testing-modes
