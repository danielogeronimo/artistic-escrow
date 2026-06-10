# 🎨 Artistic Escrow – Contrato Inteligente e Pagamento Garantido para Artistas

## Sobre o desafio
Este projeto foi desenvolvido como parte do **desafio TrustCode** do Hackathon Web3 RESTIC 29.  
O objetivo é demonstrar a automação de acordos financeiros entre duas partes (cliente : Empresas publicas/privadas e fornecedor : Artistas) utilizando contratos inteligentes, reduzindo burocracia e intermediários.

## Problema real enfrentado
Artistas (músicos, designers, pintores, produtores culturais) que prestam serviços para **empresas públicas ou privadas** enfrentam:
- Atrasos recorrentes no pagamento, mesmo após a entrega do trabalho.
- Burocracia excessiva: notas fiscais, assinaturas manuais, processos internos lentos.
- Falta de transparência sobre quando o dinheiro será liberado.
- Dependência de intermediários (agentes, gestores de contratos) que aumentam custos e tempo.

As empresas também sofrem com a falta de garantia de que o artista cumpriu exatamente o que foi acordado antes do pagamento.

## Solução – Artistic Escrow
Um **contrato inteligente de garantia (escrow)** onde:
- A empresa deposita o valor em ETH (ou token) na rede Sepolia.
- O artista confirma a entrega do trabalho.
- A empresa tem um prazo para aprovar ou liberar o pagamento.
- Se a empresa não agir no prazo, o contrato libera automaticamente os fundos para o artista.
- Se o artista não entregar até o prazo final, a empresa pode cancelar e recuperar o valor.

**Redução de intermediários:** Nenhum banco, cartório ou agente de cobrança. Toda a lógica de liberação está no código.

## Fluxo de valor e regras automatizadas

| Papel            | Ação                                 | Regra / Condição no contrato                          |
|------------------|--------------------------------------|-------------------------------------------------------|
| Empresa (cliente) | Cria o contrato e deposita ETH       | Fornece endereço do artista, valor, prazos            |
| Artista           | Confirma a entrega física/digital    | Antes do `deadline` e após criação                    |
| Empresa           | Aprova e libera pagamento            | Somente após `confirmDelivery()` e antes de `approvalDeadline` |
| Artista           | Força liberação após prazo de silêncio | Se empresa não aprovou dentro de `approvalDeadline`   |
| Empresa           | Cancela contrato                     | Se artista não confirmou entrega até o `deadline`     |

## Tecnologias utilizadas
- **Solidity** (0.8.34) – Desenvolvimento do smart contract.
- **Sepolia Testnet** – Rede de testes Ethereum.
- **Ethers.js (v6)** – Interação com a blockchain.
- **React** – Frontend mínimo e utilizável.
- **MetaMask** – Carteira digital para assinatura de transações.
- **Remix IDE** – Alternativa para deploy rápido e testes.

## Estrutura do projeto
artistic-escrow/
├── contracts/
│ └── ArtisticEscrow.sol # Smart contract principal
├── frontend/
│ ├── src/
│ │ ├── App.js # Interface React + Ethers
│ │ └── ...
│ ├── public/
│ └── package.json
├── scripts/
│ └── Deploy com REMIX IDE
├── test/
│ └── ArtisticEscrow.test.sol # Testes unitários 
├── docs/ # Documentação adicional
├── README.md # Este arquivo


## Como executar o projeto (Windows / Linux / Mac)

### Pré‑requisitos
- **Node.js** (versão 16 ou superior) – [Download](https://nodejs.org/)
- **npm** (instalado junto com Node)
- **MetaMask** (extensão do navegador) – [Instalar](https://metamask.io/)
- **Conta na Sepolia Testnet** com ETH de teste (obtenha em [Sepolia Faucet](https://sepoliafaucet.com/))

Alternativa rápida (Recomendada para testes): Use o Remix IDE para deploy (veja seção abaixo).

Executando o frontend (React)
1. Acesse a pasta do frontend
bash
cd frontend
2. Instale as dependências do frontend
bash
npm install ethers react-scripts
3. Substitua o App.js pelo código fornecido
Copie o conteúdo do componente React (disponível neste repositório em /frontend/src/App.js).

4. Inicie o servidor de desenvolvimento
bash
npm start
O navegador abrirá automaticamente em http://localhost:3000.

5. Conecte a MetaMask (rede Sepolia)
Clique em Conectar MetaMask.

Selecione a conta desejada e permita a conexão.

6. Carregue o contrato
No campo Endereço do contrato, cole o endereço obtido no Remix.

Clique em Carregar Contrato.

7. Execute o fluxo
Empresa (cliente): Implanta o contrato (ou carrega um já criado) e depois libera o pagamento.

Artista: Carrega o mesmo contrato (com a carteira do artista) e confirma a entrega.

Fluxo completo (passo a passo)
Etapa	Quem	Ação	Onde executar	Resultado on-chain
1.	Empresa	Deploy + depósito ETH	Remix ou Hardhat	Contrato criado, status Created, saldo = valor
2.	Artista	Confirma entrega (confirmDelivery)	Frontend ou Remix	Status = Delivered, deliveryTimestamp registrado
3.	Empresa	Libera pagamento (releasePayment)	Frontend ou Remix	Status = Released, ETH transferido ao artista
(alt)	Artista (após prazo)	Força liberação (forceRelease)	Frontend ou Remix	Status = Released, ETH transferido ao artista
(alt)	Empresa (sem entrega)	Cancela (cancel)	Frontend ou Remix	Status = Cancelled, ETH devolvido à empresa

Demonstração via Remix IDE (sem frontend)
1. Abra Remix IDE.

2. Crie ArtisticEscrow.sol e cole o código.

3. Compile (0.8.34).

4. Vá em Deploy & Run → Environment: Injected Provider – MetaMask (Sepolia).

Preencha:

_artist: endereço do artista (outra carteira)

_approvalDeadline: 604800 (7 dias)

Value: 0.01 ETH

5. Clique em Transact.

6. Copie o endereço do contrato.

7. Troque a conta no MetaMask para o artista e carregue o contrato (At Address).

8. Execute confirmDelivery().

9. Volte para a conta empresa e execute releasePayment() ou espere o artista forçar liberação.

Segurança do contrato
Modificadores (onlyClient, onlyArtist, onlyActive) garantem que apenas as partes autorizadas executem ações críticas.

Require com mensagens claras facilitam o debugging.

Prazos baseados em timestamp evitam bloqueios eternos.

Reentrância mitigada: utiliza call com verificação de sucesso, mas sem transferências repetidas.

Sem delegação de chamadas ou selfdestruct.

Possíveis melhorias futuras
Suporte a tokens ERC-20 (USDC, DAI) em vez de ETH nativo.

Adição de mediador para resolver disputas.

Interface mais rica com gráficos de prazos.

Registro de hash da obra digital (IPFS) como prova de entrega.

Equipe
Daniel O Geronimo – Analista e Desenvovedor de Sistemas

Licença
MIT

Vídeo‑pitch

https://youtu.be/EY0cjPTicIE

Repositório: https://github.com/danielogeronimo/artistic-escrow
