package handler

import (
	"fmt"
	"utils"
	"github.com/gin-gonic/gin"
)

const DefaultPath = "/data"

func GetDetails(c *gin.Context) {
	details := map[string]string {}
	fmt.Println("Start handler")
	disk_size, err := utils.GetDiskSize()
	if err != nil {
		c.JSON(500,fmt.Errorf("Error"))
		return 
	}   

	details["disk_usage"] = disk_size

	c.JSON(200, details)                                                                                                    
}