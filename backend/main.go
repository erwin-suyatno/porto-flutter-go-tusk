package main

import (
	"net/http"
	"tusk/config"
	"tusk/controllers"
	"tusk/model"

	"github.com/gin-gonic/gin"
)

func main() {
	// Database
	db := config.DatabaseConnection()
	db.AutoMigrate(&model.User{}, &model.Task{})
	config.CreateOwnerAccount(db)

	//Controller
	userController := controllers.UserController{DB: db}
	taskController := controllers.TaskController{DB: db}

	//Router
	router := gin.Default()
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, "Welcome To API Tusk")
	})

	router.POST("/users/login", userController.Login)
	router.POST("/users", userController.CreateAccount)
	router.DELETE("/users/:id", userController.DeleteAccount)
	router.GET("/users/employee", userController.GetEmployee)

	router.POST("/tasks", taskController.CreateTask)
	router.DELETE("/tasks/:id", taskController.DeleteTask)
	router.PATCH("/tasks/:id/submit", taskController.SubmitTask)
	router.PATCH("/tasks/:id/reject", taskController.RejectTask)
	router.PATCH("/tasks/:id/fix", taskController.FixTask)
	router.PATCH("/tasks/:id/approve", taskController.ApproveTask)
	router.GET("/tasks/:id", taskController.GetTask)
	router.GET("/tasks/review/asc", taskController.NeedToBeReviewed)
	router.GET("/tasks/progress/:userId", taskController.ProgressTasks)
	router.GET("/tasks/statistic/:userId", taskController.StatisticTask)
	router.GET("/tasks/user/:userId/:status", taskController.FindByUserAndStatus)

	router.Static("/assets", "./assets") //showing assets in backend
	router.Run("192.168.0.141:8080")     //sesuaikan dengan ip address atau server
}
