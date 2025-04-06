# syntax=docker/dockerfile:1

FROM golang:alpine AS builder

LABEL org.opencontainers.image.source=https://github.com/PatrykZ3121/pawcho6

WORKDIR /app

COPY <<EOF main.go
package main

import (
    "fmt"
    "net"
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        hostname, _ := os.Hostname()
        addrs, _ := net.InterfaceAddrs()
        var ip string
        for _, addr := range addrs {
            if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
                if ipnet.IP.To4() != nil {
                    ip = ipnet.IP.String()
                    break
                }
            }
        }
        version := os.Getenv("VERSION")
        fmt.Fprintf(w, "IP: %s\\nHostname: %s\\nVersion: %s\\n", ip, hostname, version)
    })
    http.ListenAndServe(":8080", nil)
}
EOF

RUN go build -o app main.go

FROM scratch

COPY --from=builder /app/app /app

ARG VERSION
ENV VERSION=${VERSION}

EXPOSE 8080

CMD ["/app"]