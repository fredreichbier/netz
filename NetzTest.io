app := Object clone do(
    handleRequest := method(req,
        req startResponse("200 OK", "Content-type: text/html")
        req writeln("<html><head><title>NetzTest</title></head><body><h1>It works!</h1>")
        req writeln("<h2>Environment</h2>")
        req writeln("<dl>")
        req environment foreach(key, value,
            req writeln("<dt>#{ key }</dt><dd>#{ Netz escapeHtmlSpecialChars(value) }</dd>" interpolate)
        )
        req writeln("</dl>\n<h2>Body</h2>\n<pre>")
        req writeln(req body)
        req writeln("</pre></body></html>")
    )
)

if(System args size < 3,
    "Usage: io NetzTest.io scgi | http port" println
,
    name := System args at(1)
    server := nil
    if(name == "scgi") then(
        NetzSCGI
        server = NetzSCGI SCGIServer clone
    ) elseif(name == "http") then(
        NetzHTTP
        server = NetzHTTP HTTPServer clone
    ) else(
        "Unknown netz backend name: #{ name }" interpolate
        exit(1)
    )
    server setApplication(app)
    server setPort(System args at(2) asNumber)
    "Now serving ..." println
    server start
)
