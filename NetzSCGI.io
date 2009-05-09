# contains parts of io-scgi <http://github.com/quag/io-scgi>
# by Jonathan Wright

Netz

NetzSCGI := Object clone do(
    Request := Netz SocketRequest clone do(
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

    SCGIServer := Server clone do(
        application ::= nil

        handleSocket := method(socket,
            @handleSocketAsync(socket)
        )

        with := method(application,
            c := self clone
            c setApplication(application)
            c
        )

        handleSocketAsync := method(socket,
            while(socket isOpen,
                if(socket streamReadNextChunk) then(
                    input := socket readBuffer
                    # get the netstring length
                    colonPos := input findSeq(":")
                    length := input exSlice(0, colonPos) asNumber
                    headers := input exSlice(colonPos + 1, colonPos + length + 1)
                    counter := 0
                    key := nil
                    environ := Map clone
                    headers split("\0") foreach(part,
                        if(counter isEven,
                            key = part
                        ,
                            environ atPut(key, part)
                        )
                        counter = counter + 1
                    )
                    # the rest is the body
                    if((input at(colonPos + length + 1) == 44) not, # 44 is the comma
                        Netz NetzError raise("Malformed netstring received (no comma)")
                    )
                    body := ""
                    if(environ hasKey("CONTENT_LENGTH"),
                        bodyPos := colonPos + length + 2
                        body = input exSlice(bodyPos, bodyPos + environ at("CONTENT_LENGTH") asNumber)
                    )
                    # create a request object
                    request := NetzSCGI Request clone setEnvironment(environ) setSocket(socket) setBody(body)
                    application handleRequest(request)
                    socket close
                    break
                )
            )
        )
    )
)
