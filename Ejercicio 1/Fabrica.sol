// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

contract FabricaContract {
    // ID del producto será de 16 dígitos
    uint idDigits = 16;
    uint idModulus = 10 ** idDigits;

    // Estructura para los productos
    struct Producto {
        string nombre;
        uint id;
    }

    // Array público de productos
    Producto[] public productos;

    // Mapeo para asignar propiedad de un producto a un propietario
    mapping (uint => address) public productoAPropietario;
    mapping (address => uint) propietarioProductos;

    // Evento para notificar la creación de un nuevo producto
    event NuevoProducto(uint productoId, string nombre, uint id);

    // Función privada para crear productos
    function crearProducto(string memory _nombre, uint _id) private {
        productos.push(Producto(_nombre, _id));
        uint productoId = productos.length - 1;

        // Asignamos la propiedad del producto al creador
        productoAPropietario[productoId] = msg.sender;
        propietarioProductos[msg.sender]++;

        // Emitimos el evento de nuevo producto
        emit NuevoProducto(productoId, _nombre, _id);
    }

    // Función privada para generar un ID aleatorio basado en un string
    function _generarIdAleatorio(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % idModulus;
    }

    // Función pública para crear productos con un ID aleatorio
    function crearProductoAleatorio(string memory _nombre) public {
        uint randId = _generarIdAleatorio(_nombre);
        crearProducto(_nombre, randId);
    }

    // Función para asignar la propiedad de un producto a quien llama la función
    function asignarPropiedad(uint _productoId) public {
        require(productoAPropietario[_productoId] == address(0), "Producto ya tiene propietario.");
        productoAPropietario[_productoId] = msg.sender;
        propietarioProductos[msg.sender]++;
    }

    // Función externa para obtener los productos de un propietario específico
    function getProductosPorPropietario(address _propietario) external view returns (uint[] memory) {
        uint contador = 0;
        uint[] memory resultado = new uint[](propietarioProductos[_propietario]);

        for (uint i = 0; i < productos.length; i++) {
            if (productoAPropietario[i] == _propietario) {
                resultado[contador] = i;
                contador++;
            }
        }
        return resultado;
    }
}
