package handler

import (
	"os"
	"github.com/gin-gonic/gin"
)

func PauseEngine(c *gin.Context) {
	EngineProcessName := os.Getenv("SERVICE_ENGINE_PROCESS_NAME")
	c.JSON(200, "PauseEngine")                                                                                                    
}

func StartEngine(c *gin.Context){
	c.JSON(200, "StartEngine")                                                                                                    
}