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

        write := method(stuff,
            NotImplementedError raise("Request misses a `write` implementation!")
        )

        writeln := method(line,
            self write(line)
            self write("\r\n")
            self
        )

        # Call it like this:
        # `startResponse("200 OK", "Content-type: text/html", "Bla: Blubb", ...)`
        startResponse := method(status,
            self writeln("Status: " .. status)
            for(i, 1, call argCount - 1,
                self writeln(call evalArgAt(i))
            )
            # now write a blank line (content follows)
            self writeln
            self
        )
    )
)
