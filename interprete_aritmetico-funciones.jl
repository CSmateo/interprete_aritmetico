function es_valida(expresion)
    # Esta función verifica si una expresión aritmética es válida.

    # Verifica si la expresion está vacía
    if isempty(expresion)
        error("La lista está vacía")
    end

    # Elimina espacios, tabuladores y retornos de línea
    expresion_limpia = ""
    for char in expresion
        if char != ' ' && char != '\t' && char != '\n'
            expresion_limpia = string(expresion_limpia, char)
        end
    end

    # Contadores de paréntesis abiertos y cerrados
    contador_parentesis = 0
    prev_char = ' '

    for char in expresion_limpia
        if char == '('
            contador_parentesis += 1
        elseif char == ')'
            contador_parentesis -= 1
        end

        # Si hay más paréntesis cerrados que abiertos, es inválido
        if contador_parentesis < 0
            error("Error en paréntesis: Paréntesis desequilibrados")
        end

        # Verifica caracteres inválidos
        if !(isdigit(char) || char == '.' || char == '+' || char == '*' || char == '(' || char == ')')
            error("Carácter inválido")
        end

        # Verifica operadores consecutivos
        if (char in ['+', '*']) && (prev_char in ['+', '*'])
            error("Operadores consecutivos")
        end

        prev_char = char
    end

    # Verifica si no se han proporcionado números
    if all(c -> c in ['+', '*', '(', ')'], expresion_limpia)
        error("No se han proporcionado números")
    end

    # Si el contador de paréntesis no es cero, es inválido
    if contador_parentesis != 0
        error("Error en paréntesis: Paréntesis desequilibrados")
    end

    # La expresión es válida si ha pasado todas las verificaciones
    return true
end

function tokenize(expresion)
    # Esta función tokeniza una expresión aritmética en números, operadores y paréntesis.

    # Elimina espacios, tabuladores y retornos de línea
    expresion_limpia = ""
    for char in expresion
        if char != ' ' && char != '\t' && char != '\n'
            expresion_limpia = string(expresion_limpia,char)
        end
    end

    # Inicia la lista de tokens
    tokens = []
    i = 1

    while i <= length(expresion_limpia)
        char = expresion_limpia[i]

        if isdigit(char) || char == '.'
            j = i + 1
            while j <= length(expresion_limpia) && (isdigit(expresion_limpia[j]) || expresion_limpia[j] == '.')
                j += 1
            end
            push!(tokens, expresion_limpia[i:j - 1])
            i = j
        elseif char == '+' || char == '*' || char == '(' || char == ')'
            push!(tokens, char)
            i += 1
        end
    end
    return tokens
end

function shunting_yard(tokens)
    # Esta función utiliza el algoritmo Shunting Yard para evaluar la lista que tokenizamos

    # Inicializa la cola de salida y la pila de operadores
    output = []
    operator_stack = []

    # Define la precedencia de los operadores
    precedence = Dict('+' => 1, '*' => 2)

    for token in tokens
        if token != '+' && token != '*' && token != '(' && token != ')'
            # Si el token es un número, lo agrega a la cola de salida
            push!(output, parse(Float64, token))
        elseif token in ['+', '*']
            # Si el token es un operador, saca operadores de la pila a la cola de salida
            while !isempty(operator_stack) && operator_stack[end] in ['+', '*'] &&
                  precedence[token] <= precedence[operator_stack[end]]
                push!(output, pop!(operator_stack))
            end
            push!(operator_stack, token)
        elseif token == '('
            # Si el token es un paréntesis abierto, lo mete en la pila
            push!(operator_stack, token)
        elseif token == ')'
            # Si el token es un paréntesis cerrado, saca operadores de la pila a la cola de salida
            while !isempty(operator_stack) && operator_stack[end] != '('
                push!(output, pop!(operator_stack))
            end
            if isempty(operator_stack) || operator_stack[end] != '('
                error("Paréntesis no coincidentes")
            end
            pop!(operator_stack)  # Saca el paréntesis de apertura de la pila
        else
            error("Token inválido")
        end
    end

    # Saca cualquier operador restante de la pila a la cola de salida
    while !isempty(operator_stack)
        if operator_stack[end] == '('
            error("Paréntesis no coincidentes")
        end
        push!(output, pop!(operator_stack))
    end

    # Evalúa la expresión
    value_stack = []
    for token in output
        if token != '+' && token != '*' && token != '(' && token != ')'
            push!(value_stack, token)
        elseif token in ['+', '*']
            if length(value_stack) < 2
                error("Operando insuficiente para el operador")
            end
            b = pop!(value_stack)
            a = pop!(value_stack)
            if token == '+'
                push!(value_stack, a + b)
            elseif token == '*'
                push!(value_stack, a * b)
            end
        else
            error("Token inválido en salida")
        end
    end

    if length(value_stack) != 1
        error("Expresión inválida")
    end

    return value_stack[1]
end
