Netz := Object clone do(
    NotImplementedError := Exception clone

    BaseRequest := Object clone do(
        environment ::= nil

        requestMethod := method(
             environment at("REQUEST_METHOD") asUppercase
        )

        contentType := method(
            environment at("CONTENT_TYPE")
        )

        isGet := method(requestMethod == "GET")
        isPost := method(requestMethod == "POST")
        isPut := method(requestMethod == "PUT")
        isDelete := method(requestMethod == "DELETE")

        path := method(
            environment at("PATH_INFO")
        )

        writeln := method(line,
            NotImplementedError raise("Request misses a `write` implementation!")
        )       
    )
)
