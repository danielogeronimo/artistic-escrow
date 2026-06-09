// SPDX-License-Identifier: MIT

pragma solidity ^0.8.34;

/**
 * @title ArtisticEscrow
 * @dev Contrato de garantia para pagamento entre empresa (cliente) e artista.
 * Cliente deposita ETH, artista entrega, cliente aprova (ou silêncio libera).
 * Reduz burocracia e intermediários.
 */
contract ArtisticEscrow {
    // --- Participantes ---
    address payable public client;      // Empresa que paga
    address payable public artist;      // Artista que recebe
    address public mediator;            // (opcional) para disputas, não usado aqui

    // --- Valores e prazos ---
    uint256 public amount;              // Valor depositado (em wei)
    uint256 public deadline;            // Prazo máximo para o artista entregar
    uint256 public approvalDeadline;    // Prazo para o cliente aprovar após entrega
    uint256 public deliveryTimestamp;   // Momento em que o artista confirmou entrega

    // --- Estado ---
    enum Status { Created, Delivered, Released, Cancelled }
    Status public status;

    // --- Eventos para rastreamento on-chain ---
    event EscrowCreated(address indexed client, address indexed artist, uint256 amount);
    event DeliveryConfirmed(address indexed artist, uint256 timestamp);
    event PaymentReleased(address indexed artist, uint256 amount);
    event EscrowCancelled(address indexed client, uint256 amount);

    // --- Modificadores ---
    modifier onlyClient() {
        require(msg.sender == client, "Somente o cliente pode executar");
        _;
    }

    modifier onlyArtist() {
        require(msg.sender == artist, "Somente o artista pode executar");
        _;
    }

    modifier onlyActive() {
        require(status == Status.Created || status == Status.Delivered, "Contrato ja finalizado");
        _;
    }

    // @param _artist Endereço do artista beneficiário
    // @param _amount Valor em wei a ser depositado
    // @param _deadline Timestamp até quando o artista deve entregar
    // @param _approvalDeadline Duração (em segundos) para aprovação após entrega
    
    constructor(address payable _artist, uint256 _approvalDeadline) payable {
        require(msg.value > 0, "Deposito necessario");
        require(_artist != address(0), "Artista invalido");
        require(_artist != msg.sender, "Cliente e artista nao podem ser iguais");

        client = payable(msg.sender);
        artist = _artist;
        amount = msg.value;
        deadline = block.timestamp + 30 days;      // Prazo padrão: 30 dias para entrega
        approvalDeadline = _approvalDeadline;      // Ex: 7 dias (7*86400)
        status = Status.Created;

        emit EscrowCreated(msg.sender, _artist, msg.value);
    }

    /// @notice Artista confirma que o serviço/obra foi entregue
    function confirmDelivery() external onlyArtist onlyActive {
        require(block.timestamp <= deadline, "Prazo de entrega expirado");
        require(status == Status.Created, "Entrega ja confirmada ou contrato cancelado");

        status = Status.Delivered;
        deliveryTimestamp = block.timestamp;

        emit DeliveryConfirmed(msg.sender, block.timestamp);
    }

    /// @notice Cliente aprova a entrega e libera o pagamento imediatamente
    function releasePayment() external onlyClient onlyActive {
        require(status == Status.Delivered, "Entrega ainda nao confirmada");
        require(block.timestamp <= deliveryTimestamp + approvalDeadline, "Prazo de aprovacao expirado, use forceRelease");

        _release();
    }

    /// @notice Artista força liberação após o prazo de aprovação sem ação do cliente
    function forceRelease() external onlyArtist onlyActive {
        require(status == Status.Delivered, "Entrega nao confirmada");
        require(block.timestamp > deliveryTimestamp + approvalDeadline, "Ainda dentro do prazo de aprovacao");

        _release();
    }

    /// @notice Cliente cancela o contrato se o artista não entregou até o deadline
    function cancel() external onlyClient onlyActive {
        require(status == Status.Created, "Contrato ja esta em andamento ou finalizado");
        require(block.timestamp > deadline, "Artista ainda pode entregar");

        status = Status.Cancelled;
        (bool sent, ) = client.call{value: amount}("");
        require(sent, "Falha no reembolso");

        emit EscrowCancelled(client, amount);
    }

    /// @dev Função interna que transfere o ETH para o artista e finaliza
    function _release() internal {
        status = Status.Released;
        (bool sent, ) = artist.call{value: amount}("");
        require(sent, "Falha na transferencia para o artista");

        emit PaymentReleased(artist, amount);
    }

    /// @notice Retorna informações resumidas para o frontend
    function getDetails() external view returns (
        address clientAddr,
        address artistAddr,
        uint256 amountWei,
        uint256 deadlineTs,
        uint256 approvalDeadlineSec,
        uint256 deliveryTs,
        Status currentStatus
    ) {
        return (client, artist, amount, deadline, approvalDeadline, deliveryTimestamp, status);
    }
}