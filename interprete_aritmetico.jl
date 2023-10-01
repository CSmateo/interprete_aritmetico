# Función principal
include("interprete_aritmetico-funciones.jl")
function interprete_aritmetico()
    println("Ingrese una expresión aritmética:")
    expresion = readline()
    
    if es_valida(expresion)
        tokens = tokenize(expresion)
        result = shunting_yard(tokens)
    end
    return result
end