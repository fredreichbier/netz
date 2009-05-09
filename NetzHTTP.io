Netz

NetzHTTP := Object clone do(
    Request := Netz SocketRequest clone do(
        # Call it like this:
        # `startResponse("200 OK", "Content-type: text/html", "Bla: Blubb", ...)`
        startResponse := method(status,
            self writeln("HTTP/1.1 " .. status)
            for(i, 1, call argCount - 1,
                self writeln(call evalArgAt(i))
            )
            # now write a blank line (content follows)
            self writeln
            self
        )
    )

    HTTPServer := Server clone do(
        application ::= nil

        handleSocket := method(socket,
            @handleSocketAsync(socket)
        )

        handleSocketAsync := method(socket,
            # read it till the end and parse it
            while(socket isOpen,
                if(socket streamReadNextChunk) then(
                    lines := socket readBuffer split("\r\n")
                    requestLineTokens := lines removeFirst split(" ")
                    requestMethod := requestLineTokens at(0)
                    requestUrl := requestLineTokens at(1)
                    # ignore HTTP/1.x :(
                    environ := Map clone
                    lines foreach(line,
                        if(line strip isEmpty,
                            break
                        )
                        splitted := line splitAt(line findNthSeq(":", 1))
                        environ atPut(splitted at(0), Netz decodeUrlParam(splitted at(1)))
                    )
                    # TODO: message body!
                    request := NetzHTTP Request clone setSocket(socket) setEnvironment(environ)
                    application handleRequest(request)
                    socket close
                    break
                )
            )
        )
    )
)
