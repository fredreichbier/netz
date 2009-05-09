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

    )

    SocketRequest := BaseRequest clone do(
        socket ::= nil

        write := method(line,
            if(line isNil not,
                socket write(line)
            )
        )
    )

    /*doc Netz decodeUrlParam(url)
    decode an url parameter as described in rfc 1738
    */
    decodeUrlParam := method(url,
        sign := "%" at(0)
        i := 0
        decoded := Sequence clone asMutable
        while(i < url size,
            if(url at(i) == sign,
                # decode sequence following
                seq := (url at(i + 1) asCharacter) .. (url at(i + 2) asCharacter)
                decoded append(("0x" .. seq) asNumber)
                i = i + 3
            ,
                # nothing special following
                decoded append(url at(i))
                i = i + 1
            )
        )
        decoded
    )
)
