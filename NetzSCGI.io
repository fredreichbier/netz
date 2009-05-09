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

                    # get the header netstring
                    i := input findSeq(":")
                    count := input exSlice(0, i) asNumber
                    params := input exSlice(i + 1, i + 1 + count) split("\0")
                    rest := input exSlice(i + 1 + count + 1)

                    # set the header values
                    environ := Map clone
                    key := nil
                    params foreach(i, value,
                        if(i isEven,
                            key = value
                        ,
                            environ atPut(key, value)
                        )
                    )
                    # create a request object
                    request := NetzSCGI Request clone setEnvironment(environ) setSocket(socket)
                    application handleRequest(request)
                    socket close
                    break
                )
            )
        )
    )
)
