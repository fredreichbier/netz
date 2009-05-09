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
        serverName ::= "NetzHTTP"

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
                    requestUrl := Netz decodeUrlParam(requestLineTokens at(1))
                    requestVersion := requestLineTokens at(2)
                    environ := Map clone
                    # fill the initial values
                    environ atPut("REQUEST_URI", requestUrl)
                    environ atPut("SERVER_NAME", self serverName)
                    environ atPut("SERVER_PROTOCOL", requestVersion)
                    environ atPut("REQUEST_METHOD", requestMethod)
                    if(requestUrl findSeq("?") isNil not,
                        # has query string
                        splitted := requestUrl splitAt(requestUrl findSeq("?"))
                        environ atPut("PATH_INFO", splitted at(0))
                        environ atPut("QUERY_STRING", splitted at(1))
                    ,
                        # clone because we don't want to have the path info
                        # and the request uri to be the same object
                        environ atPut("PATH_INFO", requestUrl clone)
                        environ atPut("QUERY_STRING", "")
                    )
                    environ atPut("REMOTE_ADDR", socket ipAddress ip)
                    # TODO: make "REMOTE_HOST" available?
                    # TODO: make "CONTENT_TYPE" available
                    lines foreach(line,
                        if(line strip isEmpty,
                            break
                        )
                        splitted := line splitAt(line findSeq(": "))
                        value := splitted at(1) exSlice(2)
                        environ atPut(splitted at(0), Netz decodeUrlParam(value))
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
