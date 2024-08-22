package config

import (
	"fmt"
	"tusk/model"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func DatabaseConnection() *gorm.DB {
	dsn := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		"root", "", "localhost", 3306, "tusk")
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic(err)
	}
	return db
}

func CreateOwnerAccount(db *gorm.DB) {
	hashedPasswordBytes, _ := bcrypt.GenerateFromPassword([]byte("123456"), 10)
	owner := model.User{
		Role:     "Admin",
		Name:     "Owner",
		Password: string(hashedPasswordBytes),
		Email:    "owner@gmail.com",
	}

	if db.Where("email=?", owner.Email).First(&owner).RowsAffected == 0 {
		db.Create(&owner)
	} else {
		fmt.Print("owner exist")
	}
}
