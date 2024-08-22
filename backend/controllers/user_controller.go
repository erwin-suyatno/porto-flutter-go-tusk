package controllers

import (
	"net/http"
	"tusk/model"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserController struct {
	DB *gorm.DB
}

// login is a method of the UserController struct that handles the login functionality.
//
// It takes a gin.Context as a parameter and performs the following steps:
//  1. It creates a new instance of the model.User struct.
//  2. It binds the JSON data from the request to the user instance.
//  3. If there is an error during the JSON binding, it returns an HTTP Internal Server Error response.
//  4. It retrieves the user from the database based on the email.
//  5. If the user is not found in the database, it returns an HTTP Internal Server Error response.
//  6. It compares the provided password with the hashed password stored in the database.
//  7. If the password comparison fails, it returns an HTTP Unauthorized response.
//  8. If all the steps are successful, it returns an HTTP OK response with the user data.
func (u *UserController) Login(c *gin.Context) {
	user := model.User{}
	errBindJson := c.ShouldBindJSON(&user)
	if errBindJson != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errBindJson.Error(),
		})
		return
	}

	password := user.Password

	errDb := u.DB.Where("email=?", user.Email).Take(&user).Error
	if errDb != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Password or Email is incorrect",
		})
		return
	}
	hashedPassword := user.Password
	errHash := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	if errHash != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Password or Email is incorrect",
		})
		return
	}

	c.JSON(http.StatusOK, user)
}

func (u *UserController) CreateAccount(c *gin.Context) {
	user := model.User{}
	errBindJson := c.ShouldBindJSON(&user)
	if errBindJson != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errBindJson.Error(),
		})
		return
	}

	emailExist := u.DB.Where("email=?", user.Email).First(&user).RowsAffected != 0
	if emailExist {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email already exist",
		})
		return
	}

	hashedPasswordBytes, errHash := bcrypt.GenerateFromPassword([]byte("123456"), 10)

	if errHash != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errHash.Error(),
		})
		return
	}

	user.Password = string(hashedPasswordBytes)
	user.Role = "Employee"

	errDB := u.DB.Create(&user).Error

	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, user)
}

func (u *UserController) DeleteAccount(c *gin.Context) {
	id := c.Param("id")

	errDB := u.DB.Delete(&model.User{}, id).Error

	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, "Deleted successfully")
}

func (u *UserController) GetEmployee(c *gin.Context) {
	users := []model.User{}

	errDB := u.DB.Select("id, name").Where("role=?", "Employee").Find(&users).Error

	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, users)
}
