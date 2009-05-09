NetzHTTP

app := Object clone do(
    handleRequest := method(req,
        req startResponse("200 OK", "Content-type: text/html")
        req writeln("<h1>Hi!</h1>")
    )
)

s := NetzHTTP HTTPServer clone setApplication(app) setPort(8001)
s start
