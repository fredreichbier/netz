NetzHTTP

app := Object clone do(
    handleRequest := method(req,
        req startResponse("200 OK", "Content-type: text/html")
        req writeln("<html><head><title>NetzTest</title></head><body><h1>It works!</h1>")
        req writeln("<dl>")
        req environment foreach(key, value,
            req writeln("<dt>#{ key }</dt><dd>#{ value }</dd>" interpolate)
        )
        req writeln("</dl></body></html>")
    )
)

s := NetzHTTP HTTPServer clone setApplication(app) setPort(8001)
s start
