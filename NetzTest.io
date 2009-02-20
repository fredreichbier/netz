NetzSCGI

app := Object clone do(
    handleRequest := method(req,
        req writeln("Content-type: text/html")
        req writeln
        req writeln("<h1>Hi!</h1>")
    )
)

s := NetzSCGI SCGIServer clone setApplication(app) setPort(4001)
s start
