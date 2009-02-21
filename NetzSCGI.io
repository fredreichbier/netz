# contains parts of io-scgi <http://github.com/quag/io-scgi>
# by Jonathan Wright

Netz

NetzSCGI := Object clone do(
    Request := Netz BaseRequest clone do(
        socket ::= nil
        
        writeln := method(line,
            if(line isNil not,
                socket write(line)
            )
            socket write("\r\n")
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
            writeln("[Got scgi request connection from ", socket ipAddress, "]")
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
            writeln("[Closed ", socket ipAddress, "]")        
        )
    )
)
