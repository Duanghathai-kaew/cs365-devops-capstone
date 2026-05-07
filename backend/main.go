package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

type server struct {
    Engine *gin.Engine
}

func main() {
    godotenv.Load()
    //port := os.Getenv("PORT")
	port := "8080"
    engine := gin.Default()
    serv := server{Engine: engine}.Engine

    // APIS routes

    serv.GET("/ping", func(c *gin.Context) {
        c.JSON(200, "Hello World")
    })

    // start server
    fmt.Printf("Server run on port : %s", port)
    serv.Run(":" + port)

}

