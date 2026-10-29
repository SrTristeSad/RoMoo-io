# Direção de arte — RoMoo io

A jogabilidade é inspirada em jogos de sobrevivência .io, mas o ambiente, os personagens e os elementos precisam ter **identidade própria**. Não reproduzir malhas ou texturas de MooMoo.io.

## Cenário 3D
- Campo: grama baixa verde, pequenos tufos mais escuros e claros, flores coloridas e pedrinhas.
- Neve: solo branco-azulado e pinheiros estilizados; transição gradual para o campo.
- Deserto: areia dourada, pequenos cactos e rochas; transição gradual para o campo.
- Árvores de coleta: copas arredondadas em camadas, com paletas adaptadas ao bioma.
- Recursos: visual reconhecível, prioritariamente formas simples e leitura clara vista de cima.
- Cenário decorativo: `CanCollide=false`, `CanTouch=false`, `CanQuery=false`, sem recompensas ou dano.
- Recursos de coleta e animais continuam sistemas separados, sem interferência dos adornos.

## Desempenho e qualidade
A quantidade de decoração fica em `src/shared/Config.luau` sob `Decoration`. Padrão: até 160 tufos, 40 flores, 40 pedras de campo, 16 pinheiros, 14 cactos e 24 pedras de areia.

Cada planta usa 1 a 4 Parts leves, sem física nem shadow casting. Não há animação contínua nessas partes. A geração usa seed fixa, dispensa malhas/texturas externas e evita raio de 36 studs ao redor do spawn e 8 studs ao redor dos recursos.

Para diagnosticar quedas de FPS, primeiro reduza `GrassTufts` para 80 e `Flowers` para 20. Se necessário, defina `Decoration.Enabled=false`. Isso não interrompe coleta, construções, PvP nem animais.

## Importante: Roblox Studio
A Baseplate padrão de um place novo pode competir com o chão gerado e causar cintilação visual. O gerador remove apenas um objeto BasePart chamado `Baseplate` com dimensões X/Z de pelo menos 500 studs. Não remove outros objetos.
Não afirmar validação de FPS ou aparência sem rodar no Studio em dispositivo real.

## Próximas evoluções visuais
1. Silhuetas mais distintivas de árvores, recursos e construções.
2. Rio/ponte e efeitos de água com colisão bem definida.
3. Efeitos leves de ataque, colheita e impacto.
4. LOD e/ou mesclagem de elementos de vegetação, conforme testes reais de FPS.
