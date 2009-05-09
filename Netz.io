Netz := Object clone do(
    NotImplementedError := Exception clone
    NetzError := Exception clone

    BaseRequest := Object clone do(
        environment ::= nil
        body ::= nil

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
                seq := url exSlice(i + 1, i + 3)
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

    /*doc Netz escapeHtmlSpecialChars(string[, quotes])
    convert <, > and & to &lt;, &gt; and &amp;. If *quotes*
    is true, " is additionally converted to &quot;.
    Make sure that you call this for already url-decoded
    strings (call decodeUrlParam before) for more safety.
    */
    escapeHtmlSpecialChars := method(string, quotes,
        if(string isMutable not,
            string = string asMutable
        )
        string println
        string replaceSeq("&", "&amp;")
        string replaceSeq("<", "&lt;")
        string replaceSeq(">", "&gt;")
        if(quotes,
            string replaceSeq("\"", "&quot;")
        )
        string
    )
)
