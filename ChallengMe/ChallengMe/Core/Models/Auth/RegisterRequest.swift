// Equivalente: RegistroRequest
struct RegisterRequest: Encodable {
    let email:         String
    let password:      String
    let nombreUsuario: String
}
