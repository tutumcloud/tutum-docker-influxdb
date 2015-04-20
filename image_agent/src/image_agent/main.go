// image_agent project image_agent.go
package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"handler"
)

func main() {
	router := gin.Default()

	router.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "hello world")
	})

	router.GET("/ping", func(c *gin.Context) {
        c.String(http.StatusOK, "pong")
    })

    router.GET("/details", handler.GetDetails)

    //make agent stop service engine running
    router.POST("/pause", handler.PauseEngine)

    //make agent start service engine running
    router.POST("/start", handler.StartEngine)

	router.Run(":8080")
}
