// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.18;

contract TokenContract {
    // Dirección del propietario del contrato
    address public owner;
    
    // Estructura para almacenar los receptores con nombre y cantidad de tokens
    struct Receivers {
        string name;
        uint256 tokens;
    }

    // Mapeo para asociar direcciones a receptores
    mapping(address => Receivers) public users;

    // Modificador que permite que solo el propietario ejecute ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion");
        _;
    }

    // Precio del token en Wei (1 Ether = 10^18 Wei), 5 Ether por token
    uint256 public constant tokenPrice = 5 ether;

    // Constructor que inicializa el contrato asignando tokens al propietario
    constructor() {
        owner = msg.sender;
        users[owner].tokens = 100; // El propietario empieza con 100 tokens
    }

    // Función para duplicar un valor dado (sin relación con el token)
    function double(uint _value) public pure returns (uint) {
        return _value * 2;
    }

    // Función para registrar el nombre de un usuario
    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    // Función que permite al propietario transferir tokens a otra dirección
    function giveToken(address _receiver, uint256 _amount) public onlyOwner {
        require(users[owner].tokens >= _amount, "El propietario no tiene suficientes tokens");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    // Función para comprar tokens con Ether (1 token cuesta 5 Ether)
    function buyTokens(uint256 _amount) public payable {
        uint256 cost = _amount * tokenPrice; // Calcula el costo total en Ether

        // Verifica que el comprador haya enviado suficiente Ether
        require(msg.value >= cost, "No has enviado suficiente Ether para comprar los tokens");

        // Verifica que el propietario tenga suficientes tokens para vender
        require(users[owner].tokens >= _amount, "El propietario no tiene suficientes tokens");

        // Transferencia de tokens al comprador
        users[owner].tokens -= _amount;
        users[msg.sender].tokens += _amount;

        // Devolver el exceso de Ether si se envió más de lo necesario
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    // Función para ver el saldo de Ether del contrato
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Función que permite al propietario retirar el Ether del contrato
    function withdrawEther() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
